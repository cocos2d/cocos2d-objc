//
// Shader Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ShaderTest.h"

// uniform index
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// attribute index
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};


static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Shader1",
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}


@interface ShaderNode : CCNode
{
	GLProgram	*program_;
	GLuint		vertexIndex_;
	GLuint		colorIndex_;
	GLuint		samplerIndex_;
	GLuint		texCoordIndex_;
	GLuint		matrixIndex_;
	GLuint		anchorIndex_;

	CCTexture2D	*texture_;
}
@end

@implementation ShaderNode

-(id) init
{
	if( (self=[super init]) ) {
		
		
		texture_ = [[CCTextureCache sharedTextureCache] addImage:@"grossini.png"];
		
		[self setContentSize: [texture_ contentSize]];
		
		[self setAnchorPoint:ccp(0.5f, 0.5f)];

		program_ = [[GLProgram alloc] initWithVertexShaderFilename:@"Shader.vsh"
										   fragmentShaderFilename:@"Shader.fsh"];
		
		[program_ addAttribute:@"aVertex"];
		[program_ addAttribute:@"aColor"];
		[program_ addAttribute:@"aTexCoord"];
		
		[program_ link];
		
		vertexIndex_ = [program_ attributeIndex:@"aVertex"];
		colorIndex_ = [program_ attributeIndex:@"aColor"];
		texCoordIndex_ = [program_ attributeIndex:@"aTexCoord"];

		matrixIndex_ = [program_ uniformIndex:@"uMatrix"];
		anchorIndex_ = [program_ uniformIndex:@"uAnchor"];

		samplerIndex_ = [program_ uniformIndex:@"sTexture"];
		
	}
	
	return self;
}

- (void) dealloc
{
	[program_ release];
	[super dealloc];
}

-(void) drawShader
{
	
	CGSize size = [texture_ contentSize];
	GLfloat s = [texture_ maxS];
	GLfloat t = [texture_ maxT];

	// Reverse
	GLfloat vertex[] = {
		size.width, size.height,
		0, size.height,
		size.width, 0,
		0, 0,
	};

	GLfloat texCoords[] = {0,0,
						s, 0,
						0, t,
						s, t};

	
	GLfloat colors[] = { 1, 1, 1, 1,
						1, 1, 1, 1,
						1, 1, 1, 1,
						1, 1, 1, 1,
	};
	
	GLfloat matrix[16];
	CGAffineTransform affine = [self nodeToParentTransform];
	CGAffineToGL(&affine, &matrix[0]);

	[program_ use];	
	

	glVertexAttribPointer(vertexIndex_, 2, GL_FLOAT, GL_FALSE, 0, vertex);
	glEnableVertexAttribArray(vertexIndex_);

	glVertexAttribPointer(texCoordIndex_, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
	glEnableVertexAttribArray(texCoordIndex_);

	glVertexAttribPointer(colorIndex_, 4, GL_FLOAT, GL_FALSE, 0, colors);
	glEnableVertexAttribArray(colorIndex_);


	glUniformMatrix4fv(matrixIndex_, 1, GL_FALSE, &matrix[0]);
	glUniform2f(anchorIndex_, anchorPointInPixels_.x, anchorPointInPixels_.y);

	glActiveTexture( GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texture_.name);
	
	// Set the sampler texture unit to 0
	glUniform1i ( samplerIndex_, 0 );
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end


@implementation ShaderTest
-(id) init
{
	if( (self = [super init]) ) {

		ShaderNode *node = [ShaderNode node];
		[self addChild:node];
		
		CCMoveBy *action = [CCMoveBy actionWithDuration:2 position:ccp(200,200)];
		[node runAction:action];
		
		CCRotateBy *rot = [CCRotateBy actionWithDuration:2 angle:360];
		[node runAction:rot];

		CCScaleBy *scale = [CCScaleBy actionWithDuration:2 scale:2];
		[node runAction:scale];
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark Example Shader1

@implementation Shader1
-(id) init
{
	if( (self=[super init] ) ) {

	}
	
	return self;
	
}

-(NSString *) title
{
	return @"Parallax: parent and 3 children";
}
@end

// CLASS IMPLEMENTATIONS
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
			 
	[director runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif
