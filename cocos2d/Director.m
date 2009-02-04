/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

/* Idea of decoupling Window from Director from OC3D project: http://code.google.com/p/oc3d/
 */
 
// cocos2d imports
#import "Director.h"
#import "Camera.h"
#import "Scheduler.h"
#import "LabelAtlas.h"
#import "ccMacros.h"
#import "ccExceptions.h"

// support imports
#import "Support/glu.h"
#import "Support/OpenGL_Internal.h"
#import "Support/Texture2D.h"

#import "Layer.h"

#define kDefaultFPS		60.0	// 60 frames per second


@interface Director (Private)
-(BOOL)isOpenGLAttached;
-(BOOL)initOpenGLViewWithView:(UIView *)view andRect:(CGRect)rect;

-(void) initGLDefaultValues;

-(void) mainLoop;
-(void) startAnimation;
-(void) stopAnimation;
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
@synthesize runningScene;
@synthesize displayFPS, eventsEnabled;
@synthesize openGLView=_openGLView;
@synthesize pixelFormat=_pixelFormat;

//
// singleton stuff
//
static Director *sharedDirector = nil;

+ (Director *)sharedDirector
{
	@synchronized([Director class])
	{
		if (!sharedDirector)
			[[Director alloc] init];
		
		return sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([Director class])
	{
		NSAssert(sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedDirector = [super alloc];
		return sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

- (id) init
{   
	//Create a full-screen window

	// default values
	_pixelFormat = RGB565;
	_depthBufferFormat = 0;

	// scenes
	runningScene = nil;
	nextScene = nil;
	scenes = [[NSMutableArray arrayWithCapacity:10] retain];
	
	oldAnimationInterval = animationInterval = 1.0 / kDefaultFPS;
	eventHandlers = [[NSMutableArray arrayWithCapacity:8] retain];
	
	
	// landscape
	landscape = NO;
	
	// FPS
	displayFPS = NO;
	frames = 0;
	
	// paused ?
	paused = NO;
	
	// touch events enabled ?
	eventsEnabled = YES;
	
	return self;
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);

#ifdef FAST_FPS_DISPLAY
	[FPSLabel release];
#endif
	[eventHandlers release];
	[runningScene release];
	[scenes release];
	
	[super dealloc];
}

-(void) initGLDefaultValues
{
	// This method SHOULD be called only after _openGLview was initialized
	NSAssert( _openGLView, @"_openGLView must be initialized");

	[self setAlphaBlending: YES];
	[self setDepthTest: YES];
	[self setDefaultProjection];
	
	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
#ifdef FAST_FPS_DISPLAY
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
	if( ! paused )
		[[Scheduler sharedScheduler] tick: dt];
	
	
	/* to avoid flickr, nextScene MUST be here: after tick and before draw */
	if( nextScene )
		[self setNextScene];
	
	glPushMatrix();
	
	[self applyLandscape];
	
	/* draw the scene */
	[runningScene visit];
	if( displayFPS )
		[self showFPS];
	
		glPopMatrix();
	
	/* swap buffers */
	[_openGLView swapBuffers];	
}

-(void) calculateDeltaTime
{
	struct timeval now;
	
	if( gettimeofday( &now, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	
	// new delta time
	if( nextDeltaTimeZero ) {
		dt = 0;
		nextDeltaTimeZero = NO;
	} else {
		dt = (now.tv_sec - lastUpdate.tv_sec) + (now.tv_usec - lastUpdate.tv_usec) / 1000000.0f;
		dt = MAX(0,dt);
	}
	
	lastUpdate = now;	
}

-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	nextDeltaTimeZero = YES;
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
	
	_pixelFormat = format;
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

   _depthBufferFormat = format;
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
	glOrthof(0, _openGLView.frame.size.width, 0, _openGLView.frame.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

// set a 3d projection matrix
-(void)set3Dprojection
{
	glViewport(0, 0, _openGLView.frame.size.width, _openGLView.frame.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60, (GLfloat)_openGLView.frame.size.width/_openGLView.frame.size.height, 0.5f, 1500.0f);
	
	glMatrixMode(GL_MODELVIEW);	
	glLoadIdentity();
	gluLookAt( _openGLView.frame.size.width/2, _openGLView.frame.size.height/2, [Camera getZEye],
			  _openGLView.frame.size.width/2, _openGLView.frame.size.height/2, 0,
			  0.0f, 1.0f, 0.0f);
}

- (void) setAlphaBlending: (BOOL) on
{
	if (on) {
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

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
	return ([_openGLView superview]!=nil);
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
	[_openGLView removeFromSuperview];
	
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
	if([self initOpenGLViewWithView:window andRect:[window frame]])
	{
		return YES;
	}
	
	return NO;
}

-(BOOL)attachInView:(UIView *)view
{
	if([self initOpenGLViewWithView:view andRect:[view frame]])
	{
		return YES;
	}
	
	return NO;
}

-(BOOL)attachInView:(UIView *)view with:(CGRect)frame
{
	if([self initOpenGLViewWithView:view andRect:frame])
	{
		return YES;
	}
	
	return NO;
}

-(BOOL)initOpenGLViewWithView:(UIView *)view andRect:(CGRect)rect
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
	if(!_openGLView)
	{
		// define the pixel format
		NSString	*pFormat = kEAGLColorFormatRGB565;
	    GLuint		depthFormat = 0;
		
		if(_pixelFormat==RGBA8)
			pFormat = kEAGLColorFormatRGBA8;
		
		if(_depthBufferFormat == DepthBuffer16)
			depthFormat = GL_DEPTH_COMPONENT16_OES;
		else if(_depthBufferFormat == DepthBuffer24)
			depthFormat = GL_DEPTH_COMPONENT24_OES;
		
		// alloc and init the opengl view
		_openGLView = [[EAGLView alloc] initWithFrame:rect pixelFormat:pFormat depthFormat:depthFormat preserveBackbuffer:NO];
		
		// check if the view was alloced and initialized
		if(!_openGLView)
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
		[_openGLView setAutoresizesEAGLSurface:YES];
		
		// set the touch delegate of the glview to self
		[_openGLView setTouchDelegate:self];
	}
	else
	{
		// set the (new) frame of the glview
		[_openGLView setFrame:rect];
	}
	
	// check if the superview has touchs enabled and enable it in our view
	if([view isUserInteractionEnabled])
	{
		[_openGLView setUserInteractionEnabled:YES];
		[self setEventsEnabled:YES];
	}
	else
	{
		[_openGLView setUserInteractionEnabled:NO];
		[self setEventsEnabled:NO];
	}
	
	// check if multi touches are enabled and set them
	if([view isMultipleTouchEnabled])
	{
		[_openGLView setMultipleTouchEnabled:YES];
	}
	else
	{
		[_openGLView setMultipleTouchEnabled:NO];
	}
	
	// add the glview to his (new) superview
	[view addSubview:_openGLView];
	
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
	int newY = _openGLView.frame.size.height - p.y;
	
	CGPoint ret = CGPointMake( p.x, newY );
	if( ! landscape )
	{
		ret = ret;
	}
	else 
	{
#if LANDSCAPE_LEFT
		ret.x = p.y;
		ret.y = p.x;
#else
		ret.x = p.y;
		ret.y = _openGLView.frame.size.width -p.x;
#endif // LANDSCAPE_LEFT
	}
	
	return ret;
}

// get the current size of the glview
-(CGSize)winSize
{
	CGSize s = _openGLView.frame.size;
	if( landscape ) {
		// swap x,y in landscape mode
		s.width = _openGLView.frame.size.height;
		s.height = _openGLView.frame.size.width;
	}
	return s;
}

// return  the current frame size
-(CGSize)displaySize
{
	return _openGLView.frame.size;
}

- (BOOL) landscape
{
	return landscape;
}

- (void) setLandscape: (BOOL) on
{
	if( on != landscape ) {
		landscape = on;
		if( landscape )
#if LANDSCAPE_LEFT
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];
#else
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];
#endif
		else
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:NO];

	}
	return;
}

-(void) applyLandscape
{
	if( landscape ) {
		glTranslatef(160,240,0);
		
#if LANDSCAPE_LEFT
		glRotatef(-90,0,0,1);
		glTranslatef(-240,-160,0);
#else		
		// rotate left
		glRotatef(90,0,0,1);
		glTranslatef(-240,-160,0);
#endif // LANDSCAPE_LEFT
	}	
}

#pragma mark Director Scene Management

- (void)runScene:(Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert( runningScene == nil, @"You can't run an scene if another Scene is running");
		
//	[self pushScene: scene];
	[self replaceScene: scene];
	[self startAnimation];
}

-(void) replaceScene: (Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	nextScene = [scene retain];
}

- (void) pushScene: (Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert( runningScene != nil, @"A running Scene is needed");

	[scenes addObject: runningScene];
	nextScene = [scene retain];		// retained twice
}

-(void) popScene
{	
	NSAssert( runningScene != nil, @"A running Scene is needed");

	int c = [scenes count];
	if( c == 0 ) {
		[self end];
	} else {
		nextScene = [[scenes objectAtIndex:c-1] retain];
		[scenes removeLastObject];
	}
}

-(void) end
{
	[scenes release];
	scenes = nil;

	[runningScene onExit];
	[runningScene release];
	runningScene = nil;
	[self stopAnimation];
	
	[eventHandlers release];
	eventHandlers = nil;

	if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
}

-(void) setNextScene
{
	[runningScene onExit];
	[runningScene release];
	
	[nextScene onEnter];
	runningScene = nextScene;
	
	nextScene = nil;
}

-(void) pause
{
	if( paused )
		return;

	oldAnimationInterval = animationInterval;
	
	// when paused, don't consume CPU
	[self setAnimationInterval:1/4.0];
	paused = YES;
}

-(void) resume
{
	if( ! paused )
		return;
	
	[self setAnimationInterval: oldAnimationInterval];

	if( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	
	paused = NO;
	dt = 0;
}

/** Hides the Director Window & stops animation */
-(void) hide
{
	[self stopAnimation];
//	window.hidden = YES;
}

/** UnHides the Director Window & starts animation*/
-(void) unhide
{
	[self startAnimation];
//	[window makeKeyAndVisible];
}


- (void)startAnimation
{
	if( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	

	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(mainLoop) userInfo:nil repeats:YES];
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

#pragma mark Director Events

-(void) addEventHandler:(CocosNode*) node
{
	NSAssert( node != nil, @"Director.AddEventHandler: Node must be non nil");	
	[eventHandlers insertObject:node atIndex:0];
}

-(void) removeEventHandler:(CocosNode*) node
{
	NSAssert( node != nil, @"Director.removeEventHandler: Node must be non nil");
	[eventHandlers removeObject:node];
}

//
// multi touch proxies
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventsEnabled ) {
		NSArray *copyArray = [eventHandlers copy];
		for( id eventHandler in copyArray ) {
			if( [eventHandler respondsToSelector:@selector(ccTouchesBegan:withEvent:)] ) {
				if( [eventHandler ccTouchesBegan:touches withEvent:event] == kEventHandled )
					break;
			}
		}
		
		[copyArray release];
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventsEnabled ) {
		NSArray *copyArray = [eventHandlers copy];
		for( id eventHandler in copyArray ) {
			if( [eventHandler respondsToSelector:@selector(ccTouchesMoved:withEvent:)] ) {
				if( [eventHandler ccTouchesMoved:touches withEvent:event] == kEventHandled )
					break;
			}
		}
		[copyArray release];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventsEnabled ) {
		NSArray *copyArray = [eventHandlers copy];
		for( id eventHandler in copyArray ) {
			if( [eventHandler respondsToSelector:@selector(ccTouchesEnded:withEvent:)] ) {
				if( [eventHandler ccTouchesEnded:touches withEvent:event] == kEventHandled )
					break;
			}
		}
		[copyArray release];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventsEnabled )  {
		NSArray *copyArray = [eventHandlers copy];
		for( id eventHandler in copyArray ) {
			if( [eventHandler respondsToSelector:@selector(ccTouchesCancelled:withEvent:)] ) {
				if( [eventHandler ccTouchesCancelled:touches withEvent:event] == kEventHandled )
					break;
			}
		}
		[copyArray release];
	}
}


#ifdef FAST_FPS_DISPLAY

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
	
	glColor4ub(224,224,244,200);
	[texture drawAtPoint: CGPointMake(5,2)];
	[texture release];
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}
#endif


@end

