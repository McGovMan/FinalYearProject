
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include "../common/gue.h"
#include "../common/parsing_helpers.h"
#include <arpa/inet.h>
#include "map_utils.h"

#define IPV6_FLOWINFO_MASK              bpf_htonl(0x0FFFFFFF)
#define set_header_or_return_drop(hdr, packet_context, offset, hdr_type) do { \
    if ((uint8_t *)((hdr) + 1) > (packet_context)->packet_end) return -1; \
    __builtin_memcpy(((uint8_t *)((packet_context)->packet_start + (offset))), (uint8_t *)((hdr)), sizeof((hdr))); \
    } while (0)

unsigned char source_mac[] = {0x08, 0x00, 0x27, 0x9b, 0xe4, 0xf5};
unsigned char gateway_mac[] = {0x0a, 0x00, 0x27, 0x00, 0x00, 0x16};

/* from include/net/ip.h */
/*static int ip_decrease_ttl(struct iphdr *iph)
{
    __u32 check = iph->check;
    check += bpf_htons(0x0100);
    iph->check = (check + (check >= 0xFFFF));
    return --iph->ttl;
}*/

static uint16_t compute_ipv4_checksum(void *iph) {
    uint16_t *iph16 = (uint16_t *)iph;

    // to avoid poorly clang unrolled loops in eBPF, just manually add
    // the 10 shorts (20 bytes header)
    uint64_t csum =
            iph16[0] + iph16[1] + iph16[2] + iph16[3] + iph16[4] +
            iph16[5] + iph16[6] + iph16[7] + iph16[8] + iph16[9];

    // since we have a fixed size (no options) ip header, the maximum sum above is
    // (0xffff * 10) = 0x9fff6; 0xfff6 + 0x9 = 0xffff. which means
    // we can lazily just perform the 'carry' folding once for ipv4 (no options).
    csum = (csum & 0xffff) + (csum >> 16);

    return ~csum;
}

static __always_inline int encapsulate_packet(struct xdp_md *ctx, struct packet_context *c)
{
    /* Make space for an extra IP, UDP & GUE header */
    int ok = bpf_xdp_adjust_head(ctx, 0 - (int)sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct lb_gue_hdr));
    if (ok == -1)
        return -1;

    /* Keep track of the new start of the packet */
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;

    /* Add all the new headers need for encapsulation */
    get_header_or_return_drop(c->eth_hdr, c, 0, struct ethhdr);
    if (c->eth_hdr + 1 > c->packet_end)
        return -1;
    get_header_or_return_drop(c->ip4_hdr, c, sizeof(struct ethhdr), struct iphdr);
    if (c->ip4_hdr + 1 > c->packet_end)
        return -1;
    get_header_or_return_drop(c->udp_hdr, c, sizeof(struct ethhdr) + sizeof(struct iphdr), struct udphdr);
    if (c->udp_hdr + 1 > c->packet_end)
        return -1;
    get_header_or_return_drop(c->gue_hdr, c, sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr), struct lb_gue_hdr);
    if (c->gue_hdr + 1 > c->packet_end)
        return -1;
    get_header_or_return_drop(c->orig_ip4_hdr, c, sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct lb_gue_hdr), struct iphdr);
    if (c->orig_ip4_hdr + 1 > c->packet_end)
        return -1;

    /* Get the server we want to send the client to and the backup servers */


    /* Setup all the headers */
    /* As we're overwriting the old ethernet header and new address space
     *lets make sure it's all zeros */
    /* We can do two things, try and do a lookup to see if the server is one of our neighbours and send the packet
     * directly to them, or we can send it to our gateway to handle it for us. We could do both? In most cases
     * as this balancer is going to have an anycast IP, it won't be neighbours in all likelyhood */

    /* Setup new Ethernet header */
    c->eth_hdr->h_proto = htons(ETH_P_IP);
    __builtin_memcpy(c->eth_hdr->h_source, source_mac, sizeof(char) * 6);
    __builtin_memcpy(c->eth_hdr->h_dest, gateway_mac, sizeof(char) * 6);

    /* Setup new IPv4 header */
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
    c->ip4_hdr->saddr = (unsigned int)(192 + (168 << 8) + (216 << 16) + (5 << 24));
    c->ip4_hdr->daddr = (unsigned int)(192 + (168 << 8) + (216 << 16) + (10 << 24));
    c->ip4_hdr->check = compute_ipv4_checksum(c->ip4_hdr);

    bpf_printk("here2");

    binds_row_key key = {
            .ip  = (unsigned int)(192 + (168 << 8) + (216 << 16) + (5 << 24)),
            .port = 80,
            .protocol = 6,
    };
    get_binds_row(&key);

    bpf_printk("here3");

    /* So, the new setup is that on each backend row we will provide the ifindex that can be used to reach the server.
     * We will only be using the ifindex for the first server and none of the ones specified in the GUE header, we
     * will leave it up to the end-server to figure out how to reroute it to one of the backup servers.
     * The reason we do this is, so we can stop the load balancer from having to do lookups on all available interfaces
     * to figure out what the next hop is. The also gives us the opportunity to send directly to the servers instead of
     * always sending through a gateway. This allows us to reduce load on gateways.
     * The GO program will figure out for all servers what interface it is reachable on set that when it is doing
     * its health-check on the servers. */
    /*struct bpf_fib_lookup fib_params;
    fib_params.family	= AF_INET;
    fib_params.tos		= iph->tos;
    fib_params.l4_protocol	= iph->protocol;
    fib_params.sport	= 0;
    fib_params.dport	= 0;
    fib_params.tot_len	= ntohs(iph->tot_len);
    fib_params.ipv4_src	= iph->saddr;
    fib_params.ipv4_dst	= iph->daddr;*/

    /* Setup new UDP header */
    __builtin_memset(c->udp_hdr, 0, sizeof(struct udphdr));
    c->udp_hdr->source = htons (GUE_PORT);
    c->udp_hdr->dest = htons (GUE_PORT);
    c->udp_hdr->len = htons((void *)c->packet_end - (void *)c->packet_start - sizeof(struct ethhdr) - sizeof(struct iphdr));
    c->udp_hdr->check = 0;

    /* Setup new GUE header */
    __builtin_memset(c->gue_hdr, 0, sizeof(struct lb_gue_hdr));
    c->gue_hdr->version = 0B10;
    c->gue_hdr->control = 0;
    c->gue_hdr->hlen = 0;
    c->gue_hdr->proto_ctype = IPPROTO_IP; // TODO should be c->orig_ip_type
    c->gue_hdr->flags = 0;
    c->gue_hdr->reversed = 0;
    c->gue_hdr->next_hop = 0;
    c->gue_hdr->hop_count = 2;
    c->gue_hdr->hops[0] = 0;
    c->gue_hdr->hops[1] = 0;
    c->gue_hdr->next_hop = 0;

    return 0;
}