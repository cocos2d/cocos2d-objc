//
//  CCTouchIOS.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import "CCTouchIOS.h"
#import "cocos2d.h"
#import "CCTouch.h"
#import "CCDirector.h"

#if __CC_PLATFORM_IOS

@implementation CCTouchIOS

- (CGPoint)locationInView:(CCGLView *)view
{
    return [self.uiTouch locationInView:view];
}

- (CGPoint)previousLocationInView:(CCGLView *)view
{
    return [self.uiTouch previousLocationInView:view];
}

@end

#endif
