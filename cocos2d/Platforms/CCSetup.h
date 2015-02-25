/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2015 Cocos2D Authors
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
 */

#import <Foundation/Foundation.h>
#import "CCDirector.h"

@class NSWindow;
@class CCGLView;
@class CCScene;

/**
 *  
 CCSetup serves as the setup point for the application and prepares cocos2d to run with various platform specific settings.
 It exists outside of cocos scene management, and as such can be used to start application specific logic.
 
 An instance of this class (or a subclass) should be invoked from the entry point of execution for each platform. These points are:
 
 * AppDelegate#application:didFinishLaunchingWithOptions: (iOS)
 * AppDelegate#applicationDidFinishLaunching: (Mac)
 * CCActivity#run (Android)
  
 For SpriteBuilder projects the above files will be generated automatically with the correct invocations. 
 
 Caveats exist for Android, as unlike with other platforms the GL context is not initialized before the setup process begins. Care must 
 be taken not to perform setup logic that requires access to GL functions before initialization is complete.

 */



@interface CCSetup : NSObject

+ (instancetype)sharedSetup;

#if __CC_PLATFORM_IOS

@property (nonatomic, readonly) UIWindow *window;

#elif __CC_PLATFORM_MAC

@property (nonatomic, readonly) NSWindow *window;

#endif

@property (nonatomic, readonly) NSDictionary *config;

/**
*  Loads configCocos2D.plist from disk or returns an empty dictionary.
*  Override to provide alternate configuration shared by all platforms.
*/
-(NSDictionary *)baseConfig;

/**
*  The view in which the cocos nodes and scene graph are rendered
*/
@property (nonatomic) CC_VIEW<CCView> *view;

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

#if __CC_PLATFORM_MAC
/// -----------------------------------------------------------------------
/// @name Mac Specific
/// -----------------------------------------------------------------------

/**
*  Override to provide Mac specific configuration options.
*  Default implementation simply calls baseConfig.
*/
- (NSDictionary *)macConfig;

/**
 Called from setupApplication to setup the Mac platform. Override this to perform custom setup.
 */
- (void)setupMac;

/**
 *  The application window size to be displayed on mac.
    Default value (480.0f, 320.0f)
 *
 *  @return CGSize
 */
- (CGSize)defaultWindowSize;
#endif


#if __CC_PLATFORM_IOS
/// -----------------------------------------------------------------------
/// @name iOS Specific
/// -----------------------------------------------------------------------

/**
*  Override to provide iOS specific configuration options.
*  Default implementation simply calls baseConfig.
*/
- (NSDictionary *)iosConfig;

/**
 Called from setupApplication to setup the iOS platform. Override this to perform custom setup.
 */
- (void)setupMac;
#endif


#if __CC_PLATFORM_ANDROID
/// -----------------------------------------------------------------------
/// @name Android Specific
/// -----------------------------------------------------------------------

/**
*  Override to provide Android specific configuration options.
*  Default implementation simply calls baseConfig.
*/
- (NSDictionary *)androidConfig;

/**
 Called from setupApplication to setup the iOS platform. Override this to perform custom setup.
 */
- (void)setupAndroid;
#endif


/// -----------------------------------------------------------------------
/// @name Application Setup
/// -----------------------------------------------------------------------


/**
 *  The name of the first scene to be displayed - by default this is "MainScene"
 */
@property(nonatomic, copy) NSString *firstSceneName;

/**
 *  Setup and configure cocos for the current platform. This method should be invoked from the entry point of the application.
 */
- (void)setupApplication;

- (void)setupIOS;
- (void)setupAndroid;

/**
    Instantiate and return the first scene in the application
    Only override this if you wish to load something other than a `.ccb` file
    (i.e. a programaticaly created CCScene instance)
 */
- (CCScene*) createFirstScene;


@end
