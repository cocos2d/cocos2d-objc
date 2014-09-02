//
//  CCEffectRenderer.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/21/14.
//
//

#import "CCEffectRenderer.h"
#import "CCConfiguration.h"
#import "CCDirector.h"
#import "CCEffect.h"
#import "CCEffectStack.h"
#import "CCTexture.h"
#import "ccUtils.h"

#import "CCEffect_Private.h"
#import "CCRenderer_Private.h"
#import "CCSprite_Private.h"
#import "CCTexture_Private.h"


static CCSpriteVertexes padVertices(const CCSpriteVertexes *input, CGSize padding, BOOL padVertices);
static CCVertex padVertex(CCVertex input, GLKVector2 positionOffset, GLKVector2 texCoord1Offset, GLKVector2 texCoord2Offset);

@interface CCEffectRenderTarget : NSObject

@property (nonatomic, readonly) CCTexture *texture;
@property (nonatomic, readonly) GLuint FBO;
@property (nonatomic, readonly) GLuint depthRenderBuffer;
@property (nonatomic, readonly) BOOL glResourcesAllocated;

@end

@implementation CCEffectRenderTarget

- (id)init
{
    if((self = [super init]))
    {
    }
    return self;
}

- (void)dealloc
{
    if (self.glResourcesAllocated)
    {
        [self destroyGLResources];
    }
}

- (BOOL)setupGLResourcesWithSize:(CGSize)size
{
    NSAssert(!_glResourcesAllocated, @"");
    
    glPushGroupMarkerEXT(0, "CCEffectRenderTarget: allocateRenderTarget");
    
	// Textures may need to be a power of two
	NSUInteger powW;
	NSUInteger powH;
    
	if( [[CCConfiguration sharedConfiguration] supportsNPOT] )
    {
		powW = size.width;
		powH = size.height;
	}
    else
    {
		powW = CCNextPOT(size.width);
		powH = CCNextPOT(size.height);
	}
    
    static const CCTexturePixelFormat kRenderTargetDefaultPixelFormat = CCTexturePixelFormat_RGBA8888;
    
    // Create a new texture object for use as the color attachment of the new
    // FBO.
	_texture = [[CCTexture alloc] initWithData:nil pixelFormat:kRenderTargetDefaultPixelFormat pixelsWide:powW pixelsHigh:powH contentSizeInPixels:size contentScale:[CCDirector sharedDirector].contentScaleFactor];
	[_texture setAliasTexParameters];
	
    // Save the old FBO binding so it can be restored after we create the new
    // one.
	GLint oldFBO;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    
	// Generate a new FBO and bind it so it can be modified.
	glGenFramebuffers(1, &_FBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    
	// Associate texture with FBO
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture.name, 0);
    
	// Check if it worked (probably worth doing :) )
	NSAssert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Could not attach texture to framebuffer");
    
    // Restore the old FBO binding.
	glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
	
	CC_CHECK_GL_ERROR_DEBUG();
	glPopGroupMarkerEXT();
    
    _glResourcesAllocated = YES;
    return YES;
}

- (void)destroyGLResources
{
    NSAssert(_glResourcesAllocated, @"");
    glDeleteFramebuffers(1, &_FBO);
    if (_depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &_depthRenderBuffer);
    }
    
    _texture = nil;
    
    _glResourcesAllocated = NO;
}

@end


@interface CCEffectRenderer ()

@property (nonatomic, strong) NSMutableArray *allRenderTargets;
@property (nonatomic, strong) NSMutableArray *freeRenderTargets;
@property (nonatomic, assign) GLKVector4 oldViewport;
@property (nonatomic, assign) GLint oldFBO;

+(CCShader *)sharedCopyShader;

@end


@implementation CCEffectRenderer

+ (CCShader *)sharedCopyShader
{
	static dispatch_once_t once;
	static CCShader *copyShader = nil;
	dispatch_once(&once, ^{
        copyShader = [[CCShader alloc] initWithFragmentShaderSource:@"void main(){gl_FragColor = texture2D(cc_MainTexture, cc_FragTexCoord1);}"];
        copyShader.debugName = @"CCEffectRendererTextureCopyShader";
	});
	return copyShader;
}

-(id)init
{
    if((self = [super init]))
    {
        _allRenderTargets = [[NSMutableArray alloc] init];
        _freeRenderTargets = [[NSMutableArray alloc] init];
        _contentSize = CGSizeMake(1.0f, 1.0f);
        _contentScale = [CCDirector sharedDirector].contentScaleFactor;
    }
    return self;
}

-(void)dealloc
{
    [self destroyAllRenderTargets];
}

-(void)drawSprite:(CCSprite *)sprite withEffect:(CCEffect *)effect uniforms:(NSMutableDictionary *)uniforms renderer:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    NSAssert(effect.readyForRendering, @"Effect not ready for rendering. Call prepareForRendering first.");
    [self freeAllRenderTargets];
    
    if (!effect.renderPassesRequired)
    {
        [sprite enqueueTriangles:renderer transform:transform];
        return;
    }
    
    NSUInteger effectPassCount = effect.renderPassesRequired;
    NSUInteger extraPassCount = 0;
    if (!effect.supportsDirectRendering)
    {
        extraPassCount = 1;
    }
    
    CCEffectRenderTarget *previousPassRT = nil;
    for(NSUInteger i = 0; i < (effectPassCount + extraPassCount); i++)
    {
        BOOL fromIntermediate = (i > 0);
        BOOL toFramebuffer = (i == (effectPassCount + extraPassCount - 1));
        
        CCTexture *previousPassTexture = nil;
        if (previousPassRT)
        {
            NSAssert(previousPassRT.texture, @"Texture for render target unexpectedly nil.");
            previousPassTexture = previousPassRT.texture;
        }
        else
        {
            previousPassTexture = sprite.texture ?: [CCTexture none];
        }
        
        CCEffectRenderPass* renderPass = nil;
        if (i < effectPassCount)
        {
            renderPass = [effect renderPassAtIndex:i];
        }
        else
        {
            renderPass = [[CCEffectRenderPass alloc] init];
            renderPass.debugLabel = @"CCEffectRenderer composite pass";
            renderPass.shader = [CCEffectRenderer sharedCopyShader];
            renderPass.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTex){
                
                pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTex;
                pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTex;
            } copy]];

        }
        renderPass.renderer = renderer;
        renderPass.renderPassId = i;
        
        // The different render sources and destinations and how we need to handle padding.
        // When the source of a render pass is the original sprite, we need to pad both the
        // vertex positions and texture coordinates to make the rendered geometry larger without
        // visibly scaling the sprite image. When the source of a render pass is an intermediate
        // render target, we pad the vertex positions but not the texture coordinates because the
        // render target has already been padded.
        //
        // - First pass directly into FB : Pad vertices and texture coordinates
        // - First pass into intermediate RT : Pad vertices and texture coordinates, add padding to RT, adjust ortho matrix
        // - Later pass into FB : Pad vertices but not texture coordiates
        // - Later pass into intermediate RT : Pad vertices but not texture coordinates, add padding to RT, adjust ortho matrix
        //
        
        renderPass.verts = padVertices(sprite.vertexes, effect.padding, !fromIntermediate);
        renderPass.texCoord1Center = GLKVector2Make((sprite.vertexes->tr.texCoord1.s + sprite.vertexes->bl.texCoord1.s) * 0.5f, (sprite.vertexes->tr.texCoord1.t + sprite.vertexes->bl.texCoord1.t) * 0.5f);
        renderPass.texCoord1Extents = GLKVector2Make((sprite.vertexes->tr.texCoord1.s - sprite.vertexes->bl.texCoord1.s) * 0.5f, (sprite.vertexes->tr.texCoord1.t - sprite.vertexes->bl.texCoord1.t) * 0.5f);
        renderPass.texCoord2Center = GLKVector2Make((sprite.vertexes->tr.texCoord2.s + sprite.vertexes->bl.texCoord2.s) * 0.5f, (sprite.vertexes->tr.texCoord2.t + sprite.vertexes->bl.texCoord2.t) * 0.5f);
        renderPass.texCoord2Extents = GLKVector2Make((sprite.vertexes->tr.texCoord2.s - sprite.vertexes->bl.texCoord2.s) * 0.5f, (sprite.vertexes->tr.texCoord2.t - sprite.vertexes->bl.texCoord2.t) * 0.5f);

        renderPass.blendMode = [CCBlendMode premultipliedAlphaMode];
        renderPass.needsClear = !toFramebuffer;
        renderPass.shaderUniforms = uniforms;
        
        CCEffectRenderTarget *rt = nil;
        
        [renderer pushGroup];
        if (toFramebuffer)
        {
            renderPass.transform = *transform;

            GLKMatrix4 ndcToWorldMat;
            [renderer.globalShaderUniforms[CCShaderUniformProjectionInv] getValue:&ndcToWorldMat];
            renderPass.ndcToWorld = ndcToWorldMat;
            
            [renderPass begin:previousPassTexture];
            [renderPass update];
            [renderPass end];
        }
        else
        {
            bool inverted;
            
            GLKMatrix4 renderTargetProjection = GLKMatrix4MakeOrtho(-effect.padding.width, _contentSize.width + effect.padding.width, -effect.padding.height, _contentSize.height + effect.padding.height, -1024.0f, 1024.0f);
            GLKMatrix4 invRenderTargetProjection = GLKMatrix4Invert(renderTargetProjection, &inverted);
            NSAssert(inverted, @"Unable to invert matrix.");
            
            GLKMatrix4 invGlobalProjection;
            [renderer.globalShaderUniforms[CCShaderUniformProjectionInv] getValue:&invGlobalProjection];
            
            GLKMatrix4 ndcToNodeMat = invRenderTargetProjection;
            GLKMatrix4 nodeToWorldMat = GLKMatrix4Multiply(invGlobalProjection, *transform);
            GLKMatrix4 ndcToWorldMat = GLKMatrix4Multiply(nodeToWorldMat, ndcToNodeMat);

            renderPass.transform = renderTargetProjection;
            renderPass.ndcToWorld = ndcToWorldMat;
            
            CGSize rtSize = CGSizeMake((_contentSize.width + 2 * effect.padding.width) * _contentScale, (_contentSize.height + 2 * effect.padding.height) * _contentScale);
            rtSize.width = (rtSize.width <= 1.0f) ? 1.0f : rtSize.width;
            rtSize.height = (rtSize.height <= 1.0f) ? 1.0f : rtSize.height;
            
            rt = [self renderTargetWithSize:rtSize];
            
            [renderPass begin:previousPassTexture];
            [self bindRenderTarget:rt withRenderer:renderer];
            [renderPass update];
            [self restoreRenderTargetWithRenderer:renderer];
            [renderPass end];
        }
        [renderer popGroupWithDebugLabel:renderPass.debugLabel globalSortOrder:0];
        
        previousPassRT = rt;
    }
}

- (void)bindRenderTarget:(CCEffectRenderTarget *)rt withRenderer:(CCRenderer *)renderer
{
    CGSize pixelSize = rt.texture.contentSizeInPixels;
    GLuint fbo = rt.FBO;
    
    [renderer enqueueBlock:^{
        glGetFloatv(GL_VIEWPORT, _oldViewport.v);
        glViewport(0, 0, pixelSize.width, pixelSize.height );
        
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        
    } globalSortOrder:NSIntegerMin debugLabel:@"CCEffectRenderer: Bind FBO" threadSafe:NO];
}

- (void)restoreRenderTargetWithRenderer:(CCRenderer *)renderer
{
    [renderer enqueueBlock:^{
        glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
        glViewport(_oldViewport.v[0], _oldViewport.v[1], _oldViewport.v[2], _oldViewport.v[3]);
    } globalSortOrder:NSIntegerMax debugLabel:@"CCEffectRenderer: Restore FBO" threadSafe:NO];
    
}

- (CCEffectRenderTarget *)renderTargetWithSize:(CGSize)size
{
    NSAssert((size.width > 0.0f) && (size.height > 0.0f), @"Render targets must have non-zero dimensions.");

    // If there is a free render target available for use, return that one. If
    // not, create a new one and return that.
    CCEffectRenderTarget *rt = nil;
    if (_freeRenderTargets.count)
    {
        rt = [_freeRenderTargets lastObject];
        [_freeRenderTargets removeLastObject];
    }
    else
    {
        rt = [[CCEffectRenderTarget alloc] init];
        [rt setupGLResourcesWithSize:size];
        [_allRenderTargets addObject:rt];
    }
    return rt;
}

- (void)destroyAllRenderTargets
{
    // Destroy all allocated render target objects and the associated GL resources.
    for (CCEffectRenderTarget *rt in _allRenderTargets)
    {
        [rt destroyGLResources];
    }
    [_allRenderTargets removeAllObjects];
    [_freeRenderTargets removeAllObjects];
}

- (void)freeRenderTarget:(CCEffectRenderTarget *)rt
{
    // Put the supplied render target back into the free list. If it's already there
    // them somebody is doing something wrong.
    NSAssert(![_freeRenderTargets containsObject:rt], @"Double freeing a render target!");
    [_freeRenderTargets addObject:rt];
}

- (void)freeAllRenderTargets
{
    // Reset the free render target list to contain all allocated render targets.
    [_freeRenderTargets removeAllObjects];
    [_freeRenderTargets addObjectsFromArray:_allRenderTargets];
}

@end

CCSpriteVertexes padVertices(const CCSpriteVertexes *input, CGSize padding, BOOL padTexCoords)
{
    CCSpriteVertexes output;
    if (CGSizeEqualToSize(CGSizeZero, padding))
    {
        output = *input;
    }
    else
    {
        GLKVector2 texCoord1Step = GLKVector2Make(0.0f, 0.0f);
        GLKVector2 texCoord2Step = GLKVector2Make(0.0f, 0.0f);
        if (padTexCoords)
        {
            texCoord1Step = GLKVector2Make(padding.width * (input->br.texCoord1.s - input->bl.texCoord1.s) / (input->br.position.x - input->bl.position.x),
                                           padding.height * (input->tl.texCoord1.t - input->bl.texCoord1.t) / (input->tl.position.y - input->bl.position.y));
            texCoord2Step = GLKVector2Make(padding.width * (input->br.texCoord2.s - input->bl.texCoord2.s) / (input->br.position.x - input->bl.position.x),
                                           padding.height * (input->tl.texCoord2.t - input->bl.texCoord2.t) / (input->tl.position.y - input->bl.position.y));
        }
        
        output.bl = padVertex(input->bl, GLKVector2Make(-padding.width, -padding.height), GLKVector2Make(-texCoord1Step.x, -texCoord1Step.y), GLKVector2Make(-texCoord2Step.x, -texCoord2Step.y));
        output.br = padVertex(input->br, GLKVector2Make( padding.width, -padding.height), GLKVector2Make( texCoord1Step.x, -texCoord1Step.y), GLKVector2Make( texCoord2Step.x, -texCoord2Step.y));
        output.tr = padVertex(input->tr, GLKVector2Make( padding.width,  padding.height), GLKVector2Make( texCoord1Step.x,  texCoord1Step.y), GLKVector2Make( texCoord2Step.x,  texCoord2Step.y));
        output.tl = padVertex(input->tl, GLKVector2Make(-padding.width,  padding.height), GLKVector2Make(-texCoord1Step.x,  texCoord1Step.y), GLKVector2Make(-texCoord2Step.x,  texCoord2Step.y));
    }
    return output;
}

CCVertex padVertex(CCVertex input, GLKVector2 positionOffset, GLKVector2 texCoord1Offset, GLKVector2 texCoord2Offset)
{
    CCVertex output;
    output.position.x = input.position.x + positionOffset.x;
    output.position.y = input.position.y + positionOffset.y;
    output.position.z = input.position.z;
    output.position.w = input.position.w;
    output.texCoord1.s = input.texCoord1.s + texCoord1Offset.x;
    output.texCoord1.t = input.texCoord1.t + texCoord1Offset.y;
    output.texCoord2.s = input.texCoord2.s + texCoord2Offset.x;
    output.texCoord2.t = input.texCoord2.t + texCoord2Offset.y;
    output.color = input.color;
    
    return output;
}

