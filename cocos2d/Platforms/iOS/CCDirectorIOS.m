/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 *
 */


#include <sys/time.h>

#import "ccMacros.h"
#if __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>

#import "ccUtils.h"

#import "CCDirectorIOS.h"
#import "CCDirector_Private.h"
#import "CCRenderer_Private.h"
#import "CCRenderDispatch_Private.h"

#import "CCScheduler.h"
#import "CCTextureCache.h"
#import "ccMacros.h"
#import "CCScene.h"
#import "CCShader.h"
#import "ccFPSImages.h"
#import "CCDeviceInfo.h"
#import "CCTouch.h"
#import "CCFileLocator.h"

#pragma mark -
#pragma mark Director

@interface CCDirector ()
-(void) setNextScene;
-(void) showStats;
-(void) calculateDeltaTime;
-(void) calculateMPF;
@end

@implementation CCDirector (iOSExtensionClassMethods)

+(Class) defaultDirector
{
	return [CCDirectorDisplayLink class];
}

-(void) setInterfaceOrientationDelegate:(id)delegate
{
	// override me
}

@end



#pragma mark -
#pragma mark CCDirectorIOS

@implementation CCDirectorIOS

#pragma mark Director Point Convertion

-(CGPoint)convertTouchToGL:(CCTouch*)touch
{
	CGPoint uiPoint = [touch locationInView: [touch view]];
	return [self convertToGL:uiPoint];
}

-(void) end
{
	[super end];
}

// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	BOOL ret =YES;
//	if( [_delegate respondsToSelector:_cmd] )
//		ret = (BOOL) [_delegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
//
//	return ret;
//}

// Commented. See issue #1453 for further info: http://code.google.com/p/cocos2d-iphone/issues/detail?id=1453
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//	if( [_delegate respondsToSelector:_cmd] )
//		[_delegate willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}

-(void) startRunLoopIfPossible
{
    UIApplicationState state = UIApplication.sharedApplication.applicationState;
    if (state != UIApplicationStateBackground)
    {
        [self startRunLoop];
    }
    else
    {
        // we are backgrounded, try again in 1 second, we want to make sure that this call eventually goes through in the event
        // that there was a full screen view controller that caused additional stop animation calls
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            [self startRunLoopIfPossible];
        });
    }
}

//-(void) viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//
//    // This line was presumably added to deal with apps entering and leaving the background.
//    // ViewWillAppear is called many times on application launch (7 times for the unit tests) and it's also called
//    // by the OS outside of normal control, so it's very hard to actually call stopRunLoop and expect it to work.
////    [self startRunLoopIfPossible];
//}
//
//-(void) viewDidAppear:(BOOL)animated
//{
//	[super viewDidAppear:animated];
////	[self startRunLoop];
//}
//
//-(void) viewWillDisappear:(BOOL)animated
//{
////	[self stopRunLoop];
//
//	[super viewWillDisappear:animated];
//}
//
//-(void) viewDidDisappear:(BOOL)animated
//{
//	[self stopRunLoop];
//
//	[super viewDidDisappear:animated];
//}
//
//- (void)didReceiveMemoryWarning
//{
//	// Release any cached data, images, etc that aren't in use.
//	[super purgeCachedData];
//
//    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//}
//
//-(void) viewDidLoad
//{
//	CCLOG(@"cocos2d: viewDidLoad");
//
//	[super viewDidLoad];
//}
//
//
//- (void)viewDidUnload
//{
//	CCLOG(@"cocos2d: viewDidUnload");
//
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}

#pragma mark helper

-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len contentScale:(CGFloat *)scale
{
    *datapointer = cc_fps_images_png;
    *len = cc_fps_images_len();
    *scale = 1;
}

@end


#pragma mark -
#pragma mark DirectorDisplayLink

@implementation CCDirectorDisplayLink {
	CADisplayLink	*_displayLink;
	CFTimeInterval	_lastDisplayTime;
}

-(void) mainLoop:(id)sender
{
	[self mainLoopBody];
}

-(void)setFrameSkipInterval:(NSUInteger)frameSkipInterval
{
    [super setFrameSkipInterval:frameSkipInterval];
    _displayLink.frameInterval = frameSkipInterval;
}

- (void) startRunLoop
{
	[super startRunLoop];

    if(_animating)
        return;
    
    _lastUpdate = CACurrentMediaTime();

	// approximate frame rate
	// assumes device refreshes at 60 fps
	int frameInterval = (int) floor(_animationInterval * 60.0f);

	CCLOG(@"cocos2d: animation started with frame interval: %.2f", 60.0f/frameInterval);

	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop:)];
	[_displayLink setFrameInterval:frameInterval];

	// setup DisplayLink in main thread
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    _animating = YES;
}

- (void) stopRunLoop
{
    if(!_animating)
        return;

    if([_delegate respondsToSelector:@selector(stopRunLoop)])
    {
        [_delegate stopRunLoop];
    }
    
	CCLOG(@"cocos2d: animation stopped");

	[_displayLink invalidate];
	_displayLink = nil;
    _animating = NO;
}

// Overriden in order to use a more stable delta time
-(void) calculateDeltaTime
{
    // New delta time. Re-fixed issue #1277
    if( _nextDeltaTimeZero || _lastDisplayTime==0 ) {
        _dt = 0;
        _nextDeltaTimeZero = NO;
    } else {
        _dt = _displayLink.timestamp - _lastDisplayTime;
        _dt = MAX(0,_dt);
    }
    // Store this timestamp for next time
    _lastDisplayTime = _displayLink.timestamp;

	// needed for SPF
	if( _displayStats ){
		_lastUpdate = CACurrentMediaTime();
    }

#if DEBUG
	// If we are debugging our code, prevent big delta time
	if( _dt > 0.2f )
		_dt = 1/60.0f;
#endif
}


#pragma mark Director Thread

//
// Director has its own thread
//
-(void) threadMainLoop
{
	@autoreleasepool {

		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

		// start the run loop
		[[NSRunLoop currentRunLoop] run];

	}
}

@end

#endif // __CC_PLATFORM_IOS
