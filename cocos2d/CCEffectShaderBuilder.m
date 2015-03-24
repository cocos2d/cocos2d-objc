//
//  CCEffectShaderBuilder.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/9/15.
//
//

#import "CCEffectShaderBuilder.h"
#import "CCEffectFunction.h"
#import "CCEffectUniform.h"
#import "CCEffectVarying.h"

@implementation CCEffectShaderBuilder

- (id)initWithType:(CCEffectShaderBuilderType)type functions:(NSArray *)functions calls:(NSArray *)calls uniforms:(NSArray *)uniforms
{
    NSAssert(functions, @"");
    NSAssert(calls, @"");
    
    if((self = [super init]))
    {
        _type = type;
        _functions = [functions copy];
        _calls = [calls copy];
        _uniforms = [uniforms copy];
    }
    return self;
}

@end
