//
//  EAGLViewBugAppDelegate.h
//  EAGLViewBug
//
//  Created by Wylan Werth on 7/5/10.
//  Copyright BanditBear Games 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "bugViewController.h"

@interface EAGLViewBugAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	bugViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) UIWindow *viewController;

@end
