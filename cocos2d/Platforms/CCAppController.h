//
//  CCAppController.h
//  cocos2d
//
//  Created by Donald Hutchison on 13/01/15.
//
//

#import <Foundation/Foundation.h>
#import "CCDirector.h"

@class NSWindow;
@class CCGLView;
@class CCScene;

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

/**
*  The view in which the cocos nodes and scene graph are rendered
*/
@property (weak) CC_VIEW<CCView> *glView;

/// -----------------------------------------------------------------------
/// @name Mac Specific
/// -----------------------------------------------------------------------

/**
*  The application window (set from .xib)
*/
@property (weak) NSWindow *window;

/**
*  Configuration options that are used to setup cocos2d on Mac
*/
- (NSDictionary *)macConfig;

/**
 *  The application window size to be displayed on mac.
    Default value (480.0f, 320.0f)
 *
 *  @return CGSize
 */
- (CGSize)defaultWindowSize;


/// -----------------------------------------------------------------------
/// @name iOS Specific
/// -----------------------------------------------------------------------

/**
*  Configuration options that are used to setup cocos2d on iOS
*  By default this reads from "configCocos2d.plist" in the Published-iOS directory
*/
- (NSDictionary *)iosConfig;

/// -----------------------------------------------------------------------
/// @name Android Specific
/// -----------------------------------------------------------------------

/**
*  Configuration options that are used to setup cocos2d on Android
*  By default this reads from "configCocos2d.plist" in the Published-Android directory
*/
- (NSDictionary *)androidConfig;

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

/**
    Instantiate and return the first scene in the application
    Only override this if you wish to load something other than a `.ccb` file
    (i.e. a programaticaly created CCScene instance)
 */
- (CCScene*) createFirstScene;


@end
