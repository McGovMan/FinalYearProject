#include <stdint.h>
#include <linux/bpf.h>
#include "maps.h"
#include "blake3.h"

/*
 * This struct defines what the binds map key looks like
 */
typedef struct {
    uint32_t ip;
    uint16_t port;
    uint8_t  protocol;
} binds_row_key;

/*
 * The binds_backend map and hash_key map both contain keys that are 32 bits
 * no need to create a struct for them
 */

/*
 * This function will return the array index in the bind_backends row to the
 * row attribute where the inner map of 65k backends resides. We need to give
 * it a binds_row_key struct as the binds map is a hash map and is only
 * searchable with a key.
 *
 */
static binds_row *get_binds_row(binds_row_key *row_key) {
    // have to hash the key using blake3
    blake3_hasher hasher;
    blake3_hasher_init(&hasher);
    uint8_t output[32];
    blake3_hasher_update(&hasher, &row_key, sizeof(binds_row_key));
    blake3_hasher_finalize(&hasher, output, 32);

    return (binds_row *)bpf_map_lookup_elem(&binds, &output);
}

/*
 * This function will return the inner map which contains all the backends.
 */
static int get_bind_backends_row(uint32_t *index, bind_backends_row *row) {
    row = bpf_map_lookup_elem(&bind_backends, index);
    if (row == NULL) return -1;
    return 0;
}