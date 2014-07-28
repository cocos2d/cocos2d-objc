//
//  CCTouchAndroid.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//
#import "CCTouchAndroid.h"

#if __CC_PLATFORM_ANDROID

@implementation CCTouchAndroid {
    CGPoint _location;
    CGPoint _prevLoc;
    CCTouchPhase _phase;
    NSTimeInterval _timestamp;
}

- (id)init
{
    self = [super initWithPlatformTouch:nil];
    return self;
}

- (void)update:(CGPoint)pt phase:(CCTouchPhase)phase timestamp:(NSTimeInterval)timestamp
{
    _prevLoc = _location;
    _location = pt;
    _phase = phase;
    _timestamp = timestamp;
}

- (CCTouchPhase)phase
{
    return _phase;
}

- (NSTimeInterval)timestamp
{
    return _timestamp;
}

- (CGPoint)locationInView:(CCGLView *)view
{
    return _location;
}

- (CGPoint)previousLocationInView:(CCGLView *)view
{
    return _prevLoc;
}
@end

#endif