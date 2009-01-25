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

// cocos2d imports
#import "Director.h"
#import "Camera.h"
#import "Scheduler.h"

// support imports
#import "glu.h"
#import "OpenGL_Internal.h"
#import "Texture2D.h"
#import "LabelAtlas.h"

#import "Layer.h"

#define kDefaultFPS		60.0	// 60 frames per second


@interface Director (Private)
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
@synthesize window;
@synthesize runningScene;
@synthesize displayFPS, eventsEnabled;

//
// singleton stuff
//
static Director *sharedDirector = nil;
static int _pixelFormat = RGB565;

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
	NSString *format;
	//Create a full-screen window
	winSize = [[UIScreen mainScreen] bounds];
	window = [[UIWindow alloc] initWithFrame:winSize];

	if( _pixelFormat == RGB565 )
		format = kEAGLColorFormatRGB565;
	else
		format = kEAGLColorFormatRGBA8;
	
	if( ! (self = [super initWithFrame:[window bounds] pixelFormat:format] ) )
		return nil;

	[window addSubview:self];
	
	// scenes
	runningScene = nil;
	nextScene = nil;
	scenes = [[NSMutableArray arrayWithCapacity:10] retain];
	
	oldAnimationInterval = animationInterval = 1.0 / kDefaultFPS;
	eventHandlers = [[NSMutableArray arrayWithCapacity:8] retain];
	
	[self setAlphaBlending: YES];
	[self setDepthTest: YES];
	[self setDefaultProjection];

	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// landscape
	landscape = NO;
	
	// FPS
	displayFPS = NO;
	frames = 0;
#ifdef FAST_FPS_DISPLAY
	FPSLabel = [[LabelAtlas labelAtlasWithString:@"00.0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'] retain];
#endif
	
	// paused ?
	paused = NO;
	
	// touch events enabled ?
	eventsEnabled = YES;
	
	//Show window
	[window makeKeyAndVisible];	
	return self;
}

- (void) dealloc
{
	NSLog( @"deallocing %@", self);

#ifdef FAST_FPS_DISPLAY
	[FPSLabel release];
#endif
	[eventHandlers release];
	[runningScene release];
	[scenes release];
	[window release];
	
	[super dealloc];
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
	
	glPopMatrix();
	
	if( displayFPS ) {
		glPushMatrix();
		[self applyLandscape];
		[self showFPS];
		glPopMatrix();
	}
	
	/* swap buffers */
	[self swapBuffers];	
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

+(void) setPixelFormat: (int) format
{
	if( format != RGB565 && format != RGBA8 ) {
		NSException* myException = [NSException
									exceptionWithName:@"DirectorInvalidPixelFormat"
									reason:@"Invalid Pixel Format for GL view"
									userInfo:nil];
		@throw myException;		
	}
	
	if( sharedDirector ) {
		NSException* myException = [NSException
									exceptionWithName:@"DirectorAlreadyInitialized"
									reason:@"Can't change the pixel format after the director was initialized"
									userInfo:nil];
		@throw myException;		
	}
	
	_pixelFormat = format;
}

#pragma mark Director Scene OpenGL Helper

- (void) setDefaultProjection
{
//	[self set2Dprojection];
	[self set3Dprojection];
}

-(void) set2Dprojection
{
	//Setup OpenGL projection matrix
//	glViewport(0, 0, winSize.size.width, winSize.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, winSize.size.width, 0, winSize.size.height, -1, 1);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

-(void) set3Dprojection
{
	glViewport(0, 0, winSize.size.width, winSize.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60, (GLfloat)winSize.size.width/winSize.size.height, 0.5f, 1500.0f);
	
	glMatrixMode(GL_MODELVIEW);	
	glLoadIdentity();
	gluLookAt( winSize.size.width/2, winSize.size.height/2, [Camera getZEye],
			  winSize.size.width/2, winSize.size.height/2, 0,
			  0.0f, 1.0f, 0.0f
			  );
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

#pragma mark Director Scene Landscape

-(CGPoint) convertCoordinate: (CGPoint) p
{
	int newY = winSize.size.height - p.y;
	
	CGPoint ret = CGPointMake( p.x, newY );
	if( ! landscape ) {
		ret = ret;
	} else {
	
	#if LANDSCAPE_LEFT
		ret.x = p.y;
		ret.y = p.x;
	#else
		ret.x = p.y;
		ret.y = winSize.size.width -p.x;
	#endif // LANDSCAPE_LEFT
	}

	return ret;
}

- (CGRect) winSize
{
	CGRect r = winSize;
	if( landscape ) {
		// swap x,y in landscape mode
		r.size.width = winSize.size.height;
		r.size.height = winSize.size.width;
	}
	return r;
}

-(CGRect) displaySize
{
	return winSize;
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

	[scenes addObject: runningScene];
	nextScene = [scene retain];		// retained twice
}

-(void) popScene
{	
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
	window.hidden = YES;
}

/** UnHides the Director Window & starts animation*/
-(void) unhide
{
	[self startAnimation];
	[window makeKeyAndVisible];
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

