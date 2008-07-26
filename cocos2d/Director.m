/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
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

#define kDefaultFPS		30.0	// 30 frames per second

@implementation Director

@synthesize animationInterval;
@synthesize window;
@synthesize runningScene;
@synthesize eventHandler;
@synthesize displayFPS;

//
// singleton stuff
//
static Director *sharedDirector;
static int _pixelFormat = RGB565;

+(void) setPixelFormat: (int) format
{
	if( format != RGB565 && format != RGBA8 ) {
		NSException* myException = [NSException
									exceptionWithName:@"DirectorInvalidPixelFormat"
									reason:@"Invalid Pixel Format for GL view"
									userInfo:nil];
		@throw myException;		
	}
	_pixelFormat = format;
}

+ (Director *)sharedDirector
{
	@synchronized(self)
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
	@synchronized(self)
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
	
	if( ! [super initWithFrame:[window bounds] pixelFormat:format] )
		return nil;

	[window addSubview:self];
	
	// scenes
	runningScene = nil;
	nextScene = nil;
	scenes = [[NSMutableArray arrayWithCapacity:10] retain];
	
	animationInterval = 1.0 / kDefaultFPS;
	eventHandler = nil;
	
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
	
	// paused ?
	paused = NO;
	
	//Show window
	[window makeKeyAndVisible];	
	return self;
}

- (void) dealloc {
	NSLog( @"deallocing %@", self);

	[runningScene release];
	[scenes release];
	[window release];
	
	[super dealloc];
}

- (void) setDefaultProjection
{
	[self set3Dprojection];
}

-(void) set2Dprojection
{
	//Setup OpenGL projection matrix
	glViewport(0, 0, winSize.size.width, winSize.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, winSize.size.width, 0, winSize.size.height, -100, 100);
	
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

-(CGPoint) convertCoordinate: (CGPoint) p
{
	int newY = winSize.size.height - p.y;
	
	CGPoint ret = CGPointMake( p.x, newY );
	if( ! landscape )
		return ret;

#if LANDSCAPE_LEFT
	ret.x = p.y;
	ret.y = p.x;
#else
	ret.x = p.y;
	ret.y = winSize.size.width -p.x;
#endif // LANDSCAPE_LEFT
	return ret;
}

//
// custom properties
//
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

//
// OpenGL helpers
//
- (void) setAlphaBlending: (BOOL) on
{
	if (on) {
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
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

//
// Scene Management
//
- (void)runScene:(Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
		
	[self pushScene: scene];
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

	[scenes addObject: scene];
	nextScene = [scene retain];		// retained twice
}

-(void) popScene
{	
	NSAssert( [scenes count]!=0, @"Abnormal error in director scene stack.");
	
	[scenes removeLastObject];
	int c = [scenes count];
	if( c == 0 ) {
		[self end];
	} else {
		nextScene = [[scenes objectAtIndex:c-1] retain];
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
	paused = YES;
}

-(void) resume
{
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

//
// timers
//
- (void)startAnimation
{
	if( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	

	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawScene) userInfo:nil repeats:YES];
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

//
// landscape mode
//
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

//
// main loop
//
- (void) drawScene
{
	/* calculate "global" dt */
	[self calculateDeltaTime];

	/* clear window */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	/* new scene */
	if( nextScene ) {
		[self setNextScene];
	}

	glPushMatrix();

	[self applyLandscape];
	
	/* draw the scene */
	[runningScene visit];
	
	glPopMatrix();

	if( displayFPS )
		[self showFPS];
	
	if( ! paused )
		[[Scheduler sharedScheduler] tick: dt];

		
	/* swap buffers */
	[self swapBuffers];
}

//
// show FPS
//
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
	Texture2D *texture = [[Texture2D alloc] initWithString:str dimensions:CGSizeMake(100,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24];
	glEnable(GL_TEXTURE_2D);
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glColor4ub(224,224,244,200);
	[texture drawAtPoint: CGPointMake(60,20)];
	[texture release];
		
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
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
	dt = (now.tv_sec - lastUpdate.tv_sec) + (now.tv_usec - lastUpdate.tv_usec) / 1000000.0;
	
	lastUpdate = now;	
}


//
// multi touch proxies
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventHandler && [eventHandler respondsToSelector:_cmd] )
		[eventHandler touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventHandler && [eventHandler respondsToSelector:_cmd] )
		[eventHandler touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventHandler && [eventHandler respondsToSelector:_cmd] )
		[eventHandler touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventHandler && [eventHandler respondsToSelector:_cmd] )
		[eventHandler touchesCancelled:touches withEvent:event];
}
@end
