//
//  CCEffectBrightnessAndContrast.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/1/14.
//
//

#import "CCEffect.h"

@interface CCEffectBrightnessAndContrast : CCEffect

-(id)initWithBrightness:(float)brightness contrast:(float)contrast;

@property (nonatomic) float brightness;
@property (nonatomic) float contrast;

@end
