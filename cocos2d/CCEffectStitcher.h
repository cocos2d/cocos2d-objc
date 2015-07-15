//
//  CCEffectStitcher.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/9/15.
//
//

#import <Foundation/Foundation.h>

@interface CCEffectStitcher : NSObject

@property (nonatomic, readonly) NSArray *renderPassDescriptors;
@property (nonatomic, readonly) NSArray *shaders;

- (id)init;
+ (instancetype)stitcherWithEffects:(NSArray *)effects manglePrefix:(NSString *)prefix stitchListIndex:(NSUInteger)stitchListIndex shaderStartIndex:(NSUInteger)shaderStartIndex;

@end
