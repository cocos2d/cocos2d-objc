//
//  CCEffectRenderer.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/21/14.
//
//

#import "CCEffectRenderer.h"
#import "CCConfiguration.h"
#import "CCEffect.h"
#import "CCEffectStack.h"
#import "CCTexture.h"
#import "ccUtils.h"

#import "CCTexture_Private.h"


@interface CCEffectRenderTarget : NSObject

@property (nonatomic, readonly) CCTexture *texture;
@property (nonatomic, readonly) GLuint FBO;
@property (nonatomic, readonly) GLuint depthRenderBuffer;

@end

@implementation CCEffectRenderTarget

- (id)initWithTexture:(CCTexture*)texture FBO:(GLuint)fbo depthRenderBuffer:(GLuint)depthBuffer
{
    if((self = [super init]))
    {
        _texture = texture;
        _FBO = fbo;
        _depthRenderBuffer = depthBuffer;
    }
    return self;
}

@end


@interface CCEffectRenderer ()

@property (nonatomic, strong) NSMutableArray *renderTargets;
@property (nonatomic, assign) GLKVector4 oldViewport;
@property (nonatomic, assign) GLint oldFBO;

@end


@implementation CCEffectRenderer

-(CCTexture *)outputTexture
{
    CCEffectRenderTarget *rt = [_renderTargets lastObject];
    return rt.texture;
}

-(id)init
{
    return [self initWithWidth:0 height:0];
}

-(id)initWithWidth:(int)width height:(int)height
{
    if((self = [super init]))
    {
        _renderTargets = [[NSMutableArray alloc] init];
        _width = width;
        _height = height;
    }
    return self;
}

-(void)dealloc
{
    [self destroyAllRenderTargets];
}

-(void)drawSprite:(CCSprite *)sprite withEffects:(CCEffectStack *)effectStack renderer:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    [self destroyAllRenderTargets];
    
    CCEffectRenderPass* renderPass = [[CCEffectRenderPass alloc] init];
    renderPass.sprite = sprite;
    renderPass.renderer = renderer;
    
    CCTexture *inputTexture = sprite.texture;
    
    CCEffectRenderTarget *previousPassRT = nil;
    for (NSUInteger e = 0; e < effectStack.effectCount; e++)
    {
        CCEffect *effect = [effectStack effectAtIndex:e];
        if(effect.shader && sprite.shader != effect.shader)
        {
            sprite.shader = effect.shader;
            [sprite.shaderUniforms removeAllObjects];
            [sprite.shaderUniforms addEntriesFromDictionary:effect.shaderUniforms];
        }
        
        if (previousPassRT)
        {
            renderPass.sprite.shaderUniforms[@"cc_MainTexture"] = previousPassRT.texture;
        }
        else
        {
            renderPass.sprite.shaderUniforms[@"cc_MainTexture"] = inputTexture;
        }
        
        for(int i = 0; i < effect.renderPassesRequired; i++)
        {
            CCEffectRenderTarget *rt = [self allocRenderTargetWithWidth:_width height:_height];
            
            renderPass.transform = *transform;
            renderPass.renderPassId = i;
            
            if (previousPassRT)
            {
                renderPass.sprite.shaderUniforms[@"cc_PreviousPassTexture"] = previousPassRT.texture;
            }
            else
            {
                renderPass.sprite.shaderUniforms[@"cc_PreviousPassTexture"] = inputTexture;
            }
            
            [effect renderPassBegin:renderPass defaultBlock:nil];

            // Begin
            {
                CGSize pixelSize = rt.texture.contentSizeInPixels;
                GLuint fbo = rt.FBO;
                
                [renderer pushGroup];
                [renderer enqueueBlock:^{
                    glGetFloatv(GL_VIEWPORT, _oldViewport.v);
                    glViewport(0, 0, pixelSize.width, pixelSize.height );
                    
                    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
                    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
                    
                } globalSortOrder:NSIntegerMin debugLabel:@"CCEffectNode: Bind FBO" threadSafe:NO];
            }
            // /Begin
            
            
            [effect renderPassUpdate:renderPass defaultBlock:^{
                GLKMatrix4 xform = renderPass.transform;
                GLKVector4 clearColor;
                
                renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
                [renderPass.renderer enqueueClear:GL_COLOR_BUFFER_BIT color:clearColor depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
                [renderPass.sprite visit:renderPass.renderer parentTransform:&xform];
            }];

            
            // End
            {
                [renderer enqueueBlock:^{
                    glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
                    glViewport(_oldViewport.v[0], _oldViewport.v[1], _oldViewport.v[2], _oldViewport.v[3]);
                } globalSortOrder:NSIntegerMax debugLabel:@"CCEffectNode: Restore FBO" threadSafe:NO];
                
                [renderer popGroupWithDebugLabel:[NSString stringWithFormat:@"CCEffectNode: %@: Pass %d", effect.debugName, i] globalSortOrder:0];
            }
            // /End
            
            [effect renderPassEnd:renderPass defaultBlock:nil];
            
            previousPassRT = rt;
        }
    }
}

- (CCEffectRenderTarget *)allocRenderTargetWithWidth:(int)width height:(int)height
{
    glPushGroupMarkerEXT(0, "CCEffectRenderTarget: allocateRenderTarget");

	// Textures may need to be a power of two
	NSUInteger powW;
	NSUInteger powH;
    
	if( [[CCConfiguration sharedConfiguration] supportsNPOT] )
    {
		powW = width;
		powH = height;
	}
    else
    {
		powW = CCNextPOT(width);
		powH = CCNextPOT(height);
	}

    static const CCTexturePixelFormat kRenderTargetDefaultPixelFormat = CCTexturePixelFormat_RGBA8888;
    static const float kRenderTargetDefaultContentScale = 1.0f;
    
    // Create a new texture object for use as the color attachment of the new
    // FBO.
	CCTexture *texture = [[CCTexture alloc] initWithData:nil pixelFormat:kRenderTargetDefaultPixelFormat pixelsWide:powW pixelsHigh:powH contentSizeInPixels:CGSizeMake(width, height) contentScale:kRenderTargetDefaultContentScale];
	[texture setAliasTexParameters];
	
    // Save the old FBO binding so it can be restored after we create the new
    // one.
	GLint oldFBO;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    
	// Generate a new FBO and bind it so it can be modified.
    GLuint fbo;
	glGenFramebuffers(1, &fbo);
	glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    
	// Associate texture with FBO
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.name, 0);
    
	// Check if it worked (probably worth doing :) )
	NSAssert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Could not attach texture to framebuffer");
    
    CCEffectRenderTarget *rt = [[CCEffectRenderTarget alloc] initWithTexture:texture FBO:fbo depthRenderBuffer:0];
    
    // Restore the old FBO binding.
	glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
	
	CC_CHECK_GL_ERROR_DEBUG();
	glPopGroupMarkerEXT();
	
    [_renderTargets addObject:rt];
    
    return rt;
}

- (void)destroyRenderTarget:(CCEffectRenderTarget *)rt
{
    GLuint fbo = rt.FBO;
    glDeleteFramebuffers(1, &fbo);
	
    GLuint depthRenderBuffer = rt.depthRenderBuffer;
    if (depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderBuffer);
    }
}

- (void)destroyAllRenderTargets
{
    for (CCEffectRenderTarget *rt in _renderTargets)
    {
        [self destroyRenderTarget:rt];
    }
    [_renderTargets removeAllObjects];
}

@end
