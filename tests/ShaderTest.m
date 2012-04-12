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
	
	@"ShaderMonjori",
	@"ShaderMandelbrot",
	@"ShaderJulia",
	@"ShaderHeart",
	@"ShaderFlower",
	@"ShaderPlasma",
	@"ShaderBlur",
	@"ShaderRetroEffect",
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

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
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
	ccVertex2F	center_;
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

+(id) shaderNodeWithVertex:(NSString*)vert fragment:(NSString*)frag
{
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
	CCGLProgram *shader = [[CCGLProgram alloc] initWithVertexShaderFilename:vert
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

-(void) setPosition:(CGPoint)newPosition
{
	[super setPosition:newPosition];
	center_ = (ccVertex2F) { position_.x * CC_CONTENT_SCALE_FACTOR(), position_.y * CC_CONTENT_SCALE_FACTOR() };
}

-(void) draw
{
	CC_NODE_DRAW_SETUP();

	float w = SIZE_X, h = SIZE_Y;
	GLfloat vertices[12] = {0,0, w,0, w,h, 0,0, 0,h, w,h};

	//
	// Uniforms
	//
	[shaderProgram_ setUniformLocation:uniformCenter withF1:center_.x f2:center_.y];
	[shaderProgram_ setUniformLocation:uniformResolution withF1:resolution_.x f2:resolution_.y];

	// time changes all the time, so it is Ok to call OpenGL directly, and not the "cached" version
	glUniform1f( uniformTime, time_ );
//	[shaderProgram_ setUniformLocation:uniformTime with1f:time_];


	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);

	glDrawArrays(GL_TRIANGLES, 0, 6);
	
	CC_INCREMENT_GL_DRAWS(1);
}
@end

#pragma mark -
#pragma mark ShaderMonjori

@implementation ShaderMonjori

-(id) init
{
	if( (self=[super init]) ) {
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"example_Monjori.vsh" fragment:@"example_Monjori.fsh"];

		CGSize s = [[CCDirector sharedDirector] winSize];
		sn.position = ccp(s.width/2, s.height/2);

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
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"example_Mandelbrot.vsh" fragment:@"example_Mandelbrot.fsh"];

		CGSize s = [[CCDirector sharedDirector] winSize];
		sn.position = ccp(s.width/2, s.height/2);

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
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"example_Julia.vsh" fragment:@"example_Julia.fsh"];

		CGSize s = [[CCDirector sharedDirector] winSize];
		sn.position = ccp(s.width/2, s.height/2);

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

		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"example_Heart.vsh" fragment:@"example_Heart.fsh"];

		CGSize s = [[CCDirector sharedDirector] winSize];
		sn.position = ccp(s.width/2, s.height/2);

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

		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"example_Flower.vsh" fragment:@"example_Flower.fsh"];

		CGSize s = [[CCDirector sharedDirector] winSize];
		sn.position = ccp(s.width/2, s.height/2);

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
		ShaderNode *sn = [ShaderNode shaderNodeWithVertex:@"example_Plasma.vsh" fragment:@"example_Plasma.fsh"];

		CGSize s = [[CCDirector sharedDirector] winSize];
		sn.position = ccp(s.width/2, s.height/2);

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
	GLfloat	sub_[4];

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

		GLchar * fragSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"example_Blur.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
		shaderProgram_ = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert fragmentShaderByteArray:fragSource];


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

	[shaderProgram_ use];
	[shaderProgram_ setUniformForModelViewProjectionMatrix];
	[shaderProgram_ setUniformLocation:blurLocation withF1:blur_.x f2:blur_.y];
	[shaderProgram_ setUniformLocation:subLocation with4fv:sub_ count:1];

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
	
	CC_INCREMENT_GL_DRAWS(1);
}

-(void) setBlurSize:(CGFloat)f
{
	CGSize s = [texture_ contentSizeInPixels];

	blur_ = ccp(1/s.width, 1/s.height);
	blur_ = ccpMult(blur_,f);
}

@end


@implementation ShaderBlur

@synthesize sliderCtl=sliderCtl_;

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

		self.sliderCtl = [self createSliderCtl];

#ifdef __CC_PLATFORM_IOS

		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		UIViewController *ctl = [app navController];

		[ctl.view addSubview: sliderCtl_];

#elif defined(__CC_PLATFORM_MAC)
		CCGLView *view = [[CCDirector sharedDirector] view];

		if( ! overlayWindow ) {
			overlayWindow  = [[NSWindow alloc] initWithContentRect:[[view window] frame]
														 styleMask:NSBorderlessWindowMask
														   backing:NSBackingStoreBuffered
															 defer:NO];

			[overlayWindow setFrame:[[view window] frame] display:NO];

			[[overlayWindow contentView] addSubview:sliderCtl_];
			[overlayWindow setParentWindow:[view window]];
			[overlayWindow setOpaque:NO];
			[overlayWindow makeKeyAndOrderFront:nil];
			[overlayWindow setBackgroundColor:[NSColor clearColor]];
			[[overlayWindow contentView] display];
		}

		[[view window] addChildWindow:overlayWindow ordered:NSWindowAbove];
		[overlayWindow release];
#endif
	}

	return self;
}

-(void) dealloc
{
	[sliderCtl_ release];
	[sliderCtl_ removeFromSuperview];

	[super dealloc];
}

-(NSString *) title
{
	return @"Shader: Frag shader";
}

-(NSString *) subtitle
{
	return @"Gaussian blur";
}

#ifdef __CC_PLATFORM_IOS
-(UISlider*) createSliderCtl
{
	CGRect frame = CGRectMake(40.0f, 110.0f, 240.0f, 7.0f);
	UISlider *slider = [[UISlider alloc] initWithFrame:frame];
	[slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];

	// in case the parent view draws with a custom color or gradient, use a transparent color
	slider.backgroundColor = [UIColor clearColor];

	slider.minimumValue = 0.0f;
	slider.maximumValue = 3.0f;
	slider.continuous = YES;
	slider.value = 1.0f;

	return [slider autorelease];
}
#elif defined(__CC_PLATFORM_MAC)
-(NSSlider*) createSliderCtl
{
	NSSlider *slider = [[NSSlider alloc] initWithFrame: NSMakeRect(200, 350, 240, 20)];
	[slider setMinValue: 0];
	[slider setMaxValue: 3];
	[slider setFloatValue: 1];
	[slider setAction: @selector (sliderAction:)];
	[slider setTarget: self];
	[slider setContinuous: YES];

	return [slider autorelease];
}
#endif // Mac

-(void) sliderAction:(id) sender
{
#ifdef __CC_PLATFORM_IOS
	[blurSprite setBlurSize: sliderCtl_.value];
#elif defined(__CC_PLATFORM_MAC)
	[blurSprite setBlurSize: [sliderCtl_ floatValue]];
#endif
}
@end

#pragma mark -
#pragma mark ShaderRetroEffect

@implementation ShaderRetroEffect
-(id) init
{
	if( (self=[super init] ) ) {
		
		GLchar * fragSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"example_HorizontalColor.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
		CCGLProgram *p = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTexture_vert fragmentShaderByteArray:fragSource];
		
		[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
		[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
		
		[p link];
		[p updateUniforms];


		CCDirector *director = [CCDirector sharedDirector];
		CGSize s = [director winSize];

		label_ = [CCLabelBMFont labelWithString:@"RETRO EFFECT" fntFile:@"west_england-64.fnt"];
		
		label_.shaderProgram = p;
		
		[p release];
		
	
		[label_ setPosition:ccp(s.width/2,s.height/2)];
		
		[self addChild:label_];
		
		[self scheduleUpdate];
		
	}
	
	return self;
}

-(void) update:(ccTime)dt
{
//	CGSize size = [[CCDirector sharedDirector] winSize];

	accum_ += dt;

	CCArray *array = [label_ children];
	
	int i=0;
	for( CCSprite *sprite in array ) {
		i++;
		CGPoint oldPosition = sprite.position;
		sprite.position = ccp( oldPosition.x, sinf( accum_ * 2 + i/2.0) * 20  );
		
		
		// add fabs() to prevent negative scaling
		float scaleY = ( sinf( accum_ * 2 + i/2.0 + 0.707) );
		
		sprite.scaleY = scaleY;
	}
}

-(NSString *) title
{
	return @"Shader: Retro test";
}

-(NSString *) subtitle
{
	return @"sin() effect with moving colors";
}
@end


// CLASS IMPLEMENTATIONS
#ifdef __CC_PLATFORM_IOS

#pragma mark -
#pragma mark AppController

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Display retina Display
	useRetinaDisplay_ = NO;

	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];


	CCScene *scene = [CCScene node];
	
	[scene addChild: [nextAction() node]];

	[director_ pushScene: scene];

	return YES;
}
@end

#elif defined(__CC_PLATFORM_MAC)
@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// don't call super. Window is created manually in this sample
//	[super applicationDidFinishLaunching:aNotification];

	CGSize winSize = CGSizeMake(640,480);

	//
	// CC_DIRECTOR_INIT:
	// 1. It will create an NSWindow with a given size
	// 2. It will create a CCGLView and it will associate it with the NSWindow
	// 3. It will register the CCGLView to the CCDirector
	//
	// If you want to create a fullscreen window, you should do it AFTER calling this macro
	//
	CC_DIRECTOR_INIT(winSize);

	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];

	[director_ setResizeMode:kCCDirectorResize_AutoScale];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ pushScene:scene];
	[director_ startAnimation];
}
@end
#endif
