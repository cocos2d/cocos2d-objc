//
//  CCEffectBrightness.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffect.h"


/**
 * CCEffectBrightness adjusts the brightness of the sprite or effect node
 * it is attached to.
 *
 */

@interface CCEffectBrightness : CCEffect


/// -----------------------------------------------------------------------
/// @name Creating a Brightness Effect
/// -----------------------------------------------------------------------

/**
*  Creates a CCEffectBrightness object with the supplied parameters.
*
*  @param brightness The desired brightness adjustment.
*
*  @return The CCEffectBrightness object.
*  @since v3.2 and later
*/
+(id)effectWithBrightness:(float)brightness;

/**
 *  Initializes a CCEffectBrightness object with a brightness adjustment of 0.
 *
 *  @return The CCEffectBrightness object.
 *  @since v3.2 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectBrightness object with the supplied parameters.
 *
 *  @param brightness The desired brightness adjustment.
 * 
 *  @return The CCEffectBrightness object.
 *  @since v3.2 and later
 */
-(id)initWithBrightness:(float)brightness;


/// -----------------------------------------------------------------------
/// @name Brightness
/// -----------------------------------------------------------------------

/** The brightness adjustment value that is added to the pixel colors of the
 *  affected node. This is a normalized value in the range of [-1..1]. A value
 *  of -1 reduces the affected color to 0 (black), 0 results in no change, 1
 *  increases the affected color to 1 (white).
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float brightness;

@end
