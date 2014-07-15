//
//  CCEffectGlass.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/15/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectGlass : CCEffect

@property (nonatomic) float refraction;
@property (nonatomic) float fresnelBias;
@property (nonatomic) float fresnelPower;
@property (nonatomic) CCSprite *refractionEnvironment;
@property (nonatomic) CCSprite *reflectionEnvironment;
@property (nonatomic) CCSpriteFrame *normalMap;

-(id)init;
-(id)initWithRefraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap;
+(id)effectWithRefraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap;

@end
#endif
