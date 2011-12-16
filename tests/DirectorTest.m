//
// Director Test
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "DirectorTest.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "RootViewController.h"
#endif

static int sceneIdx=-1;
static NSString *transitions[] = {	

	@"DirectorViewDidDisappear",

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
#pragma mark DirectorTest

@implementation DirectorTest
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
#pragma mark Director1


@implementation DirectorViewDidDisappear

-(id) init
{
	if( (self=[super init]) ) {	
		
		CCMenuItem *item = [CCMenuItemFont itemFromString:@"Press Me" block:^(id sender) {
			
			UIViewController *viewController = [[UIViewController alloc] init];
			
			// view
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 240)];
			view.backgroundColor = [UIColor yellowColor];
			
			// back button
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[button addTarget:self 
					   action:@selector(buttonBack:)
			 forControlEvents:UIControlEventTouchDown];
			[button setTitle:@"Back" forState:UIControlStateNormal];
			button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
			[view addSubview:button];
			
			viewController.view = view;
			
			AppController *app = [[UIApplication sharedApplication] delegate];

//			[[app viewController] setView:view];
			UINavigationController *nav = [app navigationController];
			[nav pushViewController:viewController animated:YES];
		}
							];
		
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		
	}	
	return self;
}

-(void) buttonBack:(id)sender
{
	AppController *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];
	[nav popViewControllerAnimated:YES];
}

-(NSString *) title
{
	return @"RootViewController";
}

-(NSString*) subtitle
{
	return @"RootViewController viewDidDissapear";
}
@end


#pragma mark -
#pragma mark AppDelegate

// CLASS IMPLEMENTATIONS

@implementation AppController

@synthesize window=window_, viewController=viewController_, navigationController=navigationController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// before creating any layer, set the landscape mode
	CCDirector *director = [CCDirector sharedDirector];
	
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
	
	// Display Milliseconds Per Frame
	[director setDisplayStats:kCCDirectorStatsMPF];
	
	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	EAGLView *glView = [EAGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// 2D projection
	[director setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Init the View Controller
	viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController_.wantsFullScreenLayout = YES;
	
	// make the OpenGLView a child of the view controller
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
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// create the main scene
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	
	// and run it!
	[director pushScene: scene];
	
	return YES;
}

- (void)dealloc {
    
	[window_ release];
    [super dealloc];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	AppController *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];

	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	AppController *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	

	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	AppController *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	AppController *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{	
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[director end];
}
@end
