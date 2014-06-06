//
//  CCEffectStack.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectStack : CCEffect

@property (nonatomic, readonly) NSUInteger effectCount;

- (id)init;
- (id)initWithEffects:(NSArray *)effects;

- (void)addEffect:(CCEffect *)effect;
- (void)removeEffect:(CCEffect *)effect;
- (CCEffect *)effectAtIndex:(NSUInteger)effectIndex;

+(CCEffect*)effects:(id)firstObject, ...;

@end
#endif
