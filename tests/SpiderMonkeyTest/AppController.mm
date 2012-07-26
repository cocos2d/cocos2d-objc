//
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "AppController.h"
#import "ScriptingCore.h"
#import "js_manual_conversions.h"

// dlopen
#include <dlfcn.h>

// SpiderMonkey
#include "jsapi.h"  

#pragma mark - AppDelegate - iOS

// CLASS IMPLEMENTATIONS

@implementation AppController

#pragma mark - AppController - iOS

#ifdef __CC_PLATFORM_IOS
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Don't call super
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0 //GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:4];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	// Multiple touches
	[glView setMultipleTouchEnabled:YES];
	
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
//	[director_ setProjection:kCCDirectorProjection2D];
	[director_ setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director_ enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");

	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// set the Navigation Controller as the root view controller
//	[window_ setRootViewController:navController_];
	[window_ addSubview:navController_.view];

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
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	if( CC_CONTENT_SCALE_FACTOR() == 2 )
		[sharedFileUtils setEnableFallbackSuffixes:YES];		// Default: NO. No fallback suffixes are going to be used

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];


	[self run];

	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//	return YES;
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	glDisable( GL_DEPTH_TEST );
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// Mac... Use iPad resources by default
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setMacRetinaDisplaySuffix:@"-ipadhd"];
	[sharedFileUtils setMacSuffix:@"-ipad"];
	[sharedFileUtils setEnableFallbackSuffixes:YES];		// Default: NO. No fallback suffixes are going to be used
	
	[director_ setResizeMode:kCCDirectorResize_AutoScale];

	[self run];
}

#endif // Platform specific
	

#pragma mark - AppController - Common

- (void)initThoMoServer
{
    thoMoServer = [[ThoMoServerStub alloc] initWithProtocolIdentifier:@"JSConsole"];
    [thoMoServer setDelegate:self];
    [thoMoServer start];
}

- (void) server:(ThoMoServerStub *)theServer acceptedConnectionFromClient:(NSString *)aClientIdString {
    NSLog(@"New Client: %@", aClientIdString);
}

- (void) server:(ThoMoServerStub *)theServer didReceiveData:(id)theData fromClient:(NSString *)aClientIdString {
    NSString *script = (NSString *)theData;
	
	
	NSThread *cocos2dThread = [[CCDirector sharedDirector] runningThread];
	
	[cocos2dThread performBlock:^(void) { 
		NSString * string = @"None\n";
		jsval out;
		BOOL success = [[ScriptingCore sharedInstance] evalString:script outVal:&out];
		
		if(success)
		{
			if(JSVAL_IS_BOOLEAN(out))
			{
				string = [NSString stringWithFormat:@"Result(bool): %@.\n", (JSVAL_TO_BOOLEAN(out)) ? @"true" : @"false"];
			}
			else if(JSVAL_IS_INT(out))
			{
				string = [NSString stringWithFormat:@"Result(int): %i.\n", JSVAL_TO_INT(out)];
			}
			else if(JSVAL_IS_DOUBLE(out))
			{
				string = [NSString stringWithFormat:@"Result(double): %f.\n", JSVAL_TO_DOUBLE(out)];
			}
			else if(JSVAL_IS_STRING(out)) {
				NSString *tmp;
				jsval_to_nsstring( [[ScriptingCore sharedInstance] globalContext], out, &tmp );
				string = [NSString stringWithFormat:@"Result(string): %@.\n", tmp];
			}
			else if (JSVAL_IS_VOID(out) )
				string = @"Result(void):\n";
			else if (JSVAL_IS_OBJECT(out) )
				string = @"Result(object):\n";
		}
		else
		{
			string = [NSString stringWithFormat:@"Error evaluating script:\n#############################\n%@\n#############################\n", script];
		}
		
		[thoMoServer sendToAllClients:string];
		
	}
				  waitUntilDone:NO];
	
}


-(void)dealloc
{
	[thoMoServer stop];
	[thoMoServer release];

	[super dealloc];
}

-(void) run
{
#if DEBUG
	// init server
	[self initThoMoServer];
#endif
	
//	[[ScriptingCore sharedInstance] runScript:@"javascript-spidermonkey/main.js"];
//	[[ScriptingCore sharedInstance] runScript:@"javascript-spidermonkey/playground.js"];
	[[ScriptingCore sharedInstance] runScript:@"javascript-spidermonkey/game-main.js"];
//	[[ScriptingCore sharedInstance] runScript:@"javascript-spidermonkey/playground_gc2.js"];
//	[[ScriptingCore sharedInstance] runScript:@"javascript-spidermonkey/test-sprite.js"];
//	[[ScriptingCore sharedInstance] runScript:@"javascript-spidermonkey/test-actions.js"];

}
@end


