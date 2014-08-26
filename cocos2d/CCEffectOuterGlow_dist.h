//
//  CCEffectOuterGlow.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/8/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectOuterGlow create a drop shadow.
 *
 */

@interface CCEffectOuterGlow : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** Color of the shadow,
 * [CCColor blackColor] will result in an opaque black drop shadow.
 */
@property (nonatomic) CCColor* glowColor;

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectOuterGlow object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectOuterGlow object with a (5, -5) black drop shadow offset .
 *
 *  @return The CCEffectOuterGlow object.
 */
-(id)init;

/**
 *  Initializes a CCEffectOuterGlow object with the supplied parameters.
 *
 *  @param glowColor Color of the glow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *
 *  @return The CCEffectOuterGlow object.
 */
-(id)initWithGlowColor:(CCColor*)glowColor;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectOuterGlow object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectOuterGlow object with the supplied parameters.
 *
 *  @param glowColor Color of the glow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *
 *  @return The CCEffectOuterGlow object.
 */
+(id)effectWithGlowColor:(CCColor*)glowColor;

@end
