//
//  CCEffectBloom.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/14/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectBloom : CCEffect

// ranges between 0.0-1.0 - defines which part of the image should be glown via a luminance factor (brightness).
@property (nonatomic) float luminanceThreshold;

// intensity ranges between 0.0-1.0 - defines the contrast of the glowing image. A higher value will make the glow more prevelant.
@property (nonatomic) float intensity;

// blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
// of varying variables that can be passed to a glsl program). TODO: create a slower bloom shader, that does not have this restriction.
@property (nonatomic) NSUInteger blurRadius;

/**
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number 
 *  of varying variables that can be passed to a glsl program). TODO: create a slower bloom shader, that does not have this restriction.
 *  @param intensity ranges between 0.0-1.0 - defines the contrast of the glowing image. A higher value will make the glow more prevelant.
 *  @param luminanceThreshold ranges between 0.0-1.0 - defines which part of the image should be glown via a luminance factor (brightness). 
 *  A value of 0.0 will apply bloom to the whole image, a value of 1.0 will only apply bloom to the brightest part of the image.
 */
-(id)init;
-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius intensity:(float)intensity luminanceThreshold:(float)luminanceThreshold;
+(id)effectWithPixelBlurRadius:(NSUInteger)blurRadius intensity:(float)intensity luminanceThreshold:(float)luminanceThreshold;

@end
#endif
