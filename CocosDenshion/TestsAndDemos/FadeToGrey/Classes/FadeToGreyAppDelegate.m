//
//  FadeToGreyAppDelegate.m
//  FadeToGrey
//
//  Created by Stephen Oldmeadow on 5/03/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FadeToGreyAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@implementation FadeToGreyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Display retina Display
	useRetinaDisplay_ = NO;

	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// display FPS (useful when debugging)
	[director_ setDisplayStats:YES];

	// frames per second
	[director_ setAnimationInterval:1.0/60];

	// multiple touches
	[director_.view setMultipleTouchEnabled:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];


	[director_ pushScene: [HelloWorld scene]];

	return YES;
}
@end
