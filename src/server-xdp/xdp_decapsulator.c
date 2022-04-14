
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>
#include "../common/gue.h"
#include "../common/parsing_helpers.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>
#include "xdp_decapsulator.h"

unsigned char source_mac[] = {0x08, 0x00, 0x27, 0x07, 0xb7, 0x19};

static __always_inline int decapsulate_packet(struct xdp_md *ctx, struct packet_context *c)
{
    /* Make a copy of the ethernet header as the packet won't
     * look right to the kernel if it's missing it once we delete
     * the extra headers. Although it won't have the original info */
    struct ethhdr eth_hdr;
    __builtin_memcpy((void *)&eth_hdr, c->eth_hdr, sizeof(struct ethhdr));

    /* Take away space for the extra IP, UDP & GUE header
     * At this point we don't care about it, we've logged it
     * and its of no other use to us */
    unsigned int offset = sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct lb_gue_hdr);
    int ok = bpf_xdp_adjust_head(ctx, 0 + (int)offset);
    if (ok == -1)
        return -1;

    /* Keep track of the new start of the packet */
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;

    /* Put back in the balancer -> server ethernet header */
    get_header_or_return_drop(c->eth_hdr, c, 0, struct ethhdr);
    if (c->eth_hdr + 1 > c->packet_end)
        return -1;
    __builtin_memcpy(c->eth_hdr, (void *)&eth_hdr, sizeof(struct ethhdr));

    // FIXME Dirty Fix as Virtualbox Gateway doesn't change the mac address for whatever reason
    // if the packet is coming from within the same subnet, just forwards as is
    __builtin_memcpy(c->eth_hdr->h_dest, source_mac, sizeof(char) * 6);

    return 0;
}

static int process_packet(struct xdp_md *ctx)
{
    /* Default action XDP_PASS. Everything we can't process is assumed
     * to not be from the load balancer */
    __u32 action = XDP_PASS;

    struct packet_context *c = malloc(sizeof(struct packet_context));
    c->packet_start = (void *)(long)ctx->data;
    c->packet_end = (void *)(long)ctx->data_end;

    get_header_or_return_drop(c->eth_hdr, c, 0, struct ethhdr);
    if (c->eth_hdr + 1 > c->packet_end)
        return -1;
    get_header_or_return_drop(c->ip4_hdr, c, sizeof(struct ethhdr), struct iphdr);
    if (c->ip4_hdr + 1 > c->packet_end)
        return -1;

    if (c->ip4_hdr->protocol == IPPROTO_UDP)
    {
        get_header_or_return_drop(c->udp_hdr, c, sizeof(struct ethhdr) + sizeof(struct iphdr), struct udphdr);
        if (c->udp_hdr + 1 > c->packet_end)
            return -1;

        // we only care about decapsulating udp packets that come via port 7666
        if (bpf_ntohs(c->udp_hdr->dest) != GUE_PORT)
            return action;

        int ok = decapsulate_packet(ctx, c);
        // At this point we may have made amendments to the packet and need
        // to drop it as it'll go back onto the wire as a jumble
        // TODO add special error codes for if no amendment has been made yet
        // which will allow for packets to be put back on the wire if we
        // cant process them
        if (ok == -1)
            return XDP_DROP;
    }

    /* Once we've handled the packet, put it back on the wire as
     * if it came in that way natively */
    bpf_printk("got to end");
    return action;
}

SEC("xdp_decapsulator")
int decapsulator(struct xdp_md *ctx)
{
    // cat /sys/kernel/debug/tracing/trace_pipe
    bpf_printk("Dia Dhuit");

    return process_packet(ctx);
}

char _license[] SEC("license") = "GPL";