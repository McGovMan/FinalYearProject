#include <linux/bpf.h>
#include <linux/in.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>
#include "../rewriting_helpers.h"
#include "../../common/parsing_helpers.h"

static __always_inline int process_packet(struct hdr_cursor *nh, void *data, void *data_end)
{
    struct ethhdr *eth = nh->pos;
    struct ipv6hdr *ip6h;
    struct iphdr *ip4h;

    /* Default action XDP_DROP. Everything we can't process and pass
     * onto destination servers should be dropped */
    __u32 action = XDP_DROP;

    /* Parse ethernet header */
    int eth_type = parse_ethhdr(nh, data_end, &eth), ip_protocol;
    /* Accept IPv4, IPv6 and pass ARP packets, drop everything else */
    switch (eth_type) {
        case ETH_P_ARP: {
            action = XDP_PASS;
            goto out;
            break;
        }
        case ETH_P_IP:
            ip_protocol = parse_ip4hdr(nh, data_end, &ip4h);
            /* do not support fragmented packets as L4 headers may be missing */
            // TODO
            break;
        case ETH_P_IPV6:
            ip_protocol = parse_ip6hdr(nh, data_end, &ip6h);
            break;
        default:
            goto out;
    }

    /* Only accept ICMP/ICMPv6, TCP (check for MPTCP) & UDP (check for QUIC) */
    switch (ip_protocol) {
        case IPPROTO_TCP: {
            break;
        }
        case IPPROTO_UDP: {
            break;
        }
        default:
            goto out;
    }

    /* Once we've handled the packet, retransmit it over the same wire */
    action = XDP_TX;

out:
    return action;
}

SEC("xdp_balancer")
int balancer(struct xdp_md *ctx)
{
    void *data = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    /* These keep track of the next header type and iterator pointer */
    struct hdr_cursor nh;
    /* Start next header cursor position at data start */
    nh.pos = data;

    return process_packet(&nh, data, data_end);
}

SEC("xdp_pass")
int xdp_pass_func(struct xdp_md *ctx)
{
    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
