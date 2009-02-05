/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 mark@abitofthought.com 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "FastDirector.h"

@interface FastDirector (Private)
-(void) mainLoop;
-(void) startAnimation;
-(void) stopAnimation;
@end

@implementation FastDirector : Director

static FastDirector *sharedDirector = nil;

+ (FastDirector *) sharedDirector
{
	@synchronized(self)
	{
		if (!sharedDirector)
			[[FastDirector alloc] init];
		
		return sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

+(id) alloc
{
	@synchronized(self)
	{
		NSAssert(sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedDirector = [super alloc];
		return sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

- (id) init {
    if (self = [super init]) {
        isRunning = NO;
    }
    return self;
}

- (void) startAnimation
{
	if ( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	
	isRunning = YES;
	while (isRunning) {
		if (paused) {
			usleep(250000); // Sleep for a quarter of a second (250,000 microseconds) so that the framerate is 4 fps.
		}
		
		[self mainLoop];
		
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
	}
}

- (void) stopAnimation
{
	isRunning = NO;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	NSAssert(YES,@"FastDirectory doesn't support setAnimationInterval. Use Director instead");
}
@end
