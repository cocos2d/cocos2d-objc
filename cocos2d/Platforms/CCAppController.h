//
//  CCAppController.h
//  cocos2d
//
//  Created by Donald Hutchison on 13/01/15.
//
//

#import <Foundation/Foundation.h>

@class NSWindow;
@class CCGLView;

/**
 *  
 CCAppController serves as the setup point for the application and prepares cocos2d to run with various platform specific settings.
 It exists outside of cocos scene management, and as such can be used to start application specific logic.
 
 An instance of this class (or a subclass) should be invoked from the entry point of execution for each platform. These points are:
 
 * AppDelegate#application:didFinishLaunchingWithOptions: (iOS)
 * AppDelegate#applicationDidFinishLaunching: (Mac)
 * CCActivity#run (Android)
  
 For SpriteBuilder projects the above files will be generated automatically with the correct invocations. 
 
 Caveats exist for Android, as unlike with other platforms the GL context is not initialized before the setup process begins. Care must 
 be taken not to perform setup logic that requires access to GL functions before initialization is complete.

 */

@interface CCAppController : NSObject


/// -----------------------------------------------------------------------
/// @name Mac Specific
/// -----------------------------------------------------------------------

/**
*  The application window (set from .xib)
*/
@property (weak) NSWindow *window;

/**
 *  The GLView (set from .xib)
 */
@property (weak) CCGLView *glView;

/**
 *  The application window size to be displayed on mac.
    Default value (480.0f, 320.0f)
 *
 *  @return CGSize
 */
- (CGSize)defaultWindowSize;


/// -----------------------------------------------------------------------
/// @name Application Setup
/// -----------------------------------------------------------------------


/**
 *  The name of the first scene to be displayed - by default this is "MainScene"
 */
@property(nonatomic, copy) NSString *firstSceneName;

/**
 *  Setup and configure cocos for the current platform. This method should be invoked from the entry point of
*  the application.
 */
- (void)setupApplication;

@end
