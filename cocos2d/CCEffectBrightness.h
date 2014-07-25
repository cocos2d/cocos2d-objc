//
//  CCEffectBrightness.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffect.h"

@interface CCEffectBrightness : CCEffect

@property (nonatomic) float brightness;

-(id)init;
-(id)initWithBrightness:(float)brightness;
+(id)effectWithBrightness:(float)brightness;

@end
