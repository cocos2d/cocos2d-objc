//
//  CCGLViewBugAppDelegate.m
//  CCGLViewBug
//
//  Created by Wylan Werth on 7/5/10.
//  Copyright BanditBear Games 2010. All rights reserved.
//

#import "EAGLViewBugAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"
#import "bugViewController.h"

@implementation EAGLViewBugAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];


	[director_.view setMultipleTouchEnabled:YES];

	[director_ setAnimationInterval:1.0/60];
	[director_ setDisplayStats:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Run the intro Scene
	[director_ pushScene: [HelloWorld scene]];

	return YES;
}
@end


int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"EAGLViewBugAppDelegate");
	[pool release];
	return retVal;
}

