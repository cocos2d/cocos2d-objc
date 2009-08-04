/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

/* Idea of decoupling Window from Director taken from OC3D project: http://code.google.com/p/oc3d/
 */
 
// cocos2d imports
#import "Director.h"
#import "TouchDelegateProtocol.h"
#import "Camera.h"
#import "Scheduler.h"
#import "ActionManager.h"
#import "TextureMgr.h"
#import "LabelAtlas.h"
#import "ccMacros.h"
#import "ccExceptions.h"
#import "Transition.h"
#import "Scene.h"
#import "TouchDispatcher.h"

// support imports
#import "Support/glu.h"
#import "Support/OpenGL_Internal.h"
#import "Support/Texture2D.h"
#import "Support/CGPointExtension.h"

#import "Layer.h"

#define kDefaultFPS		60.0	// 60 frames per second


@interface Director (Private)
-(BOOL)isOpenGLAttached;
-(BOOL)initOpenGLViewWithView:(UIView *)view withFrame:(CGRect)rect;

-(void) initGLDefaultValues;

-(void) mainLoop;
-(void) setNextScene;
// rotates the screen if Landscape mode is activated
-(void) applyLandscape;
// shows the FPS in the screen
-(void) showFPS;
// calculates delta time since last time it was called
-(void) calculateDeltaTime;


@end

@implementation Director

@synthesize animationInterval;
@synthesize runningScene = runningScene_;
@synthesize displayFPS;
@synthesize openGLView=openGLView_;
@synthesize pixelFormat=pixelFormat_;
@synthesize nextDeltaTimeZero=nextDeltaTimeZero_;
@synthesize deviceOrientation=deviceOrientation_;
@synthesize isPaused=isPaused_;

//
// singleton stuff
//
static Director *_sharedDirector = nil;

+ (Director *)sharedDirector
{
	@synchronized([Director class])
	{
		if (!_sharedDirector)
			[[self alloc] init];
		
		return _sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

// This function was created to avoid confussion for the users
// Calling [FastDirector sharedDirector] is enough, but is somewhat
// confusing since the user needs to understand what's under the hood
+ (void) useFastDirector
{
	NSAssert(_sharedDirector==nil, @"A Director was alloced. To use Fast Director this must be the first call to Director");
	[FastDirector sharedDirector];
}

+(id)alloc
{
	@synchronized([Director class])
	{
		NSAssert(_sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedDirector = [super alloc];
		return _sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

- (id) init
{   
	if( (self=[super init]) ) {

		// default values
		pixelFormat_ = kPixelFormatRGB565;
		depthBufferFormat_ = 0;

		// scenes
		runningScene_ = nil;
		nextScene = nil;
		
		oldAnimationInterval = animationInterval = 1.0 / kDefaultFPS;
		scenesStack_ = [[NSMutableArray arrayWithCapacity:10] retain];
		
		// landscape
		deviceOrientation_ = CCDeviceOrientationPortrait;

		// FPS
		displayFPS = NO;
		frames = 0;
		
		// paused ?
		isPaused_ = NO;
	}

	return self;
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);

#if DIRECTOR_DISPLAY_FAST_FPS
	[FPSLabel release];
#endif
	[runningScene_ release];
	[scenesStack_ release];
	
	[super dealloc];
}

-(void) initGLDefaultValues
{
	// This method SHOULD be called only after openGLView_ was initialized
	NSAssert( openGLView_, @"openGLView_ must be initialized");

	[self setAlphaBlending: YES];
	[self setDepthTest: YES];
	[self setDefaultProjection];
	
	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
#if DIRECTOR_DISPLAY_FAST_FPS
    if (!FPSLabel)
        FPSLabel = [[LabelAtlas labelAtlasWithString:@"00.0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'] retain];
#endif	
}

//
// main loop
//
- (void) mainLoop
{    
	/* clear window */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	/* calculate "global" dt */
	[self calculateDeltaTime];
	if( ! isPaused_ )
		[[Scheduler sharedScheduler] tick: dt];
	
	
	/* to avoid flickr, nextScene MUST be here: after tick and before draw */
	if( nextScene )
		[self setNextScene];
	
	glPushMatrix();
	
	[self applyLandscape];
	
	/* draw the scene */
	[runningScene_ visit];
	if( displayFPS )
		[self showFPS];
	
	glPopMatrix();
	
	/* swap buffers */
	[openGLView_ swapBuffers];	
}

-(void) calculateDeltaTime
{
	struct timeval now;
	
	if( gettimeofday( &now, NULL) != 0 ) {
		CCLOG(@"error in gettimeofday");
		dt = 0;
		return;
	}
	
	// new delta time
	if( nextDeltaTimeZero_ ) {
		dt = 0;
		nextDeltaTimeZero_ = NO;
	} else {
		dt = (now.tv_sec - lastUpdate.tv_sec) + (now.tv_usec - lastUpdate.tv_usec) / 1000000.0f;
		dt = MAX(0,dt);
	}
	
	lastUpdate = now;	
}

#pragma mark Director Scene iPhone Specific

-(void) setPixelFormat: (tPixelFormat) format
{	
	if( [self isOpenGLAttached] ) {
		NSException* myException = [NSException
									exceptionWithName:@"DirectorAlreadyInitialized"
									reason:@"Can't change the pixel format after the director was initialized"
									userInfo:nil];
		@throw myException;		
	}
	
	pixelFormat_ = format;
}

-(void) setDepthBufferFormat: (tDepthBufferFormat) format
{
	if( [self isOpenGLAttached] ) {
		NSException* myException = [NSException
                                  exceptionWithName:@"DirectorAlreadyInitialized"
                                  reason:@"Can't change the depth buffer format after the director was initialized"
                                  userInfo:nil];
		@throw myException;		
	}

   depthBufferFormat_ = format;
}

#pragma mark Director Scene OpenGL Helper

- (void) setDefaultProjection
{
//	[self set2Dprojection];
	[self set3Dprojection];
}

-(void)set2Dprojection
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, openGLView_.frame.size.width, 0, openGLView_.frame.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

// set a 3d projection matrix
-(void)set3Dprojection
{
	glViewport(0, 0, openGLView_.frame.size.width, openGLView_.frame.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60, (GLfloat)openGLView_.frame.size.width/openGLView_.frame.size.height, 0.5f, 1500.0f);
	
	glMatrixMode(GL_MODELVIEW);	
	glLoadIdentity();
	gluLookAt( openGLView_.frame.size.width/2, openGLView_.frame.size.height/2, [Camera getZEye],
			  openGLView_.frame.size.width/2, openGLView_.frame.size.height/2, 0,
			  0.0f, 1.0f, 0.0f);
}

- (void) setAlphaBlending: (BOOL) on
{
	if (on) {
		glEnable(GL_BLEND);
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	} else
		glDisable(GL_BLEND);
}

- (void) setTexture2D: (BOOL) on
{
	if (on)
		glEnable(GL_TEXTURE_2D);
	else
		glDisable(GL_TEXTURE_2D);
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
	// check if the view is attached
	if(![self isOpenGLAttached])
	{
		// the view is not attached
		NSException* myException = [NSException
									exceptionWithName:kccException_OpenGLViewNotAttached
									reason:@"Can't detach the OpenGL View, because it is not attached. Attach it first."
									userInfo:nil];
		@throw myException;
		
		return NO;
	}
	
	// remove from the superview
	[openGLView_ removeFromSuperview];
	
	// check if the view is not attached anymore
	if(![self isOpenGLAttached])
	{
		return YES;
	}
	
	// the view is still attached
	NSException* myException = [NSException
								exceptionWithName:kccException_OpenGLViewCantDetach
								reason:@"Can't detach the OpenGL View, it is still attached to the superview."
								userInfo:nil];
	@throw myException;
	
	return NO;
}

-(BOOL)attachInWindow:(UIWindow *)window
{
	if([self initOpenGLViewWithView:window withFrame:[window bounds]])
	{
		return YES;
	}
	
	return NO;
}

-(BOOL)attachInView:(UIView *)view
{
	if([self initOpenGLViewWithView:view withFrame:[view bounds]])
	{
		return YES;
	}
	
	return NO;
}

-(BOOL)attachInView:(UIView *)view withFrame:(CGRect)frame
{
	if([self initOpenGLViewWithView:view withFrame:frame])
	{
		return YES;
	}
	
	return NO;
}

-(BOOL)initOpenGLViewWithView:(UIView *)view withFrame:(CGRect)rect
{
	// check if the view is not attached
	if([self isOpenGLAttached])
	{
		// the view is already attached
		NSException* myException = [NSException
									exceptionWithName:kccException_OpenGLViewAlreadyAttached
									reason:@"Can't re-attach the OpenGL View, because it is already attached. Detach it first."
									userInfo:nil];
		@throw myException;
		
		return NO;
	}
	
	// check if the view is not initialized
	if(!openGLView_)
	{
		// define the pixel format
		NSString	*pFormat = kEAGLColorFormatRGB565;
	    GLuint		depthFormat = 0;
		
		if(pixelFormat_==kPixelFormatRGBA8888)
			pFormat = kEAGLColorFormatRGBA8;
		
		if(depthBufferFormat_ == kDepthBuffer16)
			depthFormat = GL_DEPTH_COMPONENT16_OES;
		else if(depthBufferFormat_ == kDepthBuffer24)
			depthFormat = GL_DEPTH_COMPONENT24_OES;
		
		// alloc and init the opengl view
		openGLView_ = [[EAGLView alloc] initWithFrame:rect pixelFormat:pFormat depthFormat:depthFormat preserveBackbuffer:NO];
		
		// check if the view was alloced and initialized
		if(!openGLView_)
		{
			// the view was not created
			NSException* myException = [NSException
										exceptionWithName:kccException_OpenGLViewCantInit
										reason:@"Could not alloc and init the OpenGL View."
										userInfo:nil];
			@throw myException;
			
			return NO;
		}
		
		// set autoresizing enabled when attaching the glview to another view
		[openGLView_ setAutoresizesEAGLSurface:YES];		
	}
	else
	{
		// set the (new) frame of the glview
		[openGLView_ setFrame:rect];
	}
	
	// set the touch delegate of the glview to self
	[openGLView_ setTouchDelegate: [TouchDispatcher sharedDispatcher]];

	
	// check if the superview has touchs enabled and enable it in our view
	if([view isUserInteractionEnabled])
	{
		[openGLView_ setUserInteractionEnabled:YES];
		[[TouchDispatcher sharedDispatcher] setDispatchEvents: YES];
	}
	else
	{
		[openGLView_ setUserInteractionEnabled:NO];
		[[TouchDispatcher sharedDispatcher] setDispatchEvents: NO];
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
	
	// set the background color of the glview
	//	[backgroundColor setOpenGLClearColor];
	
	// check if the glview is attached now
	if([self isOpenGLAttached])
	{
		[self initGLDefaultValues];
		return YES;
	}
	
	// the glview is not attached, but it should have been
	NSException* myException = [NSException
								exceptionWithName:kccException_OpenGLViewCantAttach
								reason:@"Can't attach the OpenGL View."
								userInfo:nil];
	@throw myException;
	
	return NO;
}

#pragma mark Director Scene Landscape

// convert a coordinate from uikit to opengl
-(CGPoint)convertCoordinate:(CGPoint)p
{
	float newY = openGLView_.frame.size.height - p.y;
	float newX = openGLView_.frame.size.width -p.x;
	
	CGPoint ret;
	switch ( deviceOrientation_) {
		case CCDeviceOrientationPortrait:
			 ret = ccp( p.x, newY );
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			ret = ccp(newX, p.y);
			break;
		case CCDeviceOrientationLandscapeLeft:
			ret.x = p.y;
			ret.y = p.x;
			break;
		case CCDeviceOrientationLandscapeRight:
			ret.x = newY;
			ret.y = newX;
			break;
		}
	return ret;
}

// get the current size of the glview
-(CGSize)winSize
{
	CGSize s = openGLView_.frame.size;
	if( deviceOrientation_ == CCDeviceOrientationLandscapeLeft || deviceOrientation_ == CCDeviceOrientationLandscapeRight ) {
		// swap x,y in landscape mode
		s.width = openGLView_.frame.size.height;
		s.height = openGLView_.frame.size.width;
	}
	return s;
}

// return  the current frame size
-(CGSize)displaySize
{
	return openGLView_.frame.size;
}

- (BOOL) landscape
{
	return deviceOrientation_ == CCDeviceOrientationLandscapeLeft;
}

- (void) setLandscape: (BOOL) on
{
	if( on )
		[self setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	else
		[self setDeviceOrientation:CCDeviceOrientationPortrait];
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
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:NO];
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

-(void) applyLandscape
{	
	// XXX it's using hardcoded values.
	// What if the the screen size changes in the future?
	switch ( deviceOrientation_ ) {
		case CCDeviceOrientationPortrait:
			// nothing
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			// upside down
			glTranslatef(160,240,0);
			glRotatef(180,0,0,1);
			glTranslatef(-160,-240,0);
			break;
		case CCDeviceOrientationLandscapeRight:
			glTranslatef(160,240,0);
			glRotatef(90,0,0,1);
			glTranslatef(-240,-160,0);
			break;
		case CCDeviceOrientationLandscapeLeft:
			glTranslatef(160,240,0);
			glRotatef(-90,0,0,1);
			glTranslatef(-240,-160,0);
			break;
	}	
}

#pragma mark Director Scene Management

- (void)runWithScene:(Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert( runningScene_ == nil, @"You can't run an scene if another Scene is running. Use replaceScene or pushScene instead");
	
	[self pushScene:scene];
	[self startAnimation];
}

-(void) replaceScene: (Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	NSUInteger index = [scenesStack_ count];

	[scenesStack_ replaceObjectAtIndex:index-1 withObject:scene];
	nextScene = scene;	// nextScene is a weak ref
}

- (void) pushScene: (Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	[scenesStack_ addObject: scene];
	nextScene = scene;	// nextScene is a weak ref
}

-(void) popScene
{	
	NSAssert( runningScene_ != nil, @"A running Scene is needed");

	[scenesStack_ removeLastObject];
	NSUInteger c = [scenesStack_ count];
	
	if( c == 0 ) {
		[self end];
	} else {
		nextScene = [scenesStack_ objectAtIndex:c-1];
	}
}

-(void) end
{
	[runningScene_ onExit];
	[runningScene_ cleanup];
	[runningScene_ release];

	runningScene_ = nil;
	nextScene = nil;
	
	// remove all objects, but don't release it.
	// runWithScene might be executed after 'end'.
	[scenesStack_ removeAllObjects];

	// don't release the event handlers
	// They are needed in case the director is run again
	[[TouchDispatcher sharedDispatcher] removeAllDelegates];
	
	[self stopAnimation];
	[self detach];
	
	// Purge all managers
	[[Scheduler sharedScheduler] release];
	[[ActionManager sharedManager] release];
	[[TextureMgr sharedTextureMgr] release];
}

-(void) setNextScene
{
	BOOL runningIsTransition = [runningScene_ isKindOfClass:[TransitionScene class]];
	BOOL newIsTransition = [nextScene isKindOfClass:[TransitionScene class]];

	// If it is not a transition, call onExit
	if( ! newIsTransition )
		[runningScene_ onExit];

	[runningScene_ release];
	
	runningScene_ = [nextScene retain];
	nextScene = nil;

	if( ! runningIsTransition ) {
		[runningScene_ onEnter];
		[runningScene_ onEnterTransitionDidFinish];
	}
}

-(void) pause
{
	if( isPaused_ )
		return;

	oldAnimationInterval = animationInterval;
	
	// when paused, don't consume CPU
	[self setAnimationInterval:1/4.0];
	isPaused_ = YES;
}

-(void) resume
{
	if( ! isPaused_ )
		return;
	
	[self setAnimationInterval: oldAnimationInterval];

	if( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	
	isPaused_ = NO;
	dt = 0;
}

- (void)startAnimation
{
	NSAssert( animationTimer == nil, @"animationTimer must be nil. Calling startAnimation twice?");

	if( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(mainLoop) userInfo:nil repeats:YES];

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
	animationInterval = interval;
	
	if(animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}

#if DIRECTOR_DISPLAY_FAST_FPS

// display the FPS using a LabelAtlas
// updates the FPS every frame
-(void) showFPS
{
	frames++;
	accumDt += dt;
	
	if ( accumDt > 0.1)  {
		frameRate = frames/accumDt;
		frames = 0;
		accumDt = 0;
	}
		
	NSString *str = [NSString stringWithFormat:@"%.1f",frameRate];
//	glTranslatef(10.0, 10.0, 0);
	[FPSLabel setString:str];
	[FPSLabel draw];
}
#else
// display the FPS using a manually generated Texture (very slow)
// updates the FPS 3 times per second aprox.
-(void) showFPS
{
	frames++;
	accumDt += dt;
	
	if ( accumDt > 0.3)  {
		frameRate = frames/accumDt;
		frames = 0;
		accumDt = 0;
	}
	
	NSString *str = [NSString stringWithFormat:@"%.2f",frameRate];
	Texture2D *texture = [[Texture2D alloc] initWithString:str dimensions:CGSizeMake(100,30) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:24];
	glEnable(GL_TEXTURE_2D);
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glColor4ub(224,224,244,200);
	[texture drawAtPoint: ccp(5,2)];
	[texture release];
	
	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}
#endif

@end

#pragma mark -
#pragma mark Director FastDirector

@implementation FastDirector

- (id) init
{
#if DIRECTOR_FASTDIRECTOR_FAST_EVENTS
	CCLOG(@"Using Fast Director with Fast Events");
#else
	CCLOG(@"Using Fast Director");
#endif

	if(( self = [super init] )) {
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

	if ( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	

	isRunning = YES;

	SEL selector = @selector(preMainLoop);
	NSMethodSignature* sig = [[[Director sharedDirector] class]
							  instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
								invocationWithMethodSignature:sig];
	[invocation setTarget:[Director sharedDirector]];
	[invocation setSelector:selector];
	[invocation performSelectorOnMainThread:@selector(invokeWithTarget:)
								 withObject:[Director sharedDirector] waitUntilDone:NO];
}

-(void) preMainLoop
{
	while (isRunning) {
	
		NSAutoreleasePool *loopPool = [NSAutoreleasePool new];

#if DIRECTOR_FASTDIRECTOR_FAST_EVENTS
		while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004f, FALSE) == kCFRunLoopRunHandledSource);
#else
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
#endif

		if (isPaused_) {
			usleep(250000); // Sleep for a quarter of a second (250,000 microseconds) so that the framerate is 4 fps.
		}
		
		[self mainLoop];

#if DIRECTOR_FASTDIRECTOR_FAST_EVENTS
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

