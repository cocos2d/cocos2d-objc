//
//  CCTouchIOS.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import "CCTouch.h"

#if __CC_PLATFORM_IOS

@class CCViewiOSGL;

@interface CCTouchIOS : CCTouch

- (CGPoint)locationInView:(CCViewiOSGL *)view;
- (CGPoint)previousLocationInView:(CCViewiOSGL *)view;

@end

#endif
