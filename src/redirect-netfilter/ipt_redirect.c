#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/icmp.h>
#include <linux/icmpv6.h>
#include <linux/skbuff.h>
#include <linux/version.h>
#include <linux/proc_fs.h>
#include <linux/u64_stats_sync.h>
#include <net/tcp.h>
#include <net/gue.h>
#include <net/udp.h>
#include <net/checksum.h>
#include <net/ip.h>

#include <linux/netfilter_ipv4/ip_tables.h>
#include <linux/netfilter/x_tables.h>
#include <net/netfilter/nf_conntrack.h>
#include <net/netfilter/nf_conntrack_core.h>
#include <net/netfilter/nf_conntrack_zones.h>
#include <net/inet6_hashtables.h>
#include <net/net_namespace.h>

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/version.h>

#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/tcp.h>
#include <linux/udp.h>

#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>

#include "ipt_redirect.h"

MODULE_AUTHOR("Conor Mc Govern <conor@mcgov.ie>");
MODULE_DESCRIPTION("FYP: Packet Redirector/Decapsulator");
MODULE_LICENSE("GPL");

#define PROCFS_NAME "redirect_stats"

struct nf_hook_ops inp;
struct nf_hook_ops out;
int priv_in = 0, priv_out = 1;

struct stats {
    __u64 total_packets;
    __u64 accepted_packets;
    __u64 accepted_malformed_packets;
    __u64 accepted_syn_packets;
    __u64 accepted_last_resort_packets;
    __u64 accepted_established_packets;
    __u64 accepted_syn_cookie_packets;
    __u64 forwarded_to_self_packets;
    __u64 forwarded_to_alternate_packets;
    struct u64_stats_sync syncp;
};

struct gue_private {
    uint16_t    reserved;
    uint8_t     next_hop;
    uint8_t     hop_count;
    __be32      hops[255];
} __attribute__((packed));

struct stats __percpu *percpu_stats;

static unsigned int increment_malformed_packets_and_drop(void)
{
    struct stats *s = this_cpu_ptr(percpu_stats);

    u64_stats_update_begin(&s->syncp);
    s->accepted_malformed_packets++;
    u64_stats_update_end(&s->syncp);
    return NF_DROP;
}

static unsigned int is_our_tcp_connection(struct sk_buff *skb, struct iphdr *inner_ip_h, struct tcphdr *tcp_h)
{
    return 0;

    struct stats *s = this_cpu_ptr(percpu_stats);

    struct sock *socket;
    socket = inet_lookup_established(dev_net(skb_dst(skb)->dev), &tcp_hashinfo,
                                     inner_ip_h->saddr, tcp_h->source,
                                     inner_ip_h->daddr, tcp_h->dest,
                                     inet_iif(skb));

    if (socket) {
        u64_stats_update_begin(&s->syncp);
        s->accepted_established_packets++;
        u64_stats_update_end(&s->syncp);

        sock_gen_put(socket);

        return 1;
    }

    if (tcp_h->ack && !tcp_h->fin && !tcp_h->rst && !tcp_h->syn) {
        struct sock *listen_sk;
        int ret = 0;

        listen_sk = inet_lookup_listener(dev_net(skb_dst(skb)->dev), &tcp_hashinfo, skb, ip_hdrlen(skb) + __tcp_hdrlen(tcp_h),
                                         inner_ip_h->saddr, tcp_h->source, inner_ip_h->daddr,
                                         tcp_h->dest, inet_iif(skb), 0);

        if (listen_sk && !refcount_inc_not_zero(&listen_sk->sk_refcnt))
            listen_sk = NULL;

        if (listen_sk) {
            int syncookies = sock_net(listen_sk)->ipv4.sysctl_tcp_syncookies;
            bool want_cookie = (syncookies == 2 || !tcp_synq_no_recent_overflow(listen_sk));

            if (want_cookie) {
                int mss = __cookie_v4_check(inner_ip_h, tcp_h, ntohl(tcp_h->ack_seq) - 1);
                if (mss > 0)
                    ret = 1;
            }

            sock_put(listen_sk);
        }

        if (ret == 1) {
            u64_stats_update_begin(&s->syncp);
            s->accepted_syn_cookie_packets++;
            u64_stats_update_end(&s->syncp);
        }

        return ret;
    }

    return 0;
}

static unsigned int redirect_handle_inner_tcp(struct sk_buff *skb, struct iphdr *ip_h, struct udphdr *udp_h,
        struct gue_private *gue_priv_hdr, struct iphdr *inner_ip_h, int inner_l4_h_offset)
{
    struct stats *s = this_cpu_ptr(percpu_stats);
    struct tcphdr *tcp_h, tcp_h_buf;
    __be32 next_hop_ip;

    printk(KERN_INFO "Got TCP Packet\n");

    tcp_h = skb_header_pointer(skb, inner_l4_h_offset, sizeof(tcp_h_buf), &tcp_h_buf);
    if (tcp_h == NULL)
        return NF_DROP;

    /* Always accept TCP Packets */
    if (tcp_h->syn) {
        u64_stats_update_begin(&s->syncp);
        s->accepted_syn_packets++;
        u64_stats_update_end(&s->syncp);

        return NF_ACCEPT;
    }

    /* Check for existing connection, if not, redirect it to the next server */
    if (is_our_tcp_connection(skb, inner_ip_h, tcp_h)) {
        // this is our packet, accept it
        return NF_ACCEPT;
    }

    /* It's not our packet */

    /* We've no other alternative servers we can send the packet to, lets respond
     * and say so instead of dropping the packet */
    if (gue_priv_hdr->next_hop >= gue_priv_hdr->hop_count) {
        u64_stats_update_begin(&s->syncp);
        s->accepted_last_resort_packets++;
        u64_stats_update_end(&s->syncp);

        return NF_ACCEPT;
    }

    /* Get the IP of the next server */
    next_hop_ip = gue_priv_hdr->hops[gue_priv_hdr->next_hop];
    /* We should expect that the next_hop_ip be different to our IP, but there are cases where it
     * can happen, and in that case, we should log it so we know */
    if (next_hop_ip == ip_h->daddr) {
        u64_stats_update_begin(&s->syncp);
        s->forwarded_to_self_packets++;
        u64_stats_update_end(&s->syncp);

        return NF_ACCEPT;
    }

    /* Adjust the UDP checksum if we got one */
    if (udp_h->check != 0) {
        csum_replace2(&udp_h->check, gue_priv_hdr->next_hop, gue_priv_hdr->next_hop + 1);
        csum_replace4(&udp_h->check, ip_h->saddr, ip_h->daddr);
        csum_replace4(&udp_h->check, ip_h->daddr, next_hop_ip);
    }

    gue_priv_hdr->next_hop++;
    ip_h->saddr = ip_h->daddr;
    ip_h->daddr = next_hop_ip;

    return NF_ACCEPT;
}

static unsigned int redirect_handle_inner_generic(struct sk_buff *skb, struct iphdr *ip_h, struct udphdr *udp_h,
        struct gue_private *gue_priv_hdr, struct iphdr *inner_ip_h, int inner_l4_h_offset)
{
    printk(KERN_INFO "Got Generic Packet\n");

    return NF_ACCEPT;
}

static unsigned int redirect_handle_inner_ipv4(struct sk_buff *skb, struct iphdr *ip_h, struct udphdr *udp_h,
        struct gue_private *gue_priv_hdr, int inner_ip_h_offset)
{
    struct iphdr *inner_ip_h, inner_ip_h_buf;

    inner_ip_h = skb_header_pointer(skb, inner_ip_h_offset, sizeof(inner_ip_h_buf), &inner_ip_h_buf);
    if (inner_ip_h == NULL)
        return increment_malformed_packets_and_drop();

    switch (inner_ip_h->protocol) {
        case IPPROTO_TCP:
            return redirect_handle_inner_tcp(skb, ip_h, udp_h, gue_priv_hdr, inner_ip_h, inner_ip_h_offset + sizeof(inner_ip_h_buf));
        default:
            return redirect_handle_inner_generic(skb, ip_h, udp_h, gue_priv_hdr, inner_ip_h, inner_ip_h_offset + sizeof(inner_ip_h_buf));
    }

    return NF_DROP;
}

static unsigned int redirect_handle_inner_ipv6(struct sk_buff *skb, struct iphdr *ip_h, struct udphdr *udp_h,
        struct gue_private *gue_priv_hdr, int inner_ip_h_offset)
{
    return NF_DROP;
}

static unsigned int redirect_tg_common(struct sk_buff *skb, void *ip_h, size_t ip_h_size)
{
    struct stats *s = this_cpu_ptr(percpu_stats);
    struct udphdr *udp_h, udp_h_buf;
    struct guehdr *gue_h, gue_h_buf;
    struct gue_private *gue_priv_h, gue_priv_h_buf;
    int udp_h_offset, gue_h_offset, gue_priv_h_offset, inner_ip_h_offset;

    /*
     * The default here is to just pass the packet up to the networking stack if we don't
     * understand it, or we recognise it as a packet that we don't care about (not a UDP
     * packet coming over port 7666)
     */

    /*
     * Extract the UDP packet
     * Pass the packet up the networking stack if it's not a UDP packet on port 7666
     */
    udp_h_offset = ip_h_size;
    udp_h = skb_header_pointer(skb, udp_h_offset, sizeof(udp_h_buf), &udp_h_buf);
    if (udp_h == NULL)
        return NF_ACCEPT;
    if (udp_h->dest != __builtin_bswap16(7666))
        return NF_ACCEPT;

    u64_stats_update_begin(&s->syncp);
    s->accepted_packets++;
    u64_stats_update_end(&s->syncp);

    printk(KERN_INFO "Got LB Packet\n");

    /*
     * Extract the common GUE header
     * Drop the packet if it doesn't contain a common GUE header as we always expect
     * it on UDP port 7666
     */
    gue_h_offset = udp_h_offset + sizeof(udp_h_buf);
    gue_h = skb_header_pointer(skb, gue_h_offset, sizeof(gue_h_buf), &gue_h_buf);
    if (gue_h == NULL)
        return increment_malformed_packets_and_drop();

    printk(KERN_INFO "Got GUE Packet\n");

    /*
     * Extract our private GUE fields
     * Entire GUE must be at leave 4 bytes plus size of one IP
     */
    if (gue_h->hlen < 8)
        return increment_malformed_packets_and_drop();

    gue_priv_h_offset = gue_h_offset + sizeof(gue_h_buf);
    gue_priv_h = skb_header_pointer(skb, gue_priv_h_offset, 4 + gue_h->hlen, &gue_priv_h_buf);
    if (gue_priv_h == NULL)
        return increment_malformed_packets_and_drop();

    inner_ip_h_offset = gue_h_offset + 4 + gue_h->hlen;

    // The packet should be an IPv4 or IPv6 encapsulated packet, drop it if otherwise
    if (gue_h->proto_ctype == IPPROTO_IPIP) {
        /* IPv4 inside */
        return redirect_handle_inner_ipv4(skb, ip_h, udp_h, gue_priv_h, inner_ip_h_offset);
    } else if (gue_h->proto_ctype == IPPROTO_IPV6) {
        /* IPv6 inside */
        return redirect_handle_inner_ipv6(skb, ip_h, udp_h, gue_priv_h, inner_ip_h_offset);
    }

    return increment_malformed_packets_and_drop();
}

//static unsigned int redirect_tg4(struct sk_buff *skb, const struct xt_action_param *par)
static unsigned int hook_v4(void *priv, struct sk_buff *skb, const struct nf_hook_state *hook_state)
{
    struct stats *s = this_cpu_ptr(percpu_stats);
    struct iphdr *ip_h;
    struct udphdr *udp_h, udp_h_buf;

    u64_stats_update_begin(&s->syncp);
    s->total_packets++;
    u64_stats_update_end(&s->syncp);

    /* Extract first IP header */
    ip_h = ip_hdr(skb);
    if (ip_h == NULL)
        return NF_ACCEPT;

    /* Pass the packet up the networking stack if it's anything except a UDP packet */
    if (ip_h->protocol != IPPROTO_UDP)
        return NF_ACCEPT;

    return redirect_tg_common(skb, ip_h, sizeof(struct iphdr));
}

static unsigned int hook_v6(void *priv, struct sk_buff *skb, const struct nf_hook_state *hook_state)
{
    struct stats *s = this_cpu_ptr(percpu_stats);
    struct ipv6hdr *ip_h;

    printk(KERN_INFO "Got Packet\n");

    u64_stats_update_begin(&s->syncp);
    s->total_packets++;
    u64_stats_update_end(&s->syncp);

    /* Extract first IP header */
    ip_h = ipv6_hdr(skb);
    if (ip_h == NULL)
        return NF_ACCEPT;

    /* Pass the packet up the networking stack if it's anything except a UDP packet */
    if (ip_h->nexthdr != IPPROTO_UDP)
        return NF_ACCEPT;

    return redirect_tg_common(skb, ip_h, sizeof(struct ipv6hdr));
}

static int proc_show(struct seq_file *m, void *v)
{
    unsigned int cpu, start;
    struct stats sum = {0};

    for_each_possible_cpu(cpu) {
        struct stats *s = per_cpu_ptr(percpu_stats, cpu);
        struct stats tmp = {0};

        do {
            start = u64_stats_fetch_begin(&s->syncp);
            tmp.total_packets = s->total_packets;
            tmp.accepted_packets = s->accepted_packets;
            tmp.accepted_malformed_packets = s->accepted_malformed_packets;
            tmp.accepted_syn_packets = s->accepted_syn_packets;
            tmp.accepted_last_resort_packets = s->accepted_last_resort_packets;
            tmp.accepted_established_packets = s->accepted_established_packets;
            tmp.accepted_syn_cookie_packets = s->accepted_syn_cookie_packets;
            tmp.forwarded_to_self_packets = s->forwarded_to_self_packets;
            tmp.forwarded_to_alternate_packets = s->forwarded_to_alternate_packets;
        } while (u64_stats_fetch_retry(&s->syncp, start));

        sum.total_packets += tmp.total_packets;
        sum.accepted_packets += tmp.accepted_packets;
        sum.accepted_malformed_packets += tmp.accepted_malformed_packets;
        sum.accepted_syn_packets += tmp.accepted_syn_packets;
        sum.accepted_last_resort_packets += tmp.accepted_last_resort_packets;
        sum.accepted_established_packets += tmp.accepted_established_packets;
        sum.accepted_syn_cookie_packets += tmp.accepted_syn_cookie_packets;
        sum.forwarded_to_self_packets += tmp.forwarded_to_self_packets;
        sum.forwarded_to_alternate_packets += tmp.forwarded_to_alternate_packets;
    }

    seq_printf(m, "total_packets: %llu\n", sum.total_packets);
    seq_printf(m, "accepted_packets: %llu\n", sum.accepted_packets);
    seq_printf(m, "accepted_malformed_packets: %llu\n", sum.accepted_malformed_packets);
    seq_printf(m, "accepted_syn_packets: %llu\n", sum.accepted_syn_packets);
    seq_printf(m, "accepted_last_resort_packets: %llu\n", sum.accepted_last_resort_packets);
    seq_printf(m, "accepted_established_packets: %llu\n", sum.accepted_established_packets);
    seq_printf(m, "accepted_syn_cookie_packets: %llu\n", sum.accepted_syn_cookie_packets);
    seq_printf(m, "forwarded_to_self_packets: %llu\n", sum.forwarded_to_self_packets);
    seq_printf(m, "forwarded_to_alternate_packets: %llu\n", sum.forwarded_to_alternate_packets);

    return 0;
}

static int proc_open(struct inode *inode, struct file *file)
{
    return single_open(file, proc_show, NULL);
}

// use proc_ops in newer kernels
// https://lore.kernel.org/linux-fsdevel/20191225172228.GA13378@avx2/
static const struct proc_ops proc_operations = {
        .proc_open		= proc_open,
        .proc_read		= seq_read,
        .proc_lseek		= seq_lseek,
        .proc_release	= single_release,
};

static struct nf_hook_ops hook_ops[] = {
        {
            .hook       = hook_v4,
            .pf         = PF_INET,
            .hooknum    = NF_INET_PRE_ROUTING,
            .priority   = NF_IP_PRI_FIRST,
        },
        {
            .hook       = hook_v6,
            .pf         = PF_INET6,
            .hooknum    = NF_INET_PRE_ROUTING,
            .priority   = NF_IP_PRI_FIRST,
        },
};

static int __init redirect_init(void)
{
    unsigned int cpu;
    int err;

    percpu_stats = alloc_percpu(struct stats);
    if (!percpu_stats)
        return -ENOMEM;

    for_each_possible_cpu(cpu) {
        struct stats *s = per_cpu_ptr(percpu_stats, cpu);
        u64_stats_init(&s->syncp);
    }

    err = nf_register_net_hooks(&init_net, hook_ops, ARRAY_SIZE(hook_ops));
    if (err < 0)
        goto err;

    printk(KERN_INFO "Netfilter: Adding Load Balancer Redirect Module\n");

    proc_create(PROCFS_NAME, 0, NULL, &proc_operations);
    return 0;

    err:
    free_percpu(percpu_stats);
    return err;
}

static void __exit redirect_exit(void)
{
    remove_proc_subtree(PROCFS_NAME, NULL);
    nf_unregister_net_hooks(&init_net, hook_ops, ARRAY_SIZE(hook_ops));
    free_percpu(percpu_stats);

    printk(KERN_INFO "Netfilter: Removing Load Balancer Redirect Module\n");
}

module_init(redirect_init);
module_exit(redirect_exit);