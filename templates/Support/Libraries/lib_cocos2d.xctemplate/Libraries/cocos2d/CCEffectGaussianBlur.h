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

@property (nonatomic) float blurStrength;
@property (nonatomic) GLKVector2 blurDirection;

-(id)initWithbBurStrength:(float)blurStrength direction:(GLKVector2)direction;
+(id)effectWithBlurStrength:(float)blurStrength direction:(GLKVector2)direction;

@end
#endif



