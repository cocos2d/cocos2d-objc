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

-(id)initWithBlock:(CCEffectRenderPassBeginBlock)block uniformTranslationTable:(NSDictionary *)utt
{
    if (self = [super init])
    {
        _block = [block copy];
        _uniformTranslationTable = [utt copy];
    }
    return self;
}

-(id)initWithBlock:(CCEffectRenderPassBeginBlock)block
{
    return [self initWithBlock:block uniformTranslationTable:nil];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    // CCEffectRenderPassBeginBlockContext is immutable so no need to really copy.
    return self;
}

@end


#pragma mark CCEffectRenderPassDescriptor

@implementation CCEffectRenderPassDescriptor

-(id)init
{
    if((self = [super init]))
    {
        _shaderIndex = 0;
        _texCoordsMapping = CCEffectTexCoordsMappingDefault;
        _blendMode = [CCBlendMode premultipliedAlphaMode];
        _beginBlocks = nil;
        _updateBlocks = nil;
        _debugLabel = nil;
    }
    return self;
}

+(instancetype)descriptor
{
    return [[self alloc] init];
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    CCEffectRenderPassDescriptor *newDescriptor = [[CCEffectRenderPassDescriptor alloc] init];
    newDescriptor.shaderIndex = _shaderIndex;
    newDescriptor.texCoordsMapping = _texCoordsMapping;
    newDescriptor.blendMode = _blendMode;
    newDescriptor.beginBlocks = _beginBlocks;
    newDescriptor.updateBlocks = _updateBlocks;
    newDescriptor.debugLabel = _debugLabel;
    return newDescriptor;
}

@end


#pragma mark CCEffectRenderPass

@implementation CCEffectRenderPass

-(id)initWithIndex:(NSUInteger)indexInEffect
  texCoordsMapping:(CCEffectTexCoordsMapping)texCoordsMapping
         blendMode:(CCBlendMode *)blendMode
       shaderIndex:(NSUInteger)shaderIndex
      effectShader:(CCEffectShader *)effectShader
       beginBlocks:(NSArray *)beginBlocks
      updateBlocks:(NSArray *)updateBlocks
        debugLabel:(NSString *)debugLabel
{
    if((self = [super init]))
    {
        _indexInEffect = indexInEffect;
        _texCoordsMapping = texCoordsMapping;
        _blendMode = blendMode;
        _shaderIndex = shaderIndex;
        _effectShader = effectShader;
        _beginBlocks = [beginBlocks copy];
        
        if (updateBlocks)
        {
            _updateBlocks = [updateBlocks copy];
        }
        else
        {
            CCEffectRenderPassUpdateBlock updateBlock = ^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
                if (passInputs.needsClear)
                {
                    [passInputs.renderer enqueueClear:GL_COLOR_BUFFER_BIT color:[CCColor clearColor].glkVector4 depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
                }
                [pass enqueueTriangles:passInputs];
            };
            _updateBlocks = @[[updateBlock copy]];
        }
        
        _debugLabel = [debugLabel copy];
        
        return self;
    }
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    // CCEffectRenderPass is immutable so no need to really copy.
    return self;
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

