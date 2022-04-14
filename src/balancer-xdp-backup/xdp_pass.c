#include <stdint.h>
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

/*
 * The config map contains the information we put into balancer.conf
 * Such as:
 * - 4 bytes for the number of table columns
*/
struct bpf_map_def SEC("maps") config = {
        .type = BPF_MAP_TYPE_ARRAY,
        .key_size = sizeof(__u32),
        .value_size = 4, // maximum size stored
        .max_entries = 1,
};

/*
 * The binds map contains the all the binds in the forwarding config
 * We hash the Bind: IP, Port, and Protocol and let that be the key
 * The value is just the index to the array in the bind_backends map
*/
struct bpf_map_def SEC("maps") binds = {
        .type = BPF_MAP_TYPE_HASH,
        .key_size = 32,
        .value_size = sizeof(__u32),
        .max_entries = 4096,
};

/*
 * The bind_backends map contains all the backends associated with (a)
 * particular bind(s). Each array contains 65k rows, which contain IPs
 * to all the servers for a client IP hash. The IPs are saved as 4 bytes
 * for each server IP; the amount of columns you specify in the balancer
 * config dictate how many bytes are per row.
 * Example:
 * If you have 3 columns, there will be 12 bytes. The 32-bit IP addresses
 * are packed in one after another. So IP1 will start at byte1 and IP2 at
 * byte5.
 */
struct bpf_map_def SEC("maps") bind_backends = {
        .type = BPF_MAP_TYPE_ARRAY_OF_MAPS,
        .key_size = sizeof(__u32),
        .max_entries = 4096,
};

/*
 * The hash_keys contains the hash_keys for each service.
 */
struct bpf_map_def SEC("maps") hash_keys = {
        .type = BPF_MAP_TYPE_ARRAY,
        .key_size = sizeof(__u32),
        .value_size = 16,
        .max_entries = 4096,
};

SEC("xdp_pass")
int pass(struct xdp_md *ctx)
{
    bpf_printk("got packet");
    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
