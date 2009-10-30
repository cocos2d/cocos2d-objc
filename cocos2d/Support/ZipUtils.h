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
int inflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out);


#ifdef __cplusplus
}
#endif	
		
#endif // __CC_ZIP_UTILS_H
