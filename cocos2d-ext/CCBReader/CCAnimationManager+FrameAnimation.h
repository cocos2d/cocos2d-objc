//
//  CCBAnimationManager+FrameAnimation.h
//  cocos2d-ios
//
//  Created by Martin Walsh on 14/04/2014.
//
//

#import "CCAnimationManager.h"

/** CCAnimationManager category for sprite frame animations. */
@interface CCAnimationManager (FrameAnimation)

- (void)animationWithSpriteFrames:animFrames delay:(float)delay name:(NSString*)name node:(CCNode*)node loop:(BOOL)loop;

/** @name Sprite Frame Animations */

#pragma mark Legacy Animation Support
/**
 *  Add an animation from a NSDictionary.
 *
 *  @param dictionary Animation data.
 *  @param node The node that will play this animation.
 */
- (void)addAnimationsWithDictionary:(NSDictionary *)dictionary node:(CCNode*)node;


/**
 *  Add an animation from a file.
 *
 *  @param plist File path with dictionary plist containing animation data.
 *  @param node The node that will play this animation.
 */
- (void)addAnimationsWithFile:(NSString *)plist node:(CCNode*)node;

@end
