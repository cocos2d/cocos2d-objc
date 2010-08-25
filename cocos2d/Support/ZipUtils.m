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
 */

#import <Availability.h>

#import <zlib.h>
#import <stdlib.h>
#import <assert.h>
#import <stdio.h>

#import "ZipUtils.h"
#import "../ccMacros.h"

int inflateMemory_(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int *outLength)
{
#if 1
	/* ret value */
	int err = Z_OK;
	
	/* 256k initial decompress buffer */
	int bufferSize = 256 * 1024;
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
	
    for (;;) {
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
			
			// memory in iPhone is precious
			// Should buffer factor be 1.5 instead of 2 ?
#define BUFFER_INC_FACTOR (2)
			unsigned char *tmp = realloc(*out, bufferSize * BUFFER_INC_FACTOR);
			
			/* not enough memory, ouch */
			if (! tmp ) {
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
#else
	return 0;
#endif
}

int inflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out)
{
#if 1
	unsigned int outLength = 0;
	int err = inflateMemory_(in, inLength, out, &outLength);
	
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
#else
	return 0;
#endif
}
