//
//  CCEffectDropShadow.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/7/14.
//
//

#import "CCEffect.h"

/**
 * CCEffectDropShadow creates a drop shadow.
 *
 */

@interface CCEffectDropShadow : CCEffect

/// -----------------------------------------------------------------------
/// @name Creating a Drop Shadow Effect
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectDropShadow object with the supplied parameters.
 *
 *  @param shadowOffset A value of (5.0, -5.0) will place the drop shadow at the bottom right.
 *  @param shadowColor Color of the shadow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *  @param blurRadius The size of the blur. This value is in the range [0..6] anything higher than 6 pixel blur radius will yeild a performance decrease.
 *
 *  @return The CCEffectDropShadow object.
 *  @since v3.3 and later
 *  @see CCColor
 */
+(instancetype)effectWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor blurRadius:(NSUInteger)blurRadius;

/**
 *  Initializes a CCEffectDropShadow object with a (5, -5) black drop shadow offset .
 *
 *  @return The CCEffectDropShadow object.
 *  @since v3.3 and later
 */
-(id)init;

/**
 *  Initializes a CCEffectDropShadow object with the supplied parameters.
 *
 *  @param shadowOffset A value of (5.0, -5.0) will place the drop shadow at the bottom right.
 *  @param shadowColor Color of the shadow, a [CCColor blackColor] will result in an opaque black drop shadow.
 *  @param blurRadius The size of the blur. This value is in the range [0..6] anything higher than 6 pixel blur radius will yeild a performance decrease.
 *
 *  @return The CCEffectDropShadow object.
 *  @since v3.3 and later
 *  @see CCColor
 */
-(id)initWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor blurRadius:(NSUInteger)blurRadius;


/// -----------------------------------------------------------------------
/// @name Shadow Properties
/// -----------------------------------------------------------------------

/** Adjust which direction the shadow should point. A value of (5.0, -5.0) will
 *  place the drop shadow at the bottom right.
 *  @since v3.3 and later
 */
@property (nonatomic) GLKVector2 shadowOffset __attribute__((deprecated));
@property (nonatomic) CGPoint shadowOffsetWithPoint;

/** Color of the shadow. [CCColor blackColor] will result in an opaque black drop shadow.
 *  @since v3.3 and later
 *  @see CCColor
 */
@property (nonatomic, strong) CCColor* shadowColor;

/** The size of the blur. This value is in the range [0..6] anything higher than 6 pixel blur radius will yeild a performance decrease.
 *  @since v3.3 and later
 */
@property (nonatomic) NSUInteger blurRadius;

@end


