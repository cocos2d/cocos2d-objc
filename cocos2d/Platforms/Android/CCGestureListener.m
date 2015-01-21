//
//  CCGestureListener.m
//  cocos2d-ios
//
//  Created by Philippe Hausler on 6/30/14.
//
//

#import "CCGestureListener.h"

#if __CC_PLATFORM_ANDROID


@implementation CCGestureListener {
    id<CCGestureListenerDelegate> _delegate;
    struct {
        int onDoubleTap:1;
        int onDown:1;
        int onFling:1;
        int onLongPress:1;
        int onScroll:1;
        int reserved:3;
    } _flags;
}

- (void)setDelegate:(id<CCGestureListenerDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _flags.onDoubleTap = [delegate respondsToSelector:@selector(onDoubleTap:)];
        _flags.onDown = [delegate respondsToSelector:@selector(onDown:)];
        _flags.onFling = [delegate respondsToSelector:@selector(onFling:end:velocityX:velocityY:)];
        _flags.onLongPress = [delegate respondsToSelector:@selector(onLongPress:)];
        _flags.onScroll = [delegate respondsToSelector:@selector(onScroll:end:distanceX:distanceY:)];
        _delegate = delegate;
    }
}

- (id<CCGestureListenerDelegate>)delegate
{
    return _delegate;
}

- (BOOL)onDoubleTap:(AndroidMotionEvent *)e
{
    if (!_flags.onDoubleTap) {
        return NO;
    }
    
    return [_delegate onDoubleTap:e];
}

- (BOOL)onDown:(AndroidMotionEvent *)e
{
    if (!_flags.onDown) {
        return NO;
    }
    
    return [_delegate onDown:e];
}

- (BOOL)onFling:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end velocityX:(float)velocityX velocityY:(float)velocityY
{
    if (!_flags.onFling) {
        return NO;
    }
    
    return [_delegate onFling:start end:end velocityX:velocityX velocityY:velocityY];
}

- (void)onLongPress:(AndroidMotionEvent *)e
{
    if (!_flags.onLongPress) {
        return;
    }
    
    [_delegate onLongPress:e];
}

- (BOOL)onScroll:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end distanceX:(float)dx distanceY:(float)dy
{
    if (!_flags.onScroll) {
        return NO;
    }
    
    return [_delegate onScroll:start end:end distanceX:dx distanceY:dy];
}

@end

#endif
