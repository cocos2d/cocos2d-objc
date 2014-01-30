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
#ifdef __CC_PLATFORM_IOS

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCDirectorIOS.h"

NSString* const CCSetupPixelFormat;
NSString* const CCSetupScreenMode;
NSString* const CCSetupScreenOrientation;
NSString* const CCSetupAnimationInterval;
NSString* const CCSetupFixedUpdateInterval;
NSString* const CCSetupShowDebugStats;
NSString* const CCSetupTabletScale2X;


// Landscape screen orientation. Used with CCSetupScreenOrientation.
NSString* const CCScreenOrientationLandscape;

// Portrait screen orientation.  Used with CCSetupScreenOrientation.
NSString* const CCScreenOrientationPortrait;


// The flexible screen mode is Cocos2d's default. It will give you an area that can vary slightly in size. In landscape mode the height will be 320 points for mobiles and 384 points for tablets. The width of the area can vary from 480 to 568 points.
NSString* const CCScreenModeFlexible;

// The fixed screen mode will setup the working area to be 568 x 384 points. Depending on the device, the outer edges may be cropped. The safe area, that will be displayed on all sorts of devices, is 480 x 320 points and placed in the center of the working area.
NSString* const CCScreenModeFixed;


@class CCAppDelegate;
@class CCScene;


@interface CCNavigationController : UINavigationController <CCDirectorDelegate> {
}
@end

/**
 *  Most Cocos2d apps should override the CCAppDelegate, it serves as the apps starting point. By the very least, the startScene method should be overridden to return the first scene the app should display. To further customize the behavior of Cocos2d, such as the screen mode of pixel format, override the applicaton:didFinishLaunchingWithOptions: method.
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
 *  The window used to display the Cocos2d content.
 */
@property (nonatomic, strong) UIWindow *window;

/**
 *  The navigation controller that Cocos2d is using.
 */
@property (atomic, readonly) CCNavigationController *navController;

// -----------------------------------------------------------------------
/** @name Setting Up the Start Scene */
// -----------------------------------------------------------------------

/**
 *  Override this method to return the first scene that Cocos2d should display.
 *
 *  @return Starting scene for your app.
 */
- (CCScene*) startScene;

// -----------------------------------------------------------------------
/** @name Cocos2d Configuration */
// -----------------------------------------------------------------------

/**
 *  This method is normally called from the applicaton:didFinishLaunchingWithOptions: method. It will configure Cocos2d with the options that you provide. You can leave out any of the options and Cocos2d will use the default values.
 *
 *  Currently supported keys for the configuration dictionary are:
 *
 *  - CCSetupPixelFormat NSString with the pixel format, normally kEAGLColorFormatRGBA8 or kEAGLColorFormatRGB565. The RGB565 option is faster, but will allow less colors.
 *  - CCSetupScreenMode NSString value that accepts either CCScreenModeFlexible or CCScreenModeFixed.
 *  - CCSetupScreenOrientation NSString value that accepts either CCScreenOrientationLandscape or CCScreenOrientationPortrait.
 *  - CCSetupAnimationInterval NSNumber with double. Specifies the desired interval between animation frames. Supported values are 1.0/60.0 (default) and 1.0/30.0.
 *  - CCSetupFixedUpdateInterval NSNumber with double. Specifies the desired interval between fixed updates.Should be smaller than CCSetupAnimationInterval. Defaults to 1/60.0.
 *  - CCSetupShowDebugStats NSNumber with bool. Specifies if the stats (FPS, frame time and draw call count) should be shown. Defaults to NO.
 *  - CCSetupTabletScale2X NSNumber with bool. If true, the iPad will be setup to act like it has a 512x384 "retina" screen. This makes it much easier to make universal iOS games. This value is ignored when using the fixed screen mode.
 *
 *  @param config Dictionary with options for configuring Cocos2d.
 */
- (void) setupCocos2dWithOptions:(NSDictionary*)config;

@end

#endif
