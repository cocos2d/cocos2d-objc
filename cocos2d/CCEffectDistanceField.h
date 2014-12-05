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
/// @name Creating a Distance Field Effect
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDistanceField object with the supplied parameters.
 *
 *  @param glowColor Color of the glow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *  @param outlineColor Color of the outline.
 *
 *  @return The CCEffectDistanceField object.
 *  @since v3.3 and later
 *  @see CCColor
 */
+(id)effectWithGlowColor:(CCColor*)glowColor outlineColor:(CCColor*)outlineColor;

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
 *  @see CCColor
 */
-(id)initWithGlowColor:(CCColor*)glowColor outlineColor:(CCColor*)outlineColor;

/// -----------------------------------------------------------------------
/// @name Effect Color
/// -----------------------------------------------------------------------

/** Fill Color
 * [CCColor blackColor] will result in an opaque black drop shadow.
 * @since v3.3 and later
 */
@property (nonatomic, strong) CCColor* glowColor;
/** .. */
@property (nonatomic, strong) CCColor* fillColor;
/** .. */
@property (nonatomic, strong) CCColor* outlineColor;

/// -----------------------------------------------------------------------
/// @name Glow and Outline Properties
/// -----------------------------------------------------------------------

/** .. */
@property (nonatomic) BOOL glow;
/** .. */
@property (nonatomic) BOOL outline;
/** .. */
@property (nonatomic) float outlineInnerWidth;
/** .. */
@property (nonatomic) float outlineOuterWidth;
/** .. */
@property (nonatomic) GLKVector2 glowOffset;
/** .. */
@property (nonatomic) float glowWidth;

@end

#endif
