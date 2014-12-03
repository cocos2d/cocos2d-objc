//
//  CCEffectBloom.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/14/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectBloom simulates bloooming of bright light when viewed against a darker
 * background. A threshold value allows for the selection of pixels above a certain
 * brightness level while radius and intensity parameters how large the bloom is and
 * how much it contributes to the resulting image.
 */

@interface CCEffectBloom : CCEffect


/// -----------------------------------------------------------------------
/// @name Creating a Bloom Effect
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectBloom object with the specified parameters.
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program).
 *
 *  @param intensity ranges between 0.0-1.0 - defines the contrast of the glowing image. A higher value will make the glow more prevelant.
 *
 *  @param luminanceThreshold ranges between 0.0-1.0 - defines which part of the image should be glown via a luminance factor (brightness).
 *  A value of 0.0 will apply bloom to the whole image, a value of 1.0 will only apply bloom to the brightest part of the image.
 *
 *  @return The CCEffectBloom object.
 *  @since v3.2 and later
 */
+(id)effectWithBlurRadius:(NSUInteger)blurRadius intensity:(float)intensity luminanceThreshold:(float)luminanceThreshold;

/**
 *  Initializes a CCEffectBloom object with the following default values:
 *  blurRadius = 2, intensity = 1, luminanceThreshold = 0
 *
 *  @return The CCEffectBloom object.
 *  @since v3.2 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectBloom object with the following default parameters:
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number 
 *  of varying variables that can be passed to a glsl program).
 *
 *  @param intensity ranges between 0.0-1.0 - defines the contrast of the glowing image. A higher value will make the glow more prevelant.
 *
 *  @param luminanceThreshold ranges between 0.0-1.0 - defines which part of the image should be glown via a luminance factor (brightness).
 *  A value of 0.0 will apply bloom to the whole image, a value of 1.0 will only apply bloom to the brightest part of the image.
 *
 *  @return The CCEffectBloom object.
 *  @since v3.2 and later
 */
-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius intensity:(float)intensity luminanceThreshold:(float)luminanceThreshold;

/// -----------------------------------------------------------------------
/// @name Effect Properties
/// -----------------------------------------------------------------------

/** The luminance threshold at which pixels will contribute to the bloom.
 *  This value is in the range [0..1]. Lower values mean that more pixels will
 *  contribute to the blurry bloom image.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float luminanceThreshold;

/** The intensity of the blurred out bloom image when added to the original
 *  unmodified image. This value is in the range [0..1]. 0 results in no bloom
 *  while higher values result in more bloom.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float intensity;

/** The size of the blur of the bloom image. This value is in the range [0..6].
 *  @since v3.2 and later
 */
@property (nonatomic, assign) NSUInteger blurRadius;


@end
