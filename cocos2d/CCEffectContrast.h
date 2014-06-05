//
//  CCEffectContrast.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectContrast : CCEffect

-(id)initWithContrast:(float)contrast;
+(id)effectWithContrast:(float)contrast;

@property (nonatomic) float contrast;

@end
#endif
