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

#import "TouchDispatcher.h"
#import "TouchHandler.h"
#import "Director.h"

@interface TouchDispatcher (private)
-(BOOL) targetedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withHandler:(TargetedTouchHandler*)handler;
-(void) updateKnownTouches:(NSSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim handler:(TargetedTouchHandler*)handler;
@end

@implementation TouchDispatcher

@synthesize dispatchEvents;

static TouchDispatcher *sharedDispatcher = nil;

+(TouchDispatcher*) sharedDispatcher
{
	@synchronized(self) {
		if (sharedDispatcher == nil)
			[[self alloc] init]; // assignment not done here
	}
	return sharedDispatcher;
}

+(id) allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedDispatcher == nil) {
			sharedDispatcher = [super allocWithZone:zone];
			return sharedDispatcher;  // assignment and return on first allocation
		}
	}
	return nil; // on subsequent allocation attempts return nil
}

-(id) copyWithZone:(NSZone *)zone { return self; }
-(id) retain { return self; }
-(unsigned) retainCount { return UINT_MAX; } 
-(void) release { }
-(id) autorelease { return self; }

-(id) init
{
	if((self = [super init])) {
	
		dispatchEvents = YES;
		touchHandlers = [[NSMutableArray alloc] initWithCapacity:8];
	}
	
	return self;
}

-(void) dealloc
{
	[touchHandlers release];
	[super dealloc];
}

//
// handlers management
//

// private helper
-(void) insertHandler:(TouchHandler *)handler
{
	NSUInteger i = 0;
	for( TouchHandler *h in touchHandlers ) {
		if( h.priority >= handler.priority )
			break;
		i++;
	}
	[touchHandlers insertObject:handler atIndex:i];
}

#pragma mark add event handlers
-(void) addStandardEventHandler:(id<StandardTouchDelegate>) delegate
{
	[self addStandardEventHandler:delegate priority:0];
}

-(void) addStandardEventHandler:(id<StandardTouchDelegate>) delegate priority:(int) priority
{
	NSAssert( delegate != nil, @"TouchDispatcher.addEventHandler:priority:swallowTouches: -- Delegate must be non nil");	
	
	TouchHandler *handler = [StandardTouchHandler handlerWithDelegate:delegate];
	
	handler.priority = priority;
	[self insertHandler:handler];
}

-(void) addTargetedEventHandler:(id<TargetedTouchDelegate>) delegate
{
	[self addTargetedEventHandler:delegate priority:0 swallowTouches:YES];
}

-(void) addTargetedEventHandler:(id<TargetedTouchDelegate>) delegate priority:(int) priority swallowTouches:(BOOL) swallowTouches
{
	NSAssert( delegate != nil, @"TouchDispatcher.addEventHandler:priority:swallowTouches: -- Delegate must be non nil");	
	
	TargetedTouchHandler *handler = [TargetedTouchHandler handlerWithDelegate:delegate];
	handler.swallowsTouches = swallowTouches;
	
	handler.priority = priority;
	[self insertHandler:handler];
}

#pragma mark remove event handlers

-(void) removeEventHandler:(id<StandardTouchDelegate>) delegate
{
	if( delegate == nil )
		return;
	
	TouchHandler *handler = nil;
	for( handler in touchHandlers )
		if( handler.delegate ==  delegate ) break;
	
	if( handler != nil )
		[touchHandlers removeObject:handler];
}

-(void) removeAllEventHandlers
{
	[touchHandlers removeAllObjects];
}

#pragma mark priority event handlers

-(void) setPriority:(int) priority forEventHandler:(id<StandardTouchDelegate>) delegate
{
	NSAssert( delegate != nil, @"TouchDispatcher.setPriority:forEventHandler: -- Delegate must be non nil");	
	
	NSUInteger i = [touchHandlers indexOfObject:delegate];
	if( i == NSNotFound )
		[NSException raise:NSInvalidArgumentException format:@"Delegate not found"];
	
	TouchHandler *handler = [touchHandlers objectAtIndex:i];
	
	if( handler.priority != priority ) {
		[handler retain];
		[touchHandlers removeObjectAtIndex:i];
		
		handler.priority = priority;
		[self insertHandler:handler];
		[handler release];
	}
}

//
// multi touch proxies
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	BOOL ret = kEventIgnored;
	if( dispatchEvents )  {
		NSArray *copyArray = [touchHandlers copy];
		for( id eventHandler in copyArray ) {
			if([eventHandler isKindOfClass:[StandardTouchHandler class]]) {
				// standard
				if( [[eventHandler delegate] respondsToSelector:@selector(ccTouchesBegan:withEvent:)] ) {
					ret = [[eventHandler delegate] ccTouchesBegan:touches withEvent:event];
				}
			} else
				// targeted
				ret = [self targetedTouchesBegan:touches withEvent:event withHandler:(TargetedTouchHandler*)eventHandler];

			if( ret == kEventHandled )
				break;
		}
		[copyArray release];
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *copyArray = [touchHandlers copy];
		for( id eventHandler in copyArray ) {
			if([eventHandler isKindOfClass:[StandardTouchHandler class]]) {
				if( [[eventHandler delegate] respondsToSelector:@selector(ccTouchesMoved:withEvent:)] ) {
					if( [[eventHandler delegate] ccTouchesMoved:touches withEvent:event] == kEventHandled )
						break;
				}
			} else {
				[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchMoved:withEvent:) unclaim:NO handler:(TargetedTouchHandler*)eventHandler];
			}
		}
		[copyArray release];
	}	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	BOOL ret = kEventIgnored;
	if( dispatchEvents )  {
		NSArray *copyArray = [touchHandlers copy];
		for( id eventHandler in copyArray ) {
			if([eventHandler isKindOfClass:[StandardTouchHandler class]]) {
				// standard touch
				if( [[eventHandler delegate] respondsToSelector:@selector(ccTouchesEnded:withEvent:)] )
					ret = [[eventHandler delegate] ccTouchesEnded:touches withEvent:event];
			} else {
				// targeted
				[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchEnded:withEvent:) unclaim:YES handler:(TargetedTouchHandler*)eventHandler];

			}
		}
		[copyArray release];
	}	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *copyArray = [touchHandlers copy];
		for( id eventHandler in copyArray ) {
			if([eventHandler isKindOfClass:[StandardTouchHandler class]]) {
				// standard
				if( [[eventHandler delegate] respondsToSelector:@selector(ccTouchesCancelled:withEvent:)] ) {
					if( [[eventHandler delegate] ccTouchesCancelled:touches withEvent:event] == kEventHandled )
						break;
				}
			} else {
				// targeted
				[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchCancelled:withEvent:) unclaim:YES handler:(TargetedTouchHandler*)eventHandler];

			}
		}
		[copyArray release];
	}
}
#pragma mark -
#pragma mark Targeted Touch Logic

//
// Targeted Touch Logic
//
-(BOOL) targetedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withHandler:(TargetedTouchHandler*)handler
{
	for( UITouch *touch in touches) {
		BOOL touchWasClaimed = [[handler delegate] ccTouchBegan:touch withEvent:event];
		
		if( touchWasClaimed ) {
			[handler.claimedTouches addObject:touch];
			
			if( handler.swallowsTouches )
				break;
		}
	}
	return kEventIgnored;
}

-(void) updateKnownTouches:(NSSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim handler:(TargetedTouchHandler*)handler
{
	NSArray *handlers = [touchHandlers copy];
	
	for( UITouch *touch in touches) {
		if( [handler.claimedTouches containsObject:touch] ) {
			
			if( dispatchEvents && [handler.delegate respondsToSelector:selector] )
				[handler.delegate performSelector:selector withObject:touch withObject:event];
			
			if( doUnclaim )
				[handler.claimedTouches removeObject:touch];
			
			if( handler.swallowsTouches )
				break;
		}
	}
	[handlers release];
}
@end
