//
//  CCEffectNode.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/26/14.
//
//

#import <Foundation/Foundation.h>

#import "ccMacros.h"
#import "CCNode.h"
#import "CCRenderTexture.h"
#import "CCSprite.h"
#import "CCTexture.h"
#import "CCEffect.h"
#import "CCEffectStack.h"
#import "CCEffectBloom.h"
#import "CCEffectBrightness.h"
#import "CCEffectContrast.h"
#import "CCEffectPixellate.h"
#import "CCEffectSaturation.h"
#import "CCEffectRefraction.h"


#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif // iPHone

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectNode : CCRenderTexture <CCEffectProtocol>

-(id)initWithWidth:(int)w height:(int)h;

@end
#endif
