#ifndef __REWRITING_HELPERS_H
#define __REWRITING_HELPERS_H

#include <stddef.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/icmp.h>
#include <linux/icmpv6.h>
#include <linux/udp.h>
#include <linux/tcp.h>

/*
 * Swaps destination and source MAC addresses inside an Ethernet header
 */
static __always_inline void swap_src_dst_mac(struct ethhdr *eth)
{
    __u8 h_tmp[ETH_ALEN];
    __builtin_memcpy(h_tmp, eth->h_source, ETH_ALEN);
    __builtin_memcpy(eth->h_source, eth->h_dest, ETH_ALEN);
    __builtin_memcpy(eth->h_dest, h_tmp, ETH_ALEN);
}

/*
 * Swaps destination and source IPv6 addresses inside an IPv6 header
 */
static __always_inline void swap_src_dst_ipv6(struct ipv6hdr *ip6hdr)
{
    struct in6_addr tmp = ip6hdr->saddr;
    ip6hdr->saddr = ip6hdr->daddr;
    ip6hdr->daddr = tmp;
}

/*
 * Swaps destination and source IPv4 addresses inside an IPv4 header
 */
static __always_inline void swap_src_dst_ipv4(struct iphdr *iphdr)
{
    __be32 tmp = iphdr->saddr;
    iphdr->saddr = iphdr->daddr;
    iphdr->daddr = tmp;
}

static __always_inline __u16 csum16_add(__u16 csum, __u16 addend)
{
    csum += addend;
    return csum + (csum < addend);
}

#endif /* __REWRITING_HELPERS_H */