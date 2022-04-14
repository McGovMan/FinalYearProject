#include <stdio.h>
#include <stdlib.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include "../common/gue.h"
#include "encap.h"
#include "../common/parsing_helpers.h"

static __always_inline int process_packet(struct xdp_md *ctx)
{
    const char fmt[] = "%d";
    const char fmt1[] = "%llx";

    /* Default action XDP_DROP. Everything we can't process and pass
     * onto destination servers should be dropped */
    __u32 action = XDP_DROP;

    /*
     * We first need to hash the IP, Port, and Protocol to figure out if the packet
     * is worth investing any resources into; aka, if this load balancer is even
     * supposed to forward that packet.
     * Below we're just going to very cheaply get the IP header and hash the attributes.
     * TODO WE CURRENTLY ONLY ASSUME THIS IS IPv4
     */

    void *data = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    struct iphdr *ip4_hdr = data + sizeof(struct ethhdr);
    if (ip4_hdr + 1 > data_end)
        return action;

    // Check if its a tcp/udp packet, else drop it
    uint16_t port;
    if (ip4_hdr->protocol == 6) {
        struct tcphdr *tcp_hdr = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
        if (tcp_hdr + 1 > data_end)
            return action;
        __builtin_memcpy(&port, &tcp_hdr->dest, sizeof(port));
    } else if (ip4_hdr->protocol == 17) {
        struct udphdr *udp_hdr = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
        if (udp_hdr + 1 > data_end)
            return action;
        __builtin_memcpy(&port, &udp_hdr->dest, sizeof(port));
    } else {
        return action;
    }

    binds_row_key binds_key = {
            .ip  = __bswap_32(ip4_hdr->daddr),
            .port = port,
            .protocol = ip4_hdr->protocol,
    };

    // Search the binds map to see if we've bound to the interface the device
    // is trying to reach us on.
    uint32_t backends_key = get_binds_row(&binds_key);
    // We couldn't find an associated bind, get rid of the packet
    if (backends_key == -1)
        return action;

    bpf_printk("Congrats, your packet was accepted");

    // Start doing the expensive allocation now
    struct packet_context *c = malloc(sizeof(struct packet_context));
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;
    c->backends_key = &backends_key;

    /* Get the ethernet type and ip protocol, if its not IPv4, IPv6, ARP, drop it */
    int ok = parse_packet(c);
    if (ok == -1)
        return action;

    /* Make space for an extra IP, UDP & GUE header */
    ok = bpf_xdp_adjust_head(ctx, 0 - (int)(sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct lb_gue_hdr)));
    if (ok == -1)
        return action;

    /* Keep track of the new start of the packet */
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;

    /* Add all the new headers need for encapsulation */
    get_header_or_return_drop(c->eth_hdr, c, 0, struct ethhdr);
    if (c->eth_hdr + 1 > c->packet_end)
        return action;
    get_header_or_return_drop(c->ip4_hdr, c, sizeof(struct ethhdr), struct iphdr);
    if (c->ip4_hdr + 1 > c->packet_end)
        return action;
    get_header_or_return_drop(c->udp_hdr, c, sizeof(struct ethhdr) + sizeof(struct iphdr), struct udphdr);
    if (c->udp_hdr + 1 > c->packet_end)
        return action;
    get_header_or_return_drop(c->gue_hdr, c, sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr), struct lb_gue_hdr);
    if (c->gue_hdr + 1 > c->packet_end)
        return action;
    get_header_or_return_drop(c->orig_ip4_hdr, c, sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct lb_gue_hdr), struct iphdr);
    if (c->orig_ip4_hdr + 1 > c->packet_end)
        return action;

    /* Get the server we want to send the client to and the backup servers */
    // TODO use get_config_row to get the hashkeys, preferably inside the get bind backends row function
    uint64_t hashingKey1 = 0x6b74707279636f6E;
    uint64_t hashingKey2 = 0x64656465656E7965;
    uint64_t hash;
    bind_backends_row *backends_row = get_bind_backends_row(c->backends_key);
    if (backends_row == NULL) return -1;
    siphash((uint8_t *)&c->orig_ip4_hdr->saddr, sizeof(4), (uint8_t *)&hash,
            sizeof(hash), hashingKey1, hashingKey2);
    uint32_t hashToIndex = hash % 65536;

    // we want to try and get the inner_row at the index without de-referencing the array as we don't have the
    // memory to space. We do this by giving bpf_map_lookup the address of the map we got from get_bind_backends_row.
    // The BPF verifier doesn't let us use pointer manipulation to get the row ourselves,
    // e.g. backends_row = (char *)backends_row + hashToIndex
    bind_backends_inner_row *backends_inner_row = get_bind_backends_inner_row(backends_row, &hashToIndex);
    if (backends_inner_row == NULL) return -1;

    /* Setup all the headers */
    /* We can do two things, try and do a lookup to see if the server is one of our neighbours and send the packet
     * directly to them, or we can send it to our gateway to handle it for us. We could do both? In most cases
     * as this balancer is going to have an anycast IP, it won't be neighbours in all likelihood.
     * --
     * So, the new setup is that on each backend row we will provide the ifindex that can be used to reach the server.
     * We will only be using the ifindex for the first server and none of the ones specified in the GUE header, we
     * will leave it up to the end-server to figure out how to reroute it to one of the backup servers.
     * The reason we do this is, so we can stop the load balancer from having to do lookups on all available interfaces
     * to figure out what the next hop is. The also gives us the opportunity to send directly to the servers instead of
     * always sending through a gateway. This allows us to reduce load on gateways.
     * The GO program will figure out for all servers what interface it is reachable on set that when it is doing
     * its health-check on the servers. */

    /* Setup new IPv4 header */
    // This part of the packet is in new memory space so we best set everything to 0's as there could be some stray
    // 1's in there from the last program using the memory.
    __builtin_memset(c->ip4_hdr, 0, sizeof(struct iphdr));
    c->ip4_hdr->ihl = 5;
    c->ip4_hdr->version = 4;
    c->ip4_hdr->tos = 0;
    c->ip4_hdr->tot_len = htons((void *)c->packet_end - (void *)c->packet_start - sizeof(struct ethhdr));
    c->ip4_hdr->id = 0;
    c->ip4_hdr->frag_off = 0;
    c->ip4_hdr->ttl = 255;
    c->ip4_hdr->protocol = IPPROTO_UDP;
    c->ip4_hdr->check = 0; // Set to 0 before calculating checksum
    c->ip4_hdr->saddr = c->orig_ip4_hdr->daddr;
    c->ip4_hdr->daddr = backends_inner_row->ips[0];
    c->ip4_hdr->check = compute_ipv4_checksum(c->ip4_hdr);

    /* Setup new UDP header */
    __builtin_memset(c->udp_hdr, 0, sizeof(struct udphdr));
    c->udp_hdr->source = htons (GUE_PORT);
    c->udp_hdr->dest = htons (GUE_PORT);
    c->udp_hdr->len = htons((void *)c->packet_end - (void *)c->packet_start - sizeof(struct ethhdr) - sizeof(struct iphdr));
    c->udp_hdr->check = 0;

    /* Setup new GUE header */
    __builtin_memset(c->gue_hdr, 0, sizeof(&c->gue_hdr));
    /*c->gue_hdr->version = 0B10;
    c->gue_hdr->control = 0;
    c->gue_hdr->hlen = 0;
    c->gue_hdr->proto_ctype = c->orig_ip_type;
    c->gue_hdr->flags = 0;
    c->gue_hdr->reversed = 0;
    c->gue_hdr->next_hop = 0;
    c->gue_hdr->hop_count = 2;
    c->gue_hdr->hops[0] = backends_inner_row->ips[1];
    c->gue_hdr->hops[1] = backends_inner_row->ips[2];*/

    /*
     * HERE IS WHERE I LEFT OFF
     * For some reason when ever you set variables in the GUE header, the verifier in go fails.
     * But we can hash the source ip of the client, get the backend row in the map and forward it to that IP succesfully.
     * Theres just a few bits: arp still is funny. A permanently address should be set everyone or else XDP doesn't
     * know how to forward it. Currently only tcp and udp are let in, all other packets are dropped.
     */

    /* So, the new setup is that on each backend row we will provide the ifindex that can be used to reach the server.
     * We will only be using the ifindex for the first server and none of the ones specified in the GUE header, we
     * will leave it up to the end-server to figure out how to reroute it to one of the backup servers.
     * The reason we do this is, so we can stop the load balancer from having to do lookups on all available interfaces
     * to figure out what the next hop is. The also gives us the opportunity to send directly to the servers instead of
     * always sending through a gateway. This allows us to reduce load on gateways.
     * The GO program will figure out for all servers what interface it is reachable on set that when it is doing
     * its health-check on the servers. */
    struct bpf_fib_lookup fib_params = {};
    __builtin_memset(&fib_params, 0, sizeof(fib_params));
    fib_params.ifindex = backends_inner_row->ethernetIndex;
    fib_params.family = AF_INET;
    fib_params.tos = c->orig_ip4_hdr->tos;
    fib_params.l4_protocol = IPPROTO_UDP;
    fib_params.sport = 0;
    fib_params.dport = 0;
    fib_params.tot_len = ntohs(c->orig_ip4_hdr->tot_len);
    fib_params.ipv4_src = c->orig_ip4_hdr->daddr;
    fib_params.ipv4_dst = backends_inner_row->ips[0];

    int rc = bpf_fib_lookup(ctx, &fib_params, sizeof(fib_params), 0);
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
     *
     * BPF_FIB_LKUP_RET_FWD_DISABLED:
     *  The bpf_fib_lookup respect sysctl net.ipv{4,6}.conf.all.forwarding
     *  setting, and will return BPF_FIB_LKUP_RET_FWD_DISABLED if not
     *  enabled this on ingress device.
     */
    if (rc == BPF_FIB_LKUP_RET_SUCCESS) {
        /* Verify egress index has been configured as TX-port.
         * (Note: User can still have inserted an egress ifindex that
         * doesn't support XDP xmit, which will result in packet drops).
         *
         * Note: lookup in devmap supported since 0cdbb4b09a0.
         * If not supported will fail with:
         *  cannot pass map_type 14 into func bpf_map_lookup_elem#1:
         */
        if (!bpf_map_lookup_elem(&tx_ports, &fib_params.ifindex))
            return XDP_PASS;

        __builtin_memcpy(c->eth_hdr->h_dest, fib_params.dmac, ETH_ALEN); // ETH_ALEN = sizeof(char) * 6
        __builtin_memcpy(c->eth_hdr->h_source, fib_params.smac, ETH_ALEN);
        c->eth_hdr->h_proto = htons(ETH_P_IP);
        return bpf_redirect_map(&tx_ports, fib_params.ifindex, 0);
    }

    /* Once we've handled the packet, retransmit it over the same wire */
    action = XDP_TX;

    out:
    return action;

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
