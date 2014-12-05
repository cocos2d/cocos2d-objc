//
//  CCEffectOutline.h
//  cocos2d
//
//  Created by Oleg Osin on 12/3/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectOutline create an outline around a sprite.
 *
 */

@interface CCEffectOutline : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** Color of the outline */
@property (nonatomic, strong) CCColor* outlineColor;

/** Outline pixel width of the outline */
@property (nonatomic) int outlineWidth;

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectDFOutline object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDFOutline.
 *
 *  @return The CCEffectDFOutline object.
 */
-(id)init;

/**
 *  Initializes a CCEffectOutline object with the supplied parameters.
 *
 *  @param outlineColor Color of the outline, a [CCColor blackColor] will result in an opaque black outline.
 *  @param outlineWidth pixel width of the outline.
 *
 *  @return The CCEffectOutline object.
 */
-(id)initWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth;
+(id)effectWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth;

@end
