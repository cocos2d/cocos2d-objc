/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 */

#ifndef __CC_UTILS_H
#define __CC_UTILS_H

/** @file ccUtils.h
 Misc free functions
 */

/*
 ccNextPOT function is licensed under the same license that is used in CCTexture2D.m.
 */

/** returns the Next Power of Two value.
 
 Examples:
	- If "value" is 15, it will return 16.
	- If "value" is 16, it will return 16.
	- If "value" is 17, it will return 32.
 
 @since v0.99.5
 */

unsigned int ccNextPOT( unsigned int value );

#endif // ! __CC_UTILS_H
