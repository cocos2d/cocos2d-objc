/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 *
 * inflateMemory_ based on zlib example code
 *		http://www.zlib.net
 *
 * Some ideas were taken from:
 *		http://themanaworld.org/
 *		from the mapreader.cpp file 
 *
 */

#ifndef __CC_ZIP_UTILS_H
#define __CC_ZIP_UTILS_H

#ifdef __cplusplus
extern "C" {
#endif	
	
	/* XXX: pragma pack ??? */
	/** @struct CCZHeader
	 */
	struct CCZHeader {
		char			sig[4];				// signature. Should be 'CCZ!' 4 bytes
		unsigned int	version;			// should be 1
		unsigned int	compression_type;	// should be 0
		unsigned int	len;				// size of the uncompressed file
	};
	
/** @file
 * Zip helper functions
 */

/** 
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * @returns the length of the deflated buffer
 *
 @since v0.8.1
 */
int ccInflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out);

	
/** inflates a GZip file into memory
 *
 * @returns the length of the deflated buffer
 *
 * @since v0.99.5
 */
int ccInflateGZipFile(const char *filename, unsigned char **out);

/** inflates a CCZ file into memory
 *
 * @returns the length of the deflated buffer
 *
 * @since v0.99.5
 */
int ccInflateCCZFile(const char *filename, unsigned char **out);
	

#ifdef __cplusplus
}
#endif	
		
#endif // __CC_ZIP_UTILS_H
