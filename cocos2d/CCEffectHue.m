//
//  CCEffectHue.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/9/14.
//
//

#import "CCEffectHue.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
static float conditionHue(float hue);

@interface CCEffectHue ()

@property (nonatomic) float conditionedHue;

@end


@implementation CCEffectHue

-(id)init
{
    return [self initWithHue:0.0f];
}

-(id)initWithHue:(float)hue
{
    CCEffectUniform* uniformHue = [CCEffectUniform uniform:@"float" name:@"u_hue" value:[NSNumber numberWithFloat:hue]];
    
    if((self = [super initWithFragmentUniforms:@[uniformHue] vertexUniforms:nil varying:nil]))
    {
        _hue = hue;
        _conditionedHue = conditionHue(hue);
        
        self.debugName = @"CCEffectHue";
    }
    return self;
}

+(id)effectWithHue:(float)hue
{
    return [[self alloc] initWithHue:hue];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];

    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" snippet:@"texture2D(cc_PreviousPassTexture, cc_FragTexCoord1)"];

    NSString* effectBody = CC_GLSL(
                                   return inputValue;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"hueEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectHue *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.shader = self.shader;
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        pass.shaderUniforms[self.uniformTranslationTable[@"u_hue"]] = [NSNumber numberWithFloat:weakSelf.conditionedHue];
    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setHue:(float)hue
{
    _hue = hue;
    _conditionedHue = conditionHue(hue);
}

@end

float conditionHue(float hue)
{
    NSCAssert((hue >= -1.0) && (hue <= 1.0), @"Supplied hue out of range [-1..1].");
    return clampf(hue, -1.0f, 1.0f);
}

#endif
