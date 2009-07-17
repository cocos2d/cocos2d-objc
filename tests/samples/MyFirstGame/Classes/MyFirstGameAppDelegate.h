//
//  MyFirstGameAppDelegate.h
//  MyFirstGame
//
//  Created by Ricardo Quesada on 17/07/09.
//  Copyright Sapus Media 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface MyFirstGameAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

