//
//  CCTouchAndroid.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import "CCTouch.h"

#if __CC_PLATFORM_ANDROID

@interface CCTouchAndroid : CCTouch

@property (nonatomic, readonly) CCTouchPhase phase;
@property (nonatomic, readonly) NSUInteger tapCount;
@property (nonatomic, readonly) NSTimeInterval timestamp;

- (void)update:(CGPoint)pt phase:(CCTouchPhase)phase timestamp:(NSTimeInterval)timestamp;

- (CGPoint)locationInView:(CCGLView *)view;
- (CGPoint)previousLocationInView:(CCGLView *)view;


@end

#endif
