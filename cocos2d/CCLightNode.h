//
//  CCLightNode.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/3/14.
//
//

#import "CCNode.h"

#if CC_EFFECTS_EXPERIMENTAL

typedef NS_ENUM(NSUInteger, CCLightType)
{
    CCLightPoint       = 0,
    CCLightDirectional = 1
};


/**
 * CCLightNode allows the user to define lights that will be used with
 * CCEffectLighting.
 */

@interface CCLightNode : CCNode

/// -----------------------------------------------------------------------
/// @name Accessing Node Attributes
/// -----------------------------------------------------------------------

/** The type of the light. The contribution of point lights is dependent on
 *  the relative positions of the light and the node it is lighting. The
 *  contribution of directional lights is only dependent on the light's
 *  orientation (as if it is infinitely far away). Spot lights behave like
 *  point lights but they also have a direction vector and cutoff angle.
 *  If the angle between the light's direction vector and the vector from
 *  the light to the node exceeds the cutoff angle then the light no longer
 *  contributes to the lighting of the node.
 */
@property (nonatomic, assign) CCLightType type;

/** The groups that this light belongs to. Instances of CCEffectLighting also
 *  belong to groups. The intersection of a light effect's groups and a light
 *  node's groups determine whether or not a light node contributes to a light
 *  effect.
 */
@property (nonatomic, copy) NSArray *groups;

/** The primary color of the light. As described below, the color is modulated by the
 *  intensity value to determine the contribution of the light to the lighting
 *  effect. This color is used when computing the light's position and orientation
 *  dependent contribution to the lighting effect.
 */
@property (nonatomic, strong) CCColor* color;

/** The brightness of the light's primary color. This value is in the range [0..1]
 *  with 0 resulting in no contribution from this light in the final image (the light
 *  effectively becomes black) and 1 resulting in full contribution from this
 *  light.
 */
@property (nonatomic, assign) float intensity;

/** The specular color of the light. As described below, the color is modulated by the
 *  specular intensity value to determine the contribution of the light to the lighting
 *  effect. This color is used when computing the light's specular (shiny) contribution
 *  to the lighting effect.
 */
@property (nonatomic, strong) CCColor* specularColor;

/** The brightness of the light's specular color. This value is in the range [0..1]
 *  with 0 resulting in no contribution from the specular color to the final image
 *  (the specular color effectively becomes black) and 1 resulting in full contribution
 *  from this light.
 */
@property (nonatomic, assign) float specularIntensity;

/** The ambient color of the light. As described below, the color is modulated by the
 *  ambient intensity value to determine the contribution of the light to the lighting
 *  effect. The ambient color contributes to the lighting effect independent of the light's
 *  position and orientation relative to the affected node.
 */
@property (nonatomic, strong) CCColor* ambientColor;

/** The brightness of the light's ambient color. This value is in the range [0..1]
 *  with 0 resulting in no contribution from the ambient color to the final image 
 *  (the ambient color effectively becomes black) and 1 resulting in full contribution 
 *  from this light.
 */
@property (nonatomic, assign) float ambientIntensity;

/** The radius of influence of a point light. When the distance from a sprite to this light
 *  is less than or equal to the radius, the sprite will be lit by this light. If the
 *  distance is greater, the sprite will not be lit by this light. This distance is
 *  measured in points. Setting this value to zero disables light cutoff. This propery 
 *  has no effect on directional lights.
 */
@property (nonatomic, assign) float cutoffRadius;

/** The radius at which point the light's intensity has fallen off to half of its maximum
 *  value. The value is specified in normalized units where 0 equals 0 points, and 1 equals
 *  cutoffRadius points. This propery has no effect on directional lights.
 */
@property (nonatomic, assign) float halfRadius;

/** The light's depth value within the scene. This value is independent of the node
 *  z-order which is used for sorting and is instead used by the lighting equations
 *  when computing the light's direction vector relative to the nodes it is lighting.
 *  Only values greater than or equal to 0 are valid. A depth value of 0 makes the light 
 *  coplanar with any nodes it is lighting which results in a very hard looking side light. 
 *  Increasingly positive values move the light farther and farther out of the plane of 
 *  the lit nodes resulting in a softer looking front light.
 */
@property (nonatomic, assign) float depth;



/// -----------------------------------------------------------------------
/// @name Initializing a CCLightNode object
/// -----------------------------------------------------------------------


/**
 *  Initializes a point light with a white color and full intensity.
 *
 *  @return The CCLightNode object.
 */
-(id)init;

/**
 *  Initializes a CCLightNode object with the specified parameters.
 *
 *  @param type              The type of the light.
 *  @param groups            The groups this light belongs to.
 *  @param color             The primary color of the light.
 *  @param intensity         The brightness of the light's primary color.
 *
 *  @return The CCLighttNode object.
 */
-(id)initWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity;

/**
 *  Initializes a CCLightNode object with the specified parameters.
 *
 *  @param type              The type of the light.
 *  @param groups            The groups this light belongs to.
 *  @param color             The primary color of the light.
 *  @param intensity         The brightness of the light's primary color.
 *  @param specularColor     The specular color of the light.
 *  @param specularIntensity The brightness of the light's specular color.
 *  @param ambientColor      The ambient color of the light.
 *  @param ambientIntensity  The brightness of the light's ambient color.
 *
 *  @return The CCLighttNode object.
 */
-(id)initWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity specularColor:(CCColor *)specularColor specularIntensity:(float)specularIntensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity;


/// -----------------------------------------------------------------------
/// @name Creating a CCLightNode object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCLightNode object with the specified parameters.
 *
 *  @param type              The type of the light.
 *  @param groups            The groups this light belongs to.
 *  @param color             The primary color of the light.
 *  @param intensity         The brightness of the light's primary color.
 *
 *  @return An initialized CCLightNode object.
 */
+(id)lightWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity;

/**
 *  Creates a CCLightNode object with the specified parameters.
 *
 *  @param type              The type of the light.
 *  @param groups            The groups this light belongs to.
 *  @param color             The primary color of the light.
 *  @param intensity         The brightness of the light's primary color.
 *  @param specularColor     The specular color of the light.
 *  @param specularIntensity The brightness of the light's specular color.
 *  @param ambientColor      The ambient color of the light.
 *  @param ambientIntensity  The brightness of the light's ambient color.
 *
 *  @return An initialized CCLightNode object.
 */
+(id)lightWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity specularColor:(CCColor *)specularColor specularIntensity:(float)specularIntensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity;


@end

#endif
