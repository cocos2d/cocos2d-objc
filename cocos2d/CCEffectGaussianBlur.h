//
//  CCEffectGaussianBlur.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/12/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectGaussianBlur : CCEffect

// blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
@property (nonatomic) NSUInteger blurRadius;

-(id)init;
/**
 *  @param blurRadius number of pixels blur will extend to (6 is the maximum, because we are limited by the number
 *  of varying variables that can be passed to a glsl program). TODO: create a slower bloom shader, that does not have this restriction.
 */
-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius;
+(id)effectWithPixelBlurRadius:(NSUInteger)blurRadius;

@end
#endif



