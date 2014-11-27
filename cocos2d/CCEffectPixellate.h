//
//  CCEffectPixellate.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/8/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectPixellate adjusts the size of the pixels of the sprite or effect node it is attached to.
 */

@interface CCEffectPixellate : CCEffect

/// -----------------------------------------------------------------------
/// @name Creating a Pixelate Effect
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectPixellate object with the supplied parameters.
 *
 *  @param blockSize The desired block size.
 *
 *  @return The CCEffectPixellate object.
 *  @since v3.2 and later
 */
+(id)effectWithBlockSize:(float)blockSize;

/**
 *  Initializes a CCEffectPixellate object with a block size of 1.
 *
 *  @return The CCEffectPixellate object.
 *  @since v3.2 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectPixellate object with the supplied parameters.
 *
 *  @param blockSize The desired block size.
 *
 *  @return The CCEffectPixellate object.
 *  @since v3.2 and later
 */
-(id)initWithBlockSize:(float)blockSize;


/// -----------------------------------------------------------------------
/// @name Adjusting Pixel Size
/// -----------------------------------------------------------------------

/** The resulting size of the pixel blocks of the affected node. This value is specified in points
 *  and is in the range [1..inf]. A value of 1 results in no change to the affected pixels
 *  and larger values result in larger output pixel blocks.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float blockSize;

@end
