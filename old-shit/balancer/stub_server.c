
#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/if_ether.h>	//For ETH_P_ALL
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <netinet/in.h>
#include <sys/socket.h>

#define SERVER_PORT 443
#define MAX_BUFFER 10240

int socket_fd = 0;

void signal_handler(int signum)
{
    /* handle reload request */
    if (signum == SIGUSR1) {
        //todo
    }

    /* handing shutdown */
    if (signum == SIGINT || signum == SIGTERM) {
        //todo
        exit(0);
    }
}

int main(int argc, char **argv) {
    int addr_in_size, pkt_buf_size, socket_opts = 0, on = 1;
    struct sockaddr_in addr_in;
    unsigned char pkt_buf[MAX_BUFFER];

    /* Associate signal_handler function with USR signals */
    signal(SIGUSR1, signal_handler);
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    /* Socket receives raw packets from NIC (doesn't care about protocols or ports) */
    if (((socket_fd = socket(PF_PACKET, SOCK_RAW, htons(ETHER_TYPE_IPv4))))) == -1) {
        puts("failed to open socket");
        goto done;
    }

    // Enabling use of SO_REUSEADDR
    if (setsockopt(socket_fd, SOL_SOCKET, SO_REUSEADDR, (char *)&on, sizeof on) < 0)
    {
        close(socket_fd);
        puts("failed to set socket opts");
        goto done;
    }

    addr_in.sin_family = AF_INET;
    addr_in.sin_addr = inaddr_any;
    addr_in.sin_addr.s_addr = inet_addr(SERVER_ADDRESS);
    addr_in.sin_port = htons(SERVER_PORT);
    //memset(addr_in.sin_zero, '\0', sizeof addr_in.sin_zero);  /* Set all bits of the padding field to 0 */
    addr_in_size = sizeof addr_in;

    if (bind(socket_fd, (struct sockaddr *)&addr_in, addr_in_size) == -1) {
        close(socket_fd);
        puts("failed to bind to address");
        goto done;
    }

    repeat:
    pkt_buf_size = recvfrom(socket_fd, pkt_buf, MAX_BUFFER, 0, (struct sockaddr *)&addr_in , (socklen_t*)&addr_in_size);
    printf("%d", pkt_buf_size);
    if (pkt_buf_size <= 0)
        puts("failed to read bytes from socket");

    puts("here");
    fflush(stdout);

    goto repeat;

    done:

    return 0;
}