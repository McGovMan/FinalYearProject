
#ifndef __PARSING_HELPERS_H
#define __PARSING_HELPERS_H

#include <stddef.h>
#include <arpa/inet.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/icmp.h>
#include <linux/icmpv6.h>
#include <linux/udp.h>
#include <linux/tcp.h>
#include "../balancer-xdp/rewriting_helpers.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

/* Header cursor to keep track of current parsing position */
struct hdr_cursor {
    void *pos;
};

struct packet_context {
    uint8_t *packet_start;
    uint8_t *packet_end;
    uint32_t *backends_key;
    __u16 orig_eth_type;
    uint16_t orig_ip_type;
    struct iphdr *orig_ip4_hdr;
    struct ipv6hdr *orig_ip6_hdr;
    struct ethhdr *eth_hdr;
    __u32 dest_ip4;
    struct iphdr *ip4_hdr;
    struct lb_gue_hdr *gue_hdr;
    struct udphdr *udp_hdr;
};

#define get_header_or_return_drop(hdr, packet_context, offset, hdr_type) do { \
    hdr = (hdr_type *)((packet_context)->packet_start + (offset)); \
    if ((uint8_t *)((hdr) + 1) > (packet_context)->packet_end) return -1; \
    } while (0)

/* Packet contents presented nicely */
static __always_inline int parse_packet(struct packet_context *c) {
    /* Parse ethernet header */
    const struct ethhdr *eth_hdr;
    get_header_or_return_drop(eth_hdr, c, 0, struct ethhdr);
    c->orig_eth_type = bpf_ntohs(eth_hdr->h_proto);

    /* Parse IP header */
    /* Accept IPv4, IPv6, ARP, drop everything else */
    struct ipv6hdr *ip6_hdr;
    struct iphdr *ip4_hdr;
    switch (c->orig_eth_type) {
        case ETH_P_ARP:
            // need to return pass
            break;
        case ETH_P_IP:
            get_header_or_return_drop(ip4_hdr, c, sizeof(struct ethhdr), struct iphdr);
            c->orig_ip_type = ip4_hdr->protocol;
            c->orig_ip4_hdr = ip4_hdr;
            /* do not support fragmented packets as L4 headers may be missing */
            // TODO
            break;
        case ETH_P_IPV6:
            get_header_or_return_drop(ip6_hdr, c, sizeof(struct ethhdr), struct ipv6hdr);
            c->orig_ip_type = ip6_hdr->nexthdr;
            c->orig_ip6_hdr = ip6_hdr;
            break;
        default:
            return -1;
    }

    return 0;
}

/* Expects no VLANS - Everything should come into the interface on access port */
static __always_inline int parse_ethhdr(struct hdr_cursor *nh, void *data_end,
                                        struct ethhdr **ethhdr)
{
    struct ethhdr *eth = nh->pos;

    /* Byte-count bounds check; check if current pointer + size of header
     * is after data_end.
     */
    if (eth + 1 > data_end) return -1;

    nh->pos = eth + 1;
    *ethhdr = eth;

    //return eth->h_proto; /* network-byte-order */
    return bpf_ntohs(eth->h_proto); /* host-byte order */
}

static __always_inline int parse_ip6hdr(struct hdr_cursor *nh,
                                        void *data_end,
                                        struct ipv6hdr **ip6hdr)
{
    struct ipv6hdr *ip6h = nh->pos;

    /* Pointer-arithmetic bounds check; pointer +1 points to after end of
     * thing being pointed to. We will be using this style in the remainder
     * of the tutorial.
     */
    if (ip6h + 1 > data_end)
        return -1;

    nh->pos = ip6h + 1;
    *ip6hdr = ip6h;

    return ip6h->nexthdr;
}

static __always_inline int parse_ip4hdr(struct hdr_cursor *nh,
                                       void *data_end,
                                       struct iphdr **iphdr)
{
    struct iphdr *iph = nh->pos;
    int hdrsize;

    if (iph + 1 > data_end)
        return -1;

    hdrsize = iph->ihl * 4;
    /* Sanity check packet field is valid */
    if(hdrsize < sizeof(*iph))
        return -1;

    /* Variable-length IPv4 header, need to use byte-based arithmetic */
    if (nh->pos + hdrsize > data_end)
        return -1;

    nh->pos += hdrsize;
    *iphdr = iph;

    return iph->protocol;
}

/*
 * parse_udphdr: parse the udp header and return the length of the udp payload
 */
static __always_inline int parse_udphdr(struct hdr_cursor *nh,
                                        void *data_end,
                                        struct udphdr **udphdr)
{
    int len;
    struct udphdr *h = nh->pos;

    if (h + 1 > data_end)
        return -1;

    nh->pos  = h + 1;
    *udphdr = h;

    len = bpf_ntohs(h->len) - sizeof(struct udphdr);
    if (len < 0)
        return -1;

    h->dest = bpf_htons(bpf_ntohs(h->dest) - 1);

    return len;
}

/*
 * parse_tcphdr: parse and return the length of the tcp header
 */
static __always_inline int parse_tcphdr(struct hdr_cursor *nh,
                                        void *data_end,
                                        struct tcphdr **tcphdr)
{
    int len;
    struct tcphdr *h = nh->pos;

    if (h + 1 > data_end)
        return -1;

    len = h->doff * 4;
    /* Sanity check packet field is valid */
    if(len < sizeof(h))
        return -1;

    /* Variable-length TCP header, need to use byte-based arithmetic */
    if (nh->pos + len > data_end)
        return -1;

    nh->pos += len;
    *tcphdr = h;

    h->dest = bpf_htons(bpf_ntohs(h->dest) - 1);

    return len;
}

#endif /* __PARSING_HELPERS_H */
