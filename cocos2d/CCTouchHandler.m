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

#import "CCTouchHandler.h"
#import "ccMacros.h"

#pragma mark -
#pragma mark TouchHandler
@implementation CCTouchHandler

@synthesize delegate, priority;

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
	}
	
	return self;
}

- (void)dealloc {
	CCLOG(@"cocos2d: deallocing %@", self);
	[delegate release];
	[super dealloc];
}

- (BOOL)ccTouchesBegan:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
- (BOOL)ccTouchesMoved:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
- (BOOL)ccTouchesEnded:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
- (BOOL)ccTouchesCancelled:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(NO, @"override");
	return YES;
}
@end

#pragma mark -
#pragma mark StandardTouchHandler
@implementation CCStandardTouchHandler
- (BOOL)ccTouchesBegan:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesBegan:withEvent:)] )
		return [delegate ccTouchesBegan:touches withEvent:event];
	return kEventIgnored;
}
- (BOOL)ccTouchesMoved:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesMoved:withEvent:)] )
		return [delegate ccTouchesMoved:touches withEvent:event];
	return kEventIgnored;
}
- (BOOL)ccTouchesEnded:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesEnded:withEvent:)] )
		return [delegate ccTouchesEnded:touches withEvent:event];
	return kEventIgnored;
}
- (BOOL)ccTouchesCancelled:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	if( [delegate respondsToSelector:@selector(ccTouchesCancelled:withEvent:)] )
		return [delegate ccTouchesCancelled:touches withEvent:event];
	return kEventIgnored;
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
	}
	
	return self;
}

- (void)dealloc {
	[claimedTouches release];
	[super dealloc];
}

- (BOOL)ccTouchesBegan:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	NSMutableSet *copyTouches = [touches copy];
	for( UITouch *touch in copyTouches) {
		BOOL touchWasClaimed = [delegate ccTouchBegan:touch withEvent:event];
		
		if( touchWasClaimed ) {
			[claimedTouches addObject:touch];
			
			if( swallowsTouches )
				[touches removeObject:touch];
		}
	}
	[copyTouches release];
	return kEventIgnored;
}
- (BOOL)ccTouchesMoved:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchMoved:withEvent:) unclaim:NO];
	return kEventIgnored;

}
- (BOOL)ccTouchesEnded:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchEnded:withEvent:) unclaim:YES];
	return kEventIgnored;

}
- (BOOL)ccTouchesCancelled:(NSMutableSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchCancelled:withEvent:) unclaim:YES];
	return kEventIgnored;
}

-(void) updateKnownTouches:(NSMutableSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim
{	
	NSMutableSet *copyTouches = [touches copy];
	for( UITouch *touch in copyTouches) {
		if( [claimedTouches containsObject:touch] ) {
			
			if( [delegate respondsToSelector:selector] )
				[delegate performSelector:selector withObject:touch withObject:event];
			
			if( doUnclaim )
				[claimedTouches removeObject:touch];
			
			if( swallowsTouches )
				[touches removeObject:touch];
		}
	}
	[copyTouches release];
}
@end
