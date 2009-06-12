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

#pragma mark add event handlers

-(void) addTouchHandler:(TouchHandler*)handler
{
	NSUInteger i = 0;
	for( TouchHandler *h in touchHandlers ) {
		if( h.priority >= handler.priority )
			break;
		i++;
	}
	[touchHandlers insertObject:handler atIndex:i];
}

#pragma mark remove event handlers

-(void) removeEventHandler:(id) delegate
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

-(void) setPriority:(int) priority forEventHandler:(id) delegate
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
		[self addTouchHandler:handler];
		[handler release];
	}
}

//
// dispatch events
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *copyArray = [touchHandlers copy];
		NSMutableSet *copyTouches = [[NSMutableSet setWithSet:touches] retain];
		for( id eventHandler in copyArray ) {
			if( [eventHandler ccTouchesBegan:copyTouches withEvent:event] == kEventHandled )
				break;
		}
		[copyTouches release];
		[copyArray release];
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSMutableSet *copyTouches = [[NSMutableSet setWithSet:touches] retain];
		NSArray *copyArray = [touchHandlers copy];
		for( id eventHandler in copyArray ) {
			if( [eventHandler ccTouchesMoved:copyTouches withEvent:event] == kEventHandled )
				break;
		}
		[copyTouches release];
		[copyArray release];
	}	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *copyArray = [touchHandlers copy];
		NSMutableSet *copyTouches = [[NSMutableSet setWithSet:touches] retain];
		for( id eventHandler in copyArray ) {
			if( [eventHandler ccTouchesEnded:touches withEvent:event] == kEventHandled )
				break;
		}
		[copyTouches release];
		[copyArray release];
	}	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )  {
		NSArray *copyArray = [touchHandlers copy];
		NSMutableSet *copyTouches = [[NSMutableSet setWithSet:touches] retain];
		for( id eventHandler in copyArray ) {
			if( [eventHandler ccTouchesCancelled:touches withEvent:event] == kEventHandled )
				break;
		}
		[copyTouches release];
		[copyArray release];
	}
}
@end
