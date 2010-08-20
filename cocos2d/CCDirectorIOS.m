/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

 
#import <sys/time.h>
#import <unistd.h>

#import "CCDirectorIOS.h"
#import "ccMacros.h"

#pragma mark -
#pragma mark Director iOS
@implementation CCDirectorIOS
@end

#pragma mark -
#pragma mark Director TimerDirector

@implementation CCDirectorTimer
- (void)startAnimation
{
	NSAssert( animationTimer == nil, @"animationTimer must be nil. Calling startAnimation twice?");
	
	if( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: Director: Error in gettimeofday");
	}
	
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval_ target:self selector:@selector(drawScene) userInfo:nil repeats:YES];
	
	//
	//	If you want to attach the opengl view into UIScrollView
	//  uncomment this line to prevent 'freezing'.
	//	It doesn't work on with the Fast Director
	//
	//	[[NSRunLoop currentRunLoop] addTimer:animationTimer
	//								 forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
	[animationTimer invalidate];
	animationTimer = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval_ = interval;
	
	if(animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}

-(void) dealloc
{
	[animationTimer release];
	[super dealloc];
}
@end


#pragma mark - 
#pragma mark Director DirectorFast

@implementation CCDirectorFast

- (id) init
{
	if(( self = [super init] )) {
		
#if CC_DIRECTOR_DISPATCH_FAST_EVENTS
		CCLOG(@"cocos2d: Fast Events enabled");
#else
		CCLOG(@"cocos2d: Fast Events disabled");
#endif		
		isRunning = NO;
		
		// XXX:
		// XXX: Don't create any autorelease object before calling "fast director"
		// XXX: else it will be leaked
		// XXX:
		autoreleasePool = [NSAutoreleasePool new];
	}

	return self;
}

- (void) startAnimation
{
	// XXX:
	// XXX: release autorelease objects created
	// XXX: between "use fast director" and "runWithScene"
	// XXX:
	[autoreleasePool release];
	autoreleasePool = nil;

	if ( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: Director: Error in gettimeofday");
	}
	

	isRunning = YES;

	SEL selector = @selector(preMainLoop);
	NSMethodSignature* sig = [[[CCDirector sharedDirector] class]
							  instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
								invocationWithMethodSignature:sig];
	[invocation setTarget:[CCDirector sharedDirector]];
	[invocation setSelector:selector];
	[invocation performSelectorOnMainThread:@selector(invokeWithTarget:)
								 withObject:[CCDirector sharedDirector] waitUntilDone:NO];
	
//	NSInvocationOperation *loopOperation = [[[NSInvocationOperation alloc]
//											 initWithTarget:self selector:@selector(preMainLoop) object:nil]
//											autorelease];
//	
//	[loopOperation performSelectorOnMainThread:@selector(start) withObject:nil
//								 waitUntilDone:NO];
}

-(void) preMainLoop
{
	while (isRunning) {
	
		NSAutoreleasePool *loopPool = [NSAutoreleasePool new];

#if CC_DIRECTOR_DISPATCH_FAST_EVENTS
		while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004f, FALSE) == kCFRunLoopRunHandledSource);
#else
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
#endif

		if (isPaused_) {
			usleep(250000); // Sleep for a quarter of a second (250,000 microseconds) so that the framerate is 4 fps.
		}
		
		[self drawScene];

#if CC_DIRECTOR_DISPATCH_FAST_EVENTS
		while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004f, FALSE) == kCFRunLoopRunHandledSource);
#else
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
#endif

		[loopPool release];
	}	
}
- (void) stopAnimation
{
	isRunning = NO;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	NSLog(@"FastDirectory doesn't support setAnimationInterval, yet");
}
@end

#pragma mark -
#pragma mark Director DirectorThreadedFast

@implementation CCDirectorFastThreaded

- (id) init
{
	if(( self = [super init] )) {		
		isRunning = NO;		
	}
	
	return self;
}

- (void) startAnimation
{
	
	if ( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: ThreadedFastDirector: Error on gettimeofday");
	}

	isRunning = YES;

	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(preMainLoop) object:nil];
	[thread start];
	[thread release];
}

-(void) preMainLoop
{
	while( ![[NSThread currentThread] isCancelled] ) {
		if( isRunning )
			[self performSelectorOnMainThread:@selector(drawScene) withObject:nil waitUntilDone:YES];
		
		if (isPaused_) {
			usleep(250000); // Sleep for a quarter of a second (250,000 microseconds) so that the framerate is 4 fps.
		} else {
//			usleep(2000);
		}
	}	
}
- (void) stopAnimation
{
	isRunning = NO;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	NSLog(@"FastDirector doesn't support setAnimationInterval, yet");
}
@end

#pragma mark -
#pragma mark DirectorDisplayLink

// Allows building DisplayLinkDirector for pre-3.1 SDKS
// without getting compiler warnings.
@interface NSObject(CADisplayLink)
+ (id) displayLinkWithTarget:(id)arg1 selector:(SEL)arg2;
- (void) addToRunLoop:(id)arg1 forMode:(id)arg2;
- (void) setFrameInterval:(int)interval;
- (void) invalidate;
@end

@implementation CCDirectorDisplayLink

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval_ = interval;
	if(displayLink){
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void) startAnimation
{
	if ( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: DisplayLinkDirector: Error on gettimeofday");
	}
	
	// approximate frame rate
	// assumes device refreshes at 60 fps
	int frameInterval = (int) floor(animationInterval_ * 60.0f);
	
	CCLOG(@"cocos2d: Frame interval: %d", frameInterval);

	displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(preMainLoop:)];
	[displayLink setFrameInterval:frameInterval];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void) preMainLoop:(id)sender
{
	[self drawScene];
}

- (void) stopAnimation
{
	[displayLink invalidate];
	displayLink = nil;
}

-(void) dealloc
{
	[displayLink release];
	[super dealloc];
}
@end
