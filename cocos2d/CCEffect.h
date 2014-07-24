//
//  CCEffect.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"
#import "CCShader.h"
#import "ccConfig.h"
#import "ccTypes.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffect : NSObject

@property (nonatomic, copy) NSString *debugName;

@end
#endif
