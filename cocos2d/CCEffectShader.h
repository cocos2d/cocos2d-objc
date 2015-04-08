//
//  CCEffectShader.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/9/15.
//
//

#import <Foundation/Foundation.h>

@class CCEffectShaderBuilder;
@class CCShader;

@interface CCEffectShader : NSObject <NSCopying>

@property (nonatomic, readonly) CCEffectShaderBuilder *vertexShaderBuilder;
@property (nonatomic, readonly) CCEffectShaderBuilder *fragmentShaderBuilder;
@property (nonatomic, readonly) CCShader *shader;

- (id)initWithVertexShaderBuilder:(CCEffectShaderBuilder *)vtxBuilder fragmentShaderBuilder:(CCEffectShaderBuilder *)fragBuilder;

@end
