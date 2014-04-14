//
//  CCEffectStack.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"

@interface CCEffectStack : NSObject

+(CCEffect*)effects:(id)firstObject, ...;

@end
