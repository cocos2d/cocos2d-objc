//
//  CCBAnimationManager+FrameAnimation.h
//  cocos2d-ios
//
//  Created by Martin Walsh on 14/04/2014.
//
//

#import "CCAnimationManager.h"

@interface CCAnimationManager (FrameAnimation)

- (void)animationWithSpriteFrames:animFrames delay:(float)delay name:(NSString*)name node:(CCNode*)node loop:(BOOL)loop;

#pragma mark Legacy Animation Support
/**
 *  Add an animation from a NSDictionary.
 *
 *  @param dictionary Dictionary.
 */
- (void)addAnimationsWithDictionary:(NSDictionary *)dictionary node:(CCNode*)node;


/**
 *  Add an animation from a file.
 *
 *  @param plist File path.
 */
- (void)addAnimationsWithFile:(NSString *)plist node:(CCNode*)node;

@end
