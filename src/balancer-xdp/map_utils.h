#include <stdint.h>
#include <linux/bpf.h>
#include "maps.h"
#include "siphash.h"
#include <byteswap.h>

/*
 * Get config row returns the row in the config map according to the ID.
 * ID: 0 = number of collumns
 * ID: 1 = hashing key part 1
 * ID: 2 = hashing key part 2
 */
static __always_inline uint64_t get_config_row(uint32_t key) {
    uint64_t *res = bpf_map_lookup_elem(&config, &key);
    if (res == NULL)
        return -1;
    return *res;
}

/*
 * This function will return the array index in the bind_backends row to the
 * row attribute where the inner map of 65k backends resides. We need to give
 * it a binds_row_key struct as the binds map is a hash map and is only
 * searchable with a key.
 */
static __always_inline uint32_t get_binds_row(binds_row_key *row_key) {
    uint64_t hashingKey1 = 0x6b74707279636f6E;
    uint64_t hashingKey2 = 0x64656465656E7965;
    uint64_t hash;

    siphash((uint8_t *)row_key, sizeof(binds_row_key), (uint8_t *)&hash,
            sizeof(hash), hashingKey1, hashingKey2);

    uint64_t reversed_hash = __bswap_64(hash);
    uint32_t *res = bpf_map_lookup_elem(&binds, &reversed_hash);
    if (res == NULL) return -1;
    return *res;
}

/*
 * This function will return the array map which contains all the backends.
 */
static __always_inline bind_backends_row *get_bind_backends_row(uint32_t *index) {
    bind_backends_row *row = bpf_map_lookup_elem(&bind_backends, index);
    if (row == NULL) return NULL;
    return row;
}

/*
 * This function will return the inner row which contains all the backends for a client hash and ethernet index
 * for the first server.
 */
static __always_inline bind_backends_inner_row *get_bind_backends_inner_row(bind_backends_row *row, uint32_t *index) {
    bind_backends_inner_row *inner_row = bpf_map_lookup_elem(row, index);
    if (inner_row == NULL) return NULL;
    return inner_row;
}