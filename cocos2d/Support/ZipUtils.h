/*
 * _inflateMemory and inflateMemory functions were taken from:
 * http://themanaworld.org/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#ifndef ZIP_UTILS_H
#define ZIP_UTILS_H

/** @file
 * Zip helper functions
 */

/** 
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * @returns the length of the out buffer
 *
 @since v0.8.1
 */
int inflateMemory(unsigned char *in, unsigned int inLength, unsigned char **out);


#endif // ZIP_UTILS_H
