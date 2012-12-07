//
// FileUtils Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "FileUtilsTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"Issue1344",
	@"Test1",
	@"TestResolutionDirectories",
	@"TestSearchPath",
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

#pragma mark - FileUtilsDemo

@implementation FileUtilsDemo
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

#pragma mark - Issue1344


@implementation Issue1344

-(id) init
{
	if( (self=[super init]) ) {

		CCFileUtils *fileutils = [CCFileUtils sharedFileUtils];
		
		CCLOG( @" %@", [fileutils searchResolutionsOrder]);
		
		fileutils.enableiPhoneResourcesOniPad = YES;

		CCLOG( @" %@", [fileutils searchResolutionsOrder]);

		for( NSUInteger i=1; i < 8 ; i++ ) {
			NSString *file = [NSString stringWithFormat:@"issue1344-test%d.txt", i];
			NSString *path = [fileutils fullPathFromRelativePath:file];
			NSLog(@"Test number %i: %@ -> %@", i, file, path);
		}
		
		fileutils.enableiPhoneResourcesOniPad = NO;
	}
	return self;
}

-(NSString *) title
{
	return @"Issue 1344";
}

-(NSString *) subtitle
{
	return @"CCFileUtils should return a valid path. See console";
}

@end

#pragma mark - Test1

@implementation Test1
-(id) init
{
	if ((self=[super init]) ) {
		
		// This test is only valid in Retinadisplay
		
		if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
			
			CCSprite *sprite = [[CCSprite alloc] initWithFile:@"bugs/test_issue_1179.png"];
			if( sprite )
				NSLog(@"Test #1 issue 1179: OK");
			else
				NSLog(@"Test #1 issue 1179: FAILED");
			
			[sprite release];
			
			sprite = [[CCSprite alloc] initWithFile:@"only_in_hd.pvr.ccz"];
			if( sprite )
				NSLog(@"Test #2 issue 1179: OK");
			else
				NSLog(@"Test #2 issue 1179: FAILED");
			
			[sprite release];
			
		} else {
			NSLog(@"Test issue #1179 failed. Needs to be tested with RetinaDispaly");
		}
		
		
#ifdef __CC_PLATFORM_IOS
		// Testint CCFileUtils API
		BOOL ret;
		CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
		ret = [sharedFileUtils iPhoneRetinaDisplayFileExistsAtPath:@"bugs/test_issue_1179.png"];
		if( ret )
			NSLog(@"Test #3: retinaDisplayFileExistsAtPath: OK");
		else
			NSLog(@"Test #3: retinaDisplayFileExistsAtPath: FAILED");
		
		
		ret = [sharedFileUtils iPhoneRetinaDisplayFileExistsAtPath:@"grossini-does_no_exist.png"];
		if( !ret )
			NSLog(@"Test #4: retinaDisplayFileExistsAtPath: OK");
		else
			NSLog(@"Test #4: retinaDisplayFileExistsAtPath: FAILED");
#endif // __CC_PLATFORM_IOS
		
	}
	return self;
}

-(NSString*) title
{
	return @"CCFileUtils: See console";
}
-(NSString *) subtitle
{
	return @"See the console";
}
@end

#pragma mark - TestResolutionDirectories

@implementation TestResolutionDirectories
-(id) init
{
	if ((self=[super init]) ) {
		
		CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

		NSString *ret;
		ccResolutionType resolution;
		
		[sharedFileUtils purgeCachedEntries];
		[sharedFileUtils setSearchMode:kCCFileUtilsSearchDirectory];
	
		for( int i=1; i<7; i++) {
			NSString *filename = [NSString stringWithFormat:@"test%d.txt", i];
			ret = [sharedFileUtils fullPathFromRelativePath:filename resolutionType:&resolution];
			NSLog(@"%@ -> %@ (%d)", filename, ret, resolution);
		}
		
	}
	return self;
}

-(void) onExit
{
	[[CCFileUtils sharedFileUtils] setSearchMode:kCCFileUtilsSearchSuffix];
	[super onExit];
}

-(NSString*) title
{
	return @"FileUtils: resolutions in directories";
}
-(NSString *) subtitle
{
	return @"See the console";
}
@end

#pragma mark - TestSearchPath

@implementation TestSearchPath
-(id) init
{
	if ((self=[super init]) ) {
		
		CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
		
		NSString *ret;
		ccResolutionType resolution;
		
		[sharedFileUtils purgeCachedEntries];
		[sharedFileUtils setSearchPath: @[ @"searchpath1", @"searchpath2", @"searchpath3", kCCFileUtilsDefaultSearchPath] ];
		
		for( int i=1; i<4; i++) {
			NSString *filename = [NSString stringWithFormat:@"file%d.txt", i];
			ret = [sharedFileUtils fullPathFromRelativePath:filename resolutionType:&resolution];
			NSLog(@"%@ -> %@ (%d)", filename, ret, resolution);
		}
	}
	return self;
}

-(void) onExit
{
	
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

	// reset search path
	[sharedFileUtils setSearchPath: @[ kCCFileUtilsDefaultSearchPath ] ];
	
	[sharedFileUtils setSearchMode:kCCFileUtilsSearchSuffix];
	[super onExit];
}

-(NSString*) title
{
	return @"FileUtils: search path";
}
-(NSString *) subtitle
{
	return @"See the console";
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
	[window_ setRootViewController:navController_];
	
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
		[director runWithScene:scene];
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
