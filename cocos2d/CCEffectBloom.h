//
//  CCEffectBloom.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/14/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectBloom : CCEffect

-(id)initWithPixelBlurRadius:(NSUInteger)blurRadius intensity:(float)intensity;
+(id)effectWithPixelBlurRadius:(NSUInteger)blurRadius intensity:(float)intensity;

@end
#endif
