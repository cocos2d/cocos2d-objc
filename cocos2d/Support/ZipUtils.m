/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 *
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * inflateMemory_ based on zlib example code
 *		http://www.zlib.net
 *
 * Some ideas were taken from:
 *		http://themanaworld.org/
 *		from the mapreader.cpp file
 *
 * Some modifications were taken from:
 *      https://www.codeandweb.com/texturepacker/contentprotection
 *
 */
 
#import <zlib.h>
#import <stdlib.h>
#import <assert.h>
#import <stdio.h>

#import "ZipUtils.h"
#import "CCFileUtils.h"
#import "../ccMacros.h"

// memory in iPhone is precious
// Should buffer factor be 1.5 instead of 2 ?
#define BUFFER_INC_FACTOR (2)

static int inflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int *outLength, unsigned int outLengthHint )
{
    /* ret value */
    int err = Z_OK;
    
    int bufferSize = outLengthHint;
    *out = (unsigned char*) malloc(bufferSize);
    
    z_stream d_stream; /* decompression stream */
    d_stream.zalloc = (alloc_func)0;
    d_stream.zfree = (free_func)0;
    d_stream.opaque = (voidpf)0;
    
    d_stream.next_in  = in;
    d_stream.avail_in = inLength;
    d_stream.next_out = *out;
    d_stream.avail_out = bufferSize;
    
    /* window size to hold 256k */
    if( (err = inflateInit2(&d_stream, 15 + 32)) != Z_OK )
        return err;
        
    for (;; ) {
        err = inflate(&d_stream, Z_NO_FLUSH);
        
        if (err == Z_STREAM_END)
            break;
            
        switch (err) {
        case Z_NEED_DICT:
            err = Z_DATA_ERROR;
        case Z_DATA_ERROR:
        case Z_MEM_ERROR:
            inflateEnd(&d_stream);
            return err;
        }
        
        // not enough memory ?
        if (err != Z_STREAM_END) {
        
            unsigned char *tmp = realloc(*out, bufferSize * BUFFER_INC_FACTOR);
            
            /* not enough memory, ouch */
            if (!tmp ) {
                CCLOG(@"cocos2d: ZipUtils: realloc failed");
                inflateEnd(&d_stream);
                return Z_MEM_ERROR;
            }
            /* only assign to *out if tmp is valid. it's not guaranteed that realloc will reuse the memory */
            *out = tmp;
            
            d_stream.next_out = *out + bufferSize;
            d_stream.avail_out = bufferSize;
            bufferSize *= BUFFER_INC_FACTOR;
        }
    }
    
    
    *outLength = bufferSize - d_stream.avail_out;
    err = inflateEnd(&d_stream);
    return err;
}

int ccInflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int outLengthHint )
{
    unsigned int outLength = 0;
    int err = inflateMemoryWithHint(in, inLength, out, &outLength, outLengthHint );
    
    if (err != Z_OK || *out == NULL) {
        if (err == Z_MEM_ERROR)
            CCLOG(@"cocos2d: ZipUtils: Out of memory while decompressing map data!");
            
        else if (err == Z_VERSION_ERROR)
            CCLOG(@"cocos2d: ZipUtils: Incompatible zlib version!");
            
        else if (err == Z_DATA_ERROR)
            CCLOG(@"cocos2d: ZipUtils: Incorrect zlib compressed data!");
            
        else
            CCLOG(@"cocos2d: ZipUtils: Unknown error while decompressing map data!");
            
        free(*out);
        *out = NULL;
        outLength = 0;
    }
    
    return outLength;
}

int ccInflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out)
{
    // 256k for hint
    return ccInflateMemoryWithHint(in, inLength, out, 256 * 1024 );
}

int ccInflateGZipFile(const char *path, unsigned char **out)
{
    int len;
    unsigned int offset = 0;
    
    NSCAssert( out, @"ccInflateGZipFile: invalid 'out' parameter");
    NSCAssert( &*out, @"ccInflateGZipFile: invalid 'out' parameter");
    
    gzFile inFile = gzopen(path, "rb");
    if( inFile == NULL ) {
        CCLOG(@"cocos2d: ZipUtils: error open gzip file: %s", path);
        return -1;
    }
    
    /* 512k initial decompress buffer */
    int bufferSize = 512 * 1024;
    unsigned int totalBufferSize = bufferSize;
    
    *out = malloc( bufferSize );
    if( !out ) {
        CCLOG(@"cocos2d: ZipUtils: out of memory");
        return -1;
    }
    
    for (;; ) {
        len = gzread(inFile, *out + offset, bufferSize);
        if (len < 0) {
            CCLOG(@"cocos2d: ZipUtils: error in gzread");
            free( *out );
            *out = NULL;
            return -1;
        }
        if (len == 0)
            break;
            
        offset += len;
        
        // finish reading the file
        if( len < bufferSize )
            break;
            
        bufferSize *= BUFFER_INC_FACTOR;
        totalBufferSize += bufferSize;
        unsigned char *tmp = realloc(*out, totalBufferSize );
        
        if( !tmp ) {
            CCLOG(@"cocos2d: ZipUtils: out of memory");
            free( *out );
            *out = NULL;
            return -1;
        }
        
        *out = tmp;
    }
    
    if (gzclose(inFile) != Z_OK)
        CCLOG(@"cocos2d: ZipUtils: gzclose failed");
        
    return offset;
}

typedef struct {
    uint8_t sig[4];                     // signature. Should be 'CCZp' 4 bytes
    uint16_t compression_type;          // should 0
    uint16_t version;                   // should be 2 (although version type==1 is also supported)
    uint32_t checksum;                  // Checksum
    uint32_t len;                       // size of the uncompressed file
} CCPHeader;

// TexturePacker Content Protection Part
static uint32_t caw_key[4] = {0,0,0,0};
static uint32_t caw_longKey[1024];
static bool caw_longKeyValid=false;

/**
 *    TexturePacker Set Encryption Key (Partly)
 *
 *    @param index
 *    @param value
 */
void caw_setkey_part(int index, uint32_t value)
{
    assert(index >= 0);
    assert(index < 4);
    if(caw_key[index] != value)
    {
        caw_key[index] = value;
        caw_longKeyValid = false;
    }
}

/**
 *    TexturePacker Encoding Data
 *
 *    @param data
 *    @param len
 */
static inline void caw_encdec (uint32_t *data, int len)
{
    const int enclen = 1024;
    const int securelen = 512;
    const int distance = 64;
    
    // check if key was set
    // make sure to call caw_setkey_part() for all 4 key parts
    assert(caw_key[0] != 0);
    assert(caw_key[1] != 0);
    assert(caw_key[2] != 0);
    assert(caw_key[3] != 0);
    
    // create long key
    if(!caw_longKeyValid)
    {
        uint32_t y;
        unsigned int p, rounds=6, e;
        
        uint32_t sum = 0;
        uint32_t z = caw_longKey[enclen-1];
        do
        {
            #define DELTA 0x9e3779b9
            #define MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (caw_key[(p&3)^e] ^ z)))
            
            sum += DELTA;
            e = (sum >> 2) & 3;
            for (p=0; p<enclen-1; p++)
            {
                y = caw_longKey[p+1];
                z = caw_longKey[p] += MX;
            }
            y = caw_longKey[0];
            z = caw_longKey[enclen-1] += MX;
        } while (--rounds);
        
        caw_longKeyValid = true;
    }
    
    int b=0;
    int i=0;
    
    // encrypt first part completely
    for(; i<len && i<securelen; i++)
    {
        data[i] ^= caw_longKey[b++];
        if(b >= enclen)
        {
            b=0;
        }
    }
    
    // encrypt second section partially
    for(; i<len; i+=distance)
    {
        data[i] ^= caw_longKey[b++];
        if(b >= enclen)
        {
            b=0;
        }
    }
}

/**
 *    TexturePacker Checksum For Data
 *
 *    @param data
 *    @param len
 *
 *    @return checksum
 */
static inline uint32_t caw_checksum(const uint32_t *data, int len)
{
    uint32_t cs=0;
    const int cslen=128;
    len = (len < cslen) ? len : cslen;
    for(int i=0; i<len; i++)
    {
        cs = cs ^ data[i];
    }
    return cs;
}


int ccInflateCCZFile(const char *path, unsigned char **out)
{
    printf("inflating: %s\n", path);
    
    NSCAssert( out, @"ccInflateCCZFile: invalid 'out' parameter");
    NSCAssert( &*out, @"ccInflateCCZFile: invalid 'out' parameter");
    
    // load file into memory
    unsigned char *compressed = NULL;
    NSInteger fileLen  = ccLoadFileIntoMemory( path, &compressed );
    if( fileLen < 0 ) {
        CCLOG(@"cocos2d: Error loading CCZ compressed file");
        return -1;
    }
    
    uint32_t len = 0;
    uint32_t headerSize = 0;
    
    if( compressed[0] == 'C' && compressed[1] == 'C' && compressed[2] == 'Z' && compressed[3] == '!' )
    {
        // standard ccz file
        struct CCZHeader *header = (struct CCZHeader*) compressed;
        
        // verify header version
        uint16_t version = CFSwapInt16BigToHost( header->version );
        if( version > 2 ) {
            CCLOG(@"cocos2d: Unsupported CCZ header format");
            free(compressed);
            return -1;
        }
        
        // verify compression format
        if( CFSwapInt16BigToHost(header->compression_type) != CCZ_COMPRESSION_ZLIB ) {
            CCLOG(@"cocos2d: CCZ Unsupported compression method");
            free(compressed);
            return -1;
        }
        
        len = CFSwapInt32BigToHost( header->len );
        
        headerSize = sizeof(struct CCZHeader);
    }
    else if(compressed[0] == 'C' && compressed[1] == 'C' && compressed[2] == 'Z' && compressed[3] == 'p' )
    {
        // encrypted ccz file
        CCPHeader *header = (CCPHeader*) compressed;
        
        // verify header version
        uint16_t version = CFSwapInt16BigToHost( header->version );
        if( version > 0 ) {
            CCLOG(@"cocos2d: Unsupported CCZ header format");
            free(compressed);
            return -1;
        }
        
        // verify compression format
        if( CFSwapInt16BigToHost(header->compression_type) != 0 ) {
            CCLOG(@"cocos2d: CCZ Unsupported compression method");
            free(compressed);
            return -1;
        }
        
        // decrypt
        headerSize = sizeof(CCPHeader);
        uint32_t* ints = (uint32_t*)(compressed+12);
        int enclen = (fileLen-12)/4;
        
        caw_encdec(ints, enclen);
        
        len = CFSwapInt32BigToHost( header->len );
        
#ifndef NDEBUG
        // verify checksum in debug mode
        uint32_t calculated = caw_checksum(ints, enclen);
        uint32_t required = CFSwapInt32BigToHost( header->checksum );
        if(calculated != required)
        {
            CCLOG(@"cocos2d: Can't decrypt image file: Invalid decryption key");
            free(compressed);
            return -1;
        }
#endif
    }
    else {
        CCLOG(@"cocos2d: Invalid CCZ file");
        free(compressed);
        return -1;
    }
    
    
    *out = malloc( len );
    if(!*out )
    {
        CCLOG(@"cocos2d: CCZ: Failed to allocate memory for texture");
        free(compressed);
        return -1;
    }
    
    
    uLongf destlen = len;
    uLongf source = (uLongf) compressed + headerSize;
    int ret = uncompress(*out, &destlen, (Bytef*)source, fileLen - headerSize );
    
    free( compressed );
    
    if( ret != Z_OK )
    {
        CCLOG(@"cocos2d: CCZ: Failed to uncompress data");
        free( *out );
        *out = NULL;
        return -1;
    }
    
    
    return len;
}
