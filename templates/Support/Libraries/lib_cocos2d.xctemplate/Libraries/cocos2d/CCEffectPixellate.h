//
//  CCEffectPixellate.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/8/14.
//
//

#import "CCEffect.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectPixellate : CCEffect

-(id)initWithPixelScale:(float)pixelScale;

@property (nonatomic) float pixelScale;

@end
#endif
