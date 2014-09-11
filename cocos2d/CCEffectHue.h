//
//  CCEffectHue.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/9/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectHue adjusts the hue of the sprite or effect node it is attached to.
 *
 */

@interface CCEffectHue : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** The adjustment value that is used to shift the hue of the affected pixel colors. This 
 *  value is in the range [-180..180] and represents the angle of rotation of the color 
 *  values in the HSV color space. In HSV space, the color red is at 0 degrees, green is at
 *  120 degrees, and blue is at 240 degrees. So if you have a red sprite and you apply a
 *  hue adjustment of 120 you will get a green sprite. Instead if you apply a hue adjustment
 *  of -120 you will get a blue sprite.
 */
@property (nonatomic, assign) float hue;


/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectHue object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectHue object with a hue adjustment of 0.
 *
 *  @return The CCEffectHue object.
 */
-(id)init;

/**
 *  Initializes a CCEffectHue object with the supplied parameters.
 *
 *  @param hue The desired hue adjustment.
 *
 *  @return The CCEffectHue object.
 */
-(id)initWithHue:(float)hue;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectHue object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectHue object with the supplied parameters.
 *
 *  @param hue The desired hue adjustment.
 *
 *  @return The CCEffectHue object.
 */
+(id)effectWithHue:(float)hue;

@end
