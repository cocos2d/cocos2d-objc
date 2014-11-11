//
//  CCEffectColor.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/11/14.
//
//

#import "CCEffect.h"
#import "CCColor.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectColor : CCEffect

-(id)initWithColor:(CCColor*)color;

@end
#endif
