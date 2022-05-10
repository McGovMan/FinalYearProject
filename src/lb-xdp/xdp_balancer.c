#include <stdio.h>
#include <stdlib.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include "../common/gue.h"
#include "map_utils.h"
#include <byteswap.h>
#include "../common/parsing_helpers.h"

// Thanks to https://cregit.linuxsources.org/code/4.18/samples/bpf/xdp_adjust_tail_kern.c.html
static __always_inline __u16 csum_fold_helper(__u32 csum)
{
    return ~((csum & 0xffff) + (csum >> 16));
}

// Thanks to https://cregit.linuxsources.org/code/4.18/samples/bpf/xdp_adjust_tail_kern.c.html
static __always_inline void ipv4_csum(void *data_start, int data_size, __u32 *csum)
{
    *csum = bpf_csum_diff(0, 0, data_start, data_size, *csum);
    *csum = csum_fold_helper(*csum);
}

static __always_inline int process_packet(struct xdp_md *ctx)
{
    /*
     * We first need to hash the IP, Port, and Protocol to figure out if the packet
     * is worth investing any resources into; aka, if this load balancer is even
     * supposed to forward that packet.
     * Below we're just going to very cheaply get the IP header and hash the attributes.
     */

    void *data = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    struct ethhdr *orig_eth_hdr = data;
    if (orig_eth_hdr + 1 > data_end)
        return packet_stats_record_action(ctx, XDP_DROP);

    if (bpf_ntohs(orig_eth_hdr->h_proto) == ETH_P_ARP)
        return packet_stats_record_action(ctx, XDP_PASS);

    struct iphdr *orig_ip4_hdr = data + sizeof(struct ethhdr);
    if (orig_ip4_hdr + 1 > data_end)
        return packet_stats_record_action(ctx, XDP_DROP);

    // Keep some valuable variables
    uint8_t orig_eth_hdr_src[6], orig_eth_hdr_dest[6];
    __u32 orig_ip4_hdr_src, orig_ip4_hdr_dest;

    __builtin_memcpy(orig_eth_hdr_src, orig_eth_hdr->h_dest, ETH_ALEN);
    __builtin_memcpy(orig_eth_hdr_dest, orig_eth_hdr->h_source, ETH_ALEN);
    __builtin_memcpy(&orig_ip4_hdr_src, &orig_ip4_hdr->saddr, 4);
    __builtin_memcpy(&orig_ip4_hdr_dest, &orig_ip4_hdr->daddr, 4);

    // Check if its a tcp/udp packet, else drop it
    uint16_t port;
    if (orig_ip4_hdr->protocol == 6) {
        struct tcphdr *tcp_hdr = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
        if (tcp_hdr + 1 > data_end)
            return packet_stats_record_action(ctx, XDP_DROP);
        __builtin_memcpy(&port, &tcp_hdr->dest, sizeof(port));
    } else if (orig_ip4_hdr->protocol == 17) {
        struct udphdr *udp_hdr = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
        if (udp_hdr + 1 > data_end)
            return packet_stats_record_action(ctx, XDP_DROP);
        __builtin_memcpy(&port, &udp_hdr->dest, sizeof(port));
    } else {
        return packet_stats_record_action(ctx, XDP_DROP);
    }

    binds_row_key binds_key = {
            .ip  = __bswap_32(orig_ip4_hdr->daddr),
            .port = port,
            .protocol = orig_ip4_hdr->protocol,
    };

    // Search the binds map to see if we've bound to the interface the device
    // is trying to reach us on.
    uint32_t backends_key = get_binds_row(&binds_key);
    // We couldn't find an associated bind, get rid of the packet
    if (backends_key == -1)
        return packet_stats_record_action(ctx, XDP_DROP);

    bpf_printk("Congrats, your packet was accepted");

    // Start doing the expensive allocation now
    struct packet_context *c = malloc(sizeof(struct packet_context));
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;
    c->backends_key = &backends_key;

    /* Get the ethernet type and ip protocol, if its not IPv4, IPv6, ARP, drop it */
    int ok = parse_packet(c);
    if (ok == -1)
        return packet_stats_record_action(ctx, XDP_DROP);

    /* Make space for an extra IP, UDP & GUE header */
    unsigned int hop_count = get_config_row(0) - 1;
    ok = bpf_xdp_adjust_head(ctx, 0 - (int)(sizeof(struct iphdr) + sizeof(struct udphdr) +
            sizeof(struct lb_gue_hdr) + (sizeof(__u32) * hop_count)));
    if (ok == -1)
        return packet_stats_record_action(ctx, XDP_DROP);

    /* Keep track of the new start of the packet */
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;

    /* Add all the new headers need for encapsulation */
    unsigned int offsetMin = 0;
    get_header_or_return_drop(c->eth_hdr, c, offsetMin, struct ethhdr);
    if (c->eth_hdr + 1 > c->packet_end)
        return packet_stats_record_action(ctx, XDP_DROP);
    offsetMin += sizeof(struct ethhdr);

    get_header_or_return_drop(c->ip4_hdr, c, offsetMin, struct iphdr);
    if (c->ip4_hdr + 1 > c->packet_end)
        return packet_stats_record_action(ctx, XDP_DROP);
    offsetMin += sizeof(struct iphdr);

    get_header_or_return_drop(c->udp_hdr, c, offsetMin, struct udphdr);
    if (c->udp_hdr + 1 > c->packet_end)
        return packet_stats_record_action(ctx, XDP_DROP);
    offsetMin += sizeof(struct udphdr);

    get_header_or_return_drop(c->gue_hdr, c, offsetMin, struct lb_gue_hdr);
    if (c->gue_hdr + 1 > c->packet_end)
        return packet_stats_record_action(ctx, XDP_DROP);
    offsetMin += sizeof(struct lb_gue_hdr);

    __u32 *hop1;
    get_header_or_return_drop(hop1, c, offsetMin, __u32);
    if (hop1 + 1 > c->packet_end)
        return packet_stats_record_action(ctx, XDP_DROP);
    offsetMin += sizeof(__u32);

    __u32 *hop2;
    get_header_or_return_drop(hop2, c, offsetMin, __u32);
    if (hop2 + 1 > c->packet_end)
        return packet_stats_record_action(ctx, XDP_DROP);
    offsetMin += sizeof(__u32);

    __u32 *hop3;
    get_header_or_return_drop(hop3, c, offsetMin, __u32);
    if (hop3 + 1 > c->packet_end)
        return packet_stats_record_action(ctx, XDP_DROP);
    offsetMin += sizeof(__u32);

    /* Get the server we want to send the client to and the backup servers */
    uint64_t hashingKey1 = 0x6b74707279636f6E;
    uint64_t hashingKey2 = 0x64656465656E7965;
    uint64_t hash = 0;
    bind_backends_row *backends_row = get_bind_backends_row(c->backends_key);
    if (backends_row == NULL) return packet_stats_record_action(ctx, XDP_DROP);
    siphash((uint8_t *)&orig_ip4_hdr_src, 4, (uint8_t *)&hash,
            sizeof(hash), hashingKey1, hashingKey2);
    uint32_t hashToIndex = hash % 65536;

    // we want to try and get the inner_row at the index without de-referencing the array as we don't have the
    // memory to space. We do this by giving bpf_map_lookup the address of the map we got from get_bind_backends_row.
    // The BPF verifier doesn't let us use pointer manipulation to get the row ourselves,
    // e.g. backends_row = (char *)backends_row + hashToIndex
    uint32_t *ips = get_bind_backends_inner_row(backends_row, &hashToIndex);
    if (ips == NULL) return packet_stats_record_action(ctx, XDP_DROP);

    /* Setup all the headers */
    /* Insert the old ethernet header in case we need to pass the packet up to do an arp lookup */
    __builtin_memcpy(c->eth_hdr->h_dest, orig_eth_hdr_src, ETH_ALEN); // ETH_ALEN = sizeof(char) * 6
    __builtin_memcpy(c->eth_hdr->h_source, orig_eth_hdr_dest, ETH_ALEN);
    c->eth_hdr->h_proto = htons(ETH_P_IP);

    /* Setup new IPv4 header */
    // This part of the packet is in new memory space so we best set everything to 0's as there could be some stray
    // 1's in there from the last program using the memory.
    __builtin_memset(c->ip4_hdr, 0, sizeof(struct iphdr));
    c->ip4_hdr->ihl = 5;
    c->ip4_hdr->version = 4;
    c->ip4_hdr->tos = 0;
    c->ip4_hdr->tot_len = htons((void *)c->packet_end - (void *)c->packet_start - sizeof(struct ethhdr) - 6);
    c->ip4_hdr->id = 0;
    c->ip4_hdr->frag_off = 0;
    c->ip4_hdr->ttl = 255;
    c->ip4_hdr->protocol = IPPROTO_UDP;
    c->ip4_hdr->saddr = ips[0];
    c->ip4_hdr->daddr = ips[1];
    c->ip4_hdr->check = 0;
    __u32 cs = 0 ;
    ipv4_csum(c->ip4_hdr, sizeof (*c->ip4_hdr), &cs);
    c->ip4_hdr->check = cs;

    /* Setup new UDP header */
    __builtin_memset(c->udp_hdr, 0, sizeof(struct udphdr));
    c->udp_hdr->source = htons (GUE_PORT);
    c->udp_hdr->dest = htons (GUE_PORT);
    c->udp_hdr->len = htons((void *)c->packet_end - (void *)c->packet_start - sizeof(struct ethhdr) - sizeof(struct iphdr) - 6);
    c->udp_hdr->check = 0;

    /* Setup new GUE header */
    __builtin_memset(c->gue_hdr, 0, sizeof(&c->gue_hdr));
    c->gue_hdr->version = 0;
    c->gue_hdr->control = 0;
    // dont include the first 4 bytes
    // hlen is defined as the number of 32 bits in the private area
    c->gue_hdr->hlen = 1 + hop_count;
    c->gue_hdr->proto_ctype = IPPROTO_IPIP;
    c->gue_hdr->flags = 0;
    c->gue_hdr->reserved = 0;
    c->gue_hdr->next_hop = 0;
    c->gue_hdr->hop_count = hop_count;

    if (hop_count >= 1 && (void *)(hop1) <= c->packet_end)
        *hop1 = ips[2];
    if (hop_count >= 2 && (void *)(hop2) <= c->packet_end)
        *hop2 = ips[3];
    if (hop_count >= 3 && (void *)(hop3) <= c->packet_end)
        *hop3 = ips[3];

    struct bpf_fib_lookup fib_params = {};
    __builtin_memset(&fib_params, 0, sizeof(fib_params));
    fib_params.ifindex = ctx->ingress_ifindex;
    fib_params.family = AF_INET;
    fib_params.tos = 0;
    fib_params.l4_protocol = IPPROTO_UDP;
    fib_params.sport = 0;
    fib_params.dport = 0;
    fib_params.tot_len = ntohs(c->ip4_hdr->tot_len);
    fib_params.ipv4_src = ips[0];
    fib_params.ipv4_dst = ips[1];

    int rc = bpf_fib_lookup(ctx, &fib_params, sizeof(fib_params), 0);
    char fmt[] = "%d";
    bpf_trace_printk(fmt, sizeof fmt, rc);
    bpf_trace_printk(fmt, sizeof fmt, ips[1]);
    bpf_trace_printk(fmt, sizeof fmt, fib_params.ifindex);
    /*
     * Some rc (return codes) from bpf_fib_lookup() are important,
     * to understand how this XDP-prog interacts with network stack.
     *
     * BPF_FIB_LKUP_RET_NO_NEIGH:
     *  Even if route lookup was a success, then the MAC-addresses are also
     *  needed.  This is obtained from arp/neighbour table, but if table is
     *  (still) empty then BPF_FIB_LKUP_RET_NO_NEIGH is returned.  To avoid
     *  doing ARP lookup directly from XDP, then send packet to normal
     *  network stack via XDP_PASS and expect it will do ARP resolution.
     */
    switch (rc) {
        case BPF_FIB_LKUP_RET_SUCCESS:      /* lookup successful */
            /* Verify egress index has been configured as TX-port.
             * (Note: User can still have inserted an egress ifindex that
             * doesn't support XDP xmit, which will result in packet drops).
             *
             * Note: lookup in devmap supported since 0cdbb4b09a0.
             * If not supported will fail with:
             *  cannot pass map_type 14 into func bpf_map_lookup_elem#1:
             */
            if (!bpf_map_lookup_elem(&tx_ports, &fib_params.ifindex))
                return packet_stats_record_action(ctx, XDP_PASS);

            __builtin_memcpy(c->eth_hdr->h_dest, fib_params.dmac, ETH_ALEN); // ETH_ALEN = sizeof(char) * 6
            __builtin_memcpy(c->eth_hdr->h_source, fib_params.smac, ETH_ALEN);
            c->eth_hdr->h_proto = htons(ETH_P_IP);

            if (fib_params.ifindex == ctx->ingress_ifindex)
                return packet_stats_record_action(ctx, XDP_TX);
            else
                return bpf_redirect_map(&tx_ports, fib_params.ifindex, 0);
            break;
        case BPF_FIB_LKUP_RET_NOT_FWDED:    /* packet is not forwarded */
        case BPF_FIB_LKUP_RET_FWD_DISABLED: /* fwding is not enabled on ingress */
        case BPF_FIB_LKUP_RET_UNSUPP_LWT:   /* fwd requires encapsulation */
        case BPF_FIB_LKUP_RET_FRAG_NEEDED:  /* fragmentation required to fwd */
        case BPF_FIB_LKUP_RET_NO_NEIGH:     /* no neighbor entry for nh */
            return packet_stats_record_action(ctx, XDP_PASS);
            break;
        default:
            /*
             * case BPF_FIB_LKUP_RET_BLACKHOLE:    // dest is blackholed; can be dropped
             * case BPF_FIB_LKUP_RET_UNREACHABLE:  // dest is unreachable; can be dropped
             * case BPF_FIB_LKUP_RET_PROHIBIT:     // dest not allowed; can be dropped
             */
            return packet_stats_record_action(ctx, XDP_DROP);
    }

    return packet_stats_record_action(ctx, XDP_DROP);
}

SEC("xdp_balancer")
int balancer(struct xdp_md *ctx)
{
    // cat /sys/kernel/debug/tracing/trace_pipe
    bpf_printk("Dia Dhuit");

    return process_packet(ctx);
}

SEC("xdp_pass")
int pass(struct xdp_md *ctx)
{
    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
