//
//  CCLightNode.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/3/14.
//
//

#import "CCNode.h"

/**
 * CCLightNode allows the user to define lights that will be used with
 * CCEffectLighting.
 */

@interface CCLightNode : CCNode

/// -----------------------------------------------------------------------
/// @name Accessing Node Attributes
/// -----------------------------------------------------------------------

/** The color of the light. As described below, the color is modulated by the
 *  intensity value to determine the contribution of the light to the lighting
 *  effect.
 */
@property (nonatomic, strong) CCColor* color;

/** The overall brightness of the light. This value is in the range [0..1] with
 *  0 resulting in no contribution from this light in the final image (the light
 *  effectively becomes black) and 1 resulting in full contribution from this
 *  light (the light's full color contributes).
 */
@property (nonatomic, assign) float intensity;


/// -----------------------------------------------------------------------
/// @name Initializing a CCLightNode object
/// -----------------------------------------------------------------------


/**
 *  Initializes a CCLightNode object with a white color and full intensity.
 *
 *  @return The CCLightNode object.
 */
-(id)init;

/**
 *  Initializes a CCLightNode object with the specified parameters.
 *
 *  @return The CCLighttNode object.
 */
-(id)initWithColor:(CCColor *)color intensity:(float)intensity;


/// -----------------------------------------------------------------------
/// @name Creating a CCLightNode object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCLightNode object with the specified parameters.
 *
 *  @param color     Color of the light.
 *  @param intensity The overall brightness of the light.
 *
 *  @return An initialized CCLightNode object.
 */
+(id)lightWithColor:(CCColor *)color intensity:(float)intensity;


@end
