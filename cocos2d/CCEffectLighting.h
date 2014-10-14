//
//  CCEffectLighting.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/2/14.
//
//

#import "CCEffect.h"
#import "CCLightNode.h"

#if CC_EFFECTS_EXPERIMENTAL

/**
 * CCEffectLighting uses a normal map and a collection of light nodes to compute the Phong
 * lighting on the affected node.
 */
@interface CCEffectLighting : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

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
 *  Initializes a CCEffectLighting object with no lights.
 *
 *  @return The CCEffectLighting object.
 */
-(id)init;

/**
 *  Initializes a CCEffectLighting object with the supplied parameters.
 *
 *  @param environment The array of lights that will light the affected node.
 *
 *  @return The CCEffectLighting object.
 */
-(id)initWithLights:(NSArray *)lights;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectLighting object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectLighting object with the supplied parameters.
 *
 *  @param environment The array of lights that will light the affected node.
 *
 *  @return The CCEffectLighting object.
 */
+(id)effectWithLights:(NSArray *)lights;


/// -----------------------------------------------------------------------
/// @name Adding and removing lights
/// -----------------------------------------------------------------------

/**
 *  Adds a light to the effect.
 *
 *  @param light CCLightNode to add.
 */
-(void) addLight:(CCLightNode *)light;

/**
 *  Removes a light from the effect.
 *
 *  @param light The light node to remove.
 */
-(void) removeLight:(CCLightNode *)light;

/**
 *  Removes all lights from the effect.
 */
-(void) removeAllLights;


@end

#endif

