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

#import "TouchDispatcher.h"
#import "TouchHandler.h"

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

#pragma mark Adding handlers

-(void) addHandler:(TouchHandler*) handler
{
	NSUInteger i = 0;
	for( TouchHandler *h in touchHandlers ) {
		if( h.priority < handler.priority )
			i++;
		
		if( h.delegate == handler.delegate )
			[NSException raise:NSInvalidArgumentException format:@"Delegate already added to touch dispatcher."];
	}
	[touchHandlers insertObject:handler atIndex:i];
}

-(void) addStandardDelegate:(id<StandardTouchDelegate>) delegate priority:(int)priority
{
	TouchHandler *handler = [StandardTouchHandler handlerWithDelegate:delegate priority:priority];
	[self addHandler:handler];
}

-(void) addTargetedDelegate:(id<TargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
{
	TouchHandler *handler = [TargetedTouchHandler handlerWithDelegate:delegate priority:priority swallowsTouches:swallowsTouches];
	[self addHandler:handler];
}

#pragma mark Removing handlers

-(void) removeDelegate:(id) delegate
{
	if( delegate == nil )
		return;
	
	for( TouchHandler *handler in touchHandlers ) {
		if( handler.delegate ==  delegate ) {
			[touchHandlers removeObject:handler];
			break;
		}
	}
}

-(void) removeAllDelegates
{
	[touchHandlers removeAllObjects];
}

#pragma mark Changing priority of added handlers

-(void) setPriority:(int) priority forDelegate:(id) delegate
{
	if( delegate == nil )
		[NSException raise:NSInvalidArgumentException format:@"Got nil touch delegate"];
	
	TouchHandler *handler = nil;
	for( handler in touchHandlers )
		if( handler.delegate == delegate ) break;
	
	if( handler == nil )
		[NSException raise:NSInvalidArgumentException format:@"Touch delegate not found"];
	
	if( handler.priority != priority ) {
		handler.priority = priority;
		
		[handler retain];
		[touchHandlers removeObject:handler];
		[self addHandler:handler];
		[handler release];
	}
}


//
// dispatch events
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *handlers = [touchHandlers copy];
		NSMutableSet *mutableTouches = [touches mutableCopy];
		
		for( TouchHandler *handler in handlers ) {
			if( [handler ccTouchesBegan:mutableTouches withEvent:event] == kEventHandled )
				break;
		}
		[handlers release];
		[mutableTouches release];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *handlers = [touchHandlers copy];
		NSMutableSet *mutableTouches = [touches mutableCopy];
		
		for( TouchHandler *handler in handlers ) {
			if( [handler ccTouchesMoved:mutableTouches withEvent:event] == kEventHandled )
				break;
		}
		[handlers release];
		[mutableTouches release];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *handlers = [touchHandlers copy];
		NSMutableSet *mutableTouches = [touches mutableCopy];
		
		for( TouchHandler *handler in handlers ) {
			if( [handler ccTouchesEnded:mutableTouches withEvent:event] == kEventHandled )
				break;
		}
		[handlers release];
		[mutableTouches release];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *handlers = [touchHandlers copy];
		NSMutableSet *mutableTouches = [touches mutableCopy];
		
		for( TouchHandler *handler in handlers ) {
			if( [handler ccTouchesCancelled:mutableTouches withEvent:event] == kEventHandled )
				break;
		}
		[handlers release];
		[mutableTouches release];
	}
}
@end
