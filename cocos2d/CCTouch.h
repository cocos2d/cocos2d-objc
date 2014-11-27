//
//  CCTouch.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/12/14.
//
//

#import "ccMacros.h"

#if __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#define PlatformTouch UITouch
#elif __CC_PLATFORM_ANDROID
@class CCTouchAndroid;
#define PlatformTouch CCTouchAndroid // Note: Replace this with MotionEvent or some Android touch object
#else 
#define PlatformTouch NSObject
#endif

@class CCGLView;
@class CCNode;

/** Touch phases, equivalent to [UITouch phases](https://developer.apple.com/library/ios/documentation/uikit/reference/UITouch_Class/index.html#//apple_ref/c/tdef/UITouchPhase).
 Used by touch events received through CCResponder. */
typedef NS_ENUM (NSInteger, CCTouchPhase) {
    /** A finger just touched the screen. */
    CCTouchPhaseBegan,
    /** A finger on the screen just moved. */
    CCTouchPhaseMoved,
    /** A finger touches the screen but hasn't moved recently. */
    CCTouchPhaseStationary,
    /** A finger was lifted from the screen. */
    CCTouchPhaseEnded,
    /** The system cancelled touch events. This can have many reasons, for instance when receiving a call and the screen goes black or a gesture recognizer cancelling touch events. */
    CCTouchPhaseCancelled,
};

/** Thin wrapper around platform-specific touch events (ie [UITouch](https://developer.apple.com/library/ios/documentation/uikit/reference/UITouch_Class/index.html)).
 CCTouch is platform independent version of the touch event objects sent by iOS, Android and OS X.
 
 @note You should never create instances of CCTouch. */
@interface CCTouch : NSObject

/** @name Touch Information */
/** The CCTouchPhase this touch is currently in.
 @since v3.2 and later
 */
@property (nonatomic, readonly) CCTouchPhase phase;
/** The number of taps for this touch event.
 @since v3.2 and later
*/
@property (nonatomic, readonly) NSUInteger tapCount;
/** The timestamp of the most recent touch phase change. 
 @since v3.2 and later
*/
@property (nonatomic, readonly) NSTimeInterval timestamp;

/** @name Associated View and Platform Touch */

/** The associated Cocos2D view.
 @since v3.2 and later
*/
@property (nonatomic, strong) CCGLView *view;
/** The associated platform-specific touch event (ie UITouch).
 PlatformTouch is equivalent to UITouch on iOS, CCTouchAndroid on Android and NSObject on OS X.
 @note The CCTouchAndroid class is not documented, it is just a subset of CCTouch.
 @since v3.2 and later
*/
@property (nonatomic, strong) PlatformTouch* uiTouch;

- (instancetype)initWithPlatformTouch:(PlatformTouch*)touch;
+ (instancetype)touchWithPlatformTouch:(PlatformTouch*)touch;

/** @name Convert Touch Location to Node Coordinate System */

/**
 @param node The node to which this touch should be relative to.
 @returns The touch location relative to the given node's position. 
 @since v3.2 and later
*/
- (CGPoint)locationInNode:(CCNode*) node;
/**
 @returns The touch location relative to the scene (aka "world"). 
 @since v3.2 and later
*/
- (CGPoint)locationInWorld;

/** @name Convert Touch Location to View Coordinate System */

/**
 @param view The view to which this touch should be relative to.
 @returns The touch location relative to the given view. 
 @since v3.2 and later
*/
- (CGPoint)locationInView:(CCGLView *)view;
/**
 @param view The view to which this touch should be relative to.
 @returns The previous touch location relative to the given view. 
 @since v3.2 and later
*/
- (CGPoint)previousLocationInView:(CCGLView *)view;

@end
