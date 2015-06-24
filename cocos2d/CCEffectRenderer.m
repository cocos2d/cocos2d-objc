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
#import "CCEffectUtils.h"
#import "CCTexture.h"

#import "CCEffect_Private.h"
#import "CCRenderer_Private.h"
#import "CCSprite_Private.h"
#import "CCTexture_Private.h"


typedef NS_ENUM(NSUInteger, CCEffectTexCoordSource)
{
    CCEffectTexCoordSource1  = 0,
    CCEffectTexCoordSource2  = 1,
    CCEffectTexCoordConstant = 2
};

typedef NS_ENUM(NSUInteger, CCEffectTexCoordTransform)
{
    CCEffectTexCoordTransformNone      = 0,
    CCEffectTexCoordTransformPad       = 1
};

typedef struct _CCEffectTexCoordFunc
{
    CCEffectTexCoordSource source;
    CCEffectTexCoordTransform transform;
    
} CCEffectTexCoordFunc;

static const CCEffectTexCoordFunc CCEffectTexCoordOverwrite      = { CCEffectTexCoordConstant, CCEffectTexCoordTransformNone };
static const CCEffectTexCoordFunc CCEffectTexCoord1Padded        = { CCEffectTexCoordSource1,  CCEffectTexCoordTransformPad };


static CCEffectTexCoordFunc selectTexCoordFunc(CCEffectTexCoordMapping mapping, CCEffectTexCoordSource source, BOOL fromIntermediate, BOOL padMainTexCoords);
static CCSpriteVertexes padVertices(const CCSpriteVertexes *input, CGSize padding, CCEffectTexCoordFunc tc1, CCEffectTexCoordFunc tc2);
static GLKVector4 padVertexPosition(GLKVector4 input, GLKVector2 positionOffset);
static GLKVector2 transformTexCoords(CCEffectTexCoordTransform tcTransform, GLKVector2 padding, GLKVector2 input);
static GLKVector2 selectTexCoordSource(CCEffectTexCoordSource tcSource, GLKVector2 tc1, GLKVector2 tc2, GLKVector2 tcConst);
static GLKVector2 selectTexCoordPadding(CCEffectTexCoordSource tcSource, GLKVector2 tc1Padding, GLKVector2 tc2Padding);


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
    
    CCGL_DEBUG_PUSH_GROUP_MARKER("CCEffectRenderTarget: allocateRenderTarget");
    
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
	_texture.antialiased = NO;
	
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
	CCGL_DEBUG_POP_GROUP_MARKER();
    
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
    [self freeAllRenderTargets];
    
    if (!effect.renderPassCount)
    {
        [sprite enqueueTriangles:renderer transform:transform];
        return;
    }
    
    NSUInteger effectPassCount = effect.renderPassCount;
    NSUInteger extraPassCount = 0;
    if (!effect.supportsDirectRendering)
    {
        extraPassCount = 1;
    }
    
    CCEffectRenderPassInputs *renderPassInputs = [[CCEffectRenderPassInputs alloc] init];
    renderPassInputs.renderer = renderer;
    renderPassInputs.sprite = sprite;

    BOOL padMainTexCoords = YES;
    CCEffectRenderTarget *previousPassRT = nil;
    for(NSUInteger i = 0; i < (effectPassCount + extraPassCount); i++)
    {
        renderPassInputs.renderPassId = i;
        
        BOOL fromIntermediate = (i > 0);
        BOOL toFramebuffer = (i == (effectPassCount + extraPassCount - 1));
        
        if (previousPassRT)
        {
            NSAssert(previousPassRT.texture, @"Texture for render target unexpectedly nil.");
            renderPassInputs.previousPassTexture = previousPassRT.texture;
        }
        else
        {
            renderPassInputs.previousPassTexture = sprite.texture ?: [CCTexture none];
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
            renderPass.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
                
                passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
                passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
            }]];
        }
        
        if (fromIntermediate && (renderPass.indexInEffect == 0))
        {
            padMainTexCoords = NO;
        }
        
        // The different render sources and destinations and how we need to handle padding.
        // When the source of a render pass is the original sprite, we need to pad both the
        // vertex positions and texture coordinates to make the rendered geometry larger without
        // visibly scaling the sprite image. When the source of a render pass is an intermediate
        // render target, we pad the vertex positions but not the texture coordinates because the
        // render target has already been padded.
        //
        // - First pass directly into FB : Pad vertices and texture coordinates
        // - First pass into intermediate RT : Pad vertices and texture coordinates, add padding to RT, adjust ortho matrix
        // - Later pass into FB : Pad vertices, overwrite texture coordiates so they are lower-left (0,0) upper right (1, 1)
        // - Later pass into intermediate RT : Pad vertices, overwrite texture coordiates so they are lower-left (0,0) upper right (1, 1), add padding to RT, adjust ortho matrix
        //
        
        CCEffectTexCoordFunc tc1 = selectTexCoordFunc(renderPass.texCoord1Mapping, CCEffectTexCoordSource1, fromIntermediate, padMainTexCoords);
        CCEffectTexCoordFunc tc2 = selectTexCoordFunc(renderPass.texCoord2Mapping, CCEffectTexCoordSource2, fromIntermediate, padMainTexCoords);
        
        CCSpriteVertexes paddedVerts = padVertices(sprite.vertexes, effect.padding, tc1, tc2);
        [renderPassInputs setVertsWorkAround:&paddedVerts];
        
        renderPassInputs.texCoord1Center = GLKVector2Make((sprite.vertexes->tr.texCoord1.s + sprite.vertexes->bl.texCoord1.s) * 0.5f, (sprite.vertexes->tr.texCoord1.t + sprite.vertexes->bl.texCoord1.t) * 0.5f);
        renderPassInputs.texCoord1Extents = GLKVector2Make(fabsf(sprite.vertexes->tr.texCoord1.s - sprite.vertexes->bl.texCoord1.s) * 0.5f, fabsf(sprite.vertexes->tr.texCoord1.t - sprite.vertexes->bl.texCoord1.t) * 0.5f);
        renderPassInputs.texCoord2Center = GLKVector2Make((sprite.vertexes->tr.texCoord2.s + sprite.vertexes->bl.texCoord2.s) * 0.5f, (sprite.vertexes->tr.texCoord2.t + sprite.vertexes->bl.texCoord2.t) * 0.5f);
        renderPassInputs.texCoord2Extents = GLKVector2Make(fabsf(sprite.vertexes->tr.texCoord2.s - sprite.vertexes->bl.texCoord2.s) * 0.5f, fabsf(sprite.vertexes->tr.texCoord2.t - sprite.vertexes->bl.texCoord2.t) * 0.5f);

        renderPassInputs.needsClear = !toFramebuffer;
        renderPassInputs.shaderUniforms = uniforms;
        
        CCEffectRenderTarget *rt = nil;
        
        [renderer pushGroup];
        if (toFramebuffer)
        {
            renderPassInputs.transform = *transform;
            renderPassInputs.ndcToNodeLocal = GLKMatrix4Invert(*transform, nil);
            
            [renderPass begin:renderPassInputs];
            [renderPass update:renderPassInputs];
        }
        else
        {
            bool inverted;
            
            GLKMatrix4 renderTargetProjection = GLKMatrix4MakeOrtho(-effect.padding.width, _contentSize.width + effect.padding.width, -effect.padding.height, _contentSize.height + effect.padding.height, -1024.0f, 1024.0f);
            GLKMatrix4 invRenderTargetProjection = GLKMatrix4Invert(renderTargetProjection, &inverted);
            NSAssert(inverted, @"Unable to invert matrix.");
            
            renderPassInputs.transform = renderTargetProjection;
            renderPassInputs.ndcToNodeLocal = invRenderTargetProjection;
            
            CGSize rtSize = CGSizeMake((_contentSize.width + 2 * effect.padding.width) * _contentScale, (_contentSize.height + 2 * effect.padding.height) * _contentScale);
            rtSize.width = (rtSize.width <= 1.0f) ? 1.0f : rtSize.width;
            rtSize.height = (rtSize.height <= 1.0f) ? 1.0f : rtSize.height;
            
            rt = [self renderTargetWithSize:rtSize];
            
            [renderPass begin:renderPassInputs];
            [self bindRenderTarget:rt withRenderer:renderer];
            [renderPass update:renderPassInputs];
            [self restoreRenderTargetWithRenderer:renderer];
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


CCEffectTexCoordFunc selectTexCoordFunc(CCEffectTexCoordMapping mapping, CCEffectTexCoordSource source, BOOL fromIntermediate, BOOL padMainTexCoords)
{
    CCEffectTexCoordFunc func;
    if (mapping == CCEffectTexCoordMapMainTex)
    {
        if (padMainTexCoords)
        {
            func = CCEffectTexCoord1Padded;
        }
        else
        {
            func = CCEffectTexCoordOverwrite;
        }
    }
    else if (mapping == CCEffectTexCoordMapPreviousPassTex)
    {
        if (fromIntermediate)
        {
            func = CCEffectTexCoordOverwrite;
        }
        else
        {
            func = CCEffectTexCoord1Padded;
        }
    }
    else if (mapping == CCEffectTexCoordMapCustomTex)
    {
        func.source = source;
        func.transform = CCEffectTexCoordTransformPad;
    }
    else
    {
        func.source = source;
        func.transform = CCEffectTexCoordTransformNone;
    }
    return func;
}

CCSpriteVertexes padVertices(const CCSpriteVertexes *input, CGSize padding, CCEffectTexCoordFunc tc1, CCEffectTexCoordFunc tc2)
{
    GLKVector2 tc1Padding = GLKVector2Make(padding.width * (input->br.texCoord1.s - input->bl.texCoord1.s) / (input->br.position.x - input->bl.position.x),
                                           padding.height * (input->tl.texCoord1.t - input->bl.texCoord1.t) / (input->tl.position.y - input->bl.position.y));
    GLKVector2 tc2Padding = GLKVector2Make(padding.width * (input->br.texCoord2.s - input->bl.texCoord2.s) / (input->br.position.x - input->bl.position.x),
                                           padding.height * (input->tl.texCoord2.t - input->bl.texCoord2.t) / (input->tl.position.y - input->bl.position.y));

    
    CCSpriteVertexes output;

    output.bl.position = padVertexPosition(input->bl.position, GLKVector2Make(-padding.width, -padding.height));
    output.bl.texCoord1 = transformTexCoords(tc1.transform, selectTexCoordPadding(tc1.source, GLKVector2Make(-tc1Padding.x, -tc1Padding.y), GLKVector2Make(-tc2Padding.x, -tc2Padding.y)), selectTexCoordSource(tc1.source, input->bl.texCoord1, input->bl.texCoord2, GLKVector2Make(0.0f, 0.0f)));
    output.bl.texCoord2 = transformTexCoords(tc2.transform, selectTexCoordPadding(tc2.source, GLKVector2Make(-tc1Padding.x, -tc1Padding.y), GLKVector2Make(-tc2Padding.x, -tc2Padding.y)), selectTexCoordSource(tc2.source, input->bl.texCoord1, input->bl.texCoord2, GLKVector2Make(0.0f, 0.0f)));
    output.bl.color = input->bl.color;
    
    output.br.position = padVertexPosition(input->br.position, GLKVector2Make( padding.width, -padding.height));
    output.br.texCoord1 = transformTexCoords(tc1.transform, selectTexCoordPadding(tc1.source, GLKVector2Make( tc1Padding.x, -tc1Padding.y), GLKVector2Make( tc2Padding.x, -tc2Padding.y)), selectTexCoordSource(tc1.source, input->br.texCoord1, input->br.texCoord2, GLKVector2Make(1.0f, 0.0f)));
    output.br.texCoord2 = transformTexCoords(tc2.transform, selectTexCoordPadding(tc2.source, GLKVector2Make( tc1Padding.x, -tc1Padding.y), GLKVector2Make( tc2Padding.x, -tc2Padding.y)), selectTexCoordSource(tc2.source, input->br.texCoord1, input->br.texCoord2, GLKVector2Make(1.0f, 0.0f)));
    output.br.color = input->br.color;
    
    output.tr.position = padVertexPosition(input->tr.position, GLKVector2Make( padding.width,  padding.height));
    output.tr.texCoord1 = transformTexCoords(tc1.transform, selectTexCoordPadding(tc1.source, GLKVector2Make( tc1Padding.x,  tc1Padding.y), GLKVector2Make( tc2Padding.x,  tc2Padding.y)), selectTexCoordSource(tc1.source, input->tr.texCoord1, input->tr.texCoord2, GLKVector2Make(1.0f, 1.0f)));
    output.tr.texCoord2 = transformTexCoords(tc2.transform, selectTexCoordPadding(tc2.source, GLKVector2Make( tc1Padding.x,  tc1Padding.y), GLKVector2Make( tc2Padding.x,  tc2Padding.y)), selectTexCoordSource(tc2.source, input->tr.texCoord1, input->tr.texCoord2, GLKVector2Make(1.0f, 1.0f)));
    output.tr.color = input->tr.color;

    output.tl.position = padVertexPosition(input->tl.position, GLKVector2Make(-padding.width,  padding.height));
    output.tl.texCoord1 = transformTexCoords(tc1.transform, selectTexCoordPadding(tc1.source, GLKVector2Make(-tc1Padding.x,  tc1Padding.y), GLKVector2Make(-tc2Padding.x,  tc2Padding.y)), selectTexCoordSource(tc1.source, input->tl.texCoord1, input->tl.texCoord2, GLKVector2Make(0.0f, 1.0f)));
    output.tl.texCoord2 = transformTexCoords(tc2.transform, selectTexCoordPadding(tc2.source, GLKVector2Make(-tc1Padding.x,  tc1Padding.y), GLKVector2Make(-tc2Padding.x,  tc2Padding.y)), selectTexCoordSource(tc2.source, input->tl.texCoord1, input->tl.texCoord2, GLKVector2Make(0.0f, 1.0f)));
    output.tl.color = input->tl.color;

    return output;
}

GLKVector4 padVertexPosition(GLKVector4 input, GLKVector2 positionOffset)
{
    GLKVector4 output;
    output.x = input.x + positionOffset.x;
    output.y = input.y + positionOffset.y;
    output.z = input.z;
    output.w = input.w;
    return output;
}

GLKVector2 transformTexCoords(CCEffectTexCoordTransform tcTransform, GLKVector2 padding, GLKVector2 input)
{
    GLKVector2 output;
    if (tcTransform == CCEffectTexCoordTransformPad)
    {
        output.x = input.x + padding.x;
        output.y = input.y + padding.y;
    }
    else
    {
        output = input;
    }
    return output;
}

GLKVector2 selectTexCoordSource(CCEffectTexCoordSource tcSource, GLKVector2 tc1, GLKVector2 tc2, GLKVector2 tcConst)
{
    GLKVector2 output;
    switch (tcSource)
    {
        case CCEffectTexCoordConstant:
            output = tcConst;
            break;
        case CCEffectTexCoordSource1:
            output = tc1;
            break;
        case CCEffectTexCoordSource2:
            output = tc2;
            break;
        default:
            NSCAssert(0, @"Invalid texture coordinate source.");
            break;
    }
    return output;
}

GLKVector2 selectTexCoordPadding(CCEffectTexCoordSource tcSource, GLKVector2 tc1Padding, GLKVector2 tc2Padding)
{
    GLKVector2 output;
    switch (tcSource)
    {
        case CCEffectTexCoordConstant:
            output = GLKVector2Make(0.0f, 0.0f);
            break;
        case CCEffectTexCoordSource1:
            output = tc1Padding;
            break;
        case CCEffectTexCoordSource2:
            output = tc2Padding;
            break;
        default:
            NSCAssert(0, @"Invalid texture coordinate source.");
            break;
    }
    return output;
}

