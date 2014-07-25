//
//  CCEffectSaturation.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/14/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectSaturation adjusts the saturation of the sprite or effect node it is attached to.
 *
 */

@interface CCEffectSaturation : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** The saturation adjustment value which is in the range [-1..1]. -1 completely
 *  desaturates all affected pixels resulting in a grayscale image, 0 results in
 *  no change, 1 results in an increase in saturation by 100%.
 */
@property (nonatomic) float saturation;


/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectSaturation object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectSaturation object with a saturation adjustment of 0.
 *
 *  @return The CCEffecSaturation object.
 */
-(id)init;

/**
 *  Initializes a CCEffectSaturation object with the supplied parameters.
 *
 *  @param saturation The desired saturation adjustment.
 *
 *  @return The CCEffectSaturation object.
 */
-(id)initWithSaturation:(float)saturation;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectSaturation object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectSaturation object with the supplied parameters.
 *
 *  @param saturation The desired saturation adjustment.
 *
 *  @return The CCEffectSaturation object.
 */
+(id)effectWithSaturation:(float)saturation;

@end

