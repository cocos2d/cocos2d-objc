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
#import "CCSprite.h"
#import "CCTexture.h"
#import "CCEffect.h"
#import "CCEffectTexture.h"
#import "CCEffectStack.h"
#import "CCEffectColor.h"
#import "CCEffectColorPulse.h"

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif // iPHone


@interface CCEffectNode : CCNode

/** The CCSprite being used.
 The sprite, by default, will use the following blending function: GL_ONE, GL_ONE_MINUS_SRC_ALPHA.
 The blending function can be changed in runtime by calling:
 - [[renderTexture sprite] setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
 */
@property (nonatomic,readwrite, strong) CCSprite* sprite;
@property (nonatomic, readwrite) float contentScale;
@property (nonatomic, readonly) CCTexture *texture;
@property (nonatomic, readwrite) GLKMatrix4 projection;
@property (nonatomic, strong) CCColor* clearColor;
@property (nonatomic) CCEffect* effect;

-(id)initWithWidth:(int)w height:(int)h;

@end
