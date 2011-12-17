//
//  DenshionAudioVisualDemoAppDelegate.h
//  DenshionAudioVisualDemo
//
//  Created by Lam Pham on 2/5/10.
//  Copyright FancyRatStudios Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FancyRatMeteringDemoAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window_;
	UIViewController *viewController_;		// weak ref
	UINavigationController *navigationController_;	// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;

@end
