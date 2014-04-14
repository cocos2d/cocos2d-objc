//
//  CCBAnimationManager+FrameAnimation.h
//  cocos2d-ios
//
//  Created by Martin Walsh on 14/04/2014.
//
//

#import "CCBAnimationManager.h"

@interface CCBAnimationManager (FrameAnimation)

#pragma mark Cocos2D Animation Support
- (void)animationWithSpriteFrames:animFrames delay:(float)delay name:(NSString*)name node:(CCNode*)node loop:(BOOL)loop;

@end
