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
#import "ccMacros.h"

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
	CCLOG(@"deallocing %@", self);
	[super dealloc];
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
@end

#pragma mark -
#pragma mark StandardTouchHandler
@implementation StandardTouchHandler
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesBegan:withEvent:)] )
		return [delegate ccTouchesBegan:touches withEvent:event];
	return kEventIgnored;
}
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesMoved:withEvent:)] )
		return [delegate ccTouchesMoved:touches withEvent:event];
	return kEventIgnored;
}
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesEnded:withEvent:)] )
		return [delegate ccTouchesEnded:touches withEvent:event];
	return kEventIgnored;
}
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesCancelled:withEvent:)] )
		return [delegate ccTouchesCancelled:touches withEvent:event];
	return kEventIgnored;
}
@end

#pragma mark -
#pragma mark TargetedTouchHandler

@interface TargetedTouchHandler (private)
-(void) updateKnownTouches:(NSSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim;
@end

@implementation TargetedTouchHandler

@synthesize swallowsTouches, claimedTouches;

- (id)initWithDelegate:(id) aDelegate
{
	if ((self = [super initWithDelegate:aDelegate])) {	
		claimedTouches = [[NSMutableSet alloc] initWithCapacity:2];
	}
	
	return self;
}

- (void)dealloc {
	[claimedTouches release];
	[super dealloc];
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches) {
		BOOL touchWasClaimed = [delegate ccTouchBegan:touch withEvent:event];
		
		if( touchWasClaimed ) {
			[claimedTouches addObject:touch];
			
			if( swallowsTouches )
				break;
		}
	}
	return kEventIgnored;
}
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchMoved:withEvent:) unclaim:NO];
	return kEventIgnored;
}
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchEnded:withEvent:) unclaim:YES];
	return kEventIgnored;
}
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchCancelled:withEvent:) unclaim:YES];
	return kEventIgnored;
}

-(void) updateKnownTouches:(NSSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim
{	
	for( UITouch *touch in touches) {
		if( [claimedTouches containsObject:touch] ) {
			
			if( [delegate respondsToSelector:selector] )
				[delegate performSelector:selector withObject:touch withObject:event];
			
			if( doUnclaim )
				[claimedTouches removeObject:touch];
			
			if( swallowsTouches )
				break;
		}
	}
}
@end
