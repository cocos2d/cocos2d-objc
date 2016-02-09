//
//  CCEffectGlass.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/15/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectGlass uses reflection and refraction to simulate the appearance of a transparent object
 * contained within an environment. Refraction is controlled with a single refraction strength value, 
 * the normal map, and a refraction environment sprite. Reflection is controlled with two fresnel 
 * reflectance values, the normal map, and a reflection environment sprite (which may be different 
 * from the refraction environment).
 *
 */
@interface CCEffectGlass : CCEffect

/// -----------------------------------------------------------------------
/// @name Creating a Glass Effect
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectGlass object with the supplied parameters and a nil normal map.
 *
 *  @param shininess The overall shininess.
 *  @param refraction The refraction strength.
 *  @param refractionEnvironment The environment image that will be refracted by the affected node.
 *  @param reflectionEnvironment The environment image that will be reflected by the affected node.
 *
 *  @return The CCEffectGlass object.
 *  @since v3.2 and later
 *  @see CCSprite
 */
+(instancetype)effectWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment;

/**
 *  Creates a CCEffectGlass object with the supplied parameters.
 *
 *  @param shininess The overall shininess.
 *  @param refraction The refraction strength.
 *  @param refractionEnvironment The environment image that will be refracted by the affected node.
 *  @param reflectionEnvironment The environment image that will be reflected by the affected node.
 *  @param normalMap The normal map of the affected node. This can also be specified as a property of the affected sprite.
 *
 *  @return The CCEffectGlass object.
 *  @since v3.2 and later
 *  @see CCSprite
 *  @see CCSpriteFrame
 */
+(instancetype)effectWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap;

/**
 *  Initializes a CCEffectGlass object with the following default parameters:
 *  refraction = 1.0, fresnelBias = 0.1, fresnelPower = 2.0, refractionEnvironment = nil, reflectionEnvironment = nil, normalMap = nil
 *
 *  @return The CCEffectGlass object.
 *  @since v3.2 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectGlass object with the supplied parameters and a nil normal map.
 *
 *  @param shininess The overall shininess.
 *  @param refraction The refraction strength.
 *  @param refractionEnvironment The environment image that will be refracted by the affected node.
 *  @param reflectionEnvironment The environment image that will be reflected by the affected node.
 *
 *  @return The CCEffectGlass object.
 *  @since v3.2 and later
 *  @see CCSprite
 */
-(id)initWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment;

/**
 *  Initializes a CCEffectGlass object with the supplied parameters.
 *
 *  @param shininess The overall shininess.
 *  @param refraction The refraction strength.
 *  @param refractionEnvironment The environment image that will be refracted by the affected node.
 *  @param reflectionEnvironment The environment image that will be reflected by the affected node.
 *  @param normalMap The normal map of the affected node. This can also be specified as a property of the affected sprite.
 *
 *  @return The CCEffectGlass object.
 *  @since v3.2 and later
 *  @see CCSprite
 *  @see CCSpriteFrame
 */
-(id)initWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap;


/// -----------------------------------------------------------------------
/// @name Glass Properties
/// -----------------------------------------------------------------------

/** The refraction strength value. This value is in the range [-1..1] with -1
 *  resulting in maximum minification of the refracted image, 0 resulting in no
 *  refraction, and 1 resulting in maximum magnification of the refracted image.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float refraction;

/** The overall shininess of the attached sprite. This value is in the range [0..1] and it controls
 *  how much of the reflected environment contributes to the final color of the affected pixels.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float shininess;

/** The bias term in the fresnel reflectance equation:
 *    reflectance = max(0.0, fresnelBias + (1 - fresnelBias) * pow((1 - nDotV), fresnelPower))
 *  This value is in the range [0..1] and it controls the constant (view angle independent) contribution
 *  to the reflectance equation.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float fresnelBias;

/** The power term in the fresnel reflectance equation:
 *    reflectance = max(0.0, fresnelBias + (1 - fresnelBias) * pow((1 - nDotV), fresnelPower))
 *  This value is in the range [0..inf] and it controls the view angle dependent contribution
 *  to the reflectance equation.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float fresnelPower;

/// -----------------------------------------------------------------------
/// @name Refraction, Reflection and Environment Map
/// -----------------------------------------------------------------------

/** The environment that will be refracted by the affected node. Typically this is a
 *  sprite that serves as the background for the affected node so it appears that the viewer
 *  is seeing the refracted environment through the refracting node.
 *  @since v3.2 and later
 *  @see CCSprite
 */
@property (nonatomic, strong) CCSprite *refractionEnvironment;

/** The environment that will be reflected by the affected node. Typically this is a sprite
 *  that is not visible in the scene as it is conceptually "behind the viewer" and only visible
 *  where reflected by the affected node.
 *  @since v3.2 and later
 *  @see CCSprite
 */
@property (nonatomic, strong) CCSprite *reflectionEnvironment;

/** The normal map that encodes the normal vectors of the affected node. Each pixel in the normal
 *  map is a 3 component vector that is perpendicular to the surface of the sprite at that point.
 *  @since v3.2 and later
 *  @see CCSpriteFrame
 */
@property (nonatomic, strong) CCSpriteFrame *normalMap;

@end
