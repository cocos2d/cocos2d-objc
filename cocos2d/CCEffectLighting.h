//
//  CCEffectLighting.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/2/14.
//
//

#import "CCEffect.h"

#if CC_EFFECTS_EXPERIMENTAL

/**
 * CCEffectLighting uses a normal map and a collection of light nodes to compute the Phong
 * lighting on the affected node.
 */
@interface CCEffectLighting : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------


/** The groups that this effect belongs to. Instances of CCLightNode also
 *  belong to groups. The intersection of a light effect's groups and a light
 *  node's groups determine whether or not a light node contributes to a light
 *  effect.
 */
@property (nonatomic, copy) NSArray *groups;

/**
 *  The specular color of the affected node. This color is combined with the light's
 *  color and the effect's shininess value to determine the color of specular highlights
 *  that appear when lighting shiny surfaces.
 */
@property (nonatomic, strong) CCColor* specularColor;

/** 
 *  The shininess of the affected node. This value controls the tightness of specular
 *  highlights. 0 results in no specular contribution to the lighting equations and
 *  increasing values result in tighter highlights.
 */
@property (nonatomic, assign) float shininess;

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectLighting object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectLighting object.
 *
 *  @return The CCEffectLighting object.
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
 */
-(id)initWithGroups:(NSArray *)groups specularColor:(CCColor *)specularColor shininess:(float)shininess;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectLighting object
/// -----------------------------------------------------------------------

/**
 *  Creates and initializes a CCEffectLighting object with the supplied parameters.
 *
 *  @param groups         The light groups this effect belongs to.
 *  @param specularColor  The specular color of this effect.
 *  @param shininess      The overall shininess of the effect.
 *
 *  @return The CCEffectLighting object.
 */
+(id)effectWithGroups:(NSArray *)groups specularColor:(CCColor *)specularColor shininess:(float)shininess;

@end

#endif

