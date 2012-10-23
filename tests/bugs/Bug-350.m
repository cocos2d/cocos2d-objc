//
// Bug-350
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=350
//

#import "Bug-350.h"

#pragma mark -
#pragma mark MemBug

@implementation Layer1

// Don't create the background imate at "init" time.
// Instead create it at "onEnter" time.
-(id) init
{
	if( (self=[super init]) ) {
	
		CGSize size = [[CCDirector sharedDirector] winSize];

		CCSprite *_background;

		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			_background = [CCSprite spriteWithFile:@"Default.png"];
			_background.rotation = 90;
		} else {
			_background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
		_background.position = ccp(size.width/2, size.height/2);

		[self addChild:_background];
	}
	return self;
}
@end


// CLASS IMPLEMENTATIONS
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
							   numberOfSamples:0];
	
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director_ enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");

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
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// Use "setRootViewController" instead of "addSubview" to prevent flicker
//	[window_ addSubview:navController_.view];
	[window_ setRootViewController:navController_];	// iOS6 bug: Needs setRootViewController

	// make main window visible
	[window_ makeKeyAndVisible];

//	CCScene *scene = [CCScene node];
//	[scene addChild: [Layer1 node]];
//	[director_ runWithScene: scene];

	return YES;
}

-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [Layer1 node]];
		[director runWithScene: scene];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end
