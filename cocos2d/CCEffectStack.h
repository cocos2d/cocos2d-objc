//
//  CCEffectStack.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectStack allows multiple effects to be stacked together to form interesting
 * visual combinations. Effect stacks are immutable in the sense that the effects they
 * contain cannot be changed once the stack is created. However, the parameters of the
 * contained effects can be changed.
 *
 */

@interface CCEffectStack : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Stack Attributes
/// -----------------------------------------------------------------------

/** The number of effects contained in the stack. */
@property (nonatomic, readonly) NSUInteger effectCount;


/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectStack object
/// -----------------------------------------------------------------------

/**
 *  Initializes an empty effect stack object.
 *
 *  @return The CCEffectStack object.
 */
- (id)init;

/**
 *  Initializes an effect stack object with the specified array of effects.
 *
 *  @param effects The array of effects to add to the stack.
 *
 *  @return The CCEffectStack object.
 */
- (id)initWithEffects:(NSArray *)effects;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectStack object
/// -----------------------------------------------------------------------

/**
 *  Creates an effect stack object with the specified array of effects.
 *
 *  @param effects The array of effects to add to the stack.
 *
 *  @return The CCEffectStack object.
 */
+ (id)effectStackWithEffects:(NSArray *)effects;


/// -----------------------------------------------------------------------
/// @name Accessing Contained Effects
/// -----------------------------------------------------------------------

/**
 *  Retrieve a contained effect.
 *
 *  @param effectIndex The index of the effect object to retrieve.
 *
 *  @return The selected effect object.
 */
- (CCEffect *)effectAtIndex:(NSUInteger)effectIndex;

@end
