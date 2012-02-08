//
//  Box2DAppDelegate.m
//  Box2D
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//


#import <UIKit/UIKit.h>
#import "Box2DAppDelegate.h"
#import "Box2DView.h"
#import "cocos2d.h"

@implementation Box2DAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

    [application setStatusBarHidden:true];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director_ setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:NO] )
		CCLOG(@"Retina Display Not supported");

	CCScene *scene = [CCScene node];
	[scene addChild: [MenuLayer menuWithEntryID:0]];

	[director_ pushScene: scene];

	return YES;
}
@end
