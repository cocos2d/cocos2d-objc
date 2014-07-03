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

@property (nonatomic) GLKVector2 blurDirection;

-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius;
+(id)effectWithPixelBlurRadius:(NSUInteger)blurRadius;

@end
#endif



