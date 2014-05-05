//
//  CCEffectColorPulse.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/14/14.
//
//

#import "CCEffect.h"
#import "CCColor.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectColorPulse : CCEffect

-(id)initWithColor:(CCColor*)fromColor toColor:(CCColor*)toColor;

@end
#endif
