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

#pragma mark -
#pragma mark TouchHandler
@implementation TouchHandler

@synthesize delegate, priority;

+ (id)handlerWithDelegate:(id) aDelegate
{
	return [[[self alloc] initWithDelegate:aDelegate] autorelease];
}

- (id)initWithDelegate:(id) aDelegate
{
	if ((self = [super init])) {
		delegate = aDelegate;
	}
	
	return self;
}

- (void)dealloc {
	[super dealloc];
}

@end

#pragma mark -
#pragma mark StandardTouchHandler
@implementation StandardTouchHandler
@end

#pragma mark -
#pragma mark TargetedTouchHandler
@implementation TargetedTouchHandler

@synthesize swallowsTouches, claimedTouches;

- (id)initWithDelegate:(id) aDelegate
{
	if ((self = [super init])) {	
		claimedTouches = [[NSMutableSet alloc] initWithCapacity:2];
	}
	
	return self;
}

- (void)dealloc {
	[claimedTouches release];
	[super dealloc];
}

@end
