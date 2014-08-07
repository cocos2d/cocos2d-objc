//
//  CCEffectBlur.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/12/14.
//
//

#import "CCEffect.h"


/**
 * CCEffectBlur performs blur operation on the pixels of the attached node.
 */

@interface CCEffectBlur : CCEffect


/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** The size of the blur. This value is in the range [0..6].
 */
@property (nonatomic) NSUInteger blurRadius;


/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectBlur object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectBlur object with the following default parameters:
 *  blurRadius = 2
 *
 *  @return The CCEffectBlur object.
 */
-(id)init;

/**
 *  Initializes a CCEffectBlur object with the specified parameters.
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program).
 *
 *  @return The CCEffectBlur object.
 */
-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectBlur object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectBlur object with the specified parameters.
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program).
 *
 *  @return The CCEffectBlur object.
 */
+(id)effectWithBlurRadius:(NSUInteger)blurRadius;

@end



