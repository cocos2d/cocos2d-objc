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
 * Some modifications were taken from:
 *      https://www.codeandweb.com/texturepacker/contentprotection
 *
 */
 
#ifndef __CC_ZIP_UTILS_H
#define __CC_ZIP_UTILS_H

#import <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Set the TexturePacker encryption key
 *
 * If your key used to encrypt the pvr.ccz file is
 * aaaaaaaabbbbbbbbccccccccdddddddd
 * you have to call this function 4 times:
 * caw_setkey_part(0, 0xaaaaaaaa);
 * caw_setkey_part(1, 0xbbbbbbbb);
 * caw_setkey_part(2, 0xcccccccc);
 * caw_setkey_part(3, 0xdddddddd);
 *
 * Distribute the call accross some files but make sure
 * to call all of the parts *before* loading the first
 * spritesheet.
 *
 * @param index part of the key [0..3]
 * @param value value of the key part
 */
void caw_setkey_part(int index, uint32_t value);

/* XXX: pragma pack ??? */
/** @struct CCZHeader
 */
struct CCZHeader {
    uint8_t sig[4];                         // signature. Should be 'CCZ!' 4 bytes
    uint16_t compression_type;              // should 0
    uint16_t version;                       // should be 2 (although version type==1 is also supported)
    uint32_t reserved;                      // Reserverd for users.
    uint32_t len;                           // size of the uncompressed file
};

enum {
    CCZ_COMPRESSION_ZLIB,                   // zlib format.
    CCZ_COMPRESSION_BZIP2,                  // bzip2 format (not supported yet)
    CCZ_COMPRESSION_GZIP,                   // gzip format (not supported yet)
    CCZ_COMPRESSION_NONE,                   // plain (not supported yet)
};

/** @file
 * Zip helper functions
 */
 
/**
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * It will allocate 256k for the destination buffer. If it is not enought it will multiply the previous buffer size per 2, until there is enough memory.
 * @returns the length of the deflated buffer
 *
   @since v0.8.1
 */
int ccInflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out);

/**
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * outLengthHint is assumed to be the needed room to allocate the inflated buffer.
 *
 * @returns the length of the deflated buffer
 *
   @since v1.0.0
 */
int ccInflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int outLengthHint );


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
