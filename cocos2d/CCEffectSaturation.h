//
//  CCEffectSaturation.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/14/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectSaturation : CCEffect

-(id)initWithSaturation:(float)saturation;
+(id)effectWithSaturation:(float)saturation;

@property (nonatomic) float saturation;

@end
#endif
