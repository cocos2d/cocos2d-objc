//
//  EAGLViewBugAppDelegate.m
//  EAGLViewBug
//
//  Created by Wylan Werth on 7/5/10.
//  Copyright BanditBear Games 2010. All rights reserved.
//

#import "EAGLViewBugAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"
#import "bugViewController.h"

@implementation EAGLViewBugAppDelegate

@synthesize window;
@synthesize viewController=bugViewController;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
	CCDirector *director = [CCDirector sharedDirector];

	// Init the View Controller
	viewController = [[bugViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	// Create the EAGLView manually
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES];
	
	[glView setMultipleTouchEnabled:YES];

	// attach the openglView to the director
	[director setOpenGLView:glView];

	[director setAnimationInterval:1.0/60];
	[director setDisplayStats:kCCDirectorStatsFPS];
	
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];

	// make the View Controller a child of the main window
	[window addSubview: viewController.view];

	[window makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// Turn on display FPS
	[director setDisplayStats:kCCDirectorStatsFPS];
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];	
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];

	[viewController release];

	[window release];
	
	[director end];
	
	// BUG: The view controller is not released... why ?
	NSLog(@"viewController rc:%d", [viewController retainCount] );

}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end


int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"EAGLViewBugAppDelegate");
	[pool release];
	return retVal;
}

