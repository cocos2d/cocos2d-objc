/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <unistd.h>

// cocos2d imports
#import "CCDirectorIOS.h"
#import "CCTouchDelegateProtocol.h"
#import "CCTouchDispatcher.h"
#import "../../CCScheduler.h"
#import "../../CCActionManager.h"
#import "../../CCTextureCache.h"
#import "../../ccMacros.h"
#import "../../CCScene.h"

// support imports
#import "glu.h"
#import "../../Support/OpenGL_Internal.h"
#import "../../Support/CGPointExtension.h"

#import "CCLayer.h"

#if CC_ENABLE_PROFILERS
#import "../../Support/CCProfiling.h"
#endif


#pragma mark -
#pragma mark Director - global variables (optimization)

CGFloat	__ccContentScaleFactor = 1;

#pragma mark -
#pragma mark Director iOS

@interface CCDirector ()
-(void) setNextScene;
-(void) showFPS;
-(void) calculateDeltaTime;
@end

@implementation CCDirector (iOSExtensionClassMethods)

+(Class) defaultDirector
{
	return [CCDirectorTimer class];
}

+ (BOOL) setDirectorType:(ccDirectorType)type
{
	if( type == CCDirectorTypeDisplayLink ) {
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		
		if([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending)
			return NO;
	}
	switch (type) {
		case CCDirectorTypeNSTimer:
			[CCDirectorTimer sharedDirector];
			break;
		case CCDirectorTypeDisplayLink:
			[CCDirectorDisplayLink sharedDirector];
			break;
		case CCDirectorTypeMainLoop:
			[CCDirectorFast sharedDirector];
			break;
		case CCDirectorTypeThreadMainLoop:
			[CCDirectorFastThreaded sharedDirector];
			break;
		default:
			NSAssert(NO,@"Unknown director type");
	}
	
	return YES;
}

@end



#pragma mark -
#pragma mark CCDirectorIOS

@interface CCDirectorIOS ()
-(BOOL)isOpenGLAttached;
-(BOOL)initOpenGLViewWithView:(UIView *)view withFrame:(CGRect)rect;

-(void) updateContentScaleFactor;

@end

@implementation CCDirectorIOS

@synthesize pixelFormat=pixelFormat_;

- (id) init
{  
	if( (self=[super init]) ) {
				
		
		// default values
		pixelFormat_ = kCCPixelFormatDefault;		// DEPRECATED. Will be removed in 1.0
		depthBufferFormat_ = 0;						// DEPRECATED. Will be removed in 1.0
		
		// portrait mode default
		deviceOrientation_ = CCDeviceOrientationPortrait;
		
		__ccContentScaleFactor = 1;
		isContentScaleSupported_ = NO;
		
		// running thread is main thread on iOS
		runningThread_ = [NSThread currentThread];
	}
	
	return self;
}

- (void) dealloc
{	
	[super dealloc];
}

//
// Draw the Scene
//
- (void) drawScene
{    
	/* calculate "global" dt */
	[self calculateDeltaTime];
	
	/* tick before glClear: issue #533 */
	if( ! isPaused_ ) {
		[[CCScheduler sharedScheduler] tick: dt];	
	}
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ )
		[self setNextScene];
	
	glPushMatrix();
	
	[self applyOrientation];
	
	// By default enable VertexArray, ColorArray, TextureCoordArray and Texture2D
	CC_ENABLE_DEFAULT_GL_STATES();
	
	/* draw the scene */
	[runningScene_ visit];
	
	/* draw the notification node */
	[notificationNode_ visit];

	if( displayFPS_ )
		[self showFPS];
	
#if CC_ENABLE_PROFILERS
	[self showProfilers];
#endif
	
	CC_DISABLE_DEFAULT_GL_STATES();
	
	glPopMatrix();
	
	[openGLView_ swapBuffers];
}


#pragma mark Director Scene iPhone Specific

-(void) setPixelFormat: (tPixelFormat) format
{	
	NSAssert( ! [self isOpenGLAttached], @"Can't change the pixel format after the director was initialized" );	
	pixelFormat_ = format;
}

-(void) setDepthBufferFormat: (tDepthBufferFormat) format
{
	NSAssert( ! [self isOpenGLAttached], @"Can't change the depth buffer format after the director was initialized");
	depthBufferFormat_ = format;
}

#pragma mark Director Integration with a UIKit view

// is the view currently attached
-(BOOL)isOpenGLAttached
{
	return ([openGLView_ superview]!=nil);
}

// XXX: deprecated
-(BOOL)detach
{
	NSAssert([self isOpenGLAttached], @"FATAL: Director: Can't detach the OpenGL View, because it is not attached. Attach it first.");
	
	// remove from the superview
	[openGLView_ removeFromSuperview];
	
	NSAssert(![self isOpenGLAttached], @"FATAL: Director: Can't detach the OpenGL View, it is still attached to the superview.");
	
	
	return YES;
}

// XXX: Deprecated method
-(BOOL)attachInWindow:(UIWindow *)window
{
	if([self initOpenGLViewWithView:window withFrame:[window bounds]])
	{
		return YES;
	}
	
	return NO;
}

// XXX: Deprecated method
-(BOOL)attachInView:(UIView *)view
{
	if([self initOpenGLViewWithView:view withFrame:[view bounds]])
	{
		return YES;
	}
	
	return NO;
}

// XXX: Deprecated method
-(BOOL)attachInView:(UIView *)view withFrame:(CGRect)frame
{
	if([self initOpenGLViewWithView:view withFrame:frame])
	{
		return YES;
	}
	
	return NO;
}

// XXX: Deprecated method
-(BOOL)initOpenGLViewWithView:(UIView *)view withFrame:(CGRect)rect
{
	NSAssert( ! [self isOpenGLAttached], @"FATAL: Can't re-attach the OpenGL View, because it is already attached. Detach it first");
	
	// check if the view is not initialized
	if(!openGLView_)
	{
		// define the pixel format
		NSString	*pFormat = nil;
	    GLuint		depthFormat = 0;
		
		if(pixelFormat_==kCCPixelFormatRGBA8888)
			pFormat = kEAGLColorFormatRGBA8;
		else if(pixelFormat_== kCCPixelFormatRGB565)
			pFormat = kEAGLColorFormatRGB565;
		else {
			CCLOG(@"cocos2d: Director: Unknown pixel format.");
		}
		
		if(depthBufferFormat_ == kCCDepthBuffer16)
			depthFormat = GL_DEPTH_COMPONENT16_OES;
		else if(depthBufferFormat_ == kCCDepthBuffer24)
			depthFormat = GL_DEPTH_COMPONENT24_OES;
		else if(depthBufferFormat_ == kCCDepthBufferNone)
			depthFormat = 0;
		else {
			CCLOG(@"cocos2d: Director: Unknown buffer depth.");
		}
		
		// alloc and init the opengl view
		openGLView_ = [[EAGLView alloc] initWithFrame:rect
										  pixelFormat:pFormat
										  depthFormat:depthFormat
								   preserveBackbuffer:NO 
										   sharegroup:nil
										multiSampling:NO
									  numberOfSamples:0];
		
		// check if the view was alloced and initialized
		NSAssert( openGLView_, @"FATAL: Could not alloc and init the OpenGL view. ");
		
		// opaque by default (faster)
		openGLView_.opaque = YES;		
	}
	else
	{
		// set the (new) frame of the glview
		[openGLView_ setFrame:rect];
	}
	
	winSizeInPoints_ = rect.size;
	winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height * __ccContentScaleFactor);
	
	
	// set the touch delegate of the glview to self
	[openGLView_ setTouchDelegate: [CCTouchDispatcher sharedDispatcher]];
	
	
	// check if the superview has touchs enabled and enable it in our view
	if([view isUserInteractionEnabled])
	{
		[openGLView_ setUserInteractionEnabled:YES];
		[[CCTouchDispatcher sharedDispatcher] setDispatchEvents: YES];
	}
	else
	{
		[openGLView_ setUserInteractionEnabled:NO];
		[[CCTouchDispatcher sharedDispatcher] setDispatchEvents: NO];
	}
	
	// check if multi touches are enabled and set them
	if([view isMultipleTouchEnabled])
	{
		[openGLView_ setMultipleTouchEnabled:YES];
	}
	else
	{
		[openGLView_ setMultipleTouchEnabled:NO];
	}
	
	// add the glview to his (new) superview
	[view addSubview:openGLView_];
	
	
	NSAssert( [self isOpenGLAttached], @"FATAL: Director: Could not attach OpenGL view");
	
	[self setGLDefaultValues];
	return YES;
}

-(void) setOpenGLView:(EAGLView *)view
{
	if( view != openGLView_ ) {

		[super setOpenGLView:view];

		// set size
		winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
		
		if( __ccContentScaleFactor != 1 )
			[self updateContentScaleFactor];
		
		CCTouchDispatcher *touchDispatcher = [CCTouchDispatcher sharedDispatcher];
		[openGLView_ setTouchDelegate: touchDispatcher];
		[touchDispatcher setDispatchEvents: YES];
	}
}

#pragma mark Director - Retina Display

-(CGFloat) contentScaleFactor
{
	return __ccContentScaleFactor;
}

-(void) setContentScaleFactor:(CGFloat)scaleFactor
{
	if( scaleFactor != __ccContentScaleFactor ) {
		
		__ccContentScaleFactor = scaleFactor;
		winSizeInPixels_ = CGSizeMake( winSizeInPoints_.width * scaleFactor, winSizeInPoints_.height * scaleFactor );
		
		if( openGLView_ )
			[self updateContentScaleFactor];
		
		// update projection
		[self setProjection:projection_];
	}
}

-(void) updateContentScaleFactor
{
	// Based on code snippet from: http://developer.apple.com/iphone/prerelease/library/snippets/sp2010/sp28.html
	if ([openGLView_ respondsToSelector:@selector(setContentScaleFactor:)])
	{			
		[openGLView_ setContentScaleFactor: __ccContentScaleFactor];
		
		isContentScaleSupported_ = YES;
	}
	else
		CCLOG(@"cocos2d: 'setContentScaleFactor:' is not supported on this device");
}

-(BOOL) enableRetinaDisplay:(BOOL)enabled
{
	// Already enabled ?
	if( enabled && __ccContentScaleFactor == 2 )
		return YES;
	
	// Already disabled
	if( ! enabled && __ccContentScaleFactor == 1 )
		return YES;

	// setContentScaleFactor is not supported
	if (! [openGLView_ respondsToSelector:@selector(setContentScaleFactor:)])
		return NO;

	// SD device
	if ([[UIScreen mainScreen] scale] == 1.0)
		return NO;

	float newScale = enabled ? 2 : 1;
	[self setContentScaleFactor:newScale];
	
	return YES;
}

// overriden, don't call super
-(void) reshapeProjection:(CGSize)size
{
	winSizeInPoints_ = [openGLView_ bounds].size;
	winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
	
	[self setProjection:projection_];
}

#pragma mark Director Scene Landscape

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	CGSize s = winSizeInPoints_;
	float newY = s.height - uiPoint.y;
	float newX = s.width - uiPoint.x;
	
	CGPoint ret = CGPointZero;
	switch ( deviceOrientation_) {
		case CCDeviceOrientationPortrait:
			ret = ccp( uiPoint.x, newY );
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			ret = ccp(newX, uiPoint.y);
			break;
		case CCDeviceOrientationLandscapeLeft:
			ret.x = uiPoint.y;
			ret.y = uiPoint.x;
			break;
		case CCDeviceOrientationLandscapeRight:
			ret.x = newY;
			ret.y = newX;
			break;
	}
	
//	if( __ccContentScaleFactor != 1 && isContentScaleSupported_ )
//		ret = ccpMult(ret, __ccContentScaleFactor);
	return ret;
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	CGSize winSize = winSizeInPoints_;
	int oppositeX = winSize.width - glPoint.x;
	int oppositeY = winSize.height - glPoint.y;
	CGPoint uiPoint = CGPointZero;
	switch ( deviceOrientation_) {
		case CCDeviceOrientationPortrait:
			uiPoint = ccp(glPoint.x, oppositeY);
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			uiPoint = ccp(oppositeX, glPoint.y);
			break;
		case CCDeviceOrientationLandscapeLeft:
			uiPoint = ccp(glPoint.y, glPoint.x);
			break;
		case CCDeviceOrientationLandscapeRight:
			// Can't use oppositeX/Y because x/y are flipped
			uiPoint = ccp(winSize.width-glPoint.y, winSize.height-glPoint.x);
			break;
	}
	
	uiPoint = ccpMult(uiPoint, 1/__ccContentScaleFactor);
	return uiPoint;
}

// get the current size of the glview
-(CGSize) winSize
{
	CGSize s = winSizeInPoints_;
	
	if( deviceOrientation_ == CCDeviceOrientationLandscapeLeft || deviceOrientation_ == CCDeviceOrientationLandscapeRight ) {
		// swap x,y in landscape mode
		CGSize tmp = s;
		s.width = tmp.height;
		s.height = tmp.width;
	}
	return s;
}

-(CGSize) winSizeInPixels
{
	CGSize s = [self winSize];
	
	s.width *= CC_CONTENT_SCALE_FACTOR();
	s.height *= CC_CONTENT_SCALE_FACTOR();
	
	return s;
}

-(ccDeviceOrientation) deviceOrientation
{
	return deviceOrientation_;
}

- (void) setDeviceOrientation:(ccDeviceOrientation) orientation
{
	if( deviceOrientation_ != orientation ) {
		deviceOrientation_ = orientation;
		switch( deviceOrientation_) {
			case CCDeviceOrientationPortrait:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:NO];
				break;
			case CCDeviceOrientationPortraitUpsideDown:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIDeviceOrientationPortraitUpsideDown animated:NO];
				break;
			case CCDeviceOrientationLandscapeLeft:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];
				break;
			case CCDeviceOrientationLandscapeRight:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];
				break;
			default:
				NSLog(@"Director: Unknown device orientation");
				break;
		}
	}
}

-(void) applyOrientation
{	
	CGSize s = winSizeInPixels_;
	float w = s.width / 2;
	float h = s.height / 2;
	
	// XXX it's using hardcoded values.
	// What if the the screen size changes in the future?
	switch ( deviceOrientation_ ) {
		case CCDeviceOrientationPortrait:
			// nothing
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			// upside down
			glTranslatef(w,h,0);
			glRotatef(180,0,0,1);
			glTranslatef(-w,-h,0);
			break;
		case CCDeviceOrientationLandscapeRight:
			glTranslatef(w,h,0);
			glRotatef(90,0,0,1);
			glTranslatef(-h,-w,0);
			break;
		case CCDeviceOrientationLandscapeLeft:
			glTranslatef(w,h,0);
			glRotatef(-90,0,0,1);
			glTranslatef(-h,-w,0);
			break;
	}	
}

-(void) end
{
	// don't release the event handlers
	// They are needed in case the director is run again
	[[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
	
	[super end];
}

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
	
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval_ target:self selector:@selector(mainLoop) userInfo:nil repeats:YES];
	
	//
	//	If you want to attach the opengl view into UIScrollView
	//  uncomment this line to prevent 'freezing'.
	//	It doesn't work on with the Fast Director
	//
	//	[[NSRunLoop currentRunLoop] addTimer:animationTimer
	//								 forMode:NSRunLoopCommonModes];
}

-(void) mainLoop
{
	[self drawScene];
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

	SEL selector = @selector(mainLoop);
	NSMethodSignature* sig = [[[CCDirector sharedDirector] class]
							  instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
								invocationWithMethodSignature:sig];
	[invocation setTarget:[CCDirector sharedDirector]];
	[invocation setSelector:selector];
	[invocation performSelectorOnMainThread:@selector(invokeWithTarget:)
								 withObject:[CCDirector sharedDirector] waitUntilDone:NO];
	
//	NSInvocationOperation *loopOperation = [[[NSInvocationOperation alloc]
//											 initWithTarget:self selector:@selector(mainLoop) object:nil]
//											autorelease];
//	
//	[loopOperation performSelectorOnMainThread:@selector(start) withObject:nil
//								 waitUntilDone:NO];
}

-(void) mainLoop
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

	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(mainLoop) object:nil];
	[thread start];
	[thread release];
}

-(void) mainLoop
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

	displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(mainLoop:)];
	[displayLink setFrameInterval:frameInterval];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void) mainLoop:(id)sender
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

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
