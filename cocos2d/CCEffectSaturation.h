//
//  CCEffectSaturation.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/14/14.
//
//

#import "CCEffect.h"

@interface CCEffectSaturation : CCEffect

@property (nonatomic) float saturation;

-(id)init;
-(id)initWithSaturation:(float)saturation;
+(id)effectWithSaturation:(float)saturation;

@end

