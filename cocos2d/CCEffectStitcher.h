//
//  CCEffectStitcher.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/9/15.
//
//

#import <Foundation/Foundation.h>

@class CCEffectRenderPass;
@class CCEffectShader;

@interface CCEffectStitcher : NSObject

@property (nonatomic, readonly) NSArray *renderPasses;
@property (nonatomic, readonly) NSArray *shaders;

- (id)initWithEffects:(NSArray *)effects manglePrefix:(NSString *)prefix mangleExclusions:(NSSet *)exclusions stitchListIndex:(NSUInteger)stitchListIndex shaderStartIndex:(NSUInteger)shaderStartIndex;

@end
