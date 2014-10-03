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
 */
@interface CCEffectLighting : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** The node that will light the affected node.
 */
@property (nonatomic, strong) CCNode *light;


/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectRefraction object
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
 *  @param environment The node that will light the affected node.
 *
 *  @return The CCEffectLighting object.
 */
-(id)initWithLight:(CCNode *)light;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectLighting object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectLighting object with the supplied parameters.
 *
 *  @param environment The node that will light the affected node.
 *
 *  @return The CCEffectLighting object.
 */
+(id)effectWithLight:(CCNode *)light;

@end
