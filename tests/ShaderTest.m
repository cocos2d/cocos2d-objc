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


@interface ShaderNode : CCNode <CCRGBAProtocol>
{
	GLProgram	*program_;
	GLuint		vertexIndex_;
	GLuint		colorIndex_;
	GLuint		samplerIndex_;
	GLuint		texCoordIndex_;
	GLuint		matrixIndex_;
	GLuint		projMatrixIndex_;

	CCTexture2D	*texture_;
	
	ccColor3B	color_;
	ccColor3B	colorUnmodified_;
	GLubyte		opacity_;
	
}
@property (nonatomic,readwrite) ccColor3B color;
@property (nonatomic, readwrite) GLubyte opacity;

-(id) initWithName:(NSString *)name;
@end

@implementation ShaderNode

-(id) initWithName:(NSString*)name
{
	if( (self=[super init]) ) {
		
		
		texture_ = [[CCTextureCache sharedTextureCache] addImage:name];
		
		color_ = colorUnmodified_ = ccWHITE;
		opacity_ = 255;

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
		projMatrixIndex_ = [program_ uniformIndex:@"uProjMatrix"];		

		samplerIndex_ = [program_ uniformIndex:@"sTexture"];
		
	}
	
	return self;
}

- (void) dealloc
{
	[program_ release];
	[super dealloc];
}

-(GLubyte) opacity
{
	return opacity_;
}

-(void) setOpacity:(GLubyte) anOpacity
{
	opacity_			= anOpacity;
	
	// special opacity for premultiplied textures
	[self setColor: colorUnmodified_];	
}

- (ccColor3B) color
{
	return colorUnmodified_;
}

-(void) setColor:(ccColor3B)color3
{
	color_ = colorUnmodified_ = color3;
	
	color_.r = color3.r * opacity_/255;
	color_.g = color3.g * opacity_/255;
	color_.b = color3.b * opacity_/255;
}

-(void) drawShader
{
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	GLfloat projectionMatrix[16] = {
						2.0/winSize.width, 0.0, 0.0, -1.0,
						0.0, 2.0/winSize.height, 0.0, -1.0,
						0.0, 0.0, -1.0, 0.0,
						0.0, 0.0, 0.0, 1.0 };
	
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

	GLfloat r = color_.r / 255.0f;
	GLfloat g = color_.g / 255.0f;
	GLfloat b = color_.b / 255.0f;
	GLfloat a = opacity_ / 255.0f;

	GLfloat colors[] = { r,g,b,a,
		r,g,b,a,
		r,g,b,a,
		r,g,b,a,
	};
	
	CGAffineToGL(&transformToWorld_, &transformGL_[0] );
	isTransformDirty_ = NO;

	[program_ use];	
	

	glVertexAttribPointer(vertexIndex_, 2, GL_FLOAT, GL_FALSE, 0, vertex);
	glEnableVertexAttribArray(vertexIndex_);

	glVertexAttribPointer(texCoordIndex_, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
	glEnableVertexAttribArray(texCoordIndex_);

	glVertexAttribPointer(colorIndex_, 4, GL_FLOAT, GL_FALSE, 0, colors);
	glEnableVertexAttribArray(colorIndex_);

	glUniformMatrix4fv(matrixIndex_, 1, GL_FALSE, &transformGL_[0]);
	glUniformMatrix4fv(projMatrixIndex_, 1, GL_FALSE, &projectionMatrix[0]);

	
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

		ShaderNode *node = [[ShaderNode alloc] initWithName:@"grossini.png"];
		[self addChild:node];

		CCMoveBy *action = [CCMoveBy actionWithDuration:2 position:ccp(200,200)];
		[node runAction:action];
		
		CCRotateBy *rot = [CCRotateBy actionWithDuration:2 angle:360];
		[node runAction:rot];

		CCScaleBy *scale = [CCScaleBy actionWithDuration:2 scale:2];
		[node runAction:scale];
		
		ShaderNode *node2 = [[ShaderNode alloc] initWithName:@"grossinis_sister1.png"];
		[self addChild:node2 z:1];
		[node2 setPosition:ccp(200,200)];
		
		CCFadeOut *fade = [CCFadeOut actionWithDuration:2];
		id fade_back = [fade reverse];
		id seq = [CCSequence actions:fade, fade_back, nil];
		[node2 runAction: [CCRepeatForever actionWithAction:seq]];

		ShaderNode *node3 = [[ShaderNode alloc] initWithName:@"grossinis_sister2.png"];
		[self addChild:node3 z:-1];
		[node3 setPosition:ccp(100,200)];
		
		id moveup = [CCMoveBy actionWithDuration:2 position:ccp(0,200)];
		id movedown = [moveup reverse];
		id seq2 = [CCSequence actions:moveup, movedown, nil];
		[node3 runAction:[CCRepeatForever actionWithAction:seq2]];

		ShaderNode *node3_b = [[ShaderNode alloc] initWithName:@"grossinis_sister2.png"];
		[node3 addChild:node3_b z:1];
		[node3_b setPosition:ccp(10,10)];
		[node3_b setScale:0.5f];
		
		id rot2 = [CCRotateBy actionWithDuration:2 angle:360];
		[node3_b runAction:[CCRepeatForever actionWithAction:rot2]];
		
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
