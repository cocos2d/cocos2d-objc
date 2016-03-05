/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "../../ccMacros.h"
#if __CC_PLATFORM_IOS

#import "CCAppDelegate.h"
#import "CCTexture.h"
#import "CCFileUtils.h"
#import "CCDirector.h"
#import "CCConfiguration.h"
#import "CCScheduler.h"
#import "CCGLView.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import "CCMetalView.h"
#endif

// Fixed size. As wide as iPhone 5 at 2x and as high as the iPad at 2x.
const CGSize FIXED_SIZE = {568, 384};

@interface CCNavigationController ()
{
    CCAppDelegate* __weak _appDelegate;
    NSString* _screenOrientation;
}
@property (nonatomic, weak) CCAppDelegate* appDelegate;
@property (nonatomic, strong) NSString* screenOrientation;
@end

@implementation CCNavigationController

@synthesize appDelegate = _appDelegate;
@synthesize screenOrientation = _screenOrientation;

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([_screenOrientation isEqual:CCScreenOrientationAll])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else if ([_screenOrientation isEqual:CCScreenOrientationPortrait])
    {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    else
    {
        return UIInterfaceOrientationMaskLandscape;
    }
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([_screenOrientation isEqual:CCScreenOrientationAll])
    {
        return YES;
    }
    else if ([_screenOrientation isEqual:CCScreenOrientationPortrait])
    {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
    else
    {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
}

// Projection delegate is only used if the fixed resolution mode is enabled
-(GLKMatrix4)updateProjection
{
	CGSize sizePoint = [CCDirector sharedDirector].viewSize;
	CGSize fixed = [CCDirector sharedDirector].designSize;

	// Half of the extra size that will be cut off
	CGPoint offset = ccpMult(ccp(fixed.width - sizePoint.width, fixed.height - sizePoint.height), 0.5);
	
	return GLKMatrix4MakeOrtho(offset.x, sizePoint.width + offset.x, offset.y, sizePoint.height + offset.y, -1024, 1024);
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
    [director drawScene];
}
@end


@implementation CCAppDelegate

@synthesize window=window_, navController=navController_;

#if !defined(__TV_OS_VERSION_MAX_ALLOWED)
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	return UIInterfaceOrientationMaskAll;
}
#endif

static CGFloat
FindPOTScale(CGFloat size, CGFloat fixedSize)
{
	int scale = 1;
	while(fixedSize*scale < size) scale *= 2;
	
	return scale;
}

- (void) setupCocos2dWithOptions:(NSDictionary*)config
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	CGRect bounds = [window_ bounds];
	
	// CCView creation
	// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
	//  - Possible values: any CGRect
	// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
	//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
	// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
	//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
	// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
	//  - Possible values: nil, or any valid EAGLSharegroup group
	// multiSampling: Whether or not to enable multisampling
	//  - Possible values: YES, NO
	// numberOfSamples: Only valid if multisampling is enabled
	//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
	CC_VIEW<CCDirectorView> *ccview = nil;
	switch([CCConfiguration sharedConfiguration].graphicsAPI){
		case CCGraphicsAPIGL:
			ccview = [CCGLView
				viewWithFrame:bounds
				pixelFormat:config[CCSetupPixelFormat] ?: kEAGLColorFormatRGBA8
				depthFormat:[config[CCSetupDepthFormat] unsignedIntValue]
				preserveBackbuffer:[config[CCSetupPreserveBackbuffer] boolValue]
				sharegroup:nil
				multiSampling:[config[CCSetupMultiSampling] boolValue]
				numberOfSamples:[config[CCSetupNumberOfSamples] unsignedIntValue]
			];
			break;
#if __CC_METAL_SUPPORTED_AND_ENABLED
		case CCGraphicsAPIMetal:
			// TODO support MSAA, depth buffers, etc.
			ccview = [[CCMetalView alloc] initWithFrame:bounds];
			break;
#endif
		default: NSAssert(NO, @"Internal error: Graphics API not set up.");
	}
	
	CCDirectorIOS* director = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	// Display FSP and SPF
	[director setDisplayStats:[config[CCSetupShowDebugStats] boolValue]];
	
	// set FPS at 60
	NSTimeInterval animationInterval = [(config[CCSetupAnimationInterval] ?: @(1.0/60.0)) doubleValue];
	[director setAnimationInterval:animationInterval];
	
	director.fixedUpdateInterval = [(config[CCSetupFixedUpdateInterval] ?: @(1.0/60.0)) doubleValue];
	
	// attach the openglView to the director
	[director setView:ccview];
	
	if([config[CCSetupScreenMode] isEqual:CCScreenModeFixed]){
        [self setupFixedScreenMode:config director:director];
    } else {
        [self setupFlexibleScreenMode:config director:director];
    }
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change this setting at any time.
	[CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
	
	// Create a Navigation Controller with the Director
	navController_ = [[CCNavigationController alloc] initWithRootViewController:director];
	navController_.navigationBarHidden = YES;
	navController_.appDelegate = self;
	navController_.screenOrientation = (config[CCSetupScreenOrientation] ?: CCScreenOrientationLandscape);
    
	// for rotation and other messages
	[director setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
    
	// make main window visible
	[window_ makeKeyAndVisible];
    
    [self forceOrientation];
}

- (void)setupFlexibleScreenMode:(NSDictionary *)config director:(CCDirectorIOS *)director
{
    // Setup tablet scaling if it was requested.
    if(	UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&	[config[CCSetupTabletScale2X] boolValue] )
    {
        // Set the director to use 2 points per pixel.
        director.contentScaleFactor *= 2.0;

        // Set the UI scale factor to show things at "native" size.
        director.UIScaleFactor = 0.5;

        // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
        [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
    }

    [director setProjection:CCDirectorProjection2D];
}

- (void)setupFixedScreenMode:(NSDictionary *)config director:(CCDirectorIOS *)director
{
    CGSize size = [CCDirector sharedDirector].viewSizeInPixels;
    CGSize fixed = FIXED_SIZE;

    if([config[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait]){
			CC_SWAP(fixed.width, fixed.height);
		}

    // Find the minimal power-of-two scale that covers both the width and height.
    CGFloat scaleFactor = MIN(FindPOTScale(size.width, fixed.width), FindPOTScale(size.height, fixed.height));

    director.contentScaleFactor = scaleFactor;
    director.UIScaleFactor = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1.0 : 0.5);

    // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
    [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor: 2.0];

    director.designSize = fixed;
    [director setProjection:CCDirectorProjectionCustom];
}

// iOS8 hack around orientation bug
-(void)forceOrientation
{
#if __CC_PLATFORM_IOS && defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0 && !defined(__TV_OS_VERSION_MAX_ALLOWED)
    if([navController_.screenOrientation isEqual:CCScreenOrientationAll])
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationUnknown];
    }
    else if([navController_.screenOrientation isEqual:CCScreenOrientationPortrait])
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait | UIDeviceOrientationPortraitUpsideDown];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationLandscapeLeft | UIDeviceOrientationLandscapeRight];
    }
#endif
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if([CCDirector sharedDirector].paused == NO) {
		[[CCDirector sharedDirector] pause];
	}
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	if([CCDirector sharedDirector].paused) {
		[[CCDirector sharedDirector] resume];
	}
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if([CCDirector sharedDirector].animating) {
		[[CCDirector sharedDirector] stopAnimation];
	}
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if([CCDirector sharedDirector].animating == NO) {
		[[CCDirector sharedDirector] startAnimation];
	}
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	[[CCDirector sharedDirector] end];
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

@end

#endif
