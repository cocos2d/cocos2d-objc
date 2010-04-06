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

#import "CCBlockSupport.h"

#if NS_BLOCKS_AVAILABLE

@implementation NSObject(CCBlocksAdditions)

- (void)ccCallbackBlock {
	void (^block)(void) = (id)self;
	block();
}

- (void)ccCallbackBlockWithSender:(id)sender {
	void (^block)(id) = (id)self;
	block(sender);
}


@end

#endif
