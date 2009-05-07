/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "TouchHandler.h"

@implementation TouchHandler

@synthesize delegate, priority, swallowsTouches, claimedTouches;

+ (id)handlerWithDelegate:(id<TargetedTouchDelegate>) aDelegate
{
	return [[[self alloc] initWithDelegate:aDelegate] autorelease];
}

- (id)initWithDelegate:(id<TargetedTouchDelegate>) aDelegate
{
	if ((self = [super init]) == nil)
		return nil;
	
	delegate = aDelegate;
	claimedTouches = [[NSMutableSet alloc] initWithCapacity:2];
	
	return self;
}

- (void)dealloc {
	[claimedTouches release];
	[super dealloc];
}

@end
