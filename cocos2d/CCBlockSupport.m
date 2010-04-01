//
//  CCBlockSupport.m
//  cocos2d-iphone
//
//  Created by Stuart Carnie on 1/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
