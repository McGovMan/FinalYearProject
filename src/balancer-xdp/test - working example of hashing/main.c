#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <sys/time.h>
#include "siphash.h"
#include <stdlib.h>
#include <byteswap.h>
#include <string.h>
#include <inttypes.h>

/*
 * This struct defines what the binds map key looks like
 */
typedef struct __attribute__((__packed__)) {
    uint32_t ip;
    uint16_t port;
    uint8_t  protocol;
} binds_row_key;

int main() {
    /*binds_row_key *data = malloc(sizeof(binds_row_key));
    uint16_t port = __bswap_16(80);
    uint8_t protocol = 6;
    uint32_t ip = __bswap_32((unsigned int)(192 + (168 << 8) + (216 << 16) + (5 << 24)));
    data->ip = ip;
    data->port = port;
    data->protocol = protocol;*/

    const char *data = "192.168.216.5";
    //const uint8_t key[16] = { 0x6b, 0x74, 0x70, 0x72, 0x79, 0x63, 0x6f, 0x6E,
    //                          0x64, 0x65, 0x64, 0x65, 0x65, 0x6E, 0x79, 0x65 };

    const uint8_t key[16] = { 0x6E, 0x6F, 0x63, 0x79, 0x72, 0x70, 0x74, 0x6B,
                              0x65, 0x79, 0x6E, 0x65, 0x65, 0x64, 0x65, 0x64 };
    printf("key: ");
    for( int i = 0; i < sizeof(key); i++ )
    {
        printf("%02x", key[i]);
    }
    puts("");

    printf("bytes to be hashed: ");
    for( int i = 0; i < strlen(data); i++ )
    {
        printf("%02x", data[i]);
    }
    puts("");

    uint64_t hash = siphash24(data, strlen(data), (const char *)&key[0]);

    printf("hash: %" PRIx64, hash);

    //for( int i = 0; i < sizeof(hash); i++ )
    //{
    //    printf("%02x", hash[i]);
    //}
    puts("");

    /*






    char *data = "192.168.216.5";

    const char *data1 = data;

    uint8_t byteArray[sizeof(data)];
    memcpy(&byteArray, data, sizeof(byteArray));

    printf("bytes to be hashed: ");
    for( int i = 0; i < sizeof(byteArray); i++ )
    {
        printf("%02x", byteArray[i]);
    }
    puts("");

    uint8_t key1[16] = { 0x6e, 0x6f, 0x63, 0x79, 0x72, 0x70, 0x74, 0x6b,
                              0x65, 0x79, 0x6e, 0x65, 0x65, 0x64, 0x65, 0x64 };
    const uint8_t key[16] = { 0x6b, 0x74, 0x70, 0x72, 0x79, 0x63, 0x6f, 0x6e,
                              0x64, 0x65, 0x64, 0x65, 0x65, 0x6e, 0x79, 0x65 };
    printf("key: %s\n", key);
    printf("key: %s\n", key1);

    uint8_t hash[8];
    siphash(data1, 7, key, hash, 8);

    //for (int i = 0; i < sizeof(hash); i++)
    //{
    //    printf("%02x", hash[i]);
    //}
    return 0;*/
}
