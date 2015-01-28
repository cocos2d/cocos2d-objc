//
//  CCTouchIOS.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import "CCTouchIOS.h"
#import "CCTouch.h"
#import "CCDirector.h"

#if __CC_PLATFORM_IOS

@implementation CCTouchIOS

- (CGPoint)locationInView:(CCViewiOSGL *)view
{
    return [self.uiTouch locationInView:view];
}

- (CGPoint)previousLocationInView:(CCViewiOSGL *)view
{
    return [self.uiTouch previousLocationInView:view];
}

@end

#endif
