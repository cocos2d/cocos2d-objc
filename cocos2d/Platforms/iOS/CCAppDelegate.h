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

@class CCAppDelegate;
@class CCScene;


@interface CCNavigationController : UINavigationController <CCDirectorDelegate> {
}
@end

/**
 Most Cocos2d apps should override the CCAppDelegate, it serves as the apps starting point.
 
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
 
 @note The undocumented CCNavigationController is a subclass of [UINavigationController](https://developer.apple.com/library/ios/documentation/Uikit/reference/UINavigationController_Class/index.html).
 It implements certain navigation controller methods mainly related to orientation and projection changes Cocos2D needs to know about. Other than that it is just a regular UINavigationController.
 */
@property (atomic, readonly) CCNavigationController *navController;

// -----------------------------------------------------------------------
/** @name Creating the Start Scene */
// -----------------------------------------------------------------------

/**
 *  Override this method to return the very first scene that Cocos2D should present.
 *
 *  @return The first scene of your app. It will be presented automatically.
 */
- (CCScene*) startScene;

// -----------------------------------------------------------------------
/** @name Cocos2d Setup */
// -----------------------------------------------------------------------

/**
 *  This method is called from the `applicaton:didFinishLaunchingWithOptions:` UIApplicationDelegate method. 
 *  It will configure Cocos2D with the options that you provide. You can leave out any of the options to have Cocos2D use default values.
 *  Some of the settings can be changed at runtime, for instance the debug stats.
 *
 *  Currently supported keys for the configuration dictionary are:
 *
 *  - `CCSetupPixelFormat`: NSString with the pixel format, normally `kEAGLColorFormatRGBA8` or `kEAGLColorFormatRGB565`. The RGB565 option is faster and recommended, unless color vibrancy is noticably impaired or you need the alpha channel.
 *  - `CCSetupScreenMode`: NSString value that accepts either `CCScreenModeFlexible` or `CCScreenModeFixed`.
 *  - `CCSetupScreenOrientation`: NSString value that accepts `CCScreenOrientationLandscape`, `CCScreenOrientationPortrait`, or `CCScreenOrientationAll`.
 *  - `CCSetupAnimationInterval`: NSNumber with double. Specifies the desired interval between animation frames. Supported values are `1.0/60.0` (default, 60 fps) and `1.0/30.0` (30 fps).
 *  - `CCSetupFixedUpdateInterval`: NSNumber with double. Specifies the desired interval between fixed updates. Should be smaller than `CCSetupAnimationInterval`. Defaults to `1.0/60.0` (60 Hz).
 *  - `CCSetupShowDebugStats`: NSNumber with bool. Specifies if the stats (FPS, frame time and draw call count) should be rendered. Defaults to NO.
 *  - `CCSetupTabletScale2X`: NSNumber with bool. If true, the iPad will be setup to act like it has a 512x384 points "logical" screen size with a "Retina" pixel resolution of 1024x768. 
 *      This makes it much easier to make universal iOS games. This is the default mode for SpriteBuilder projects. This value is ignored when using the fixed screen mode.
 *
 *  - `CCSetupDepthFormat`: NSNumber with integer. Specifies the desired depth buffer format. Values are 0 (no depth buffering), `GL_DEPTH24_STENCIL8_OES` (8-Bit depth buffer) and `GL_DEPTH_COMPONENT24_OES` (24-bit depth buffer).
 *      Depth buffering is only needed in rare cases and comes at the expense of performance and additional memory usage.
 *  - `CCSetupPreserveBackbuffer`: NSNumber with bool. Specifies whether backbuffer will be preserved. Defaults to NO.
 *  - `CCSetupMultiSampling`: NSNumber with bool. Specifies whether multisampling (fullscreen anti-aliasing) is enabled. Defaults to NO.
 *  - `CCSetupNumberOfSamples`: NSNumber with integer. Specifies number of samples when multisampling is enabled. Ignored if multisampling is not enabled.
 *
 *  @param config Dictionary with setup options for Cocos2D.
 */
- (void) setupCocos2dWithOptions:(NSDictionary*)config;

@end

#endif
