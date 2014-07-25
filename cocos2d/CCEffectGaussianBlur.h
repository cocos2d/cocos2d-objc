//
//  CCEffectGaussianBlur.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/12/14.
//
//

#import "CCEffect.h"


/**
 * CCEffectGaussianBlur performs blur operation on the pixels of the attached node.
 */

@interface CCEffectGaussianBlur : CCEffect


/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** The size of the blur. This value is in the range [0..6].
 */
@property (nonatomic) NSUInteger blurRadius;


/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectGaussianBlur object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectGaussianBlur object with the following default parameters:
 *  blurRadius = 2
 *
 *  @return The CCEffectGaussianBlur object.
 */
-(id)init;

/**
 *  Initializes a CCEffectGaussianBlur object with the specified parameters.
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program).
 *
 *  @return The CCEffectGaussianBlur object.
 */
-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectGaussianBlur object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectGaussianBlur object with the specified parameters.
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program).
 *
 *  @return The CCEffectGaussianBlur object.
 */
+(id)effectWithPixelBlurRadius:(NSUInteger)blurRadius;

@end



