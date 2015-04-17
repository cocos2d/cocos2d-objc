//
//  CCEffectRenderPass.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import "CCEffectRenderPass.h"
#import "CCEffectShader.h"
#import "CCColor.h"

#pragma mark CCEffectRenderPassInputs

@implementation CCEffectRenderPassInputs

-(id)init
{
    return [super init];
}

@end


#pragma mark CCEffectRenderPassBeginBlockContext

@implementation CCEffectRenderPassBeginBlockContext

-(id)initWithBlock:(CCEffectRenderPassBeginBlock)block;
{
    if (self = [super init])
    {
        _block = [block copy];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    CCEffectRenderPassBeginBlockContext *newContext = [[CCEffectRenderPassBeginBlockContext allocWithZone:zone] initWithBlock:_block];
    newContext.uniformTranslationTable = _uniformTranslationTable;
    return newContext;
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
        _shaderIndex = 0;
        
        _texCoord1Mapping = CCEffectTexCoordMapPreviousPassTex;
        _texCoord2Mapping = CCEffectTexCoordMapCustomTex;
        
        _beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){}]];
        
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
    newPass.shaderIndex = _shaderIndex;
    newPass.texCoord1Mapping = _texCoord1Mapping;
    newPass.texCoord2Mapping = _texCoord2Mapping;
    newPass.blendMode = _blendMode;
    newPass.effectShader = _effectShader;
    newPass.beginBlocks = [_beginBlocks copy];
    newPass.updateBlocks = [_updateBlocks copy];
    newPass.debugLabel = _debugLabel;
    return newPass;
}

-(void)begin:(CCEffectRenderPassInputs *)passInputs
{
    for (CCEffectRenderPassBeginBlockContext *blockContext in _beginBlocks)
    {
        passInputs.uniformTranslationTable = blockContext.uniformTranslationTable;
        blockContext.block(self, passInputs);
    }
}

-(void)update:(CCEffectRenderPassInputs *)passInputs
{
    for (CCEffectRenderPassUpdateBlock block in _updateBlocks)
    {
        block(self, passInputs);
    }
}

-(void)enqueueTriangles:(CCEffectRenderPassInputs *)passInputs
{
    CCRenderState *renderState = [CCRenderState renderStateWithBlendMode:_blendMode shader:_effectShader.shader shaderUniforms:passInputs.shaderUniforms copyUniforms:YES];
    
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

