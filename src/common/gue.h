
#ifndef _GUE_H_
#define _GUE_H_

#define GUE_PORT 7666 /* ASCII for L (76) & B (66) */

/*
 * In future it would be an idea to implement variant 1 of GUE,
 * but it seems to not be implemented in the Linux Kernel currently.
 *
 * https://datatracker.ietf.org/doc/html/draft-ietf-intarea-gue
 *
 * The header format for version 0 of GUE in UDP is:
 *
 *   0                   1                   2                   3
 *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\
 *  |        Source port            |      Destination port         | |
 *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ UDP
 *  |           Length              |          Checksum             | |
 *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+/
 *  | 0 |C|   Hlen  |  Proto/ctype  |             Flags             |
 *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *  ~                  Extensions Fields (optional)                 ~
 *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *  ~                    Private data (optional)                    ~
 *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *
 * Some explanation:
 *
 * * Version: GUE V0
 * * C-bit: Zero indicates a IANA protocol number
 * * Hlen: Length of header
 * * Proto: IANA protocol number
 * * Flags: Indication of extension fields
 * * Reserved Data: Padding for the header that we can reserve and use in the future.
 *                   Fills and brings us up to the max private data length.
 * * Next Hop: Holds the index of the next hop in hops[] to try.
 * * Hop Count: Number of hops we've calculated for.
 * * Hops Array: Information on how to get to the next available server.
 *
 * When the C bit is set, we must specify an IANA protocol number.
 * https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
 *
 * The length of the private data MUST be a multiple of four and is
 * determined by subtracting the offset of private data in the GUE
 * header from the header length.
 * Specifically: private data length = (hlen * 4) - Length of flags
 */

struct lb_gue_hdr {
    // Include GUE Header from include/net/gue.h
    __u8	hlen:5,
            control:1,
            version:2;
    //__u8    version_control_hlen;
    __u8	proto_ctype;
    __be16	flags;

    // Our Private Fields
    __u16   reserved; // Kept for future use and extensibility
    __u8    next_hop;
    __u8    hop_count;
} __attribute__((__packed__));

#endif /* _GUE_H_ */