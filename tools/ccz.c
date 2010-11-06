/*
Copyright (c) 2010 Andreas Loew / code-and-web.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, including without 
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <zlib.h>
#include <architecture/byte_order.h>


// Format header
struct CCZHeader {
    uint8_t			sig[4];				// signature. Should be 'CCZ!' 4 bytes
    uint16_t		compression_type;	// should 0 (See below for supported formats)
    uint16_t		version;			// should be 2 
    uint32_t		reserved;			// Reserverd for users.
    uint32_t		len;				// size of the uncompressed file
};


enum {
    CCZ_COMPRESSION_ZLIB,				// zlib format.
    CCZ_COMPRESSION_BZIP2,				// bzip2 format (not supported yet)
    CCZ_COMPRESSION_GZIP,				// gzip format (not supported yet)
};


int main (int argc, const char * argv[]) 
{
    /* arg check */
    if(argc != 2)
    {
        printf("\nUSAGE: ccz <infile>\n");
        printf("\nA new file called <infile>.ccz will be generated\n\n");
        exit(10);
    }
    
    /* open file to read */
    FILE *in = fopen(argv[1], "rb");
    if(!in)
    {
        printf("Failed to open %s for reading\n", argv[1]);
        exit(10);
    }
    
    /* determine length */
    fseek(in, 0, SEEK_END);
    long len = ftell(in);
    fseek(in, 0, SEEK_SET);

    
    /* alloc memory for the input file */
    unsigned char *data = malloc(len);

    struct CCZHeader *header;

    /* allocate output memory for the compressed block */
    uLongf destLen = compressBound(len)+sizeof(*header);
    unsigned char *compressed = malloc(destLen);
    if(!data || !compressed)
    {
        printf("Out of memory\n");
        exit(10);
    }
    
    /* read data */
    if(fread(data, 1, len, in) != len)
    {
        printf("Failed to read data\n");        
        exit(10);
    }
    fclose(in);
        

    /* compress the data */
    if(compress2(compressed+sizeof(*header), &destLen, data, len, Z_DEFAULT_COMPRESSION) != Z_OK)
    {
        printf("Failed to compress the data\n");
        exit(10);
    }

    header = (struct CCZHeader*) compressed;
    header->sig[0] = 'C';
    header->sig[1] = 'C';
    header->sig[2] = 'Z';
    header->sig[3] = '!';
    
    header->len = OSSwapHostToBigInt32(len);
    header->version = OSSwapHostToBigInt16(2);
    header->compression_type = OSSwapHostToBigInt16(CCZ_COMPRESSION_ZLIB);
    
    /* write data */
    char dstname[1024];
    snprintf(&dstname[0], sizeof(dstname)-1, "%s.ccz", argv[1]);
    FILE *out = fopen(&dstname[0], "wb");
    if(!out)
    {
        printf("Failed to open %s for writing.\n", dstname);
        exit(10);
    }
    if( fwrite(compressed, 1, destLen + sizeof(*header), out) != destLen+sizeof(*header) )
    {
        printf("Failed to write data.\n");
        exit(10);
    }
    fclose(out);

    return 0;
}
