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

#import "ccMacros.h"
#if __CC_PLATFORM_IOS

#import "ccTypes.h"

#import "CCAppDelegate.h"
#import "CCTexture.h"
#import "CCPackageManager.h"
#import "CCDeviceInfo.h"

#import "CCDirector_Private.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import "CCMetalView.h"
#endif


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
-(NSUInteger)supportedInterfaceOrientations
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
	CGSize sizePoint = [CCDirector currentDirector].viewSize;
	CGSize fixed = [CCDirector currentDirector].designSize;

	// Half of the extra size that will be cut off
	CGPoint offset = ccpMult(ccp(fixed.width - sizePoint.width, fixed.height - sizePoint.height), 0.5);
	
	return GLKMatrix4MakeOrtho(offset.x, sizePoint.width + offset.x, offset.y, sizePoint.height + offset.y, -1024, 1024);
}

@end


@implementation CCAppDelegate

@synthesize window=window_, navController=navController_;

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	return UIInterfaceOrientationMaskAll;
}

- (void)constructNavController:(NSDictionary *)config
{
    // Create a Navigation Controller with the Director
    navController_ = [[CCNavigationController alloc] initWithRootViewController:[CCDirector currentDirector]];
    navController_.navigationBarHidden = YES;
    navController_.appDelegate = self;
    navController_.screenOrientation = (config[CCSetupScreenOrientation] ?: CCScreenOrientationLandscape);

    // for rotation and other messages
    [[CCDirector currentDirector] setDelegate:navController_];

    // set the Navigation Controller as the root view controller
    [window_ setRootViewController:navController_];
}

- (void)constructWindow
{
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

// iOS8 hack around orientation bug
-(void)forceOrientation
{
#if __CC_PLATFORM_IOS && defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
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

- (CC_VIEW <CCView> *)constructView:(NSDictionary *)config withBounds:(CGRect)bounds
{
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
    CC_VIEW<CCView> *ccview = nil;
    switch([CCDeviceInfo graphicsAPI]){
        case CCGraphicsAPIGL:
        {
            ccview = [CCViewiOSGL
                    viewWithFrame:bounds
                      pixelFormat:config[CCSetupPixelFormat] ?: kEAGLColorFormatRGBA8
                      depthFormat:[config[CCSetupDepthFormat] unsignedIntValue]
               preserveBackbuffer:[config[CCSetupPreserveBackbuffer] boolValue]
                       sharegroup:nil
                    multiSampling:[config[CCSetupMultiSampling] boolValue]
                  numberOfSamples:[config[CCSetupNumberOfSamples] unsignedIntValue]
            ];
        }
            break;
#if __CC_METAL_SUPPORTED_AND_ENABLED
		case CCGraphicsAPIMetal:
			// TODO support MSAA, depth buffers, etc.
			ccview = [[CCMetalView alloc] initWithFrame:bounds];
			break;
#endif
        default: NSAssert(NO, @"Internal error: Graphics API not set up.");
    }

    return ccview;
}


#pragma mark UIApplicationDelegate Protocol

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if([CCDirector currentDirector].paused == NO) {
		[[CCDirector currentDirector] pause];
	}
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector currentDirector] setNextDeltaTimeZero:YES];
	if([CCDirector currentDirector].paused) {
		[[CCDirector currentDirector] resume];
	}
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if([CCDirector currentDirector].animating) {
		[[CCDirector currentDirector] stopRunLoop];
	}
	[[CCPackageManager sharedManager] savePackages];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if([CCDirector currentDirector].animating == NO) {
		[[CCDirector currentDirector] startRunLoop];
	}
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	[[CCDirector currentDirector] end];

    [[CCPackageManager sharedManager] savePackages];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector currentDirector] purgeCachedData];

    [[CCPackageManager sharedManager] savePackages];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector currentDirector] setNextDeltaTimeZero:YES];
}

@end

#endif
