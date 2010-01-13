/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

/*
 * This file contains the delegates of the touches
 * There are 2 possible delegates:
 *   - CCStandardTouchHandler: propagates all the events at once
 *   - CCTargetedTouchHandler: propagates 1 event at the time
 */

#import "CCTouchHandler.h"
#import "ccMacros.h"

#pragma mark -
#pragma mark TouchHandler
@implementation CCTouchHandler

@synthesize delegate, priority;
@synthesize enabledSelectors=enabledSelectors_;

+ (id)handlerWithDelegate:(id) aDelegate priority:(int)aPriority
{
	return [[[self alloc] initWithDelegate:aDelegate priority:aPriority] autorelease];
}

- (id)initWithDelegate:(id) aDelegate priority:(int)aPriority
{
	NSAssert(aDelegate != nil, @"Touch delegate may not be nil");
	
	if ((self = [super init])) {
		self.delegate = aDelegate;
		priority = aPriority;
		enabledSelectors_ = 0;
	}
	
	return self;
}

- (void)dealloc {
	CCLOG(@"cocos2d: deallocing %@", self);
	[delegate release];
	[super dealloc];
}
@end

#pragma mark -
#pragma mark StandardTouchHandler
@implementation CCStandardTouchHandler
-(id) initWithDelegate:(id)del priority:(int)pri
{
	if( (self=[super initWithDelegate:del priority:pri]) ) {
		if( [del respondsToSelector:@selector(ccTouchesBegan:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorBeganBit;
		if( [del respondsToSelector:@selector(ccTouchesMoved:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorMovedBit;
		if( [del respondsToSelector:@selector(ccTouchesEnded:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorEndedBit;
		if( [del respondsToSelector:@selector(ccTouchesCancelled:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorCancelledBit;
	}
	return self;
}
@end

#pragma mark -
#pragma mark TargetedTouchHandler

@interface CCTargetedTouchHandler (private)
-(void) updateKnownTouches:(NSMutableSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim;
@end

@implementation CCTargetedTouchHandler

@synthesize swallowsTouches, claimedTouches;

+ (id)handlerWithDelegate:(id)aDelegate priority:(int)priority swallowsTouches:(BOOL)swallow
{
	return [[[self alloc] initWithDelegate:aDelegate priority:priority swallowsTouches:swallow] autorelease];
}

- (id)initWithDelegate:(id)aDelegate priority:(int)aPriority swallowsTouches:(BOOL)swallow
{
	if ((self = [super initWithDelegate:aDelegate priority:aPriority])) {	
		claimedTouches = [[NSMutableSet alloc] initWithCapacity:2];
		swallowsTouches = swallow;
		
		if( [aDelegate respondsToSelector:@selector(ccTouchBegan:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorBeganBit;
		if( [aDelegate respondsToSelector:@selector(ccTouchMoved:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorMovedBit;
		if( [aDelegate respondsToSelector:@selector(ccTouchEnded:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorEndedBit;
		if( [aDelegate respondsToSelector:@selector(ccTouchCancelled:withEvent:)] )
			enabledSelectors_ |= ccTouchSelectorCancelledBit;
	}
	
	return self;
}

- (void)dealloc {
	[claimedTouches release];
	[super dealloc];
}
@end
