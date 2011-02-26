//
// Shader Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ShaderTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"ShaderMandelbrot",
	@"ShaderHeart",
	@"ShaderFlower",
	@"ShaderPlasma",
	@"ShaderBlur",
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

#pragma mark -
@implementation ShaderTest
-(id) init
{
	if( (self = [super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		[label setColor:ccRED];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];	
		
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

-(NSString*) subtitle
{
	return nil;
}

@end

#pragma mark -
#pragma mark ShaderNode

@interface ShaderNode : CCNode
{
	ccVertex2F	resolution_;
	float		time_;
	GLuint		uniformResolution, uniformTime;
}

-(void) loadShaderVertex:(NSString*)vert fragment:(NSString*)frag;
-(id) initWithVertex:(NSString*)vert fragment:(NSString*)frag;
@end

@implementation ShaderNode
enum {
	SIZE_X = 256,
	SIZE_Y = 256,
};

-(id) initWithVertex:(NSString*)vert fragment:(NSString*)frag
{
	if( (self=[super init] ) ) {
		
		[self loadShaderVertex:vert fragment:frag];
		
		time_ = 0;
		resolution_ = (ccVertex2F) { SIZE_X/2, SIZE_Y/2 };
		
		[self scheduleUpdate];
		
		[self setContentSize:CGSizeMake(SIZE_X, SIZE_Y)];
		[self setAnchorPoint:ccp(0.5f, 0.5f)];
	}
	
	return self;
}

-(void) loadShaderVertex:(NSString*)vert fragment:(NSString*)frag
{
	GLProgram *shader = [[GLProgram alloc] initWithVertexShaderFilename:vert
												 fragmentShaderFilename:frag];
	
	[shader addAttribute:@"aVertex" index:kCCAttribVertex];
	
	[shader link];
	
	[shader updateUniforms];
	
	uniformTime = glGetUniformLocation( shader->program_, "time");
	
	uniformResolution = glGetUniformLocation( shader->program_, "resolution");
	
	
	self.shaderProgram = shader;
	
	[shader release];
}

-(void) update:(ccTime) dt
{
	time_ += dt;
}


-(void) draw
{

	float w = SIZE_X, h = SIZE_Y;
	GLfloat vertices[12] = {0,0, w,0, w,h, 0,0, 0,h, w,h};

	glUseProgram( shaderProgram_->program_ );

	//
	// Uniforms
	//
	GLfloat mat4[16];	
	CGAffineToGL( &transformMV_, mat4 );
	
	// Updated Z vertex
	mat4[14] = vertexZ_;
	
	glUniformMatrix4fv( shaderProgram_->uniforms_[kCCUniformPMatrix], 1, GL_FALSE, (GLfloat*)&ccProjectionMatrix);
	glUniformMatrix4fv( shaderProgram_->uniforms_[kCCUniformMVMatrix], 1, GL_FALSE, mat4);	
	
	glUniform1f( uniformTime, time_ );

	glUniform2fv( uniformResolution, 1, (GLfloat*)&resolution_ );
	
	glDisableVertexAttribArray(kCCAttribColor);
	glDisableVertexAttribArray(kCCAttribTexCoords);

	glVertexAttribPointer(kCCAttribVertex, 2, GL_FLOAT, GL_FALSE, 0, vertices);

	glDrawArrays(GL_TRIANGLES, 0, 6);
	
	glEnableVertexAttribArray(kCCAttribColor);
	glEnableVertexAttribArray(kCCAttribTexCoords);
}
@end


#pragma mark -
#pragma mark ShaderMandelbrot

@implementation ShaderMandelbrot
-(id) init
{
	if( (self=[super init] ) ) {
		ShaderNode *mandel = [[ShaderNode alloc] initWithVertex:@"Shaders/Mandelbrot.vert" fragment:@"Shaders/Mandelbrot.frag"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[mandel setPosition:ccp(s.width/2, s.height/2)];
		[self addChild:mandel];	
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Mandelbrot shader with Zoom";
}
@end

#pragma mark -
#pragma mark ShaderHeart

@implementation ShaderHeart
-(id) init
{
	if( (self=[super init] ) ) {
		ShaderNode *node = [[ShaderNode alloc] initWithVertex:@"Shaders/Heart.vert" fragment:@"Shaders/Heart.frag"];
		
//		CGSize s = [[CCDirector sharedDirector] winSize];
//		[node setPosition:ccp(s.width/2, s.height/2)];
		[self addChild:node];	
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Tunnel";
}
@end

#pragma mark -
#pragma mark ShaderFlower

@implementation ShaderFlower
-(id) init
{
	if( (self=[super init] ) ) {
		ShaderNode *node = [[ShaderNode alloc] initWithVertex:@"Shaders/Flower.vert" fragment:@"Shaders/Flower.frag"];
		
//		CGSize s = [[CCDirector sharedDirector] winSize];
//		[node setPosition:ccp(s.width/2, s.height/2)];

		[self addChild:node];	
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Flower";
}
@end

#pragma mark -
#pragma mark ShaderPlasma

@implementation ShaderPlasma
-(id) init
{
	if( (self=[super init] ) ) {
		ShaderNode *node = [[ShaderNode alloc] initWithVertex:@"Shaders/Plasma.vert" fragment:@"Shaders/Plasma.frag"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[node setPosition:ccp(s.width/2, s.height/2)];
		
		[self addChild:node];	
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Plasma";
}
@end

#pragma mark -
#pragma mark ShaderBlur

@interface SpriteBlur : CCSprite
{
	CGPoint blur_;
	CGFloat	sub_[4];
	
	GLuint	blurLocation;
	GLuint	subLocation;
}
@end

@implementation SpriteBlur
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	if( (self=[super initWithTexture:texture rect:rect]) ) {
		
		CGSize s = [[CCDirector sharedDirector] displaySizeInPixels];
	
		blur_ = ccp(1/s.width*2, 1/s.height*2);
		sub_[0] = sub_[1] = sub_[2] = sub_[3] = 0;
		
		GLProgram *shader = [[GLProgram alloc] initWithVertexShaderFilename:@"Shaders/VertexTextureColor.vert"
													 fragmentShaderFilename:@"Shaders/Blur.frag"];
//													 fragmentShaderFilename:@"Shaders/VertexTextureColor.frag"];

		CHECK_GL_ERROR_DEBUG();

		[shader addAttribute:@"aVertex" index:kCCAttribVertex];
		[shader addAttribute:@"aColor" index:kCCAttribColor];
		[shader addAttribute:@"aTexCoord" index:kCCAttribTexCoords];
		
		CHECK_GL_ERROR_DEBUG();
		
		[shader link];

		CHECK_GL_ERROR_DEBUG();
		
		[shader updateUniforms];

		CHECK_GL_ERROR_DEBUG();

		blurLocation = glGetUniformLocation( shader->program_, "blurSize");
		subLocation = glGetUniformLocation( shader->program_, "subtract");
		
		CHECK_GL_ERROR_DEBUG();

		self.shaderProgram = shader;
		
		[shader release];
	}
	
	return self;
}

-(void) draw
{
	// Default Attribs & States: GL_TEXTURE0, k,CCAttribVertex, kCCAttribColor, kCCAttribTexCoords
	// Needed states: GL_TEXTURE0, k,CCAttribVertex, kCCAttribColor, kCCAttribTexCoords
	// Unneeded states: -
	
	BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	glUseProgram( shaderProgram_->program_ );
	
	CHECK_GL_ERROR_DEBUG();
	
	//
	// Uniforms
	//
	GLfloat mat4[16];	
	CGAffineToGL( &transformMV_, mat4 );
	
	// Updated Z vertex
	mat4[14] = vertexZ_;
	
	glUniformMatrix4fv( shaderProgram_->uniforms_[kCCUniformPMatrix], 1, GL_FALSE, (GLfloat*)&ccProjectionMatrix);
	glUniformMatrix4fv( shaderProgram_->uniforms_[kCCUniformMVMatrix], 1, GL_FALSE, mat4);	
	glUniform1i ( shaderProgram_->uniforms_[kCCUniformSampler], 0 );
	CHECK_GL_ERROR_DEBUG();

	
	glUniform2f( blurLocation, blur_.x, blur_.y );
	glUniform4f( subLocation, sub_[0], sub_[1], sub_[2], sub_[3] );
	
	CHECK_GL_ERROR_DEBUG();

	
	glBindTexture(GL_TEXTURE_2D, [texture_ name]);	
	
	//
	// Attributes
	//
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
	
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCAttribVertex, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
	
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCAttribTexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
	
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
	
	
	CHECK_GL_ERROR_DEBUG();

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);	
	
	CHECK_GL_ERROR_DEBUG();
}
@end


@implementation ShaderBlur
-(id) init
{
	if( (self=[super init] ) ) {

		CCSprite *blurSprite = [SpriteBlur spriteWithFile:@"grossini.png"];
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[blurSprite setPosition:ccp(s.width/3, s.height/2)];
		[sprite setPosition:ccp(2*s.width/3, s.height/2)];
		
		[self addChild:blurSprite];	
		[self addChild:sprite];	
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Blur";
}
@end


// CLASS IMPLEMENTATIONS
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark -
#pragma mark AppController

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
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
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

//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];

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
