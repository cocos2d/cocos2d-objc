/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#if __CC_PLATFORM_IOS

#import <unistd.h>

// cocos2d imports
#import "CCDirectorIOS.h"
#import "../../CCScheduler.h"
#import "../../CCActionManager.h"
#import "../../CCTextureCache.h"
#import "../../ccMacros.h"
#import "../../CCScene.h"
#import "../../CCShader.h"
#import "../../ccFPSImages.h"
#import "../../CCConfiguration.h"
#import "CCRenderer_Private.h"
#import "CCTouch.h"
#import "CCRenderDispatch_Private.h"

// support imports
#import "../../Support/CGPointExtension.h"
#import "../../Support/CCFileUtils.h"

#if CC_ENABLE_PROFILERS
#import "../../Support/CCProfiling.h"
#endif

#import "CCDirector_Private.h"

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

- (id) init
{
	if( (self=[super init]) ) {
		// running thread is main thread on iOS
		_runningThread = [NSThread currentThread];
		
		// Apparently it comes with a default view, and we don't want it
//		[self setView:nil];
	}

	return self;
}

-(void) setViewport
{
	CGSize size = _winSizeInPixels;
	CCRenderDispatch(YES, ^{
		glViewport(0, 0, size.width, size.height );
	});
}

-(void) setProjection:(CCDirectorProjection)projection
{
	CGSize sizePoint = _winSizeInPoints;
    
	[self setViewport];

	switch (projection) {
		case CCDirectorProjection2D:
			_projectionMatrix = GLKMatrix4MakeOrtho(0, sizePoint.width, 0, sizePoint.height, -1024, 1024 );
			break;

		case CCDirectorProjection3D: {
			float zeye = sizePoint.height*sqrtf(3.0f)/2.0f;
			_projectionMatrix = GLKMatrix4Multiply(
				GLKMatrix4MakePerspective(CC_DEGREES_TO_RADIANS(60), (float)sizePoint.width/sizePoint.height, 0.1f, zeye*2),
				GLKMatrix4MakeTranslation(-sizePoint.width/2.0, -sizePoint.height/2, -zeye)
			);

			break;
		}

		case CCDirectorProjectionCustom:
			if( [_delegate respondsToSelector:@selector(updateProjection)] )
				_projectionMatrix = [_delegate updateProjection];
			break;

		default:
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
	}

	_projection = projection;
	[self createStatsLabel];
}

// override default logic
- (void)runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert(_runningScene == nil, @"This command can only be used to start the CCDirector. There is already a scene present.");
	
	[self pushScene:scene];
}

-(void) reshapeProjection:(CGSize)newViewSize
{
	[super reshapeProjection:newViewSize];
  
	if( [_delegate respondsToSelector:@selector(directorDidReshapeProjection:)] )
		[_delegate directorDidReshapeProjection:self];
}

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

#pragma mark Director - UIViewController delegate


-(void) setView:(CC_VIEW<CCDirectorView> *)view
{
		[super setView:view];

		if( view ) {
			// set size
			CGFloat scale = view.contentScaleFactor;
			CGSize size = view.bounds.size;
			_winSizeInPixels = CGSizeMake(size.width * scale, size.height * scale);
		}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL ret =YES;
	if( [_delegate respondsToSelector:_cmd] )
		ret = (BOOL) [_delegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];

	return ret;
}

// Commented. See issue #1453 for further info: http://code.google.com/p/cocos2d-iphone/issues/detail?id=1453
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//	if( [_delegate respondsToSelector:_cmd] )
//		[_delegate willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}

-(void) startAnimationIfPossible
{
    UIApplicationState state = UIApplication.sharedApplication.applicationState;
    if (state != UIApplicationStateBackground)
    {
        [self startAnimation];
    }
    else
    {
        // we are backgrounded, try again in 1 second, we want to make sure that this call eventually goes through in the event
        // that there was a full screen view controller that caused additional stop animation calls
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            [self startAnimationIfPossible];
        });
    }
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    [self startAnimationIfPossible];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	[self startAnimation];
}

-(void) viewWillDisappear:(BOOL)animated
{
//	[self stopAnimation];

	[super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
	[self stopAnimation];

	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
	// Release any cached data, images, etc that aren't in use.
	[super purgeCachedData];

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

-(void) viewDidLoad
{
	CCLOG(@"cocos2d: viewDidLoad");

	[super viewDidLoad];
}


- (void)viewDidUnload
{
	CCLOG(@"cocos2d: viewDidUnload");

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark helper

-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len contentScale:(CGFloat *)scale
{
	NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];

	if( device == CCDeviceiPadRetinaDisplay) {
		*datapointer = cc_fps_images_ipadhd_png;
		*len = cc_fps_images_ipadhd_len();
		*scale = 2;
		
	} else if( device == CCDeviceiPhoneRetinaDisplay || device == CCDeviceiPhone5RetinaDisplay ) {
		*datapointer = cc_fps_images_hd_png;
		*len = cc_fps_images_hd_len();
		*scale = 2;

	} else {
		*datapointer = cc_fps_images_png;
		*len = cc_fps_images_len();
		*scale = 1;
	}
}

@end


#pragma mark -
#pragma mark DirectorDisplayLink

@implementation CCDirectorDisplayLink


-(void) mainLoop:(id)sender
{
	[self drawScene];
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	_animationInterval = interval;
	if(_displayLink){
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void) startAnimation
{
	[super startAnimation];

    if(_animating)
        return;

	gettimeofday( &_lastUpdate, NULL);

	// approximate frame rate
	// assumes device refreshes at 60 fps
	int frameInterval = (int) floor(_animationInterval * 60.0f);

	CCLOG(@"cocos2d: animation started with frame interval: %.2f", 60.0f/frameInterval);

	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop:)];
	[_displayLink setFrameInterval:frameInterval];

#if CC_DIRECTOR_IOS_USE_BACKGROUND_THREAD
	//
	_runningThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMainLoop) object:nil];
	[_runningThread start];

#else
	// setup DisplayLink in main thread
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
#endif

    _animating = YES;
}

- (void) stopAnimation
{
    if(!_animating)
        return;

    if([_delegate respondsToSelector:@selector(stopAnimation)])
    {
        [_delegate stopAnimation];
    }
    
	CCLOG(@"cocos2d: animation stopped");

#if CC_DIRECTOR_IOS_USE_BACKGROUND_THREAD
	[_runningThread cancel];
	[_runningThread release];
	_runningThread = nil;
#endif

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
	if( _displayStats )
		gettimeofday( &_lastUpdate, NULL);

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
