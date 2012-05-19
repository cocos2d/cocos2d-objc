//
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "JavascriptSpidermonkey.h"
#import "ScriptingCore.h"

// dlopen
#include <dlfcn.h>

// SpiderMonkey
#include "jsapi.h"  

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
//	[window_ setRootViewController:rootViewController_];
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
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// create the main scene
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	// and run it!
	[director_ pushScene: scene];

	return YES;
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

/* The error reporter callback. */  
void reportError(JSContext *cx, const char *message, JSErrorReport *report)  
{  
	fprintf(stderr, "%s:%u:%s\n",  
			report->filename ? report->filename : "<no filename=\"filename\">",  
			(unsigned int) report->lineno,  
			message);  
}  

/* The class of the global object. */  
static JSClass global_class = {  
	"global", JSCLASS_GLOBAL_FLAGS,  
	JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub,  
	JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, JS_FinalizeStub,  
	JSCLASS_NO_OPTIONAL_MEMBERS  
};  

@implementation AppController

-(BOOL) testSpiderMonkey
{
	/* JSAPI variables. */  
	JSRuntime *rt;  
	JSContext *cx;  
	JSObject  *global;  
	
	/* Create a JS runtime. You always need at least one runtime per process. */  
	rt = JS_NewRuntime(8 * 1024 * 1024);  
	if (rt == NULL)  
		return NO;
	
	/*  
	 * Create a context. You always need a context per thread. 
	 * Note that this program is not multi-threaded. 
	 */  
	cx = JS_NewContext(rt, 8192);  
	if (cx == NULL)  
		return NO;

	JS_SetOptions(cx, JSOPTION_VAROBJFIX | /* JSOPTION_JIT | */ JSOPTION_METHODJIT);  
	JS_SetVersion(cx, JSVERSION_LATEST);  
	JS_SetErrorReporter(cx, reportError);  
	
	/* 
	 * Create the global object in a new compartment. 
	 * You always need a global object per context. 
	 */  
	global = JS_NewCompartmentAndGlobalObject(cx, &global_class, NULL);  
	if (global == NULL)  
		return NO;
	
	/* 
	 * Populate the global object with the standard JavaScript 
	 * function and object classes, such as Object, Array, Date. 
	 */  
	if (!JS_InitStandardClasses(cx, global))  
		return NO;
	
	/* Your application code here. This may include JSAPI calls 
	 * to create your own custom JavaScript objects and to run scripts. 
	 * 
	 * The following example code creates a literal JavaScript script, 
	 * evaluates it, and prints the result to stdout. 
	 * 
	 * Errors are conventionally saved in a JSBool variable named ok. 
	 */  
	char *script = "'Hello ' + 'World!'";  
	jsval rval;  
	JSString *str;  
	JSBool ok;  
	const char *filename = "noname";  
	uint lineno = 0;  
	
	ok = JS_EvaluateScript(cx, global, script, strlen(script),  
						   filename, lineno, &rval);  
//	if (rval == NULL | rval == JS_FALSE)  
//		return NO;
	
	str = JS_ValueToString(cx, rval);  
	printf("%s\n", JS_EncodeString(cx, str));  
	
	/* End of your application code */  
	
	/* Clean things up and shut down SpiderMonkey. */  
	JS_DestroyContext(cx);  
	JS_DestroyRuntime(rt);  
	JS_ShutDown();  
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	// Load cocos2d BridgeSupport (not needed I guess)
//	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
//	NSString *libPath = [fileUtils fullPathFromRelativePath:@"libmozjs.dylib"];
//	dlopen([libPath UTF8String], RTLD_NOW | RTLD_GLOBAL);
	
	
	[self testSpiderMonkey];
}

-(void)dealloc
{

	[super dealloc];
}
@end
#endif
