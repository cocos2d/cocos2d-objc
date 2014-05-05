//
//  CCEffectBrightnessAndContrast.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/1/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectBrightnessAndContrast : CCEffect

-(id)initWithBrightness:(float)brightness contrast:(float)contrast;

@property (nonatomic) float brightness;
@property (nonatomic) float contrast;

@end
#endif
