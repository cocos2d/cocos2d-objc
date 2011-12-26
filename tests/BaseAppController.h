//
//  AppController.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 12/17/11.
//  Copyright (c) 2011 Sapus Media. All rights reserved.
//

#import <Availability.h>
#import <Foundation/Foundation.h>

#import "cocos2d.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED


@class UIWindow, UINavigationController;

@interface BaseAppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *rootViewController_;

	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *rootViewController;
@property (readonly) CCDirectorIOS *director;

@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@interface BaseAppController : NSObject <NSApplicationDelegate>
{
	NSWindow		*window_;
	MacGLView		*glView_;
	CCDirectorMac	*director_;							// weak ref
}

@property (nonatomic, assign) IBOutlet NSWindow	*window;
@property (nonatomic, assign) IBOutlet MacGLView	*glView;
@property (nonatomic, readonly) CCDirectorMac	*director;

- (IBAction)toggleFullScreen:(id)sender;

@end
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
