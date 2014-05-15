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

-(id)initWithPixelSize:(float)pixelSize;

@property (nonatomic) float pixelSize;

@end
#endif
