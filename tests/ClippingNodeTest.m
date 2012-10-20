//
// Clipping Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//
// by Pierre-David Bélanger
//

#import "cocos2d.h"

#import "ClippingNodeTest.h"

enum {
	kTagTitleLabel = 1,
	kTagSubtitleLabel = 2,
	kTagStencilNode = 100,
	kTagClipperNode = 101,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"ShapeTest",
	@"ShapeInvertedTest",
	@"SpriteTest",
    @"SpriteNoAlphaTest",
	@"SpriteInvertedTest",
    @"NestedTest",
};

#pragma mark Callbacks

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{
	sceneIdx++;
	sceneIdx = sceneIdx % (sizeof(transitions) / sizeof(transitions[0]));
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	if (sceneIdx < 0)
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) - 1;
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

#pragma mark Demo examples start here

@implementation BaseClippingNodeTest

- (id)init
{
	if (self = [super init]) {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild:background z:-1];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:1 tag:kTagTitleLabel];
		[label setPosition: ccp(s.width / 2, s.height - 50)];
		
		NSString *subtitleText = [self subtitle];
		if (subtitleText) {
			CCLabelTTF *subtitle = [CCLabelTTF labelWithString:subtitleText fontName:@"Thonburi" fontSize:16];
			[self addChild:subtitle z:1 tag:kTagSubtitleLabel];
			[subtitle setPosition:ccp(s.width / 2, s.height - 80)];
		}

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png"
                                                               target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png"
                                                               target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png"
                                                               target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(s.width / 2 - item2.contentSize.width * 2, item2.contentSize.height / 2);
		item2.position = ccp(s.width / 2, item2.contentSize.height / 2);
		item3.position = ccp(s.width / 2 + item2.contentSize.width * 2, item2.contentSize.height / 2);
		[self addChild: menu z:1];
        
        [self setup];
        
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(NSString*) title
{
	return @"Clipping Demo";
}

-(NSString*) subtitle
{
	return @"";
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild:[restartAction() node]];
	[[CCDirector sharedDirector] replaceScene:s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild:[nextAction() node]];
	[[CCDirector sharedDirector] replaceScene:s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild:[backAction() node]];
	[[CCDirector sharedDirector] replaceScene:s];
}

- (void)setup
{
}

@end

#pragma mark - BasicTest

@implementation BasicTest

-(NSString*) title
{
	return @"Basic Test";
}

-(NSString*) subtitle
{
	return @"";
}

- (void)setup
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    CCNode *stencil = [self stencil];
    stencil.tag = kTagStencilNode;
    stencil.position = ccp(50, 50);
    
    CCClippingNode *clipper = [self clipper];
    clipper.tag = kTagClipperNode;
    clipper.anchorPoint = ccp(0.5, 0.5);
    clipper.position = ccp(s.width / 2 - 50, s.height / 2 - 50);
    clipper.stencil = stencil;
    [self addChild:clipper];
    
    CCNode *content = [self content];
    content.position = ccp(50, 50);
    [clipper addChild:content];
}

- (CCAction *)actionRotate
{
    return [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:90]];
}

- (CCAction *)actionScale
{
    CCScaleBy *scale = [CCScaleBy actionWithDuration:1.33 scale:1.5];
    return [CCRepeatForever actionWithAction:[CCSequence actions:scale, [scale reverse], nil]];
}

- (CCDrawNode *)shape
{
    CCDrawNode *shape = [CCDrawNode node];
    static CGPoint triangle[] = {{-100, -100}, {100, -100}, {0, 100}};
    static ccColor4F green = {0, 1, 0, 1};
    [shape drawPolyWithVerts:triangle count:3 fillColor:green borderWidth:0 borderColor:green];
    return shape;
}

- (CCSprite *)gossini
{
    CCSprite *gossini = [CCSprite spriteWithFile:@"grossini.png"];
    gossini.scale = 1.5;
    return gossini;
}

- (CCNode *)stencil
{
    return nil;
}

- (CCClippingNode *)clipper
{
    return [CCClippingNode clippingNode];
}

- (CCNode *)content
{
    return nil;
}

@end

#pragma mark - ShapeTest

@implementation ShapeTest

-(NSString*) title
{
	return @"Shape Basic Test";
}

-(NSString*) subtitle
{
	return @"A DrawNode as stencil and Sprite as content";
}

- (CCNode *)stencil
{
    CCNode *node = [self shape];
    [node runAction:[self actionRotate]];
    return node;
}

- (CCNode *)content
{
    CCNode *node = [self gossini];
    [node runAction:[self actionScale]];
    return node;
}

@end

#pragma mark - ShapeInvertedTest

@implementation ShapeInvertedTest

-(NSString*) title
{
	return @"Shape Inverted Basic Test";
}

-(NSString*) subtitle
{
	return @"A DrawNode as stencil and Sprite as content, inverted";
}

- (CCClippingNode *)clipper
{
    CCClippingNode *clipper = [super clipper];
    clipper.inverted = YES;
    return clipper;
}

@end

#pragma mark - SpriteTest

@implementation SpriteTest

-(NSString*) title
{
	return @"Sprite Basic Test";
}

-(NSString*) subtitle
{
	return @"A Sprite as stencil and DrawNode as content";
}

- (CCNode *)stencil
{
    CCNode *node = [self gossini];
    [node runAction:[self actionRotate]];
    return node;
}

- (CCNode *)content
{
    CCNode *node = [self shape];
    [node runAction:[self actionScale]];
    return node;
}

@end

#pragma mark - SpriteNoAlphaTest

@implementation SpriteNoAlphaTest

-(NSString*) title
{
	return @"Sprite No Alpha Basic Test";
}

-(NSString*) subtitle
{
	return @"A Sprite as stencil and DrawNode as content, no alpha";
}

- (CCClippingNode *)clipper
{
    CCClippingNode *clipper = [super clipper];
    clipper.alphaThreshold = 1;
    return clipper;
}

@end

#pragma mark - SpriteInvertedTest

@implementation SpriteInvertedTest

-(NSString*) title
{
	return @"Sprite Inverted Basic Test";
}

-(NSString*) subtitle
{
	return @"A Sprite as stencil and DrawNode as content, inverted";
}

- (CCClippingNode *)clipper
{
    CCClippingNode *clipper = [super clipper];
    clipper.inverted = YES;
    return clipper;
}

@end

#pragma mark - NestedTest

@implementation NestedTest

-(NSString*) title
{
	return @"Nested Test";
}

-(NSString*) subtitle
{
	return @"Nest 9 Clipping Nodes, max is usually 8";
}

- (void)setup
{
 
    static int depth = 4;
    
    CCNode *parent = self;
    
    for (int i = 0; i < depth; i++) {
                
        int size = 225 - i * (225 / (depth * 2));

        CCClippingNode *clipper = [CCClippingNode clippingNode];
        clipper.contentSize = CGSizeMake(size, size);
        clipper.anchorPoint = ccp(0.5, 0.5);
        clipper.position = ccp(parent.contentSize.width / 2, parent.contentSize.height / 2);
        [clipper runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:i % 3 ? 1.33 : 1.66 angle:i % 2 ? 90 : -90]]];
        [parent addChild:clipper];
        
        CCNode *stencil = [CCSprite spriteWithFile:@"grossini.png"];
        stencil.scale = 2.5 - (i * (2.5 / depth));
        stencil.anchorPoint = ccp(0.5, 0.5);
        stencil.position = ccp(clipper.contentSize.width / 2, clipper.contentSize.height / 2);
        stencil.visible = NO;
        [stencil runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:i] two:[CCShow action]]];
        clipper.stencil = stencil;

        [clipper addChild:stencil];
        
        parent = clipper;
        
    }

}

@end

#pragma mark - AppDelegate

#if defined(__CC_PLATFORM_IOS)

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Main Window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// GL View
	CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]
									 pixelFormat:kEAGLColorFormatRGB565
									 depthFormat:GL_DEPTH24_STENCIL8_OES
							  preserveBackbuffer:NO
									  sharegroup:nil
								   multiSampling:NO
								 numberOfSamples:0];
    
	// Director
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
	[director_ setDisplayStats:YES];
	[director_ setAnimationInterval:1.0 / 60];
	director_.wantsFullScreenLayout = YES;
    [director_ setDelegate:self];    
	// Turn on display FPS
	[director_ setDisplayStats:YES];

	[director_ setView:__glView];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used

	// Navigation Controller
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    
	// set it as the root VC
	[window_ setRootViewController:navController_];
    
	[window_ makeKeyAndVisible];
    
	return  YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [nextAction() node]];
		[director runWithScene: scene];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    window_ = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 480, 320)
                                           styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
                                             backing:NSBackingStoreBuffered
                                               defer:NO] retain];
    
    NSOpenGLPixelFormatAttribute attributes[] = {
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAStencilSize, 8,
		0
    };
    NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
    
    glView_ = [[[CCGLView alloc] initWithFrame:window_.frame pixelFormat:pixelFormat] retain];
    
    window_.contentView = glView_;
    
	director_ = (CCDirectorMac*) [CCDirector sharedDirector];
    
	[director_ setDisplayStats:YES];
    
	[director_ setView:glView_];
    
	// Center window
	[self.window center];
	    
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
    
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director_ setResizeMode:kCCDirectorResize_NoScale]; // kCCDirectorResize_AutoScale
    
    [window_ makeKeyAndOrderFront:self];
    
	CCScene *scene = [CCScene node];
	[scene addChild:[nextAction() node]];
	
	[director_ runWithScene:scene];
}
@end
#endif

