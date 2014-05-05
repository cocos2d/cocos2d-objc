//
//  CCEffectColor.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/11/14.
//
//

#import "CCEffectColor.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectColor

-(id)initWithColor:(CCColor*)color
{

    CCEffectUniform* uniform = [CCEffectUniform uniform:@"vec4" name:@"u_effectColor" value:[NSValue valueWithGLKVector4:color.glkVector4]];
    
    if(self = [super initWithUniforms:[NSArray arrayWithObjects:uniform, nil] vertextUniforms:nil varying:nil])
    {
        return self;
    }
    
    return self;
}

-(void)buildFragmentFunctions
{
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"colorEffect" body:@"return u_effectColor;" returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

@end
#endif