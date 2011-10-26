//
// Shader Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ShaderTest.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "RootViewController.h"
#endif

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"ShaderMonjori",
	@"ShaderMandelbrot",
	@"ShaderJulia",
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
	GLuint		uniformCenter, uniformResolution, uniformTime;
}

+(id) shaderNodeWithVertex:(NSString*)vert fragment:(NSString*)frag;
-(id) initWithVertex:(NSString*)vert fragment:(NSString*)frag;
-(void) loadShaderVertex:(NSString*)vert fragment:(NSString*)frag;
@end

@implementation ShaderNode
enum {
	SIZE_X = 256,
	SIZE_Y = 256,
};

+(id) shaderNodeWithVertex:(NSString*)vert fragment:(NSString*)frag {
	return [[[self alloc] initWithVertex:vert fragment:frag] autorelease];
}

-(id) initWithVertex:(NSString*)vert fragment:(NSString*)frag
{
	if( (self=[super init] ) ) {
		
		[self loadShaderVertex:vert fragment:frag];

		time_ = 0;
		resolution_ = (ccVertex2F) { SIZE_X, SIZE_Y };
		
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
	
	[shader addAttribute:@"aVertex" index:kCCVertexAttrib_Position];
	
	[shader link];
	
	[shader updateUniforms];

	uniformCenter = glGetUniformLocation( shader->program_, "center");
	uniformResolution = glGetUniformLocation( shader->program_, "resolution");
	uniformTime = glGetUniformLocation( shader->program_, "time");
	
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

	ccGLUseProgram( shaderProgram_->program_ );

	//
	// Uniforms
	//
	
	ccGLUniformModelViewProjectionMatrix( shaderProgram_ );

	glUniform2fv( uniformCenter, 1, (GLfloat*)&position_ );
	glUniform2fv( uniformResolution, 1, (GLfloat*)&resolution_ );
	glUniform1f( uniformTime, time_ );
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);

	glDrawArrays(GL_TRIANGLES, 0, 6);	
}
@end

#pragma mark -
#pragma mark ShaderMonjori

@implementation ShaderMonjori

-(id) init
{
	if( (self=[super init]) ) {
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"Monjori.vsh" fragment:@"Monjori.fsh"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[sn setPosition:ccp(s.width/2, s.height/2)];
		
		[self addChild:sn];
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Monjori plane deformations";
}

@end

#pragma mark -
#pragma mark ShaderMandelbrot

@implementation ShaderMandelbrot
-(id) init
{
	if( (self=[super init] ) ) {
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"Mandelbrot.vsh" fragment:@"Mandelbrot.fsh"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[sn setPosition:ccp(s.width/2, s.height/2)];
		
		[self addChild:sn];
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
#pragma mark ShaderJulia

@implementation ShaderJulia
-(id) init
{
	if( (self=[super init] ) ) {
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"Julia.vsh" fragment:@"Julia.fsh"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[sn setPosition:ccp(s.width/2, s.height/2)];
		
		[self addChild:sn];
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Julia shader";
}
@end


#pragma mark -
#pragma mark ShaderHeart

@implementation ShaderHeart
-(id) init
{
	if( (self=[super init] ) ) {
		
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"Heart.vsh" fragment:@"Heart.fsh"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[sn setPosition:ccp(s.width/2, s.height/2)];

		[self addChild:sn];
	}
	
	return self;	
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Heart";
}
@end

#pragma mark -
#pragma mark ShaderFlower

@implementation ShaderFlower
-(id) init
{
	if( (self=[super init] ) ) {
		
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"Flower.vsh" fragment:@"Flower.fsh"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[sn setPosition:ccp(s.width/2, s.height/2)];

		[self addChild:sn];
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
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"Plasma.vsh" fragment:@"Plasma.fsh"];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[sn setPosition:ccp(s.width/2, s.height/2)];
		
		[self addChild:sn];
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

-(void) setBlurSize:(CGFloat)f;
@end

@implementation SpriteBlur
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	if( (self=[super initWithTexture:texture rect:rect]) ) {
		
		CGSize s = [texture_ contentSizeInPixels];
	
		blur_ = ccp(1/s.width, 1/s.height);
		sub_[0] = sub_[1] = sub_[2] = sub_[3] = 0;
		
		self.shaderProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"PositionTextureColor.vsh"
													 fragmentShaderFilename:@"Blur.fsh"];
		
		[self.shaderProgram release];

		CHECK_GL_ERROR_DEBUG();

		[shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
		[shaderProgram_ addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
		[shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
		
		CHECK_GL_ERROR_DEBUG();
		
		[shaderProgram_ link];

		CHECK_GL_ERROR_DEBUG();
		
		[shaderProgram_ updateUniforms];

		CHECK_GL_ERROR_DEBUG();

		subLocation = glGetUniformLocation( shaderProgram_->program_, "substract");
		blurLocation = glGetUniformLocation( shaderProgram_->program_, "blurSize");
		
		CHECK_GL_ERROR_DEBUG();
	}
	
	return self;
}

-(void) draw
{
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex );
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );	
	
	ccGLUseProgram( shaderProgram_->program_ );
	ccGLUniformModelViewProjectionMatrix( shaderProgram_ );

	glUniform2f( blurLocation, blur_.x, blur_.y );
	glUniform4f( subLocation, sub_[0], sub_[1], sub_[2], sub_[3] );
	
	ccGLBindTexture2D(  [texture_ name] );
	
	//
	// Attributes
	//
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
	
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
	
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
	
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
	
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(void) setBlurSize:(CGFloat)f
{
	CGSize s = [texture_ contentSizeInPixels];

	blur_ = ccp(1/s.width, 1/s.height);
	blur_ = ccpMult(blur_,f);
}

@end


@implementation ShaderBlur
-(id) init
{
	if( (self=[super init] ) ) {

		blurSprite = [SpriteBlur spriteWithFile:@"grossini.png"];
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[blurSprite setPosition:ccp(s.width/3, s.height/2)];
		[sprite setPosition:ccp(2*s.width/3, s.height/2)];
		
		[self addChild:blurSprite];	
		[self addChild:sprite];
		
		sliderCtl = [self sliderCtl];
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		
		AppController *app = [[UIApplication sharedApplication] delegate];
		UIViewController *ctl = [app viewController];
		
		[ctl.view addSubview: sliderCtl];
		
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		MacGLView *view = [[CCDirector sharedDirector] openGLView];
		
		if( ! overlayWindow ) {
			overlayWindow  = [[NSWindow alloc] initWithContentRect:[[view window] frame]
														 styleMask:NSBorderlessWindowMask
														   backing:NSBackingStoreBuffered
															 defer:NO];
			
			[overlayWindow setFrame:[[view window] frame] display:NO];
			
			[[overlayWindow contentView] addSubview:sliderCtl];
			[overlayWindow setParentWindow:[view window]];
			[overlayWindow setOpaque:NO];
			[overlayWindow makeKeyAndOrderFront:nil];
			[overlayWindow setBackgroundColor:[NSColor clearColor]];
			[[overlayWindow contentView] display];
		}
		
		[[view window] addChildWindow:overlayWindow ordered:NSWindowAbove];
#endif
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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (UISlider *)sliderCtl
{
    if (sliderCtl == nil) 
    {
        CGRect frame = CGRectMake(12.0f, 12.0f, 120.0f, 7.0f);
        sliderCtl = [[UISlider alloc] initWithFrame:frame];
        [sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        sliderCtl.backgroundColor = [UIColor clearColor];
        
        sliderCtl.minimumValue = 0.0f;
        sliderCtl.maximumValue = 3.0f;
        sliderCtl.continuous = YES;
        sliderCtl.value = 1.0f;		
    }
    return [sliderCtl autorelease];
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(NSSlider*) sliderCtl
{
	if( sliderCtl == nil )
	{
		sliderCtl = [[NSSlider alloc] initWithFrame: NSMakeRect (0, 0, 200, 20)];
		[sliderCtl setMinValue: 0];
		[sliderCtl setMaxValue: 3];
		[sliderCtl setFloatValue: 1];
		[sliderCtl setAction: @selector (sliderAction:)];
		[sliderCtl setTarget: self];
		[sliderCtl setContinuous: YES];
	}
	
	return sliderCtl;
}
#endif // Mac

-(void) sliderAction:(id) sender
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[blurSprite setBlurSize: sliderCtl.value];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	[blurSprite setBlurSize: [sliderCtl floatValue]];
#endif
}

@end

// CLASS IMPLEMENTATIONS
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark -
#pragma mark AppController

@implementation AppController

@synthesize viewController = viewController_;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window_" var (it must already be declared)
	// 4. creates a UIViewController, and assign it to the "viewController_" var (it must already be declared)
	// 5. Parents EAGLView to the newly created ViewController. Parents ViewController with UIWindow
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
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
	[viewController_ release];
	[window_ release];
	[super dealloc];
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CGSize winSize = CGSizeMake(640,480);
	
	//
	// CC_DIRECTOR_INIT:
	// 1. It will create an NSWindow with a given size
	// 2. It will create a MacGLView and it will associate it with the NSWindow
	// 3. It will register the MacGLView to the CCDirector
	//
	// If you want to create a fullscreen window, you should do it AFTER calling this macro
	//	
	CC_DIRECTOR_INIT(winSize);
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
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
