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

typedef NS_ENUM (NSInteger, CCTouchPhase) {
    CCTouchPhaseBegan,
    CCTouchPhaseMoved,
    CCTouchPhaseStationary,
    CCTouchPhaseEnded,
    CCTouchPhaseCancelled,
};

@interface CCTouch : NSObject

@property (nonatomic, readonly) CCTouchPhase phase;
@property (nonatomic, readonly) NSUInteger tapCount;
@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, strong) CCGLView *view;

@property (nonatomic, strong) PlatformTouch* uiTouch;

- (instancetype)initWithPlatformTouch:(PlatformTouch*)touch;
+ (instancetype)touchWithPlatformTouch:(PlatformTouch*)touch;

- (CGPoint)locationInNode:(CCNode*) node;
- (CGPoint)locationInWorld;

- (CGPoint)locationInView:(CCGLView *)view;
- (CGPoint)previousLocationInView:(CCGLView *)view;

@end
