/*
 * Author: Conor Mc Govern
 */

#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/if_ether.h>	//For ETH_P_ALL
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <unistd.h>

#include<netinet/in.h>
#include<errno.h>
#include<netdb.h>
#include<stdio.h>	//For standard things
#include<stdlib.h>	//malloc
#include<string.h>	//strlen

#include<netinet/ip_icmp.h>	//Provides declarations for icmp header
#include<netinet/udp.h>	//Provides declarations for udp header
#include<netinet/tcp.h>	//Provides declarations for tcp header
#include<netinet/ip.h>	//Provides declarations for ip header
#include<netinet/if_ether.h>	//For ETH_P_ALL
#include<net/ethernet.h>	//For ether_header
#include<sys/socket.h>
#include<arpa/inet.h>
#include<sys/ioctl.h>
#include<sys/time.h>
#include<sys/types.h>
#include<unistd.h>

#define DEFAULT_IFACE "lo"
#define MAX_BUFFER 10240

void ProcessPacket(unsigned char* , int);
void print_ip_header(unsigned char* , int);
void print_tcp_packet(unsigned char * , int );
void print_udp_packet(unsigned char * , int );
void print_icmp_packet(unsigned char* , int );
void PrintData (unsigned char* , int);

int socket_fd = 0;
struct ifreq iface_opts;

FILE *logfile;
struct sockaddr_in source,dest;
int tcp=0,udp=0,icmp=0,others=0,igmp=0,total=0,i,j;

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

int main(int argc, char **argv)
{
    int socket_opts = 0;
    int saddr_size;
    struct sockaddr_in saddr;
    unsigned char pkt_buf[MAX_BUFFER];
    char src_ip[INET_ADDRSTRLEN];
    ssize_t bytes_read;

    logfile=fopen("log.txt","w");
    if(logfile==NULL)
    {
        printf("Unable to create log.txt file.");
    }

    /* Associate signal_handler function with USR signals */
    signal(SIGUSR1, signal_handler);
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    if ((socket_fd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) < 0) {
        puts("failed to open socket");
    }

    memset(&iface_opts, 0, sizeof(iface_opts));
    strncpy(iface_opts.ifr_name, DEFAULT_IFACE, IFNAMSIZ);

    if (ioctl(socket_fd, SIOCGIFFLAGS, &iface_opts) == -1) {
        close(socket_fd);
        puts("failed to SIOCGIFFLAGS");
    }

    iface_opts.ifr_flags |= IFF_UP | IFF_RUNNING;

    // set promiscuous mode
    iface_opts.ifr_flags |= IFF_PROMISC;

    if (ioctl(socket_fd, SIOCSIFFLAGS, &iface_opts) == -1) {
        close(socket_fd);
        //glb_log_error("failed to switch to promiscuous mode");
        goto done;
    }

    // set reuseaddr
    if (setsockopt(socket_fd, SOL_SOCKET, SO_REUSEADDR, &socket_opts,
                   sizeof(socket_opts)) == -1) {
        close(socket_fd);
        //glb_log_error("failed to switch to promiscuous mode");
        goto done;
    }

    saddr.sin_family = PF_PACKET;
    saddr.sin_addr.s_addr = INADDR_ANY;
    saddr.sin_port=htons(8001);
    saddr_size = sizeof saddr;

    // bind to device
    if (setsockopt(socket_fd, SOL_SOCKET, SO_BINDTODEVICE, DEFAULT_IFACE, IFNAMSIZ - 1) == -1) {// || bind(socket_fd, (struct sockaddr *)&saddr, saddr_size) == -1) {
        close(socket_fd);
        //glb_log_error("failed to bind to device");
        goto done;
    }

    //glb_log_info("waiting for packets from %s*", DEFAULT_SRC_IP_PREFIX);
    fflush(stdout);

    repeat:
    bytes_read = recvfrom(socket_fd, pkt_buf, MAX_BUFFER, 0, (struct sockaddr *)&saddr , (socklen_t*)&saddr_size);
    if (bytes_read <= 0) {
        puts("failed to read bytes from socket");
    }

    print_tcp_packet(pkt_buf, bytes_read);

    //struct iphdr *iph = (struct iphdr*)(pkt_buf + sizeof(struct ethhdr));
    //printf("%d", iph->protocol);
    //puts("here");
    //struct ether_hdr *eth_hdr = (struct ether_hdr *)pkt_buf;
    //struct ipv4_hdr *ipv4_hdr = (struct ipv4_hdr *)(eth_hdr + 1);

    /*inet_ntop(AF_INET, &(ipv4_hdr->src_addr), src_ip, INET_ADDRSTRLEN);

    if (strncmp(src_ip, DEFAULT_SRC_IP_PREFIX,
                strlen(DEFAULT_SRC_IP_PREFIX)) == 0) {
        pcap_packet pkt;
        pkt.data = pkt_buf;
        pkt.len = bytes_read;
        if (glb_encapsulate_packet_pcap(config_ctx, &pkt, 0) != 0) {
            puts("packet encap failed!");
        }
    }*/
    //fflush(stdout);
    //puts(pkt_buf);
    //printf("%d", bytes_read);
    goto repeat;


    done:
    iface_opts.ifr_flags &= ~IFF_PROMISC;
    if (ioctl(socket_fd, SIOCSIFFLAGS, &iface_opts) == -1) {
        puts("cant restore interface settings");
    }

    puts("here");
    sleep(10000);

    exit(0);
}


void ProcessPacket(unsigned char* buffer, int size)
{
    //Get the IP Header part of this packet , excluding the ethernet header
    struct iphdr *iph = (struct iphdr*)(buffer + sizeof(struct ethhdr));
    ++total;
    switch (iph->protocol) //Check the Protocol and do accordingly...
    {
        case 1:  //ICMP Protocol
            ++icmp;
            print_icmp_packet( buffer , size);
            break;

        case 2:  //IGMP Protocol
            ++igmp;
            break;

        case 6:  //TCP Protocol
            ++tcp;
            print_tcp_packet(buffer , size);
            break;

        case 17: //UDP Protocol
            ++udp;
            print_udp_packet(buffer , size);
            break;

        default: //Some Other Protocol like ARP etc.
            ++others;
            break;
    }
    printf("TCP : %d   UDP : %d   ICMP : %d   IGMP : %d   Others : %d   Total : %d\r", tcp , udp , icmp , igmp , others , total);
}

void print_ethernet_header(unsigned char* Buffer, int Size)
{
    struct ethhdr *eth = (struct ethhdr *)Buffer;

    fprintf(logfile , "\n");
    fprintf(logfile , "Ethernet Header\n");
    fprintf(logfile , "   |-Destination Address : %.2X-%.2X-%.2X-%.2X-%.2X-%.2X \n", eth->h_dest[0] , eth->h_dest[1] , eth->h_dest[2] , eth->h_dest[3] , eth->h_dest[4] , eth->h_dest[5] );
    fprintf(logfile , "   |-Source Address      : %.2X-%.2X-%.2X-%.2X-%.2X-%.2X \n", eth->h_source[0] , eth->h_source[1] , eth->h_source[2] , eth->h_source[3] , eth->h_source[4] , eth->h_source[5] );
    fprintf(logfile , "   |-Protocol            : %u \n",(unsigned short)eth->h_proto);
}

void print_ip_header(unsigned char* Buffer, int Size)
{
    print_ethernet_header(Buffer , Size);

    unsigned short iphdrlen;

    struct iphdr *iph = (struct iphdr *)(Buffer  + sizeof(struct ethhdr) );
    iphdrlen =iph->ihl*4;

    memset(&source, 0, sizeof(source));
    source.sin_addr.s_addr = iph->saddr;

    memset(&dest, 0, sizeof(dest));
    dest.sin_addr.s_addr = iph->daddr;

    fprintf(logfile , "\n");
    fprintf(logfile , "IP Header\n");
    fprintf(logfile , "   |-IP Version        : %d\n",(unsigned int)iph->version);
    fprintf(logfile , "   |-IP Header Length  : %d DWORDS or %d Bytes\n",(unsigned int)iph->ihl,((unsigned int)(iph->ihl))*4);
    fprintf(logfile , "   |-Type Of Service   : %d\n",(unsigned int)iph->tos);
    fprintf(logfile , "   |-IP Total Length   : %d  Bytes(Size of Packet)\n",ntohs(iph->tot_len));
    fprintf(logfile , "   |-Identification    : %d\n",ntohs(iph->id));
    //fprintf(logfile , "   |-Reserved ZERO Field   : %d\n",(unsigned int)iphdr->ip_reserved_zero);
    //fprintf(logfile , "   |-Dont Fragment Field   : %d\n",(unsigned int)iphdr->ip_dont_fragment);
    //fprintf(logfile , "   |-More Fragment Field   : %d\n",(unsigned int)iphdr->ip_more_fragment);
    fprintf(logfile , "   |-TTL      : %d\n",(unsigned int)iph->ttl);
    fprintf(logfile , "   |-Protocol : %d\n",(unsigned int)iph->protocol);
    fprintf(logfile , "   |-Checksum : %d\n",ntohs(iph->check));
    fprintf(logfile , "   |-Source IP        : %s\n",inet_ntoa(source.sin_addr));
    fprintf(logfile , "   |-Destination IP   : %s\n",inet_ntoa(dest.sin_addr));
}

void print_tcp_packet(unsigned char* Buffer, int Size)
{
    unsigned short iphdrlen;

    struct iphdr *iph = (struct iphdr *)( Buffer  + sizeof(struct ethhdr) );
    iphdrlen = iph->ihl*4;

    struct tcphdr *tcph=(struct tcphdr*)(Buffer + iphdrlen + sizeof(struct ethhdr));

    int header_size =  sizeof(struct ethhdr) + iphdrlen + tcph->doff*4;

    fprintf(logfile , "\n\n***********************TCP Packet*************************\n");

    print_ip_header(Buffer,Size);

    fprintf(logfile , "\n");
    fprintf(logfile , "TCP Header\n");
    fprintf(logfile , "   |-Source Port      : %u\n",ntohs(tcph->source));
    fprintf(logfile , "   |-Destination Port : %u\n",ntohs(tcph->dest));
    fprintf(logfile , "   |-Sequence Number    : %u\n",ntohl(tcph->seq));
    fprintf(logfile , "   |-Acknowledge Number : %u\n",ntohl(tcph->ack_seq));
    fprintf(logfile , "   |-Header Length      : %d DWORDS or %d BYTES\n" ,(unsigned int)tcph->doff,(unsigned int)tcph->doff*4);
    //fprintf(logfile , "   |-CWR Flag : %d\n",(unsigned int)tcph->cwr);
    //fprintf(logfile , "   |-ECN Flag : %d\n",(unsigned int)tcph->ece);
    fprintf(logfile , "   |-Urgent Flag          : %d\n",(unsigned int)tcph->urg);
    fprintf(logfile , "   |-Acknowledgement Flag : %d\n",(unsigned int)tcph->ack);
    fprintf(logfile , "   |-Push Flag            : %d\n",(unsigned int)tcph->psh);
    fprintf(logfile , "   |-Reset Flag           : %d\n",(unsigned int)tcph->rst);
    fprintf(logfile , "   |-Synchronise Flag     : %d\n",(unsigned int)tcph->syn);
    fprintf(logfile , "   |-Finish Flag          : %d\n",(unsigned int)tcph->fin);
    fprintf(logfile , "   |-Window         : %d\n",ntohs(tcph->window));
    fprintf(logfile , "   |-Checksum       : %d\n",ntohs(tcph->check));
    fprintf(logfile , "   |-Urgent Pointer : %d\n",tcph->urg_ptr);
    fprintf(logfile , "\n");
    fprintf(logfile , "                        DATA Dump                         ");
    fprintf(logfile , "\n");

    fprintf(logfile , "IP Header\n");
    PrintData(Buffer,iphdrlen);

    fprintf(logfile , "TCP Header\n");
    PrintData(Buffer+iphdrlen,tcph->doff*4);

    fprintf(logfile , "Data Payload\n");
    PrintData(Buffer + header_size , Size - header_size );

    fprintf(logfile , "\n###########################################################");
}

void print_udp_packet(unsigned char *Buffer , int Size)
{

    unsigned short iphdrlen;

    struct iphdr *iph = (struct iphdr *)(Buffer +  sizeof(struct ethhdr));
    iphdrlen = iph->ihl*4;

    struct udphdr *udph = (struct udphdr*)(Buffer + iphdrlen  + sizeof(struct ethhdr));

    int header_size =  sizeof(struct ethhdr) + iphdrlen + sizeof udph;

    fprintf(logfile , "\n\n***********************UDP Packet*************************\n");

    print_ip_header(Buffer,Size);

    fprintf(logfile , "\nUDP Header\n");
    fprintf(logfile , "   |-Source Port      : %d\n" , ntohs(udph->source));
    fprintf(logfile , "   |-Destination Port : %d\n" , ntohs(udph->dest));
    fprintf(logfile , "   |-UDP Length       : %d\n" , ntohs(udph->len));
    fprintf(logfile , "   |-UDP Checksum     : %d\n" , ntohs(udph->check));

    fprintf(logfile , "\n");
    fprintf(logfile , "IP Header\n");
    PrintData(Buffer , iphdrlen);

    fprintf(logfile , "UDP Header\n");
    PrintData(Buffer+iphdrlen , sizeof udph);

    fprintf(logfile , "Data Payload\n");

    //Move the pointer ahead and reduce the size of string
    PrintData(Buffer + header_size , Size - header_size);

    fprintf(logfile , "\n###########################################################");
}

void print_icmp_packet(unsigned char* Buffer , int Size)
{
    unsigned short iphdrlen;

    struct iphdr *iph = (struct iphdr *)(Buffer  + sizeof(struct ethhdr));
    iphdrlen = iph->ihl * 4;

    struct icmphdr *icmph = (struct icmphdr *)(Buffer + iphdrlen  + sizeof(struct ethhdr));

    int header_size =  sizeof(struct ethhdr) + iphdrlen + sizeof icmph;

    fprintf(logfile , "\n\n***********************ICMP Packet*************************\n");

    print_ip_header(Buffer , Size);

    fprintf(logfile , "\n");

    fprintf(logfile , "ICMP Header\n");
    fprintf(logfile , "   |-Type : %d",(unsigned int)(icmph->type));

    if((unsigned int)(icmph->type) == 11)
    {
        fprintf(logfile , "  (TTL Expired)\n");
    }
    else if((unsigned int)(icmph->type) == ICMP_ECHOREPLY)
    {
        fprintf(logfile , "  (ICMP Echo Reply)\n");
    }

    fprintf(logfile , "   |-Code : %d\n",(unsigned int)(icmph->code));
    fprintf(logfile , "   |-Checksum : %d\n",ntohs(icmph->checksum));
    //fprintf(logfile , "   |-ID       : %d\n",ntohs(icmph->id));
    //fprintf(logfile , "   |-Sequence : %d\n",ntohs(icmph->sequence));
    fprintf(logfile , "\n");

    fprintf(logfile , "IP Header\n");
    PrintData(Buffer,iphdrlen);

    fprintf(logfile , "UDP Header\n");
    PrintData(Buffer + iphdrlen , sizeof icmph);

    fprintf(logfile , "Data Payload\n");

    //Move the pointer ahead and reduce the size of string
    PrintData(Buffer + header_size , (Size - header_size) );

    fprintf(logfile , "\n###########################################################");
}

void PrintData (unsigned char* data , int Size)
{
    int i , j;
    for(i=0 ; i < Size ; i++)
    {
        if( i!=0 && i%16==0)   //if one line of hex printing is complete...
        {
            fprintf(logfile , "         ");
            for(j=i-16 ; j<i ; j++)
            {
                if(data[j]>=32 && data[j]<=128)
                    fprintf(logfile , "%c",(unsigned char)data[j]); //if its a number or alphabet

                else fprintf(logfile , "."); //otherwise print a dot
            }
            fprintf(logfile , "\n");
        }

        if(i%16==0) fprintf(logfile , "   ");
        fprintf(logfile , " %02X",(unsigned int)data[i]);

        if( i==Size-1)  //print the last spaces
        {
            for(j=0;j<15-i%16;j++)
            {
                fprintf(logfile , "   "); //extra spaces
            }

            fprintf(logfile , "         ");

            for(j=i-i%16 ; j<=i ; j++)
            {
                if(data[j]>=32 && data[j]<=128)
                {
                    fprintf(logfile , "%c",(unsigned char)data[j]);
                }
                else
                {
                    fprintf(logfile , ".");
                }
            }

            fprintf(logfile ,  "\n" );
        }
    }
}