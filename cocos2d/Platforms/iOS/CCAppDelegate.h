/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "../../ccMacros.h"
#if __CC_PLATFORM_IOS

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CCDirectorIOS.h"
#import "CCDirectorView.h"
@class CCAppDelegate;
@class CCScene;


/** Just a plain, simple subclass of [UINavigationController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UINavigationController_Class/index.html).
 It implements certain navigation controller methods mainly related to orientation and projection changes Cocos2D needs to know about. Other than that it is just a regular UINavigationController.
 */
@interface CCNavigationController : UINavigationController <CCDirectorDelegate> {
}
@end

/**
 Most Cocos2d apps should override the CCAppDelegate, it serves as the app's starting point and provides a CCNavigationController.
 
 At the very least the `startScene` method should be overridden to return the first scene the app should display.
 
 To further customize the behavior of Cocos2D, such as the screen mode of pixel format, override the `setupCocos2dWithOptions:` method.
 */
@interface CCAppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
    UIWindow *window_;
	CCNavigationController *navController_;
    
}

// -----------------------------------------------------------------------
/** @name Accessing Window and Navigation Controller */
// -----------------------------------------------------------------------

/**
 *  The [UIWindow](https://developer.apple.com/Library/ios/documentation/UIKit/Reference/UIWindow_Class/index.html) containing the Cocos2D view.
 */
@property (nonatomic, strong) UIWindow *window;

/**
 The navigation controller that Cocos2D is using.
 
 @note The CCNavigationController is a subclass of [UINavigationController](https://developer.apple.com/library/ios/documentation/Uikit/reference/UINavigationController_Class/index.html).
 It implements certain navigation controller methods mainly related to orientation and projection changes Cocos2D needs to know about. Other than that it is just a regular UINavigationController.
 */
@property (atomic, readonly) CCNavigationController *navController;

// -----------------------------------------------------------------------
/** @name Creating the Start Scene */
// -----------------------------------------------------------------------

/**
 *
 *  @note The first scene of your app. It will be presented automatically.
 */
@property (nonatomic) CCScene *startScene;


- (void)constructNavController:(NSDictionary *)config;

- (void)constructWindow;

- (void)forceOrientation;

- (CC_VIEW <CCView> *)constructView:(NSDictionary *)config withBounds:(CGRect)bounds;
@end

#endif
