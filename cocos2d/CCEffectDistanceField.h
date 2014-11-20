//
//  CCEffectDistanceField.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/8/14.
//
//

#import "CCEffect.h"

#if CC_EFFECTS_EXPERIMENTAL

/**
 * CCEffectDistanceField creates a drop shadow.
 *
 */

@interface CCEffectDistanceField : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** Color of the shadow,
 * [CCColor blackColor] will result in an opaque black drop shadow.
 * @since v3.3 and later
 */
@property (nonatomic, strong) CCColor* glowColor;
@property (nonatomic, strong) CCColor* fillColor;
@property (nonatomic, strong) CCColor* outlineColor;

@property (nonatomic) BOOL glow;
@property (nonatomic) BOOL outline;
@property (nonatomic) float outlineInnerWidth;
@property (nonatomic) float outlineOuterWidth;
@property (nonatomic) GLKVector2 glowOffset;
@property (nonatomic) float glowWidth;

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectDistanceField object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDistanceField object with a (5, -5) black drop shadow offset .
 *
 *  @return The CCEffectDistanceField object.
 *  @since v3.3 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectDistanceField object with the supplied parameters.
 *
 *  @param glowColor Color of the glow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *  @param outlineColor Color of the outline.
 *
 *  @return The CCEffectDistanceField object.
 *  @since v3.3 and later
 */
-(id)initWithGlowColor:(CCColor*)glowColor outlineColor:(CCColor*)outlineColor;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectDistanceField object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDistanceField object with the supplied parameters.
 *
 *  @param glowColor Color of the glow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *  @param outlineColor Color of the outline.
 *
 *  @return The CCEffectDistanceField object.
 *  @since v3.3 and later
 */
+(id)effectWithGlowColor:(CCColor*)glowColor outlineColor:(CCColor*)outlineColor;

@end

#endif
