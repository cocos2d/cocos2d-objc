//
//  CCEffectLighting.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/2/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectLighting uses a normal map and a collection of light nodes to compute the Phong
 * lighting on the affected node.
 *
 * @note This class is currently considered experimental. Set the `CC_EFFECTS_EXPERIMENTAL` macro to 1 in ccConfig.h if you want to use this class.
 *
 *  @since v3.4 and later
 */
@interface CCEffectLighting : CCEffect

/// -----------------------------------------------------------------------
/// @name Creating a Lighting Effect
/// -----------------------------------------------------------------------

/**
 *  Creates and initializes a CCEffectLighting object with the supplied parameters.
 *
 *  @param groups         The light groups this effect belongs to.
 *  @param specularColor  The specular color of this effect.
 *  @param shininess      The overall shininess of the effect.
 *
 *  @return The CCEffectLighting object.
 *  @since v3.4 and later
 *  @see CCColor
 */
+(id)effectWithGroups:(NSArray *)groups specularColor:(CCColor *)specularColor shininess:(float)shininess;

/**
 *  Initializes a CCEffectLighting object.
 *
 *  @return The CCEffectLighting object.
 *  @since v3.4 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectLighting object with the supplied parameters.
 *
 *  @param groups         The light groups this effect belongs to.
 *  @param specularColor  The specular color of this effect.
 *  @param shininess      The overall shininess of the effect.
 *
 *  @return The CCEffectLighting object.
 *  @since v3.4 and later
 *  @see CCColor
 */
-(id)initWithGroups:(NSArray *)groups specularColor:(CCColor *)specularColor shininess:(float)shininess;

/// -----------------------------------------------------------------------
/// @name Lighting Properties
/// -----------------------------------------------------------------------


/** The groups that this effect belongs to. Instances of CCLightNode also
 *  belong to groups. The intersection of a light effect's groups and a light
 *  node's groups determine whether or not a light node contributes to a light
 *  effect.
 *  @since v3.4 and later
 */
@property (nonatomic, copy) NSArray *groups;

/**
 *  The specular color of the affected node. This color is combined with the light's
 *  color and the effect's shininess value to determine the color of specular highlights
 *  that appear when lighting shiny surfaces.
 *  @since v3.4 and later
 *  @see CCColor
 */
@property (nonatomic, strong) CCColor* specularColor;

/**
 *  The shininess of the affected node. This value controls the tightness of specular
 *  highlights and is in the range [0..1]. 0 results in no specular contribution to the 
 *  lighting equations and increasing values result in tighter highlights.
 *  @since v3.4 and later
 */
@property (nonatomic, assign) float shininess;

@end

