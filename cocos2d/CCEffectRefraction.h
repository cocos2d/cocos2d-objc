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

-(id)initWithRefraction:(float)refraction environmentMap:(CCTexture *)envMap normalMap:(CCTexture *)normalMap;
+(id)effectWithRefraction:(float)refraction environmentMap:(CCTexture *)envMap normalMap:(CCTexture *)normalMap;

@property (nonatomic) float refraction;
@property (nonatomic) CCTexture *envMap;
@property (nonatomic) CCTexture *normalMap;

@end
#endif
