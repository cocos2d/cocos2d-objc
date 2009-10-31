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

#import "CCTouchDispatcher.h"
#import "CCTouchHandler.h"

@implementation CCTouchDispatcher

@synthesize dispatchEvents;

static CCTouchDispatcher *sharedDispatcher = nil;

+(CCTouchDispatcher*) sharedDispatcher
{
	@synchronized(self) {
		if (sharedDispatcher == nil)
			sharedDispatcher = [[self alloc] init]; // assignment not done here
	}
	return sharedDispatcher;
}

+(id) allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		NSAssert(sharedDispatcher == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super allocWithZone:zone];
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

-(void) addHandler:(CCTouchHandler*) handler
{
	NSUInteger i = 0;
	for( CCTouchHandler *h in touchHandlers ) {
		if( h.priority < handler.priority )
			i++;
		
		if( h.delegate == handler.delegate )
			[NSException raise:NSInvalidArgumentException format:@"Delegate already added to touch dispatcher."];
	}
	[touchHandlers insertObject:handler atIndex:i];
}

-(void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority
{
	CCTouchHandler *handler = [CCStandardTouchHandler handlerWithDelegate:delegate priority:priority];
	[self addHandler:handler];
}

-(void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
{
	CCTouchHandler *handler = [CCTargetedTouchHandler handlerWithDelegate:delegate priority:priority swallowsTouches:swallowsTouches];
	[self addHandler:handler];
}

#pragma mark Removing handlers

-(void) removeDelegate:(id) delegate
{
	if( delegate == nil )
		return;
	
	for( CCTouchHandler *handler in touchHandlers ) {
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
	
	CCTouchHandler *handler = nil;
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
		
		for( CCTouchHandler *handler in handlers ) {
			if( [handler ccTouchesBegan:mutableTouches withEvent:event] == kEventHandled )
				break;
			if([mutableTouches count] == 0)
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
		
		for( CCTouchHandler *handler in handlers ) {
			if( [handler ccTouchesMoved:mutableTouches withEvent:event] == kEventHandled )
				break;
			if([mutableTouches count] == 0)
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
		
		for( CCTouchHandler *handler in handlers ) {
			if( [handler ccTouchesEnded:mutableTouches withEvent:event] == kEventHandled )
				break;
			if([mutableTouches count] == 0)
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
		
		for( CCTouchHandler *handler in handlers ) {
			if( [handler ccTouchesCancelled:mutableTouches withEvent:event] == kEventHandled )
				break;
			if([mutableTouches count] == 0)
				break;
		}
		[handlers release];
		[mutableTouches release];
	}
}
@end
