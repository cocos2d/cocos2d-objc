//
//  CCEffectContrast.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffect.h"

@interface CCEffectContrast : CCEffect

@property (nonatomic) float contrast;

-(id)init;
-(id)initWithContrast:(float)contrast;
+(id)effectWithContrast:(float)contrast;

@end
