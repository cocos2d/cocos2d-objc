//
//  CCEffectReflection.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/14/14.
//
//

#import "CCEffect.h"

@interface CCEffectReflection : CCEffect

@property (nonatomic) CCSprite *environment;
@property (nonatomic) CCSpriteFrame *normalMap;
@property (nonatomic) float fresnelBias;
@property (nonatomic) float fresnelPower;

-(id)init;
-(id)initWithEnvironment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap;
-(id)initWithFresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap;

+(id)effectWithEnvironment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap;
+(id)effectWithFresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap;

@end
