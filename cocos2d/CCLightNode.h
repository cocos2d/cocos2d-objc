//
//  CCLightNode.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/3/14.
//
//

#import "CCNode.h"


typedef NS_ENUM(NSUInteger, CCLightType)
{
    CCLightPoint       = 0,
    CCLightDirectional = 1,
    CCLightSpot        = 2,
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
 *  @param type             The type of the light.
 *  @param color            The primary color of the light.
 *  @param intensity        The brightness of the light's primary color.
 *  @param ambientColor     The ambient color of the light.
 *  @param ambientIntensity The brightness of the light's ambient color.
 *
 *  @return The CCLighttNode object.
 */
-(id)initWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity;


/// -----------------------------------------------------------------------
/// @name Creating a CCLightNode object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCLightNode object with the specified parameters.
 *
 *  @param type             The type of the light.
 *  @param color            The primary color of the light.
 *  @param intensity        The brightness of the light's primary color.
 *  @param ambientColor     The ambient color of the light.
 *  @param ambientIntensity The brightness of the light's ambient color.
 *
 *  @return An initialized CCLightNode object.
 */
+(id)lightWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity;


@end
