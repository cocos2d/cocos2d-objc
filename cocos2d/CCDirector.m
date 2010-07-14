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


/* Idea of decoupling Window from Director taken from OC3D project: http://code.google.com/p/oc3d/
 */
 
#import <unistd.h>

// cocos2d imports
#import "CCDirector.h"
#import "CCTouchDelegateProtocol.h"
#import "CCCamera.h"
#import "CCScheduler.h"
#import "CCActionManager.h"
#import "CCTextureCache.h"
#import "CCLabelAtlas.h"
#import "ccMacros.h"
#import "ccExceptions.h"
#import "CCTransition.h"
#import "CCScene.h"
#import "CCTouchDispatcher.h"
#import "CCSpriteFrameCache.h"
#import "CCTexture2D.h"
#import "CCBitmapFontAtlas.h"

// support imports
#import "Support/glu.h"
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

#import "CCLayer.h"

#if CC_ENABLE_PROFILERS
#import "Support/CCProfiling.h"
#endif

#define kDefaultFPS		60.0	// 60 frames per second

extern NSString * cocos2dVersion(void);


@interface CCDirector (Private)
-(BOOL)isOpenGLAttached;
-(BOOL)initOpenGLViewWithView:(UIView *)view withFrame:(CGRect)rect;

-(void) preMainLoop;
-(void) setNextScene;
// shows the FPS in the screen
-(void) showFPS;
// calculates delta time since last time it was called
-(void) calculateDeltaTime;
-(void) updateContentScaleFactor;

#if CC_ENABLE_PROFILERS
- (void) showProfilers;
#endif

@end

@implementation CCDirector

@synthesize animationInterval=animationInterval_;
@synthesize runningScene = runningScene_;
@synthesize displayFPS = displayFPS_;
@synthesize pixelFormat=pixelFormat_;
@synthesize nextDeltaTimeZero=nextDeltaTimeZero_;
@synthesize deviceOrientation=deviceOrientation_;
@synthesize isPaused=isPaused_;
@synthesize sendCleanupToScene=sendCleanupToScene_;

//
// singleton stuff
//
static CCDirector *_sharedDirector = nil;

+ (CCDirector *)sharedDirector
{
	if (!_sharedDirector) {

		//
		// Default Director is TimerDirector
		// 
		if( [ [CCDirector class] isEqual:[self class]] )
			_sharedDirector = [[CCTimerDirector alloc] init];
		else
			_sharedDirector = [[self alloc] init];
	}
		
	return _sharedDirector;
}

+ (BOOL) setDirectorType:(ccDirectorType)type
{
	NSAssert(_sharedDirector==nil, @"A Director was alloced. setDirectorType must be the first call to Director");

	if( type == CCDirectorTypeDisplayLink ) {
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		
		if([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending)
			return NO;
	}
	switch (type) {
		case CCDirectorTypeNSTimer:
			[CCTimerDirector sharedDirector];
			break;
		case CCDirectorTypeDisplayLink:
			[CCDisplayLinkDirector sharedDirector];
			break;
		case CCDirectorTypeMainLoop:
			[CCFastDirector sharedDirector];
			break;
		case CCDirectorTypeThreadMainLoop:
			[CCThreadedFastDirector sharedDirector];
			break;
		default:
			NSAssert(NO,@"Unknown director type");
	}
	
	return YES;
}

+(id)alloc
{
	NSAssert(_sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

- (id) init
{  
	CCLOG(@"cocos2d: %@", cocos2dVersion() );

	if( (self=[super init]) ) {

		CCLOG(@"cocos2d: Using Director Type:%@", [self class]);
		
		// default values
		pixelFormat_ = kCCPixelFormatDefault;
		depthBufferFormat_ = 0;

		// scenes
		runningScene_ = nil;
		nextScene_ = nil;
		
		oldAnimationInterval_ = animationInterval_ = 1.0 / kDefaultFPS;
		scenesStack_ = [[NSMutableArray alloc] initWithCapacity:10];
		
		// landscape
		deviceOrientation_ = CCDeviceOrientationPortrait;

		// FPS
		displayFPS_ = NO;
		frames_ = 0;
		
		// paused ?
		isPaused_ = NO;
		
		contentScaleFactor_ = 1;
		screenSize_ = surfaceSize_ = CGSizeZero;
		isContentScaleSupported_ = NO;
	}

	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

#if CC_DIRECTOR_FAST_FPS
	[FPSLabel_ release];
#endif
	[runningScene_ release];
	[scenesStack_ release];
	
	_sharedDirector = nil;
	
	[super dealloc];
}

-(void) setGLDefaultValues
{
	// This method SHOULD be called only after openGLView_ was initialized
	NSAssert( openGLView_, @"openGLView_ must be initialized");

	[self setAlphaBlending: YES];
	[self setDepthTest: YES];
	[self setProjection: kCCDirectorProjectionDefault];
	
	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
#if CC_DIRECTOR_FAST_FPS
    if (!FPSLabel_) {
		CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		FPSLabel_ = [[CCLabelAtlas labelAtlasWithString:@"00.0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'] retain];
		[CCTexture2D setDefaultAlphaPixelFormat:currentFormat];		
	}
#endif	// CC_DIRECTOR_FAST_FPS
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
	if( displayFPS_ )
		[self showFPS];
	
#if CC_ENABLE_PROFILERS
	[self showProfilers];
#endif
	
	CC_DISABLE_DEFAULT_GL_STATES();
	
	glPopMatrix();
	
	/* swap buffers */
	[openGLView_ swapBuffers];	
}

-(void) calculateDeltaTime
{
	struct timeval now;
	
	if( gettimeofday( &now, NULL) != 0 ) {
		CCLOG(@"cocos2d: error in gettimeofday");
		dt = 0;
		return;
	}
	
	// new delta time
	if( nextDeltaTimeZero_ ) {
		dt = 0;
		nextDeltaTimeZero_ = NO;
	} else {
		dt = (now.tv_sec - lastUpdate_.tv_sec) + (now.tv_usec - lastUpdate_.tv_usec) / 1000000.0f;
		dt = MAX(0,dt);
	}
	
	lastUpdate_ = now;	
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

#pragma mark Director - Memory Helper

-(void) purgeCachedData
{
	[CCBitmapFontAtlas purgeCachedData];	
	[CCTextureCache purgeSharedTextureCache];	
}

#pragma mark Director - Scene OpenGL Helper

-(ccDirectorProjection) projection
{
	return projection_;
}

-(float) getZEye
{
	return ( surfaceSize_.height / 1.1566f );
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CGSize size = surfaceSize_;
	switch (projection) {
		case kCCDirectorProjection2D:
			glViewport(0, 0, size.width, size.height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glOrthof(0, size.width, 0, size.height, -1024, 1024);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();			
			break;

		case kCCDirectorProjection3D:
			glViewport(0, 0, size.width, size.height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(60, (GLfloat)size.width/size.height, 0.5f, 1500.0f);
			
			glMatrixMode(GL_MODELVIEW);	
			glLoadIdentity();
			gluLookAt( size.width/2, size.height/2, [self getZEye],
					  size.width/2, size.height/2, 0,
					  0.0f, 1.0f, 0.0f);			
			break;
			
		case kCCDirectorProjectionCustom:
			// if custom, ignore it. The user is resposible for setting the correct projection
			break;
			
		default:
			CCLOG(@"cocos2d: Director: unrecognized projecgtion");
			break;
	}
	
	projection_ = projection;
}

- (void) setAlphaBlending: (BOOL) on
{
	if (on) {
		glEnable(GL_BLEND);
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
		
	} else
		glDisable(GL_BLEND);
}

- (void) setDepthTest: (BOOL) on
{
	if (on) {
		glClearDepthf(1.0f);
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	} else
		glDisable( GL_DEPTH_TEST );
}

#pragma mark Director Integration with a UIKit view

// is the view currently attached
-(BOOL)isOpenGLAttached
{
	return ([openGLView_ superview]!=nil);
}

// detach or attach to a view or a window
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
		openGLView_ = [[EAGLView alloc] initWithFrame:rect pixelFormat:pFormat depthFormat:depthFormat preserveBackbuffer:NO];
		
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
	
	screenSize_ = rect.size;
	surfaceSize_ = CGSizeMake(screenSize_.width * contentScaleFactor_, screenSize_.height * contentScaleFactor_);

	
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

-(EAGLView*) openGLView
{
	return openGLView_;
}

-(void) setOpenGLView:(EAGLView *)view
{
	NSAssert( view, @"EAGView must be non-nil");

	if( view != openGLView_ ) {
		[openGLView_ release];
		openGLView_ = [view retain];
		
		// set size
		screenSize_ = [view bounds].size;
		surfaceSize_ = CGSizeMake(screenSize_.width * contentScaleFactor_, screenSize_.height *contentScaleFactor_);

		if( contentScaleFactor_ != 1 )
			[self updateContentScaleFactor];
		
		CCTouchDispatcher *touchDispatcher = [CCTouchDispatcher sharedDispatcher];
		[openGLView_ setTouchDelegate: touchDispatcher];
		[touchDispatcher setDispatchEvents: YES];


		[self setGLDefaultValues];
	}
}

-(void) updateContentScaleFactor
{
	// Based on code snippet from: http://developer.apple.com/iphone/prerelease/library/snippets/sp2010/sp28.html
	if ([openGLView_ respondsToSelector:@selector(setContentScaleFactor:)])
	{			
		// XXX: To avoid compile warning when using Xcode 3.2.2
		// Version 1.0 will only support Xcode 3.2.3 or newer
		typedef void (*CC_CONTENT_SCALE)(id, SEL, float);
		
		SEL selector = @selector(setContentScaleFactor:);
		CC_CONTENT_SCALE method = (CC_CONTENT_SCALE) [openGLView_ methodForSelector:selector];
		method(openGLView_,selector, contentScaleFactor_);
		
//		[openGLView_ setContentScaleFactor: contentScaleFactor_];

		isContentScaleSupported_ = YES;
	}
	else
	{
		CCLOG(@"cocos2d: WARNING: calling setContentScaleFactor on iOS < 4. Using fallback mechanism");
		/* on pre-4.0 iOS, use bounds/transform */
		openGLView_.bounds = CGRectMake(0, 0,
										openGLView_.bounds.size.width * contentScaleFactor_,
										openGLView_.bounds.size.height * contentScaleFactor_);
		openGLView_.transform = CGAffineTransformScale(openGLView_.transform, 1 / contentScaleFactor_, 1 / contentScaleFactor_); 
		
		isContentScaleSupported_ = NO;
	}
}

-(void) recalculateProjectionAndEAGLViewSize
{
	screenSize_ = [openGLView_ bounds].size;
	surfaceSize_ = CGSizeMake(screenSize_.width * contentScaleFactor_, screenSize_.height *contentScaleFactor_);
	
	[self setProjection:projection_];
}

#pragma mark Director Scene Landscape

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	CGSize s = screenSize_;
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

	if( contentScaleFactor_ != 1 && isContentScaleSupported_ )
		ret = ccpMult(ret, contentScaleFactor_);
	return ret;
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	CGSize winSize = surfaceSize_;
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
	
	uiPoint = ccpMult(uiPoint, 1/contentScaleFactor_);
	return uiPoint;
}

// get the current size of the glview
-(CGSize)winSize
{
	CGSize s = surfaceSize_;
	
	if( deviceOrientation_ == CCDeviceOrientationLandscapeLeft || deviceOrientation_ == CCDeviceOrientationLandscapeRight ) {
		// swap x,y in landscape mode
		CGSize tmp = s;
		s.width = tmp.height;
		s.height = tmp.width;
	}
	return s;
}

// return  the current frame size
-(CGSize)displaySize
{
	return surfaceSize_;
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
	CGSize s = surfaceSize_;
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

#pragma mark Director Scene Management

- (void)runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert( runningScene_ == nil, @"You can't run an scene if another Scene is running. Use replaceScene or pushScene instead");
	
	[self pushScene:scene];
	[self startAnimation];	
}

-(void) replaceScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	NSUInteger index = [scenesStack_ count];
	
	sendCleanupToScene_ = YES;
	[scenesStack_ replaceObjectAtIndex:index-1 withObject:scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

- (void) pushScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	sendCleanupToScene_ = NO;

	[scenesStack_ addObject: scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

-(void) popScene
{	
	NSAssert( runningScene_ != nil, @"A running Scene is needed");

	[scenesStack_ removeLastObject];
	NSUInteger c = [scenesStack_ count];
	
	if( c == 0 ) {
		[self end];
	} else {
		nextScene_ = [scenesStack_ objectAtIndex:c-1];
	}
}

-(void) end
{
	[runningScene_ onExit];
	[runningScene_ cleanup];
	[runningScene_ release];

	runningScene_ = nil;
	nextScene_ = nil;
	
	// remove all objects, but don't release it.
	// runWithScene might be executed after 'end'.
	[scenesStack_ removeAllObjects];

	// don't release the event handlers
	// They are needed in case the director is run again
	[[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
	
	[self stopAnimation];
	
#if CC_DIRECTOR_FAST_FPS
	[FPSLabel_ release];
	FPSLabel_ = nil;
#endif	

	// Purge bitmap cache
	[CCBitmapFontAtlas purgeCachedData];

	// Purge all managers
	[CCSpriteFrameCache purgeSharedSpriteFrameCache];
	[CCScheduler purgeSharedScheduler];
	[CCActionManager purgeSharedManager];
	[CCTextureCache purgeSharedTextureCache];
	
	
	// OpenGL view
	
	// Since the director doesn't attach the openglview to the window
	// it shouldn't remove it from the window too.
//	[openGLView_ removeFromSuperview];

	[openGLView_ release];
	openGLView_ = nil;
}

-(void) setNextScene
{
	Class transClass = [CCTransitionScene class];
	BOOL runningIsTransition = [runningScene_ isKindOfClass:transClass];
	BOOL newIsTransition = [nextScene_ isKindOfClass:transClass];

	// If it is not a transition, call onExit/cleanup
	if( ! newIsTransition ) {
		[runningScene_ onExit];

		// issue #709. the root node (scene) should receive the cleanup message too
		// otherwise it might be leaked.
		if( sendCleanupToScene_)
			[runningScene_ cleanup];
	}

	[runningScene_ release];
	
	runningScene_ = [nextScene_ retain];
	nextScene_ = nil;

	if( ! runningIsTransition ) {
		[runningScene_ onEnter];
		[runningScene_ onEnterTransitionDidFinish];
	}
}

-(void) pause
{
	if( isPaused_ )
		return;

	oldAnimationInterval_ = animationInterval_;
	
	// when paused, don't consume CPU
	[self setAnimationInterval:1/4.0];
	isPaused_ = YES;
}

-(void) resume
{
	if( ! isPaused_ )
		return;
	
	[self setAnimationInterval: oldAnimationInterval_];

	if( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: Director: Error in gettimeofday");
	}
	
	isPaused_ = NO;
	dt = 0;
}

- (void)startAnimation
{
	CCLOG(@"cocos2d: Director#startAnimation. Override me");
}

- (void)stopAnimation
{
	CCLOG(@"cocos2d: Director#stopAnimation. Override me");
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	CCLOG(@"cocos2d: Director#setAnimationInterval. Override me");
}

#if CC_DIRECTOR_FAST_FPS

// display the FPS using a LabelAtlas
// updates the FPS every frame
-(void) showFPS
{
	frames_++;
	accumDt_ += dt;
	
	if ( accumDt_ > CC_DIRECTOR_FPS_INTERVAL)  {
		frameRate_ = frames_/accumDt_;
		frames_ = 0;
		accumDt_ = 0;

//		sprintf(format,"%.1f",frameRate);
//		[FPSLabel setCString:format];

		NSString *str = [[NSString alloc] initWithFormat:@"%.1f", frameRate_];
		[FPSLabel_ setString:str];
		[str release];
	}
		
	[FPSLabel_ draw];
}
#else
// display the FPS using a manually generated Texture (very slow)
// updates the FPS 3 times per second aprox.
-(void) showFPS
{
	frames++;
	accumDt += dt;
	
	if ( accumDt > CC_DIRECTOR_FPS_INTERVAL)  {
		frameRate = frames/accumDt;
		frames = 0;
		accumDt = 0;
	}
	
	NSString *str = [NSString stringWithFormat:@"%.2f",frameRate];
	CCTexture2D *texture = [[CCTexture2D alloc] initWithString:str dimensions:CGSizeMake(100,30) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:24];

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	glDisableClientState(GL_COLOR_ARRAY);
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glColor4ub(224,224,244,200);
	[texture drawAtPoint: ccp(5,2)];
	[texture release];
	
	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// restore default GL state
	glEnableClientState(GL_COLOR_ARRAY);
}
#endif

#if CC_ENABLE_PROFILERS
- (void) showProfilers {
	accumDtForProfiler_ += dt;
	if (accumDtForProfiler_ > 1.0f) {
		accumDtForProfiler_ = 0;
		[[CCProfiler sharedProfiler] displayTimers];
	}
}
#endif

-(CGFloat) contentScaleFactor
{
	return contentScaleFactor_;
}

-(void) setContentScaleFactor:(CGFloat)scaleFactor
{
	if( scaleFactor != contentScaleFactor_ ) {

		contentScaleFactor_ = scaleFactor;
		surfaceSize_ = CGSizeMake( screenSize_.width * scaleFactor, screenSize_.height * scaleFactor );

		if( openGLView_ )
			[self updateContentScaleFactor];

		// update projection
		[self setProjection:projection_];
	}
}

@end

#pragma mark -
#pragma mark Director TimerDirector

@implementation CCTimerDirector
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
#pragma mark Director FastDirector

@implementation CCFastDirector

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
#pragma mark Director ThreadedFastDirector

@implementation CCThreadedFastDirector

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
#pragma mark DisplayLinkDirector

// Allows building DisplayLinkDirector for pre-3.1 SDKS
// without getting compiler warnings.
@interface NSObject(CADisplayLink)
+ (id) displayLinkWithTarget:(id)arg1 selector:(SEL)arg2;
- (void) addToRunLoop:(id)arg1 forMode:(id)arg2;
- (void) setFrameInterval:(int)interval;
- (void) invalidate;
@end

@implementation CCDisplayLinkDirector

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
