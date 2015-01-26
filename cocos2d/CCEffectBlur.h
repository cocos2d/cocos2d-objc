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
/// @name Blur Radius
/// -----------------------------------------------------------------------

/** The size of the blur. This value is in the range [0..n].
 *  @since v3.2 and later
 */
@property (nonatomic, assign) NSUInteger blurRadius;


/// -----------------------------------------------------------------------
/// @name Creating a Blur Effect
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectBlur object with the specified parameters.
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program).
 *
 *  @return The CCEffectBlur object.
 *  @since v3.2 and later
 */
+(instancetype)effectWithBlurRadius:(NSUInteger)blurRadius;

/**
 *  Initializes a CCEffectBlur object with the following default parameters:
 *  blurRadius = 2
 *
 *  @return The CCEffectBlur object.
 *  @since v3.2 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectBlur object with the specified parameters.
 *
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program).
 *
 *  @return The CCEffectBlur object.
 *  @since v3.2 and later
 */
-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius;

@end



