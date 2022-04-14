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

//static __always_inline int process_packet(struct hdr_cursor *nh, void *data, void *data_end)struct xdp_md *ctx
static __always_inline int process_packet(struct xdp_md *ctx)
{
    char fmt[] = "%d";

    /* Default action XDP_DROP. Everything we can't process and pass
     * onto destination servers should be dropped */
    __u32 action = XDP_DROP;

    struct packet_context *c = malloc(sizeof(struct packet_context));
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;

    /* Get the ethernet type and ip protocol, if its not IPv4, IPv6, ARP, drop it */
    int ok = parse_packet(c);
    if (ok == -1)
        return action;

    ok = encapsulate_packet(ctx, c);
    bpf_trace_printk(fmt, sizeof(fmt), ok);
    if (ok == -1)
        return action;

    /* Once we've handled the packet, retransmit it over the same wire */
    action = XDP_TX;

    //out:
    return action;
}

SEC("xdp_balancer")
int balancer(struct xdp_md *ctx)
{
    // cat /sys/kernel/debug/tracing/trace_pipe
    bpf_printk("Dia Dhuit");

    return process_packet(ctx);
}

char _license[] SEC("license") = "GPL";
