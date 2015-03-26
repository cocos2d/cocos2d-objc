//
//  CCEffectStitcherGL.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/24/15.
//
//

#import "CCEffectStitcher.h"

@interface CCEffectStitcherGL : CCEffectStitcher

- (id)initWithEffects:(NSArray *)effects manglePrefix:(NSString *)prefix stitchListIndex:(NSUInteger)stitchListIndex shaderStartIndex:(NSUInteger)shaderStartIndex;

@end
