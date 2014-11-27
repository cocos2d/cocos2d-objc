//
//  CCEffectRefraction.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 6/19/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectRefraction uses refraction to simulate the appearance of a transparent object contained within an 
 * environment. Refraction is controlled with a single refraction strength value, the normal map, and a refraction 
 * environment sprite.
 */
@interface CCEffectRefraction : CCEffect

/// -----------------------------------------------------------------------
/// @name Creating a Refraction Effect
/// -----------------------------------------------------------------------

/**
*  Creates a CCEffectRefraction object with the supplied parameters and a nil normal map.
*
*  @param refraction The refraction strength.
*  @param environment The environment image that will be refracted by the affected node.
*
*  @return The CCEffectRefraction object.
*  @since v3.2 and later
*  @see CCSprite
*/
+(id)effectWithRefraction:(float)refraction environment:(CCSprite *)environment;

/**
*  Creates a CCEffectRefraction object with the supplied parameters.
 *
 *  @param refraction The refraction strength.
 *  @param environment The environment image that will be refracted by the affected node.
 *  @param normalMap The normal map of the affected node. This can also be specified as a property of the affected sprite.
 *
 *  @return The CCEffectRefraction object.
 *  @since v3.2 and later
 *  @see CCSprite
 *  @see CCSpriteFrame
 */
+(id)effectWithRefraction:(float)refraction environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap;

/**
 *  Initializes a CCEffectRefraction object with the following default parameters:
 *  refraction = 1.0, environment = nil, normalMap = nil
 *
 *  @return The CCEffectRefraction object.
 *  @since v3.2 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectRefraction object with the supplied parameters and a nil normal map.
 *
 *  @param refraction The refraction strength.
 *  @param environment The environment image that will be refracted by the affected node.
 *
 *  @return The CCEffectRefraction object.
 *  @since v3.2 and later
 *  @see CCSprite
 */
-(id)initWithRefraction:(float)refraction environment:(CCSprite *)environment;

/**
 *  Initializes a CCEffectRefraction object with the supplied parameters.
 *
 *  @param refraction The refraction strength.
 *  @param environment The environment image that will be refracted by the affected node.
 *  @param normalMap The normal map of the affected node. This can also be specified as a property of the affected sprite.
 *
 *  @return The CCEffectRefraction object.
 *  @since v3.2 and later
 *  @see CCSprite
 *  @see CCSpriteFrame
 */
-(id)initWithRefraction:(float)refraction environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap;


/// -----------------------------------------------------------------------
/// @name Refraction
/// -----------------------------------------------------------------------

/** The refraction strength value. This value is in the range [-1..1] with -1
 *  resulting in maximum minification of the refracted image, 0 resulting in no
 *  refraction, and 1 resulting in maximum magnification of the refracted image.
 *  @since v3.2 and later
 */
@property (nonatomic, assign) float refraction;

/// -----------------------------------------------------------------------
/// @name Environment and Normal Map
/// -----------------------------------------------------------------------

/** The environment that will be refracted by the affected node. Typically this is a
 *  sprite that serves as the background for the affected node so it appears that the viewer
 *  is seeing the refracted environment through the refracting node.
 *  @since v3.2 and later
 *  @see CCSprite
 */
@property (nonatomic, strong) CCSprite *environment;

/** The normal map that encodes the normal vectors of the affected node. Each pixel in the normal
 *  map is a 3 component vector that is perpendicular to the surface of the sprite at that point.
 *  @since v3.2 and later
 *  @see CCSpriteFrame
 */
@property (nonatomic, strong) CCSpriteFrame *normalMap;

@end
