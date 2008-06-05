//
// cocos2d
// iPhone port
//

#import "Director.h"

#define kDefaultFPS		30.0	// 30 frames per second

@implementation Director

@synthesize winSize;
@synthesize animationInterval;
@synthesize window;

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
	
	//Show window
	[window makeKeyAndVisible];	
	return self;
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

- (void) dealloc {
	NSLog( @"deallocing %@", self);

	[GLView release];
	[window release];
	[runningScene release];
	
	[super dealloc];
}

- (void)runScene:(Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
		
	runningScene = [scene retain];
	[runningScene onEnter];
		
	[self startAnimation];
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
	[runningScene visit];
	[GLView swapBuffers];
}
@end