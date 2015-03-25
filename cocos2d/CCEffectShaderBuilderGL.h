//
//  CCEffectShaderBuilderGL.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/23/15.
//
//

#import "CCEffectShaderBuilder.h"

@interface CCEffectShaderBuilderGL : CCEffectShaderBuilder

@property (nonatomic, readonly) NSArray* varyings;

- (id)initWithType:(CCEffectShaderBuilderType)type functions:(NSArray *)functions calls:(NSArray *)calls temporaries:(NSArray *)temporaries uniforms:(NSArray *)uniforms varyings:(NSArray *)varyings;

+ (CCEffectShaderBuilder *)defaultVertexShaderBuilder;

@end
