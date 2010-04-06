/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Stuart Carnie
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <Foundation/Foundation.h>

/*! creates a copy of block with a retain count of 1
 */
#define BLOCK_COPY(block) [block copy]

/*! retains the specified block
 */
#define BLOCK_RETAIN(block) [block retain]

/*! creates a Copy of a Block and adds to the Autorelease pool
 */
#define BCA(block)	[[block copy] autorelease]

// To comply with Apple Objective C runtime (this is defined in NSObjCRuntime.h)
#if !defined(NS_BLOCKS_AVAILABLE)
	#if __BLOCKS__
		#define NS_BLOCKS_AVAILABLE 1
	#else
		#define NS_BLOCKS_AVAILABLE 0
	#endif
#endif

#if NS_BLOCKS_AVAILABLE

@interface NSObject(CCBlocksAdditions)

- (void)ccCallbackBlock;
- (void)ccCallbackBlockWithSender:(id)sender;

@end

#endif
