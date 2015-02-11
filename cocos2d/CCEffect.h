//
//  CCEffect.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"
#import "CCShader.h"
#import "ccConfig.h"
#import "ccTypes.h"


/**
 CCEffect is the abstract base class of the Cocos2D effects classes. Subclasses of CCEffect can be used to easily add exciting
 visual effects such has blur, bloom, reflection, refraction, and other image processing filters to your applications.
 
 ### Subclasses
 
 - CCEffectBloom
 - CCEffectBlur, CCEffectPixellate
 - CCEffectBrightness, CCEffectContrast, CCEffectHue, CCEffectSaturation, CCEffectInvert, CCEffectColorChannelOffset
 - CCEffectDropShadow
 - CCEffectGlass, CCEffectReflection, CCEffectRefraction
 - CCEffectLighting
 - CCEffectStack
 - Experimental as of v3.4: CCEffectDistanceField, CCEffectDFInnerGlow, CCEffectDFOutline
 */
@interface CCEffect : NSObject

/// -----------------------------------------------------------------------
/// @name Effect Properties
/// -----------------------------------------------------------------------

/** An identifier for debugging effects.
 *  @since v3.2 and later
*/
@property (nonatomic, copy) NSString *debugName;

/** Padding in points that will be applied to affected sprites to avoid clipping the
  * effect's visuals at the sprite's boundary. For example, if you create a blur effect
  * whose radius will animate over time but will never exceed 8 points then you should
  * set the padding to at least 8 to avoid clipping.
 *  @since v3.2 and later
  */
@property (nonatomic, assign) CGSize padding;

@end
