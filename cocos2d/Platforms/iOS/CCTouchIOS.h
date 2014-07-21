//
//  CCTouchIOS.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import "CCTouch.h"

#if __CC_PLATFORM_IOS

@interface CCTouchIOS : CCTouch

- (CGPoint)locationInView:(CCGLView *)view;
- (CGPoint)previousLocationInView:(CCGLView *)view;

@end

#endif
