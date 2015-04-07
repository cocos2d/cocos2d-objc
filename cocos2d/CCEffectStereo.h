//
//  CCEffectStereo.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/16/15.
//
//

#import "CCEffect.h"

#if CC_EFFECTS_EXPERIMENTAL

/**
 The possible color channel selectors for CCEffectStereo.
 */
typedef NS_ENUM(NSUInteger, CCEffectStereoChannelSelect)
{
    /** Only write to the red channel of the framebuffer. */
    CCEffectStereoSelectRed  = 0,

    /** Only write to the green and blue channels (combining into cyan) of the framebuffer. */
    CCEffectStereoSelectCyan = 1,
};


/**
 * CCEffectStereo implements the anaglyph 3D effect by rendering offset but 
 * superimposed copies of the affected sprite with red and cyan tinting.
 *
 */

@interface CCEffectStereo : CCEffect

/// -----------------------------------------------------------------------
/// @name Creating a Stereo Effect
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectStereo object with the supplied channel selector.
 *
 *  @param channelSelect The output channel selector.
 *
 *  @return The CCEffectStereo object.
 *  @since v3.4 and later
 */
+(instancetype)effectWithChannelSelect:(CCEffectStereoChannelSelect)channelSelect;

/**
 *  Initializes a CCEffectStereo object with an offset of zero.
 *
 *  @return The CCEffectStereo object.
 *  @since v3.4 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectColorChannelOffset object with the supplied color channel offsets.
 *
 *  @param redOffset The offset between the superimposed copies of the sprite.
 *
 *  @return The CCEffectStereo object.
 *  @since v3.4 and later
 */
-(id)initWithChannelSelect:(CCEffectStereoChannelSelect)channelSelect;


/// -----------------------------------------------------------------------
/// @name Color channel selector
/// -----------------------------------------------------------------------

/** The output color channel selector.
 @since v3.4 and later
 */
@property (nonatomic, assign) CCEffectStereoChannelSelect channelSelect;

@end

#endif

