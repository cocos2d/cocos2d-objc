//
//  CCGestureListener.h
//  cocos2d-ios
//
//  Created by Philippe Hausler on 6/30/14.
//
//

#import "CCMacros.h"
#if __CC_PLATFORM_ANDROID

#import <BridgeKitV3/BridgeKit.h>

@protocol CCGestureListenerDelegate <NSObject>
@optional
- (BOOL)onDoubleTap:(AndroidMotionEvent *)e;
- (BOOL)onDown:(AndroidMotionEvent *)e;
- (BOOL)onFling:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end velocityX:(float)velocityX velocityY:(float)velocityY;
- (void)onLongPress:(AndroidMotionEvent *)e;
- (BOOL)onScroll:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end distanceX:(float)dx distanceY:(float)dy;
@end

BRIDGE_CLASS("org.cocos2d.CCGestureListener")
@interface CCGestureListener : JavaObject <AndroidGestureDetectorOnGestureListener>

@property (nonatomic, assign) id<CCGestureListenerDelegate> delegate;

- (id)init;
- (BOOL)onDoubleTap:(AndroidMotionEvent *)e;
- (BOOL)onDown:(AndroidMotionEvent *)e;
- (BOOL)onFling:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end velocityX:(float)velocityX velocityY:(float)velocityY;
- (void)onLongPress:(AndroidMotionEvent *)e;
- (BOOL)onScroll:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end distanceX:(float)dx distanceY:(float)dy;

@end

#endif
