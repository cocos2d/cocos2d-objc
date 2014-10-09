//
//  CCEffectDropShadow.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/7/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectDropShadow create a drop shadow.
 *
 */

@interface CCEffectDropShadow : CCEffect

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** Adjust which direction the shadow should point. A value of (5.0, -5,0) will
 *  place the drop shadow at the bottom right.
 */
@property (nonatomic) GLKVector2 shadowOffset;

/** Color of the shadow,
 * [CCColor blackColor] will result in an opaque black drop shadow.
 */
@property (nonatomic, strong) CCColor* shadowColor;

/** The size of the blur. This value is in the range [0..6] anything higher than 6 pixel blur radius will yeild a performance decrease.
 */
@property (nonatomic) NSUInteger blurRadius;

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectDropShadow object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDropShadow object with a (5, -5) black drop shadow offset .
 *
 *  @return The CCEffectDropShadow object.
 */
-(id)init;

/**
 *  Initializes a CCEffectDropShadow object with the supplied parameters.
 *
 *  @param shadowOffset A value of (5.0, -5,0) will place the drop shadow at the bottom right.
 *  @param shadowColor Color of the shadow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *  @param blurRadius The size of the blur. This value is in the range [0..6] anything higher than 6 pixel blur radius will yeild a performance decrease.
 *
 *  @return The CCEffectDropShadow object.
 */
-(id)initWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor blurRadius:(NSUInteger)blurRadius;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectDropShadow object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDropShadow object with the supplied parameters.
 *
 *  @param shadowOffset A value of (5.0, -5,0) will place the drop shadow at the bottom right.
 *  @param shadowColor Color of the shadow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *  @param blurRadius The size of the blur. This value is in the range [0..6] anything higher than 6 pixel blur radius will yeild a performance decrease.
 *
 *  @return The CCEffectDropShadow object.
 */
+(id)effectWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor blurRadius:(NSUInteger)blurRadius;


@end


