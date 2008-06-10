//
//	Director.m
//	cocos2d
//

#import "Director.h"

#define kDefaultFPS		30.0	// 30 frames per second

@implementation Director

@synthesize animationInterval;
@synthesize window;
@synthesize runningScene;

//
// singleton stuff
//
static Director *sharedDirector;

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
	if( ! [super init] )
		return nil;

	runningScene = nil;
	nextScene = nil;
	animationInterval = 1.0 / kDefaultFPS;
	
	winSize = [[UIScreen mainScreen] bounds];
	
	//Create a full-screen window
	window = [[UIWindow alloc] initWithFrame:winSize];
		
	//Create the OpenGL view and add it to the window  kEAGLColorFormat
	GLView = [[EAGLView alloc] initWithFrame:[window bounds] pixelFormat:kEAGLColorFormatRGB565];
	[window addSubview:GLView];
	
	
	[self setAlphaBlending: YES];
	[self setDepthTest: NO];
	[self setDefaultProjection];
	
	// landscape
	landscape = NO;
	
	//Show window
	[window makeKeyAndVisible];	
	return self;
}

- (void) dealloc {
	NSLog( @"deallocing %@", self);
	
	[GLView release];
	[window release];
	[runningScene release];
	
	[super dealloc];
}

- (void) setDefaultProjection
{
	//Setup OpenGL projection matrix
	glLoadIdentity();
	glViewport(0, 0, winSize.size.width, winSize.size.height);
	glMatrixMode(GL_PROJECTION);
	glOrthof(0, winSize.size.width, 0, winSize.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
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

- (BOOL) landscape
{
	return landscape;
}

- (void) setLandscape: (BOOL) on
{
	if( on != landscape ) {
		landscape = on;
//		[self setDefaultProjection];
	}
	return;
}

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

- (void)runScene:(Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
		
	runningScene = [scene retain];
	[runningScene onEnter];
		
	[self startAnimation];
}

-(void) replaceScene: (Scene*) scene
{
	nextScene = [scene retain];
}

- (void) pushScene: (Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
}

-(void) popScene
{
}

- (void)startAnimation
{
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

- (void) drawScene
{
	/* clear window */
	glClear( GL_COLOR_BUFFER_BIT );
//	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	/* landscape or portrait mode */
	glLoadIdentity();
	if( landscape ) {
		glTranslatef(160,240,0);
		glRotatef(-90,0,0,1);
		glTranslatef(-240,-160,0);
	}
	
	/* draw the scene */
	[runningScene visit];
	
	/* swap buffers */
	[GLView swapBuffers];
	
	/* new scene */
	if( nextScene ) {
		[self setNextScene];
	}
}

-(void) setNextScene
{
	[runningScene onExit];
	[runningScene release];
	
	[nextScene onEnter];
	runningScene = nextScene;

	nextScene = nil;
}
@end