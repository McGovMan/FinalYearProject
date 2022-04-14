//
// Created by conor on 11/04/2022.
//

#ifndef FINALYEARPROJECT_MAPS_H
#define FINALYEARPROJECT_MAPS_H

#include <stdint.h>
#include <bpf/bpf_helpers.h>

#define BALANCER_PINNED_FILE "/sys/fs/bpf/balancer"

/*
 * ===== MAPS DEFINED AND CREATED BY BPF =====
 */

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
 * The hash_keys contains the hash_keys for each bind.
 */
struct bpf_map_def SEC("maps") hash_keys = {
        .type = BPF_MAP_TYPE_ARRAY,
        .key_size = sizeof(__u32),
        .value_size = 16,
        .max_entries = 4096,
};

/*
 * ======= STRUCTS USED TO UNMARSHAL THE CONTENT ======
 * ======= IN THE MAPS DEFINED AND CREATED BY BPF =====
 */

/*
 * This struct defines what the binds map row looks like
 */
typedef struct {
    uint32_t bindsBackendRowID;
} binds_row;

/*
 * This struct defines what the backends inner map row looks like
 */
typedef struct {
        uint32_t ethernetIndex;
        uint32_t ips[];
} bind_backends_inner_row;

/*
 * This struct defines what the backends map looks like
 */
typedef struct {
    struct bind_backends_inner_row *rows;
} bind_backends_row;

/*
 * This struct defines what the hash_keys map row looks like
 */
typedef struct {
    uint32_t hashKey[4];
} hash_keys_row;

#endif //FINALYEARPROJECT_MAPS_H
