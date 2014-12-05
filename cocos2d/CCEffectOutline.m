//
//  CCEffectOutline.m
//  cocos2d
//
//  Created by Oleg Osin on 12/3/14.
//
//

#import "CCEffectOutline.h"
#import "CCEffect_Private.h"
#import "CCSprite_Private.h"
#import "CCTexture.h"
#import "CCSpriteFrame.h"

@implementation CCEffectOutline

-(id)init
{
    return [self initWithOutlineColor:[CCColor redColor] outlineWidth:2];
}

-(id)initWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec4" name:@"u_outlineColor" value:[NSValue valueWithGLKVector4:outlineColor.glkVector4]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_stepSize" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.01, 0.01)]],
                          [CCEffectUniform uniform:@"float" name:@"u_currentPass" value:[NSNumber numberWithFloat:0.0]]
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        self.outlineWidth = outlineWidth;
        _outlineColor = outlineColor;
        
        self.debugName = @"CCEffectOutline";
    }
    return self;
}

+(id)effectWithOutlineColor:(CCColor*)outlineColor outlineWidth:(int)outlineWidth
{
    return [[self alloc] initWithOutlineColor:outlineColor outlineWidth:outlineWidth];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   
                                   if(u_currentPass == 1.0)
                                   {
                                       vec4 prev = texture2D(cc_PreviousPassTexture, cc_FragTexCoord2);
                                       vec4 orig = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                       vec4 col = mix(orig, prev, prev.a);
                                       return col;
                                   }
                                   
                                   // Use Laplacian matrix / filter to find the edges
                                   // Apply this kernel to each pixel
                                   /*
                                    0 -1  0
                                   -1  4 -1
                                    0 -1  0
                                    */
                                   
                                   float alpha = 4.0 * texture2D(cc_MainTexture, cc_FragTexCoord1).a;
                                   alpha -= texture2D(cc_MainTexture, cc_FragTexCoord1 + vec2(u_stepSize.x, 0.0)).a;
                                   alpha -= texture2D(cc_MainTexture, cc_FragTexCoord1 + vec2(-u_stepSize.x, 0.0)).a;
                                   alpha -= texture2D(cc_MainTexture, cc_FragTexCoord1 + vec2(0.0, u_stepSize.y)).a;
                                   alpha -= texture2D(cc_MainTexture, cc_FragTexCoord1 + vec2(0.0, -u_stepSize.y)).a;
                                   
                                   // do everthing in 1 pass
                                   vec4 col = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   col = mix(col, u_outlineColor, alpha);
                                   
                                   // extract the outline (used for multi pass)
                                   //vec4 col = vec4(texture2D(cc_MainTexture, cc_FragTexCoord1).a / 1.0, 0.0, 0.0, alpha);
                                   
                                   return col;
                                   
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"outlineEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildVertexFunctions
{
    self.vertexFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   
                                   
                                   return cc_Position;
                                   
                                   );
    
    CCEffectFunction* vertexFunction = [[CCEffectFunction alloc] initWithName:@"outlineEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.vertexFunctions addObject:vertexFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectOutline *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectOutline pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs) {
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineColor"]] = [NSValue valueWithGLKVector4:weakSelf.outlineColor.glkVector4];
        
        GLKVector2 stepSize = GLKVector2Make(_outlineWidth / passInputs.previousPassTexture.contentSize.width,
                                             _outlineWidth / passInputs.previousPassTexture.contentSize.height);
        
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_stepSize"]] = [NSValue valueWithGLKVector2:stepSize];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_currentPass"]] = [NSNumber numberWithFloat:0.0f];
        
    } copy]];
    
    
    // Pass 1 is a WIP (trying to scale the outline before applying it. (a bad idea so far..)
#if 0
    CCEffectRenderPass *pass1 = [[CCEffectRenderPass alloc] init];
    pass1.debugLabel = @"CCEffectOutline pass 1";
    pass1.shader = self.shader;
    pass1.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass1.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs) {
        
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineColor"]] = [NSValue valueWithGLKVector4:weakSelf.outlineColor.glkVector4];

        GLKVector2 stepSize = GLKVector2Make(_outlineWidth / passInputs.previousPassTexture.contentSize.width,
                                             _outlineWidth / passInputs.previousPassTexture.contentSize.height);
        
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_stepSize"]] = [NSValue valueWithGLKVector2:stepSize];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_currentPass"]] = [NSNumber numberWithFloat:1.0f];
        
        
        float aspect = passInputs.previousPassTexture.contentSize.width / passInputs.previousPassTexture.contentSize.height;
        float w = _outlineWidth * (4.0 * aspect); // no idea why I need to do this..
        float w2 = w / 2;
        CGRect rect = CGRectMake(w2, w2 * aspect,
                                 passInputs.previousPassTexture.contentSize.width-(w),
                                 passInputs.previousPassTexture.contentSize.height-(w*aspect));
        
        CCSpriteTexCoordSet texCoords = [CCSprite textureCoordsForTexture:passInputs.previousPassTexture
                                                                 withRect:rect rotated:NO xFlipped:NO yFlipped:NO];
        CCSpriteVertexes verts = pass.verts;
        verts.bl.texCoord2 = texCoords.bl;
        verts.br.texCoord2 = texCoords.br;
        verts.tr.texCoord2 = texCoords.tr;
        verts.tl.texCoord2 = texCoords.tl;
        pass.verts = verts;

    } copy]];
#endif
    
    self.renderPasses = @[pass0];
}

@end
