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
@property (nonatomic) CCVector2 blurDirection;

-(id)initWithbBurStrength:(float)blurStrength direction:(CCVector2)direction;
+(id)effectWithBlurStrength:(float)blurStrength direction:(CCVector2)direction;

@end
#endif



