//
//  DenshionAudioVisualDemoAppDelegate.m
//  DenshionAudioVisualDemo
//
//  Created by Lam Pham on 2/5/10.
//  Copyright FancyRatStudios Inc. 2010. All rights reserved.
//

#import "FancyRatMeteringDemoAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@implementation FancyRatMeteringDemoAppDelegate

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

	[director_ pushScene: [HelloWorld scene]];

	return YES;
}
@end
