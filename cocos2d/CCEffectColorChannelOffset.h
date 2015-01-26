//
//  CCEffectColorChannelOffset.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 8/19/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectColorChannelOffset shifts the color channels of the sprite or effect node it is attached to.
 */

@interface CCEffectColorChannelOffset : CCEffect

/// -----------------------------------------------------------------------
/// @name Creating a Color Channel Effect
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectColorChannelOffset object with the supplied color channel offsets.
 *
 *  @param redOffset The red color channel ofset.
 *  @param greenOffset The green color channel ofset.
 *  @param blueOffset The blue color channel ofset.
 *
 *  @return The CCEffectColorChannelOffset object.
 *  @since v3.2 and later
 *  @deprecated Use CGPoint version instead.
 */
+(instancetype)effectWithRedOffset:(CGPoint)redOffset greenOffset:(CGPoint)greenOffset blueOffset:(CGPoint)blueOffset;

/**
 *  Initializes a CCEffectColorChannelOffset object with zero length color channel offsets.
 *
 *  @return The CCEffectColorChannelOffset object.
 *  @since v3.2 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectColorChannelOffset object with the supplied color channel offsets.
 *
 *  @param redOffset The red color channel ofset.
 *  @param greenOffset The green color channel ofset.
 *  @param blueOffset The blue color channel ofset.
 *
 *  @return The CCEffectColorChannelOffset object.
 *  @since v3.4 and later
 */
-(id)initWithRedOffset:(CGPoint)redOffset greenOffset:(CGPoint)greenOffset blueOffset:(CGPoint)blueOffset;


/// -----------------------------------------------------------------------
/// @name Color Channel Offsets
/// -----------------------------------------------------------------------

/** The offset, in points, of the red color channel.
 @since v3.4 and later
 */
@property (nonatomic, assign) CGPoint redOffset;

/** The offset, in points, of the green color channel.
 @since v3.2 and later
 @deprecated Use CGPoint version instead.
 */
@property (nonatomic, assign) CGPoint greenOffset;

/** The offset, in points, of the blue color channel.
 @since v3.2 and later
 @deprecated Use CGPoint version instead.
 */
@property (nonatomic, assign) CGPoint blueOffset;

@end
