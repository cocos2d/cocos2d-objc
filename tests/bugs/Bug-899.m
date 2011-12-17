//
// Bug-899
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=899
//
// Test coded by: JohnnyFlash
//

#import "Bug-899.h"

#import "RootViewController.h"

#pragma mark -

@implementation Layer1
-(id) init
{
	if( (self=[super init] )) {
		
		CCSprite *bg = [CCSprite spriteWithFile:@"bugs/RetinaDisplay.jpg"];
		[self addChild:bg z:0];
		bg.anchorPoint = CGPointZero;		
	}
	return self;
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

@synthesize window=window_, viewController=viewController_, navigationController=navigationController_;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Set to 2D Projection
	CCDirector *director = [CCDirector sharedDirector];
	[director setProjection:kCCDirectorProjection2D];
	
	[director setAnimationInterval:1.0/60];
	
	
	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	EAGLView *glView = [EAGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0						//GL_DEPTH_COMPONENT24_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	[viewController_ setView:glView];

	navigationController_ = [[UINavigationController alloc] initWithRootViewController:viewController_];
	navigationController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navigationController_];
	
	[viewController_ release];
	[navigationController_ release];
	
	// make main window visible
	[window_ makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// create scene
	CCScene *scene = [CCScene node];
	CCLayer *layer = [Layer1 node];
	[scene addChild:layer];
	
	[director pushScene:scene];
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

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];

	[super dealloc];
}

@end
