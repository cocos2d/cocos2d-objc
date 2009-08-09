//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
	// WARNING: FastDirector doesn't interact well with UIKit controls
	//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
		
		
	[[Director sharedDirector] runWithScene: [HelloWorld scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[Director sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[Director sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[Director sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[Director sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
