//
// Multiple Threads Test
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "MultithreadTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"MultithreadTest1",
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

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
#pragma mark MultithreadDemo

@implementation MultithreadDemo
-(id) init
{
	if( (self = [super init]) ) {


		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

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

#pragma mark - MultithreadTest1

@implementation MultithreadTest1

-(id) init
{
	if( (self=[super init]) ) {

		[NSThread detachNewThreadSelector:@selector(newThread:) toTarget:self withObject:nil];
		
	}
	return self;
}

- (void)dealloc
{
	[node1_ release];
	[node2_ release];
	[node3_ release];
	
    [super dealloc];
}

-(void) doneLoading:(id)argument
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	node1_.position = ccp(s.width/2, s.height/2);
	[self addChild:node1_];

	node2_.position = ccp(s.width/2, s.height/2);
	[self addChild:node2_];

	node3_.position = ccp(s.width/2, s.height/2);
	[self addChild:node3_];

}
#pragma mark New Thread Stuff

-(void) loadObjects
{
	node1_ = [[CCSprite alloc] initWithFile:@"grossini.png"];
	node2_ = [[CCParticleSystemQuad alloc] initWithFile:@"Particles/SpinningPeas.plist"];
	node3_ = [[CCTMXTiledMap alloc] initWithTMXFile:@"TileMaps/hexa-test.tmx"];
	
	// callback should be executed in cocos2d thread
	[self performSelector:@selector(doneLoading:) onThread:[[CCDirector sharedDirector] runningThread] withObject:nil waitUntilDone:NO];
}
-(void) newThread:(id)argument
{
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

	
	CCGLView *view = (CCGLView*)[[CCDirector sharedDirector] view];
	NSAssert(view, @"Do not initialize the TextureCache before the Director");
	
#ifdef __CC_PLATFORM_IOS
	EAGLContext *auxGLcontext = [[EAGLContext alloc]
					 initWithAPI:kEAGLRenderingAPIOpenGLES2
					 sharegroup:[[view context] sharegroup]];
	
#elif defined(__CC_PLATFORM_MAC)
	NSOpenGLPixelFormat *pf = [view pixelFormat];
	NSOpenGLContext *share = [view openGLContext];
	
	NSOpenGLContext *auxGLcontext = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:share];
	
#endif // __CC_PLATFORM_MAC
	
#ifdef __CC_PLATFORM_IOS
	if( [EAGLContext setCurrentContext:auxGLcontext] ) {

		[self loadObjects];
		
		glFlush();
		
		[EAGLContext setCurrentContext:nil];
	} else {
		CCLOG(@"cocos2d: ERROR: TetureCache: Could not set EAGLContext");
	}
	
#elif defined(__CC_PLATFORM_MAC)
	
	[auxGLcontext makeCurrentContext];

	[self loadObjects];
	
	glFlush();

	[NSOpenGLContext clearCurrentContext];
	
#endif // __CC_PLATFORM_MAC

	[auxGLcontext release];
	
	[autoreleasepool release];
}

-(NSString *) title
{
	return @"Loading scene";
}

-(NSString *) subtitle
{
	return @"Loads a scene from another thread. Scene is run when finished";
}

@end


#pragma mark - AppDelegate - iOS

// CLASS IMPLEMENTATIONS

#ifdef __CC_PLATFORM_IOS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Don't call super
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:4];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;
	// Display Milliseconds Per Frame
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// set the Navigation Controller as the root view controller
	[window_ addSubview:navController_.view];
//	[window_ setRootViewController:navController_];	// iOS6 bug: Needs setRootViewController

	// make main window visible
	[window_ makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	return YES;
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
	return YES;
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ pushScene:scene];
	[director_ startAnimation];
}
@end
#endif
