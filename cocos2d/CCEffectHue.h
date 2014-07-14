//
//  CCEffectHue.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/9/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectHue : CCEffect

@property (nonatomic) float hue;

-(id)init;
-(id)initWithHue:(float)hue;
+(id)effectWithHue:(float)hue;

@end
#endif
