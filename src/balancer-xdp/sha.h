/**************************** sha.h ****************************/
/******************* See RFC 4634 for details ******************/
#ifndef _SHA_H_
#define _SHA_H_

/*
 *  Description:
 *      This file implements the Secure Hash Signature Standard
 *      algorithms as defined in the National Institute of Standards
 *      and Technology Federal Information Processing Standards
 *      Publication (FIPS PUB) 180-1 published on April 17, 1995, 180-2
 *      published on August 1, 2002, and the FIPS PUB 180-2 Change
 *      Notice published on February 28, 2004.
 *
 *      A combined document showing all algorithms is available at
 *              http://csrc.nist.gov/publications/fips/
 *              fips180-2/fips180-2withchangenotice.pdf
 *
 *      The five hashes are defined in these sizes:
 *              SHA-1           20 byte / 160 bit
 *              SHA-224         28 byte / 224 bit
 *              SHA-256         32 byte / 256 bit
 *              SHA-384         48 byte / 384 bit
 *              SHA-512         64 byte / 512 bit
 */

#include <stdint.h>
/*
 * If you do not have the ISO standard stdint.h header file, then you
 * must typedef the following:
 *    name              meaning
 *  uint64_t         unsigned 64 bit integer
 *  uint32_t         unsigned 32 bit integer
 *  uint8_t          unsigned 8 bit integer (i.e., unsigned char)
 *  int_least16_t    integer of >= 16 bits
 *
 */

#ifndef _SHA_enum_
#define _SHA_enum_
/*
 *  All SHA functions return one of these values.
 */
enum
{
    shaSuccess = 0,
    shaNull,			/* Null pointer parameter */
    shaInputTooLong,		/* input data too long */
    shaStateError,		/* called Input after FinalBits or Result */
    shaBadParam			/* passed a bad parameter */
};
#endif /* _SHA_enum_ */

/*
 *  These constants hold size information for each of the SHA
 *  hashing operations
 */
enum
{
    SHA1_Message_Block_Size = 64, SHA224_Message_Block_Size = 64,
    SHA256_Message_Block_Size = 64, SHA384_Message_Block_Size = 128,
    SHA512_Message_Block_Size = 128,
    USHA_Max_Message_Block_Size = SHA512_Message_Block_Size,

    SHA1HashSize = 20, SHA224HashSize = 28, SHA256HashSize = 32,
    SHA384HashSize = 48, SHA512HashSize = 64,
    USHAMaxHashSize = SHA512HashSize,

    SHA1HashSizeBits = 160, SHA224HashSizeBits = 224,
    SHA256HashSizeBits = 256, SHA384HashSizeBits = 384,
    SHA512HashSizeBits = 512, USHAMaxHashSizeBits = SHA512HashSizeBits
};

/*
 *  These constants are used in the USHA (unified sha) functions.
 */
typedef enum SHAversion
{
    SHA1, SHA224, SHA256, SHA384, SHA512
} SHAversion;

/*
 *  This structure will hold context information for the SHA-1
 *  hashing operation.
 */
typedef struct SHA1Context
{
    uint32_t Intermediate_Hash[SHA1HashSize / 4];	/* Message Digest */

    uint32_t Length_Low;		/* Message length in bits */
    uint32_t Length_High;		/* Message length in bits */

    int_least16_t Message_Block_Index;	/* Message_Block array index */
    /* 512-bit message blocks */
    uint8_t Message_Block[SHA1_Message_Block_Size];

    int Computed;			/* Is the digest computed? */
    int Corrupted;		/* Is the digest corrupted? */
} SHA1Context;

/*
 *  This structure will hold context information for the SHA-256
 *  hashing operation.
 */
typedef struct SHA256Context
{
    uint32_t Intermediate_Hash[SHA256HashSize / 4];	/* Message Digest */

    uint32_t Length_Low;		/* Message length in bits */
    uint32_t Length_High;		/* Message length in bits */

    int_least16_t Message_Block_Index;	/* Message_Block array index */
    /* 512-bit message blocks */
    uint8_t Message_Block[SHA256_Message_Block_Size];

    int Computed;			/* Is the digest computed? */
    int Corrupted;		/* Is the digest corrupted? */
} SHA256Context;

/*
 *  This structure will hold context information for the SHA-512
 *  hashing operation.
 */
typedef struct SHA512Context
{
#ifdef USE_32BIT_ONLY
    uint32_t Intermediate_Hash[SHA512HashSize / 4];	/* Message Digest  */
  uint32_t Length[4];		/* Message length in bits */
#else				/* !USE_32BIT_ONLY */
    uint64_t Intermediate_Hash[SHA512HashSize / 8];	/* Message Digest */
    uint64_t Length_Low, Length_High;	/* Message length in bits */
#endif				/* USE_32BIT_ONLY */
    int_least16_t Message_Block_Index;	/* Message_Block array index */
    /* 1024-bit message blocks */
    uint8_t Message_Block[SHA512_Message_Block_Size];

    int Computed;			/* Is the digest computed? */
    int Corrupted;		/* Is the digest corrupted? */
} SHA512Context;

/*
 *  This structure will hold context information for the SHA-224
 *  hashing operation. It uses the SHA-256 structure for computation.
 */
typedef struct SHA256Context SHA224Context;

/*
 *  This structure will hold context information for the SHA-384
 *  hashing operation. It uses the SHA-512 structure for computation.
 */
typedef struct SHA512Context SHA384Context;

/*
 *  This structure holds context information for all SHA
 *  hashing operations.
 */
typedef struct USHAContext
{
    int whichSha;			/* which SHA is being used */
    union
    {
        SHA1Context sha1Context;
        SHA224Context sha224Context;
        SHA256Context sha256Context;
        SHA384Context sha384Context;
        SHA512Context sha512Context;
    } ctx;
} USHAContext;

/*
 *  This structure will hold context information for the HMAC
 *  keyed hashing operation.
 */
typedef struct HMACContext
{
    int whichSha;			/* which SHA is being used */
    int hashSize;			/* hash size of SHA being used */
    int blockSize;		/* block size of SHA being used */
    USHAContext shaContext;	/* SHA context */
    unsigned char k_opad[USHA_Max_Message_Block_Size];
    /* outer padding - key XORd with opad */
} HMACContext;

/*
 *  Function Prototypes
 */

/* SHA-1 */
int SHA1Reset (SHA1Context *);
int SHA1Input (SHA1Context *, const uint8_t * bytes,
               unsigned int bytecount);
int SHA1FinalBits (SHA1Context *, const uint8_t bits,
                   unsigned int bitcount);
int SHA1Result (SHA1Context *, uint8_t Message_Digest[SHA1HashSize]);

/* SHA-224 */
int SHA224Reset (SHA224Context *);
int SHA224Input (SHA224Context *, const uint8_t * bytes,
                 unsigned int bytecount);
int SHA224FinalBits (SHA224Context *, const uint8_t bits,
                     unsigned int bitcount);
int SHA224Result (SHA224Context *,
                  uint8_t Message_Digest[SHA224HashSize]);

/* SHA-256 */
int SHA256Reset (SHA256Context *);
int SHA256Input (SHA256Context *, const uint8_t * bytes,
                 unsigned int bytecount);
int SHA256FinalBits (SHA256Context *, const uint8_t bits,
                     unsigned int bitcount);
int SHA256Result (SHA256Context *,
                  uint8_t Message_Digest[SHA256HashSize]);

/* SHA-384 */
int SHA384Reset (SHA384Context *);
int SHA384Input (SHA384Context *, const uint8_t * bytes,
                 unsigned int bytecount);
int SHA384FinalBits (SHA384Context *, const uint8_t bits,
                     unsigned int bitcount);
int SHA384Result (SHA384Context *,
                  uint8_t Message_Digest[SHA384HashSize]);

/* SHA-512 */
int SHA512Reset (SHA512Context *);
int SHA512Input (SHA512Context *, const uint8_t * bytes,
                 unsigned int bytecount);
int SHA512FinalBits (SHA512Context *, const uint8_t bits,
                     unsigned int bitcount);
int SHA512Result (SHA512Context *,
                  uint8_t Message_Digest[SHA512HashSize]);

/* Unified SHA functions, chosen by whichSha */
int USHAReset (USHAContext *, SHAversion whichSha);
int USHAInput (USHAContext *,
               const uint8_t * bytes, unsigned int bytecount);
int USHAFinalBits (USHAContext *,
                   const uint8_t bits, unsigned int bitcount);
int USHAResult (USHAContext *,
                uint8_t Message_Digest[USHAMaxHashSize]);
int USHABlockSize (enum SHAversion whichSha);
int USHAHashSize (enum SHAversion whichSha);
int USHAHashSizeBits (enum SHAversion whichSha);

/*
 * HMAC Keyed-Hashing for Message Authentication, RFC2104,
 * for all SHAs.
 * This interface allows a fixed-length text input to be used.
 */
int hmac (SHAversion whichSha,	/* which SHA algorithm to use */
          const unsigned char *text,	/* pointer to data stream */
          int text_len,	/* length of data stream */
          const unsigned char *key,	/* pointer to authentication key */
          int key_len,	/* length of authentication key */
          uint8_t digest[USHAMaxHashSize]);	/* caller digest to fill in */

/*
 * HMAC Keyed-Hashing for Message Authentication, RFC2104,
 * for all SHAs.
 * This interface allows any length of text input to be used.
 */
int hmacReset (HMACContext * ctx, enum SHAversion whichSha,
               const unsigned char *key, int key_len);
int hmacInput (HMACContext * ctx, const unsigned char *text,
               int text_len);

int hmacFinalBits (HMACContext * ctx, const uint8_t bits,
                   unsigned int bitcount);
int hmacResult (HMACContext * ctx, uint8_t digest[USHAMaxHashSize]);

// END OF SHA HEADER

/**************************** usha.c ****************************/
/******************** See RFC 4634 for details ******************/
/*
 *  Description:
 *     This file implements a unified interface to the SHA algorithms.
 */

#include "sha.h"

/*
 *  USHAReset
 *
 *  Description:
 *      This function will initialize the SHA Context in preparation
 *      for computing a new SHA message digest.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to reset.
 *      whichSha: [in]
 *          Selects which SHA reset to call
 *
 *  Returns:
 *      sha Error Code.
 *
 */
int
USHAReset (USHAContext * ctx, enum SHAversion whichSha)
{
    if (ctx)
    {
        ctx->whichSha = whichSha;
        switch (whichSha)
        {
            case SHA1:
                return SHA1Reset ((SHA1Context *) & ctx->ctx);
            case SHA224:
                return SHA224Reset ((SHA224Context *) & ctx->ctx);
            case SHA256:
                return SHA256Reset ((SHA256Context *) & ctx->ctx);
            case SHA384:
                return SHA384Reset ((SHA384Context *) & ctx->ctx);
            case SHA512:
                return SHA512Reset ((SHA512Context *) & ctx->ctx);
            default:
                return shaBadParam;
        }
    }
    else
    {
        return shaNull;
    }
}

/*
 *  USHAInput
 *
 *  Description:
 *      This function accepts an array of octets as the next portion
 *      of the message.
 *
 *  Parameters:
 *      context: [in/out]
 *          The SHA context to update
 *      message_array: [in]
 *          An array of characters representing the next portion of
 *          the message.
 *      length: [in]
 *          The length of the message in message_array
 *
 *  Returns:
 *      sha Error Code.
 *
 */
int
USHAInput (USHAContext * ctx, const uint8_t * bytes, unsigned int bytecount)
{
    if (ctx)
    {
        switch (ctx->whichSha)
        {
            case SHA1:
                return SHA1Input ((SHA1Context *) & ctx->ctx, bytes, bytecount);
            case SHA224:
                return SHA224Input ((SHA224Context *) & ctx->ctx, bytes, bytecount);
            case SHA256:
                return SHA256Input ((SHA256Context *) & ctx->ctx, bytes, bytecount);
            case SHA384:
                return SHA384Input ((SHA384Context *) & ctx->ctx, bytes, bytecount);
            case SHA512:
                return SHA512Input ((SHA512Context *) & ctx->ctx, bytes, bytecount);
            default:
                return shaBadParam;
        }
    }
    else
    {
        return shaNull;
    }
}

/*
 * USHAFinalBits
 *
 * Description:
 *   This function will add in any final bits of the message.
 *
 * Parameters:
 *   context: [in/out]
 *     The SHA context to update
 *   message_bits: [in]
 *     The final bits of the message, in the upper portion of the
 *     byte. (Use 0b###00000 instead of 0b00000### to input the
 *     three bits ###.)
 *   length: [in]
 *     The number of bits in message_bits, between 1 and 7.
 *
 * Returns:
 *   sha Error Code.
 */
int
USHAFinalBits (USHAContext * ctx, const uint8_t bits, unsigned int bitcount)
{
    if (ctx)
    {
        switch (ctx->whichSha)
        {
            case SHA1:
                return SHA1FinalBits ((SHA1Context *) & ctx->ctx, bits, bitcount);
            case SHA224:
                return SHA224FinalBits ((SHA224Context *) & ctx->ctx, bits,
                                        bitcount);
            case SHA256:
                return SHA256FinalBits ((SHA256Context *) & ctx->ctx, bits,
                                        bitcount);
            case SHA384:
                return SHA384FinalBits ((SHA384Context *) & ctx->ctx, bits,
                                        bitcount);
            case SHA512:
                return SHA512FinalBits ((SHA512Context *) & ctx->ctx, bits,
                                        bitcount);
            default:
                return shaBadParam;
        }
    }
    else
    {
        return shaNull;
    }
}

/*
 * USHAResult
 *
 * Description:
 *   This function will return the 160-bit message digest into the
 *   Message_Digest array provided by the caller.
 *   NOTE: The first octet of hash is stored in the 0th element,
 *      the last octet of hash in the 19th element.
 *
 * Parameters:
 *   context: [in/out]
 *     The context to use to calculate the SHA-1 hash.
 *   Message_Digest: [out]
 *     Where the digest is returned.
 *
 * Returns:
 *   sha Error Code.
 *
 */
int
USHAResult (USHAContext * ctx, uint8_t Message_Digest[USHAMaxHashSize])
{
    if (ctx)
    {
        switch (ctx->whichSha)
        {
            case SHA1:
                return SHA1Result ((SHA1Context *) & ctx->ctx, Message_Digest);
            case SHA224:
                return SHA224Result ((SHA224Context *) & ctx->ctx, Message_Digest);
            case SHA256:
                return SHA256Result ((SHA256Context *) & ctx->ctx, Message_Digest);
            case SHA384:
                return SHA384Result ((SHA384Context *) & ctx->ctx, Message_Digest);
            case SHA512:
                return SHA512Result ((SHA512Context *) & ctx->ctx, Message_Digest);
            default:
                return shaBadParam;
        }
    }
    else
    {
        return shaNull;
    }
}

/*
 * USHABlockSize
 *
 * Description:
 *   This function will return the blocksize for the given SHA
 *   algorithm.
 *
 * Parameters:
 *   whichSha:
 *     which SHA algorithm to query
 *
 * Returns:
 *   block size
 *
 */
int
USHABlockSize (enum SHAversion whichSha)
{
    switch (whichSha)
    {
        case SHA1:
            return SHA1_Message_Block_Size;
        case SHA224:
            return SHA224_Message_Block_Size;
        case SHA256:
            return SHA256_Message_Block_Size;
        case SHA384:
            return SHA384_Message_Block_Size;
        default:
        case SHA512:
            return SHA512_Message_Block_Size;
    }
}

/*
 * USHAHashSize
 *
 * Description:
 *   This function will return the hashsize for the given SHA
 *   algorithm.
 *
 * Parameters:
 *   whichSha:
 *     which SHA algorithm to query
 *
 * Returns:
 *   hash size
 *
 */
int
USHAHashSize (enum SHAversion whichSha)
{
    switch (whichSha)
    {
        case SHA1:
            return SHA1HashSize;
        case SHA224:
            return SHA224HashSize;
        case SHA256:
            return SHA256HashSize;
        case SHA384:
            return SHA384HashSize;
        default:
        case SHA512:
            return SHA512HashSize;
    }
}

/*
 * USHAHashSizeBits
 *
 * Description:
 *   This function will return the hashsize for the given SHA
 *   algorithm, expressed in bits.
 *
 * Parameters:
 *   whichSha:
 *     which SHA algorithm to query
 *
 * Returns:
 *   hash size in bits
 *
 */
int
USHAHashSizeBits (enum SHAversion whichSha)
{
    switch (whichSha)
    {
        case SHA1:
            return SHA1HashSizeBits;
        case SHA224:
            return SHA224HashSizeBits;
        case SHA256:
            return SHA256HashSizeBits;
        case SHA384:
            return SHA384HashSizeBits;
        default:
        case SHA512:
            return SHA512HashSizeBits;
    }
}


// START OF FUNCTION DECLARATIONS

#include "sha-private.h"

/*************************** sha224-256.c ***************************/
/********************* See RFC 4634 for details *********************/
/*
 * Description:
 *   This file implements the Secure Hash Signature Standard
 *   algorithms as defined in the National Institute of Standards
 *   and Technology Federal Information Processing Standards
 *   Publication (FIPS PUB) 180-1 published on April 17, 1995, 180-2
 *   published on August 1, 2002, and the FIPS PUB 180-2 Change
 *   Notice published on February 28, 2004.
 *
 *   A combined document showing all algorithms is available at
 *       http://csrc.nist.gov/publications/fips/
 *       fips180-2/fips180-2withchangenotice.pdf
 *
 *   The SHA-224 and SHA-256 algorithms produce 224-bit and 256-bit
 *   message digests for a given data stream. It should take about
 *   2**n steps to find a message with the same digest as a given
 *   message and 2**(n/2) to find any two messages with the same
 *   digest, when n is the digest size in bits. Therefore, this
 *   algorithm can serve as a means of providing a
 *   "fingerprint" for a message.
 *
 * Portability Issues:
 *   SHA-224 and SHA-256 are defined in terms of 32-bit "words".
 *   This code uses <stdint.h> (included via "sha.h") to define 32
 *   and 8 bit unsigned integer types. If your C compiler does not
 *   support 32 bit unsigned integers, this code is not
 *   appropriate.
 *
 * Caveats:
 *   SHA-224 and SHA-256 are designed to work with messages less
 *   than 2^64 bits long. This implementation uses SHA224/256Input()
 *   to hash the bits that are a multiple of the size of an 8-bit
 *   character, and then uses SHA224/256FinalBits() to hash the
 *   final few bits of the input.
 */

/* Define the SHA shift, rotate left and rotate right macro */
#define SHA256_SHR(bits,word)      ((word) >> (bits))
#define SHA256_ROTL(bits,word)                         \
  (((word) << (bits)) | ((word) >> (32-(bits))))
#define SHA256_ROTR(bits,word)                         \
  (((word) >> (bits)) | ((word) << (32-(bits))))

/* Define the SHA SIGMA and sigma macros */
#define SHA256_SIGMA0(word)   \
  (SHA256_ROTR( 2,word) ^ SHA256_ROTR(13,word) ^ SHA256_ROTR(22,word))
#define SHA256_SIGMA1(word)   \
  (SHA256_ROTR( 6,word) ^ SHA256_ROTR(11,word) ^ SHA256_ROTR(25,word))
#define SHA256_sigma0(word)   \
  (SHA256_ROTR( 7,word) ^ SHA256_ROTR(18,word) ^ SHA256_SHR( 3,word))
#define SHA256_sigma1(word)   \
  (SHA256_ROTR(17,word) ^ SHA256_ROTR(19,word) ^ SHA256_SHR(10,word))

/*
 * add "length" to the length
 */
static uint32_t addTemp;
#define SHA224_256AddLength(context, length)               \
  (addTemp = (context)->Length_Low, (context)->Corrupted = \
    (((context)->Length_Low += (length)) < addTemp) &&     \
    (++(context)->Length_High == 0) ? 1 : 0)

/* Local Function Prototypes */
static void SHA224_256Finalize (SHA256Context * context, uint8_t Pad_Byte);
static void SHA224_256PadMessage (SHA256Context * context, uint8_t Pad_Byte);
static void SHA224_256ProcessMessageBlock (SHA256Context * context);
static int SHA224_256Reset (SHA256Context * context, uint32_t * H0);
static int SHA224_256ResultN (SHA256Context * context,
                              uint8_t Message_Digest[], int HashSize);

/* Initial Hash Values: FIPS-180-2 Change Notice 1 */
static uint32_t SHA224_H0[SHA256HashSize / 4] = {
        0xC1059ED8, 0x367CD507, 0x3070DD17, 0xF70E5939,
        0xFFC00B31, 0x68581511, 0x64F98FA7, 0xBEFA4FA4
};

/* Initial Hash Values: FIPS-180-2 section 5.3.2 */
static uint32_t SHA256_H0[SHA256HashSize / 4] = {
        0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
        0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19
};

/*
 * SHA256Reset
 *
 * Description:
 *   This function will initialize the SHA256Context in preparation
 *   for computing a new SHA256 message digest.
 *
 * Parameters:
 *   context: [in/out]
 *     The context to reset.
 *
 * Returns:
 *   sha Error Code.
 */
int
SHA256Reset (SHA256Context * context)
{
    return SHA224_256Reset (context, SHA256_H0);
}

/*
 * SHA256Input
 *
 * Description:
 *   This function accepts an array of octets as the next portion
 *   of the message.
 *
 * Parameters:
 *   context: [in/out]
 *     The SHA context to update
 *   message_array: [in]
 *     An array of characters representing the next portion of
 *     the message.
 *   length: [in]
 *     The length of the message in message_array
 *
 * Returns:
 *   sha Error Code.
 */
int
SHA256Input (SHA256Context * context, const uint8_t * message_array,
             unsigned int length)
{
    if (!length)
        return shaSuccess;

    if (!context || !message_array)
        return shaNull;

    if (context->Computed)
    {
        context->Corrupted = shaStateError;
        return shaStateError;
    }

    if (context->Corrupted)
        return context->Corrupted;

    while (length-- && !context->Corrupted)
    {
        context->Message_Block[context->Message_Block_Index++] =
                (*message_array & 0xFF);

        if (!SHA224_256AddLength (context, 8) &&
            (context->Message_Block_Index == SHA256_Message_Block_Size))
            SHA224_256ProcessMessageBlock (context);

        message_array++;
    }

    return shaSuccess;

}

/*
 * SHA256FinalBits
 *
 * Description:
 *   This function will add in any final bits of the message.
 *
 * Parameters:
 *   context: [in/out]
 *     The SHA context to update
 *   message_bits: [in]
 *     The final bits of the message, in the upper portion of the
 *     byte. (Use 0b###00000 instead of 0b00000### to input the
 *     three bits ###.)
 *   length: [in]
 *     The number of bits in message_bits, between 1 and 7.
 *
 * Returns:
 *   sha Error Code.
 */
int
SHA256FinalBits (SHA256Context * context,
                 const uint8_t message_bits, unsigned int length)
{
    uint8_t masks[8] = {
            /* 0 0b00000000 */ 0x00, /* 1 0b10000000 */ 0x80,
            /* 2 0b11000000 */ 0xC0, /* 3 0b11100000 */ 0xE0,
            /* 4 0b11110000 */ 0xF0, /* 5 0b11111000 */ 0xF8,
            /* 6 0b11111100 */ 0xFC, /* 7 0b11111110 */ 0xFE
    };
    uint8_t markbit[8] = {
            /* 0 0b10000000 */ 0x80, /* 1 0b01000000 */ 0x40,
            /* 2 0b00100000 */ 0x20, /* 3 0b00010000 */ 0x10,
            /* 4 0b00001000 */ 0x08, /* 5 0b00000100 */ 0x04,
            /* 6 0b00000010 */ 0x02, /* 7 0b00000001 */ 0x01
    };

    if (!length)
        return shaSuccess;

    if (!context)
        return shaNull;

    if ((context->Computed) || (length >= 8) || (length == 0))
    {
        context->Corrupted = shaStateError;
        return shaStateError;
    }

    if (context->Corrupted)
        return context->Corrupted;

    SHA224_256AddLength (context, length);
    SHA224_256Finalize (context, (uint8_t)
            ((message_bits & masks[length]) | markbit[length]));

    return shaSuccess;
}

/*
 * SHA256Result
 *
 * Description:
 *   This function will return the 256-bit message
 *   digest into the Message_Digest array provided by the caller.
 *   NOTE: The first octet of hash is stored in the 0th element,
 *      the last octet of hash in the 32nd element.
 *
 * Parameters:
 *   context: [in/out]
 *     The context to use to calculate the SHA hash.
 *   Message_Digest: [out]
 *     Where the digest is returned.
 *
 * Returns:
 *   sha Error Code.
 */
int
SHA256Result (SHA256Context * context, uint8_t Message_Digest[])
{
    return SHA224_256ResultN (context, Message_Digest, SHA256HashSize);
}

/*
 * SHA224_256Finalize
 *
 * Description:
 *   This helper function finishes off the digest calculations.
 *
 * Parameters:
 *   context: [in/out]
 *     The SHA context to update
 *   Pad_Byte: [in]
 *     The last byte to add to the digest before the 0-padding
 *     and length. This will contain the last bits of the message
 *     followed by another single bit. If the message was an
 *     exact multiple of 8-bits long, Pad_Byte will be 0x80.
 *
 * Returns:
 *   sha Error Code.
 */
static void
SHA224_256Finalize (SHA256Context * context, uint8_t Pad_Byte)
{
    int i;
    SHA224_256PadMessage (context, Pad_Byte);
    /* message may be sensitive, so clear it out */
    for (i = 0; i < SHA256_Message_Block_Size; ++i)
        context->Message_Block[i] = 0;
    context->Length_Low = 0;	/* and clear length */
    context->Length_High = 0;
    context->Computed = 1;
}

/*
 * SHA224_256PadMessage
 *
 * Description:
 *   According to the standard, the message must be padded to an
 *   even 512 bits. The first padding bit must be a '1'. The
 *   last 64 bits represent the length of the original message.
 *   All bits in between should be 0. This helper function will pad
 *   the message according to those rules by filling the
 *   Message_Block array accordingly. When it returns, it can be
 *   assumed that the message digest has been computed.
 *
 * Parameters:
 *   context: [in/out]
 *     The context to pad
 *   Pad_Byte: [in]
 *     The last byte to add to the digest before the 0-padding
 *     and length. This will contain the last bits of the message
 *     followed by another single bit. If the message was an
 *     exact multiple of 8-bits long, Pad_Byte will be 0x80.
 *
 * Returns:
 *   Nothing.
 */
static void
SHA224_256PadMessage (SHA256Context * context, uint8_t Pad_Byte)
{
    /*
     * Check to see if the current message block is too small to hold
     * the initial padding bits and length. If so, we will pad the
     * block, process it, and then continue padding into a second
     * block.
     */
    if (context->Message_Block_Index >= (SHA256_Message_Block_Size - 8))
    {
        context->Message_Block[context->Message_Block_Index++] = Pad_Byte;
        while (context->Message_Block_Index < SHA256_Message_Block_Size)
            context->Message_Block[context->Message_Block_Index++] = 0;
        SHA224_256ProcessMessageBlock (context);
    }
    else
        context->Message_Block[context->Message_Block_Index++] = Pad_Byte;

    while (context->Message_Block_Index < (SHA256_Message_Block_Size - 8))
        context->Message_Block[context->Message_Block_Index++] = 0;

    /*
     * Store the message length as the last 8 octets
     */
    context->Message_Block[56] = (uint8_t) (context->Length_High >> 24);
    context->Message_Block[57] = (uint8_t) (context->Length_High >> 16);
    context->Message_Block[58] = (uint8_t) (context->Length_High >> 8);
    context->Message_Block[59] = (uint8_t) (context->Length_High);
    context->Message_Block[60] = (uint8_t) (context->Length_Low >> 24);
    context->Message_Block[61] = (uint8_t) (context->Length_Low >> 16);
    context->Message_Block[62] = (uint8_t) (context->Length_Low >> 8);
    context->Message_Block[63] = (uint8_t) (context->Length_Low);

    SHA224_256ProcessMessageBlock (context);
}

/*
 * SHA224_256ProcessMessageBlock
 *
 * Description:
 *   This function will process the next 512 bits of the message
 *   stored in the Message_Block array.
 *
 * Parameters:
 *   context: [in/out]
 *     The SHA context to update
 *
 * Returns:
 *   Nothing.
 *
 * Comments:
 *   Many of the variable names in this code, especially the
 *   single character names, were used because those were the
 *   names used in the publication.
 */
static void
SHA224_256ProcessMessageBlock (SHA256Context * context)
{
    /* Constants defined in FIPS-180-2, section 4.2.2 */
    static const uint32_t K[64] = {
            0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b,
            0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01,
            0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7,
            0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
            0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152,
            0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
            0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
            0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
            0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819,
            0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08,
            0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f,
            0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
            0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    };
    int t, t4;			/* Loop counter */
    uint32_t temp1, temp2;	/* Temporary word value */
    uint32_t W[64];		/* Word sequence */
    uint32_t A, B, C, D, E, F, G, H;	/* Word buffers */

    /*
     * Initialize the first 16 words in the array W
     */
    for (t = t4 = 0; t < 16; t++, t4 += 4)
        W[t] = (((uint32_t) context->Message_Block[t4]) << 24) |
               (((uint32_t) context->Message_Block[t4 + 1]) << 16) |
               (((uint32_t) context->Message_Block[t4 + 2]) << 8) |
               (((uint32_t) context->Message_Block[t4 + 3]));

    for (t = 16; t < 64; t++)
        W[t] = SHA256_sigma1 (W[t - 2]) + W[t - 7] +
               SHA256_sigma0 (W[t - 15]) + W[t - 16];

    A = context->Intermediate_Hash[0];
    B = context->Intermediate_Hash[1];
    C = context->Intermediate_Hash[2];
    D = context->Intermediate_Hash[3];
    E = context->Intermediate_Hash[4];
    F = context->Intermediate_Hash[5];
    G = context->Intermediate_Hash[6];
    H = context->Intermediate_Hash[7];

    for (t = 0; t < 64; t++)
    {
        temp1 = H + SHA256_SIGMA1 (E) + SHA_Ch (E, F, G) + K[t] + W[t];
        temp2 = SHA256_SIGMA0 (A) + SHA_Maj (A, B, C);
        H = G;
        G = F;
        F = E;
        E = D + temp1;
        D = C;
        C = B;
        B = A;
        A = temp1 + temp2;
    }

    context->Intermediate_Hash[0] += A;
    context->Intermediate_Hash[1] += B;
    context->Intermediate_Hash[2] += C;
    context->Intermediate_Hash[3] += D;
    context->Intermediate_Hash[4] += E;
    context->Intermediate_Hash[5] += F;
    context->Intermediate_Hash[6] += G;
    context->Intermediate_Hash[7] += H;

    context->Message_Block_Index = 0;
}

/*
 * SHA224_256Reset
 *
 * Description:
 *   This helper function will initialize the SHA256Context in
 *   preparation for computing a new SHA256 message digest.
 *
 * Parameters:
 *   context: [in/out]
 *     The context to reset.
 *   H0
 *     The initial hash value to use.
 *
 * Returns:
 *   sha Error Code.
 */
static int
SHA224_256Reset (SHA256Context * context, uint32_t * H0)
{
    if (!context)
        return shaNull;

    context->Length_Low = 0;
    context->Length_High = 0;
    context->Message_Block_Index = 0;

    context->Intermediate_Hash[0] = H0[0];
    context->Intermediate_Hash[1] = H0[1];
    context->Intermediate_Hash[2] = H0[2];
    context->Intermediate_Hash[3] = H0[3];
    context->Intermediate_Hash[4] = H0[4];
    context->Intermediate_Hash[5] = H0[5];
    context->Intermediate_Hash[6] = H0[6];
    context->Intermediate_Hash[7] = H0[7];

    context->Computed = 0;
    context->Corrupted = 0;

    return shaSuccess;
}

/*
 * SHA224_256ResultN
 *
 * Description:
 *   This helper function will return the 224-bit or 256-bit message
 *   digest into the Message_Digest array provided by the caller.
 *   NOTE: The first octet of hash is stored in the 0th element,
 *      the last octet of hash in the 28th/32nd element.
 *
 * Parameters:
 *   context: [in/out]
 *     The context to use to calculate the SHA hash.
 *   Message_Digest: [out]
 *     Where the digest is returned.
 *   HashSize: [in]
 *     The size of the hash, either 28 or 32.
 *
 * Returns:
 *   sha Error Code.
 */
static int
SHA224_256ResultN (SHA256Context * context,
                   uint8_t Message_Digest[], int HashSize)
{
    int i;

    if (!context || !Message_Digest)
        return shaNull;

    if (context->Corrupted)
        return context->Corrupted;

    if (!context->Computed)
        SHA224_256Finalize (context, 0x80);

    for (i = 0; i < HashSize; ++i)
        Message_Digest[i] = (uint8_t)
                (context->Intermediate_Hash[i >> 2] >> 8 * (3 - (i & 0x03)));

    return shaSuccess;
}

/**************************** hmac.c ****************************/
/******************** See RFC 4634 for details ******************/
/*
 *  Description:
 *      This file implements the HMAC algorithm (Keyed-Hashing for
 *      Message Authentication, RFC2104), expressed in terms of the
 *      various SHA algorithms.
 */

/*
 *  hmac
 *
 *  Description:
 *      This function will compute an HMAC message digest.
 *
 *  Parameters:
 *      whichSha: [in]
 *          One of SHA1, SHA224, SHA256, SHA384, SHA512
 *      key: [in]
 *          The secret shared key.
 *      key_len: [in]
 *          The length of the secret shared key.
 *      message_array: [in]
 *          An array of characters representing the message.
 *      length: [in]
 *          The length of the message in message_array
 *      digest: [out]
 *          Where the digest is returned.
 *          NOTE: The length of the digest is determined by
 *              the value of whichSha.
 *
 *  Returns:
 *      sha Error Code.
 *
 */
int
hmac (SHAversion whichSha, const unsigned char *text, int text_len,
      const unsigned char *key, int key_len, uint8_t digest[USHAMaxHashSize])
{
    HMACContext ctx;
    return hmacReset (&ctx, whichSha, key, key_len) ||
           hmacInput (&ctx, text, text_len) || hmacResult (&ctx, digest);
}

/*
 *  hmacReset
 *
 *  Description:
 *      This function will initialize the hmacContext in preparation
 *      for computing a new HMAC message digest.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to reset.
 *      whichSha: [in]
 *          One of SHA1, SHA224, SHA256, SHA384, SHA512
 *      key: [in]
 *          The secret shared key.
 *      key_len: [in]
 *          The length of the secret shared key.
 *
 *  Returns:
 *      sha Error Code.
 *
 */
int
hmacReset (HMACContext * ctx, enum SHAversion whichSha,
           const unsigned char *key, int key_len)
{
    int i, blocksize, hashsize;

    /* inner padding - key XORd with ipad */
    unsigned char k_ipad[USHA_Max_Message_Block_Size];

    /* temporary buffer when keylen > blocksize */
    unsigned char tempkey[USHAMaxHashSize];

    if (!ctx)
        return shaNull;

    blocksize = ctx->blockSize = USHABlockSize (whichSha);
    hashsize = ctx->hashSize = USHAHashSize (whichSha);

    ctx->whichSha = whichSha;

    /*
     * If key is longer than the hash blocksize,
     * reset it to key = HASH(key).
     */
    if (key_len > blocksize)
    {
        USHAContext tctx;
        int err = USHAReset (&tctx, whichSha) ||
                  USHAInput (&tctx, key, key_len) || USHAResult (&tctx, tempkey);
        if (err != shaSuccess)
            return err;

        key = tempkey;
        key_len = hashsize;
    }

    /*
     * The HMAC transform looks like:
     *
     * SHA(K XOR opad, SHA(K XOR ipad, text))
     *
     * where K is an n byte key.
     * ipad is the byte 0x36 repeated blocksize times
     * opad is the byte 0x5c repeated blocksize times
     * and text is the data being protected.
     */

    /* store key into the pads, XOR'd with ipad and opad values */
    for (i = 0; i < key_len; i++)
    {
        k_ipad[i] = key[i] ^ 0x36;
        ctx->k_opad[i] = key[i] ^ 0x5c;
    }
    /* remaining pad bytes are '\0' XOR'd with ipad and opad values */
    for (; i < blocksize; i++)
    {
        k_ipad[i] = 0x36;
        ctx->k_opad[i] = 0x5c;
    }

    /* perform inner hash */
    /* init context for 1st pass */
    return USHAReset (&ctx->shaContext, whichSha) ||
           /* and start with inner pad */
           USHAInput (&ctx->shaContext, k_ipad, blocksize);
}

/*
 *  hmacInput
 *
 *  Description:
 *      This function accepts an array of octets as the next portion
 *      of the message.
 *
 *  Parameters:
 *      context: [in/out]
 *          The HMAC context to update
 *      message_array: [in]
 *          An array of characters representing the next portion of
 *          the message.
 *      length: [in]
 *          The length of the message in message_array
 *
 *  Returns:
 *      sha Error Code.
 *
 */
int
hmacInput (HMACContext * ctx, const unsigned char *text, int text_len)
{
    if (!ctx)
        return shaNull;
    /* then text of datagram */
    return USHAInput (&ctx->shaContext, text, text_len);
}

/*
 * HMACFinalBits
 *
 * Description:
 *   This function will add in any final bits of the message.
 *
 * Parameters:
 *   context: [in/out]
 *     The HMAC context to update
 *   message_bits: [in]
 *     The final bits of the message, in the upper portion of the
 *     byte. (Use 0b###00000 instead of 0b00000### to input the
 *     three bits ###.)
 *   length: [in]
 *     The number of bits in message_bits, between 1 and 7.
 *
 * Returns:
 *   sha Error Code.
 */
int
hmacFinalBits (HMACContext * ctx, const uint8_t bits, unsigned int bitcount)
{
    if (!ctx)
        return shaNull;
    /* then final bits of datagram */
    return USHAFinalBits (&ctx->shaContext, bits, bitcount);
}

/*
 * HMACResult
 *
 * Description:
 *   This function will return the N-byte message digest into the
 *   Message_Digest array provided by the caller.
 *   NOTE: The first octet of hash is stored in the 0th element,
 *      the last octet of hash in the Nth element.
 *
 * Parameters:
 *   context: [in/out]
 *     The context to use to calculate the HMAC hash.
 *   digest: [out]
 *     Where the digest is returned.
 *   NOTE 2: The length of the hash is determined by the value of
 *      whichSha that was passed to hmacReset().
 *
 * Returns:
 *   sha Error Code.
 *
 */
int
hmacResult (HMACContext * ctx, uint8_t * digest)
{
    if (!ctx)
        return shaNull;

    /* finish up 1st pass */
    /* (Use digest here as a temporary buffer.) */
    return USHAResult (&ctx->shaContext, digest) ||
           /* perform outer SHA */
           /* init context for 2nd pass */
           USHAReset (&ctx->shaContext, ctx->whichSha) ||
           /* start with outer pad */
           USHAInput (&ctx->shaContext, ctx->k_opad, ctx->blockSize) ||
           /* then results of 1st hash */
           USHAInput (&ctx->shaContext, digest, ctx->hashSize) ||
           /* finish up 2nd pass */
           USHAResult (&ctx->shaContext, digest);
}

#endif /* _SHA_H_ */
