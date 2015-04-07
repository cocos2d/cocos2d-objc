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

extern NSString * const CCSetupPixelFormat;
extern NSString * const CCSetupScreenMode;
extern NSString * const CCSetupScreenOrientation;
extern NSString * const CCSetupFrameSkipInterval;
extern NSString * const CCSetupFixedUpdateInterval;
extern NSString * const CCSetupShowDebugStats;
extern NSString * const CCSetupTabletScale2X;

extern NSString * const CCSetupDepthFormat;
extern NSString * const CCSetupPreserveBackbuffer;
extern NSString * const CCSetupMultiSampling;
extern NSString * const CCSetupNumberOfSamples;
extern NSString * const CCSetupScreenModeFixedDimensions;

// Landscape screen orientation. Used with CCSetupScreenOrientation.
extern NSString * const CCScreenOrientationLandscape;

// Portrait screen orientation.  Used with CCSetupScreenOrientation.
extern NSString * const CCScreenOrientationPortrait;

// Support all screen orientations.  Used with CCSetupScreenOrientation.
extern NSString * const CCScreenOrientationAll;


// The flexible screen mode is Cocos2d's default. It will give you an area that can vary slightly in size. In landscape mode the height will be 320 points for mobiles and 384 points for tablets. The width of the area can vary from 480 to 568 points.
extern NSString * const CCScreenModeFlexible;

// The fixed screen mode will setup the working area to be 568 x 384 points. Depending on the device, the outer edges may be cropped. The safe area, that will be displayed on all sorts of devices, is 480 x 320 points and placed in the center of the working area.
extern NSString * const CCScreenModeFixed;

// The desired default window size for mac
extern NSString * const CCMacDefaultWindowSize;


typedef NS_ENUM(NSUInteger, CCGraphicsAPI) {
	CCGraphicsAPIInvalid = 0,
	CCGraphicsAPIGL,
	CCGraphicsAPIMetal,
};


/**
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

/**
 TODO

 @since 4.0.0
 */
+ (instancetype)sharedSetup;

/**
 In order to call sharedSetup, you must either subclass CCSetup or call createCustomSetup if you intend to set up your windows and views yourself.

 @since 4.0.0
 */
+(void)createCustomSetup;

/**
 Global content scale for the app.
 This is the number of pixels on the screen that are equivalent to a point in Cocos2D.

 @since 4.0.0
 */
@property(nonatomic, assign) float contentScale;

/**
 Minimum content scale of assets such as textures, TTF labels or render textures.
 Normally you want this value to be the same as the contentScale, but on Mac you may want a higher value since the user could resize the window.

 @since 4.0.0
 */
@property(nonatomic, assign) float assetScale;

/**
 UI scaling factor. Positions and content sizes are scale by this factor if the position type is set to UIScale.
 This is useful for creating UIs that have the same physical size (ex: centimeters) on different devices.
 This also affects the loading of assets marked as having a UIScale.

 @since 4.0.0
 */
@property(nonatomic, assign) float UIScale;

/**
 Default fixed update interval that will be used when initializing schedulers.

 @since 4.0.0
 */
@property(nonatomic, assign) CCTime fixedUpdateInterval;

/**
 Which graphics API Cocos2D will use to render.
 Defaults to the GL renderer on all current platforms.

 @since 4.0.0
 */
@property (nonatomic, assign) CCGraphicsAPI graphicsAPI;

/**
*  Loads configCocos2D.plist from disk or returns a default dictionary.
*  Override to provide alternate configuration shared by all platforms.
*
*  Currently supported keys for the configuration dictionary are:
*  - `CCSetupPixelFormat`: NSString with the pixel format, normally `kEAGLColorFormatRGBA8` or `kEAGLColorFormatRGB565`. The RGB565 option is faster and recommended, unless color vibrancy is noticably impaired or you need the alpha channel.
*  - `CCSetupScreenMode`: NSString value that accepts either `CCScreenModeFlexible` or `CCScreenModeFixed`.
*  - `CCSetupScreenOrientation`: NSString value that accepts `CCScreenOrientationLandscape`, `CCScreenOrientationPortrait`, or `CCScreenOrientationAll`.
*  - `CCSetupAnimationInterval`: NSNumber with double. Specifies the desired interval between animation frames. Supported values are `1.0/60.0` (default, 60 fps) and `1.0/30.0` (30 fps).
*  - `CCSetupFixedUpdateInterval`: NSNumber with double. Specifies the desired interval between fixed updates. Should be smaller than `CCSetupAnimationInterval`. Defaults to `1.0/60.0` (60 Hz).
*  - `CCSetupShowDebugStats`: NSNumber with bool. Specifies if the stats (FPS, frame time and draw call count) should be rendered. Defaults to NO.
*  - `CCSetupTabletScale2X`: NSNumber with bool. If true, the iPad will be setup to act like it has a 512x384 points "logical" screen size with a "Retina" pixel resolution of 1024x768.
*      This makes it much easier to make universal iOS games. This is the default mode for SpriteBuilder projects. This value is ignored when using the fixed screen mode.
*  - `CCSetupDepthFormat`: NSNumber with integer. Specifies the desired depth buffer format. Values are 0 (no depth buffering), `GL_DEPTH24_STENCIL8_OES` (8-Bit depth buffer) and `GL_DEPTH_COMPONENT24_OES` (24-bit depth buffer).
*      Depth buffering is only needed in rare cases and comes at the expense of performance and additional memory usage.
*  - `CCSetupPreserveBackbuffer`: NSNumber with bool. Specifies whether backbuffer will be preserved. Defaults to NO.
*  - `CCSetupMultiSampling`: NSNumber with bool. Specifies whether multisampling (fullscreen anti-aliasing) is enabled. Defaults to NO.
*  - `CCSetupNumberOfSamples`: NSNumber with integer. Specifies number of samples when multisampling is enabled. Ignored if multisampling is not enabled.
*/
-(NSDictionary *)setupConfig;

@property (nonatomic, readonly) NSDictionary *config;

/**
 *  Setup and configure Cocos2D for the current platform. This method should be invoked from the entry point of the application.
 */
- (void)setupApplication __attribute__((objc_requires_super));

/**
 *  Setup and configure Cocos2D to use with SpriteBuilder. (Adding search paths, etc.)
 */
-(void)setupForSpriteBuilder;

/**
    Abstract method that creates the initial scene when the app starts up.
 */
- (CCScene*) createFirstScene;

#if __CC_PLATFORM_IOS

/**
 UIWindow created by [CCSetup setupApplication] on iOS.

 @since 4.0.0
 */
@property (nonatomic, readonly) UIWindow *window;

#elif __CC_PLATFORM_MAC

/**
 NSWindow created by [CCSetup setupApplication] on Mac.

 @since 4.0.0
 */
@property (nonatomic, readonly) NSWindow *window;

#endif

/**
 CCView created by [CCSetup setupApplication].
*/
@property (nonatomic, readonly) CC_VIEW<CCView> *view;

@end
