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
#import "CCFileUtils.h"
#import "../ccMacros.h"

// memory in iPhone is precious
// Should buffer factor be 1.5 instead of 2 ?
#define BUFFER_INC_FACTOR (2)

static int inflateMemory_(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int *outLength)
{
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
}

int ccInflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out)
{
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
}

int ccInflateGZipFile(const char *path, unsigned char **out)
{
	int len;
	unsigned int offset = 0;
	
	assert( out );
	assert( &*out );

	gzFile inFile = gzopen(path, "rb");
	if( inFile == NULL ) {
		CCLOG(@"cocos2d: ZipUtils: error open gzip file: %s", path);
		return -1;
	}
	
	/* 512k initial decompress buffer */
	unsigned int bufferSize = 512 * 1024;
	unsigned int totalBufferSize = bufferSize;
	
	*out = malloc( bufferSize );
	if( ! out ) {
		CCLOG(@"cocos2d: ZipUtils: out of memory");
		return -1;
	}
		
	for (;;) {
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

		if( ! tmp ) {
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

int ccInflateCCZFile(const char *path, unsigned char **out)
{
	assert( out );
	assert( &*out );

	// load file into memory
	unsigned char *compressed = NULL;
	NSInteger fileLen  = ccLoadFileIntoMemory( path, &compressed );
	if( fileLen < 0 ) {
		CCLOG(@"cocos2d: Error loading CCZ compressed file");
	}
	
	struct CCZHeader *header = (struct CCZHeader*) compressed;

	// verify header
	if( header->sig[0] != 'C' || header->sig[1] != 'C' || header->sig[2] != 'Z' || header->sig[3] != '!' ) {
		CCLOG(@"cocos2d: Invalid CCZ file");
		free(compressed);
		return -1;
	}
	
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
	
	uint32_t len = CFSwapInt32BigToHost( header->len );
	
	*out = malloc( len );
	if(! *out )
	{
		CCLOG(@"cocos2d: CCZ: Failed to allocate memory for texture");
		free(compressed);
		return -1;
	}
	
	
	uLongf destlen = len;
	uLongf source = (uLongf) compressed + sizeof(*header);
	int ret = uncompress(*out, &destlen, (Bytef*)source, fileLen - sizeof(*header) );

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