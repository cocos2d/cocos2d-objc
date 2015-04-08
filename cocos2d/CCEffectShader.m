//
//  CCEffectShader.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/9/15.
//
//

#import "CCEffectShader.h"
#import "CCEffectShaderBuilder.h"
#import "CCShader.h"


@interface CCEffectShader ()
@property (nonatomic, assign) BOOL compileAttempted;
@end


@implementation CCEffectShader

@synthesize shader = _shader;

- (id)initWithVertexShaderBuilder:(CCEffectShaderBuilder *)vtxBuilder fragmentShaderBuilder:(CCEffectShaderBuilder *)fragBuilder
{
    NSAssert(vtxBuilder, @"");
    NSAssert(fragBuilder, @"");
    
    if((self = [super init]))
    {
        _vertexShaderBuilder = vtxBuilder;
        _fragmentShaderBuilder = fragBuilder;
        _shader = nil;
        _compileAttempted = NO;
        
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    // CCEffectShader is immutable so no need to really copy.
    return self;
}

- (CCShader *)shader
{
    // Only compile the shader on-demand and only do so once. If compilation
    // fails, we just return nil and that's okay.
    if (!self.compileAttempted)
    {
        _shader = [[CCShader alloc] initWithVertexShaderSource:_vertexShaderBuilder.shaderSource fragmentShaderSource:_fragmentShaderBuilder.shaderSource];
        self.compileAttempted = YES;
    }
    return _shader;
}

@end
