//
//  CCEffectRenderPass.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import "CCEffectRenderPass.h"
#import "CCColor.h"

#pragma mark CCEffectRenderPassInputs

@implementation CCEffectRenderPassInputs

-(id)init
{
    return [super init];
}

@end


#pragma mark CCEffectRenderPass

@implementation CCEffectRenderPass

-(id)init
{
    return [self initWithIndex:0];
}

-(id)initWithIndex:(NSUInteger)indexInEffect
{
    if((self = [super init]))
    {
        _indexInEffect = indexInEffect;
        
        _texCoord1Mapping = CCEffectTexCoordMapPreviousPassTex;
        _texCoord2Mapping = CCEffectTexCoordMapCustomTex;
        
        _beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){} copy]];
        _endBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){} copy]];
        
        CCEffectRenderPassUpdateBlock updateBlock = ^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
            if (passInputs.needsClear)
            {
                [passInputs.renderer enqueueClear:GL_COLOR_BUFFER_BIT color:[CCColor clearColor].glkVector4 depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
            }
            [pass enqueueTriangles:passInputs];
        };
        _updateBlocks = @[[updateBlock copy]];
        _blendMode = [CCBlendMode premultipliedAlphaMode];
        
        return self;
    }
    
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    CCEffectRenderPass *newPass = [[CCEffectRenderPass allocWithZone:zone] initWithIndex:_indexInEffect];
    newPass.texCoord1Mapping = _texCoord1Mapping;
    newPass.texCoord2Mapping = _texCoord2Mapping;
    newPass.blendMode = _blendMode;
    newPass.shader = _shader;
    newPass.beginBlocks = _beginBlocks;
    newPass.updateBlocks = _updateBlocks;
    newPass.endBlocks = _endBlocks;
    newPass.debugLabel = _debugLabel;
    return newPass;
}

-(void)begin:(CCEffectRenderPassInputs *)passInputs
{
    for (CCEffectRenderPassBeginBlock block in _beginBlocks)
    {
        block(self, passInputs);
    }
}

-(void)update:(CCEffectRenderPassInputs *)passInputs
{
    for (CCEffectRenderPassUpdateBlock block in _updateBlocks)
    {
        block(self, passInputs);
    }
}

-(void)end:(CCEffectRenderPassInputs *)passInputs
{
    for (CCEffectRenderPassUpdateBlock block in _endBlocks)
    {
        block(self, passInputs);
    }
}

-(void)enqueueTriangles:(CCEffectRenderPassInputs *)passInputs
{
    CCRenderState *renderState = [CCRenderState renderStateWithBlendMode:_blendMode shader:_shader shaderUniforms:passInputs.shaderUniforms copyUniforms:YES];
    
    GLKMatrix4 transform = passInputs.transform;
    CCRenderBuffer buffer = [passInputs.renderer enqueueTriangles:2 andVertexes:4 withState:renderState globalSortOrder:0];
    
    CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(passInputs.verts.bl, &transform));
    CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(passInputs.verts.br, &transform));
    CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(passInputs.verts.tr, &transform));
    CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(passInputs.verts.tl, &transform));
    
    CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

@end

