//
//  CCEffectDFOutline.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/29/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectDFOutline create a drop shadow.
 *
 */

@interface CCEffectDFOutline : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

@property (nonatomic, strong) CCColor* fillColor;
@property (nonatomic, strong) CCColor* outlineColor;

@property (nonatomic) float outlineInnerWidth;
@property (nonatomic) float outlineOuterWidth;

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectDFOutline object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDFOutline object with a (5, -5) black drop shadow offset .
 *
 *  @return The CCEffectDFOutline object.
 */
-(id)init;

/**
 *  Initializes a CCEffectDFOutline object with the supplied parameters.
 *
 *  @param glowColor Color of the glow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *
 *  @return The CCEffectDFOutline object.
 */
-(id)initWithOutlineColor:(CCColor*)outlineColor fillColor:(CCColor*)fillColor;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectDFOutline object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDFOutline object with the supplied parameters.
 *
 *  @param glowColor Color of the glow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *
 *  @return The CCEffectDFOutline object.
 */
+(id)effectWithOutlineColor:(CCColor*)outlineColor fillColor:(CCColor*)fillColor;

@end
