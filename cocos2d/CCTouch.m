//
//  CCTouch.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/12/14.
//
//

#import "cocos2d.h"
#import "CCTouch.h"
#import "CCDirector.h"

@implementation CCTouch

- (instancetype)initWithPlatformTouch:(PlatformTouch*)touch
{
    if((self = [super init]))
    {
        _uiTouch = touch;
        _view = (CCGLView*)[CCDirector sharedDirector].view;
        return self;
    }
    
    return self;
}

+ (instancetype)touchWithPlatformTouch:(PlatformTouch*)touch
{
    return [[self alloc] initWithPlatformTouch:touch];
}

- (CCTouchPhase)phase
{
    return (CCTouchPhase)_uiTouch.phase;
}

- (NSUInteger)tapCount
{
    return _uiTouch.tapCount;
}

- (NSTimeInterval)timestamp
{
    return _uiTouch.timestamp;
}

- (CGPoint)locationInNode:(CCNode*) node
{
    CCDirector* dir = [CCDirector sharedDirector];
    
    CGPoint touchLocation = [self locationInView: [self view]];
	touchLocation = [dir convertToGL: touchLocation];
    return [node convertToNodeSpace:touchLocation];
}

- (CGPoint)locationInWorld
{
    CCDirector* dir = [CCDirector sharedDirector];
    
    CGPoint touchLocation = [self locationInView: [self view]];
	return [dir convertToGL: touchLocation];
}

- (CGPoint)locationInView:(CCGLView *)view
{
    return (CGPoint){0, 0};
}

- (CGPoint)previousLocationInView:(CCGLView *)view
{
    return (CGPoint){0, 0};
}

- (NSString *)description
{
    CGPoint loc = [self locationInView:nil];
    return [NSString stringWithFormat:@"<%@: %p location: {%f, %f} phase: %ld>", [self class], self, loc.x, loc.y, (unsigned long)self.phase];
}

@end


