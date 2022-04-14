#include <stdint.h>
#include <stdio.h>

typedef struct __attribute__((__packed__)) {
    uint32_t ip;
    uint16_t port;
    uint8_t  protocol;
} binds_row_key;

int main() {

	printf("%d", sizeof(binds_row_key));

	return 0;
}
