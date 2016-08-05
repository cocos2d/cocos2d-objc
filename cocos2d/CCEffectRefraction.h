//
//  CCEffectRefraction.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 6/19/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectRefraction : CCEffect

@property (nonatomic) float refraction;
@property (nonatomic) CCSprite *environment;
@property (nonatomic) CCTexture *normalMap;

-(id)initWithRefraction:(float)refraction environment:(CCSprite *)environment normalMap:(CCTexture *)normalMap;
+(id)effectWithRefraction:(float)refraction environment:(CCSprite *)environment normalMap:(CCTexture *)normalMap;

@end
#endif
