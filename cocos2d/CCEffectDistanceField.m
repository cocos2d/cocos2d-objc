//
//  CCEffectDistanceField.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/8/14.
//
//

#import "CCEffectDistanceField.h"

#if CC_EFFECTS_EXPERIMENTAL

#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"


@interface CCEffectDistanceFieldImpl : CCEffectImpl

@property (nonatomic, weak) CCEffectDistanceField *interface;
@property (nonatomic, assign) float outlineInnerWidth;
@property (nonatomic, assign) float outlineOuterWidth;
@property (nonatomic, assign) float glowWidth;

@end


@implementation CCEffectDistanceFieldImpl

-(id)initWithInterface:(CCEffectDistanceField *)interface
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec4" name:@"u_glowColor" value:[NSValue valueWithGLKVector4:[CCColor blackColor].glkVector4]],
                          [CCEffectUniform uniform:@"vec4" name:@"u_fillColor" value:[NSValue valueWithGLKVector4:[CCColor blackColor].glkVector4]],
                          [CCEffectUniform uniform:@"vec4" name:@"u_outlineColor" value:[NSValue valueWithGLKVector4:[CCColor blackColor].glkVector4]],
                          [CCEffectUniform uniform:@"float" name:@"u_outline" value:[NSNumber numberWithFloat:1.0f]],
                          [CCEffectUniform uniform:@"float" name:@"u_glow" value:[NSNumber numberWithFloat:1.0f]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_glowOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0, 0.0)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_outlineOuterWidth" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.5, 1.0)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_outlineInnerWidth" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.4, 0.42)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_glowWidth" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.3, 0.5)]],
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        _outlineInnerWidth = 0.08f;
        _outlineOuterWidth = 0.08f;
        _glowWidth = 0.4f;
        
        self.interface = interface;
        self.debugName = @"CCEffectDistanceFieldImpl";
    }
    return self;
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectPrefix =
        @"#ifdef GL_ES\n"
        @"#ifdef GL_OES_standard_derivatives\n"
        @"#extension GL_OES_standard_derivatives : enable\n"
        @"#endif\n"
        @"#endif\n";
    
    NSString* effectBody = CC_GLSL(
                                   vec4 outputColor = u_fillColor;
                                   outputColor.a = 1.0;
                                   float distAlphaMask = texture2D(cc_MainTexture, cc_FragTexCoord1).r;
                                   
                                   // 0.5 == center(edge),  < 0.5 == outside, > 0.5 == inside
                                   float min0 = u_outlineOuterWidth.x;
                                   float max0 = u_outlineOuterWidth.y;
                                   float min1 = u_outlineInnerWidth.x;
                                   float max1 = u_outlineInnerWidth.y;
                                   if(u_outline == 1.0 && distAlphaMask >= min0 && distAlphaMask <= max1)//outline
                                   {
                                       float oFactor = 1.0;
                                       if(distAlphaMask <= min1)
                                       {
                                           oFactor = smoothstep(min0, min1, distAlphaMask);
                                       }
                                       else
                                       {
                                           oFactor = smoothstep(max1, max0, distAlphaMask);
                                       }
                                       
                                       outputColor = mix(outputColor, u_outlineColor, oFactor);
                                   }
                                   
                                   float center = 0.5;
                                   float transition = fwidth(distAlphaMask) * 1.0;
                                   
                                   float min = center - transition;
                                   float max = center + transition;

                                   // soft edges
                                   outputColor.a *= smoothstep(min, max, distAlphaMask);
                                   
                                   // glow
                                   if(u_glow == 1.0)
                                   {
                                       vec4 glowTexel = texture2D(cc_MainTexture, cc_FragTexCoord1 - u_glowOffset);
//                                       min -= 0.2;
//                                       max += 0.2;
                                       
                                       min = u_glowWidth.x;
                                       max = u_glowWidth.y;

                                       vec4 glowc = u_glowColor * smoothstep(min, max, glowTexel.r);
                                       
                                       outputColor = mix(glowc, outputColor, outputColor.a);
                                   }
                                   
                                   return outputColor;

                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"outerGlowEffect"
                                                                           body:[effectPrefix stringByAppendingString:effectBody] inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectDistanceFieldImpl *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectDistanceField pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs) {
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowColor"]] = [NSValue valueWithGLKVector4:weakSelf.interface.glowColor.glkVector4];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fillColor"]] = [NSValue valueWithGLKVector4:weakSelf.interface.fillColor.glkVector4];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineColor"]] = [NSValue valueWithGLKVector4:weakSelf.interface.outlineColor.glkVector4];
        
        // 0.5 == center(edge),  < 0.5 == outside, > 0.5 == inside
        float innerMin = 0.5;
        float innerMax = (0.5 * _outlineInnerWidth) + innerMin;
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineInnerWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(innerMin, innerMax)];
        
        float outerMin = (0.5 * (1.0 - _outlineOuterWidth));
        float outerMax = 0.5;
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineOuterWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(outerMin, outerMax)];
        
        float glowWidthMin = (0.5 * (1.0 - _glowWidth));
        float glowWidthMax = 0.5;
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(glowWidthMin, glowWidthMax)];
        
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outline"]] = weakSelf.interface.outline ? [NSNumber numberWithFloat:1.0f] : [NSNumber numberWithFloat:0.0f];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glow"]] = weakSelf.interface.glow ? [NSNumber numberWithFloat:1.0f] : [NSNumber numberWithFloat:0.0f];
        
        GLKVector2 offset = GLKVector2Make(weakSelf.interface.glowOffset.x / passInputs.previousPassTexture.contentSize.width, weakSelf.interface.glowOffset.y / passInputs.previousPassTexture.contentSize.height);
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowOffset"]] = [NSValue valueWithGLKVector2:offset];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setOutlineInnerWidth:(float)outlineInnerWidth
{
    _outlineInnerWidth = clampf(outlineInnerWidth, 0.0f, 1.0f);
}

-(void)setOutlineOuterWidth:(float)outlineOuterWidth
{
    _outlineOuterWidth = clampf(outlineOuterWidth, 0.0f, 1.0f);
}

-(void)setGlowWidth:(float)glowWidth
{
    _glowWidth = clampf(glowWidth, 0.0f, 1.0f);
}

@end


@implementation CCEffectDistanceField

-(id)init
{
    return [self initWithGlowColor:[CCColor blackColor] outlineColor:[CCColor blackColor]];
}

-(id)initWithGlowColor:(CCColor*)glowColor outlineColor:(CCColor*)outlineColor
{
    if((self = [super init]))
    {
        self.effectImpl = [[CCEffectDistanceFieldImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectDistanceField";
      
        _glow = YES;
        _outline = YES;
        _glowOffset = GLKVector2Make(0.0f, 0.0f);
        _glowColor = glowColor;
        _fillColor = [CCColor blackColor];
        _outlineColor = outlineColor;

        self.outlineInnerWidth = 0.08f;
        self.outlineOuterWidth = 0.08f;
        self.glowWidth = 0.4f;
    }
    return self;
}

+(id)effectWithGlowColor:(CCColor*)glowColor outlineColor:(CCColor*)outlineColor
{
    return [[self alloc] initWithGlowColor:glowColor outlineColor:outlineColor];
}

-(void)setOutlineInnerWidth:(float)outlineInnerWidth
{
    _outlineInnerWidth = outlineInnerWidth;
    
    CCEffectDistanceFieldImpl *distanceFieldImpl = (CCEffectDistanceFieldImpl *)self.effectImpl;
    [distanceFieldImpl setOutlineInnerWidth:outlineInnerWidth];
}

-(void)setOutlineOuterWidth:(float)outlineOuterWidth
{
    _outlineOuterWidth = outlineOuterWidth;
    
    CCEffectDistanceFieldImpl *distanceFieldImpl = (CCEffectDistanceFieldImpl *)self.effectImpl;
    [distanceFieldImpl setOutlineOuterWidth:outlineOuterWidth];
}

-(void)setGlowWidth:(float)glowWidth
{
    _glowWidth = glowWidth;
    
    CCEffectDistanceFieldImpl *distanceFieldImpl = (CCEffectDistanceFieldImpl *)self.effectImpl;
    [distanceFieldImpl setGlowWidth:glowWidth];
}

@end

#endif
