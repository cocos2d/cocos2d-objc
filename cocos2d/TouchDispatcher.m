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
	self = [super init];
	
	dispatchEvents = YES;
	touchHandlers = [[NSMutableArray alloc] initWithCapacity:8];
	
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

-(void) addEventHandler:(id<TargetedTouchDelegate>) delegate
{
	[self addEventHandler:delegate priority:0 swallowTouches:YES];
}

-(void) addEventHandler:(id<TargetedTouchDelegate>) delegate priority:(int) priority swallowTouches:(BOOL) swallowTouches
{
	NSAssert( delegate != nil, @"TouchDispatcher.addEventHandler:priority:swallowTouches: -- Delegate must be non nil");	
	
	TouchHandler *handler = [TouchHandler handlerWithDelegate:delegate];
	handler.swallowsTouches = swallowTouches;
	
	handler.priority = priority;
	[self insertHandler:handler];
}

-(void) removeEventHandler:(id<TargetedTouchDelegate>) delegate
{
	if( delegate == nil )
		return;
	
	TouchHandler *handler = nil;
	for( handler in touchHandlers )
		if( handler.delegate ==  delegate ) break;
	
	if( handler != nil )
		[touchHandlers removeObject:handler];
}

-(void) setPriority:(int) priority forEventHandler:(id<TargetedTouchDelegate>) delegate
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


-(void) removeAllEventHandlers
{
	[touchHandlers removeAllObjects];
}

//
// multi touch proxies
//
-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents ) {

		NSArray *handlers = [touchHandlers copy];
		
		for( UITouch *touch in touches) {
			for( TouchHandler *handler in handlers ) {
				BOOL touchWasClaimed = [handler.delegate ccTouchBegan:touch withEvent:event];
				
				if( touchWasClaimed ) {
					[handler.claimedTouches addObject:touch];
					
					if( handler.swallowsTouches )
						break;
				}
			}
		}
		[handlers release];
	}

	return kEventHandled;
}

-(void) updateKnownTouches:(NSSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim
{
	NSArray *handlers = [touchHandlers copy];
	
	for( UITouch *touch in touches) {
		for( TouchHandler *handler in handlers ) {
			if( [handler.claimedTouches containsObject:touch] ) {
				
				if( dispatchEvents && [handler.delegate respondsToSelector:selector] )
					[handler.delegate performSelector:selector withObject:touch withObject:event];
				
				if( doUnclaim )
					[handler.claimedTouches removeObject:touch];
				
				if( handler.swallowsTouches )
					break;
			}
		}
	}
	[handlers release];
}

-(BOOL) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (dispatchEvents)
		[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchMoved:withEvent:) unclaim:NO];
	
	return kEventHandled;
}

-(BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchEnded:withEvent:) unclaim:YES];
	
	return kEventHandled;
}

-(BOOL) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateKnownTouches:touches withEvent:event selector:@selector(ccTouchCancelled:withEvent:) unclaim:YES];
	
	return kEventHandled;
}

@end
