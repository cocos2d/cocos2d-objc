//
//  CCEffectColorPulse.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/14/14.
//
//

#import "CCEffect_Private.h"
#import "CCRenderer.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectColorPulse

-(id)initWithColor:(CCColor*)fromColor toColor:(CCColor*)toColor
{
    CCEffectUniform* fromColorUniform = [CCEffectUniform uniform:@"vec4" name:@"u_effectColorFrom" value:[NSValue valueWithCCVector4:fromColor.CCVector4]];
    CCEffectUniform* toColorUniform = [CCEffectUniform uniform:@"vec4" name:@"u_effectColorTo" value:[NSValue valueWithCCVector4:toColor.CCVector4]];
    
    if(self = [super initWithUniforms:[NSArray arrayWithObjects:fromColorUniform, toColorUniform, nil] vertextUniforms:nil varying:nil])
    {
        return self;
    }
    
    return self;
}

-(void)buildFragmentFunctions
{
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"colorPulseEffect" body:@"return mix(u_effectColorFrom, u_effectColorTo, cc_SinTime.y);" returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

@end
#endif
