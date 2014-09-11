//
//  CCEffectNode.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/26/14.
//
//

#import "CCEffectNode.h"
#import "CCEffectStack.h"
#import "CCEffectRenderer.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CCShader.h"
#import "CCConfiguration.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"

#import "CCTexture_Private.h"
#import "CCDirector_Private.h"
#import "CCNode_Private.h"
#import "CCRenderer_private.h"
#import "CCRenderTexture_Private.h"
#import "CCEffect_Private.h"

#if __CC_PLATFORM_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

@interface CCEffectNode()
{
    CCEffect *_effect;
    CCEffectRenderer *_effectRenderer;
    CGSize _allocatedSize;
}

@end

@implementation CCEffectNode


-(id)init
{
    return [self initWithWidth:1 height:1];
}

-(id)initWithWidth:(int)width height:(int)height
{
    return [self initWithWidth:width height:height pixelFormat:CCTexturePixelFormat_Default];
}

-(id)initWithWidth:(int)width height:(int)height pixelFormat:(CCTexturePixelFormat)format
{
    return [self initWithWidth:width height:height pixelFormat:format depthStencilFormat:0];
}

-(id)initWithWidth:(int)width height:(int)height pixelFormat:(CCTexturePixelFormat) format depthStencilFormat:(GLuint)depthStencilFormat
{
    if((self = [super initWithWidth:width height:height pixelFormat:CCTexturePixelFormat_Default depthStencilFormat:depthStencilFormat]))
    {
        _effectRenderer = [[CCEffectRenderer alloc] init];
        _allocatedSize = CGSizeMake(0.0f, 0.0f);
        self.clearFlags = GL_COLOR_BUFFER_BIT;
	}
	return self;
}

+(id)effectNodeWithWidth:(int)w height:(int)h
{
    return [[CCEffectNode alloc] initWithWidth:w height:h];
}

+(id)effectNodeWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format
{
    return [[CCEffectNode alloc] initWithWidth:w height:h pixelFormat:format];
}

+(id)effectNodeWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format depthStencilFormat:(GLuint)depthStencilFormat
{
    return [[CCEffectNode alloc] initWithWidth:w height:h pixelFormat:format depthStencilFormat:depthStencilFormat];
}

-(CCEffect *)effect
{
	return _effect;
}

-(void)setEffect:(CCEffect *)effect
{
    _effect = effect;
    if (effect)
    {
        [self updateShaderUniformsFromEffect];
    }
    else
    {
        _shaderUniforms = nil;
    }
}

-(void)create
{
    _allocatedSize = self.contentSizeInPoints;
    CGSize pixelSize = CGSizeMake(_allocatedSize.width * _contentScale, _allocatedSize.height * _contentScale);
    [self createTextureAndFboWithPixelSize:pixelSize];

    CGRect rect = CGRectMake(0, 0, _allocatedSize.width, _allocatedSize.height);
	[_sprite setTextureRect:rect];
    
    _projection = GLKMatrix4MakeOrtho(0.0f, _allocatedSize.width, 0.0f, _allocatedSize.height, -1024.0f, 1024.0f);
}

-(void)destroy
{
    [super destroy];
    _allocatedSize = CGSizeMake(0.0f, 0.0f);
}

-(void)begin
{
	CGSize pixelSize = self.texture.contentSizeInPixels;
	GLuint fbo = [self fbo];
  
	[_renderer pushGroup];
	[_renderer enqueueBlock:^{
		glGetFloatv(GL_VIEWPORT, _oldViewport.v);
		glViewport(0, 0, pixelSize.width, pixelSize.height );
		
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
		glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        
	} globalSortOrder:NSIntegerMin debugLabel:@"CCEffectNode: Bind FBO" threadSafe:NO];
}

-(void)endWithDebugLabel:(NSString *)debugLabel
{
    [_renderer enqueueBlock:^{
		glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
		glViewport(_oldViewport.v[0], _oldViewport.v[1], _oldViewport.v[2], _oldViewport.v[3]);
	} globalSortOrder:NSIntegerMax debugLabel:@"CCEffectNode: Restore FBO" threadSafe:NO];
	
	[_renderer popGroupWithDebugLabel:debugLabel globalSortOrder:0];
}

-(void)visit
{
    [self configureRender];
	NSAssert(_renderer, @"Cannot call [CCNode visit] without a currently bound renderer.");
    
	GLKMatrix4 projection; [_renderer.globalShaderUniforms[CCShaderUniformProjection] getValue:&projection];
	[self visit:_renderer parentTransform:&projection];
}

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	// override visit.
	// Don't call visit on its children
	if(!_visible) return;
    
    CGSize pointSize = self.contentSizeInPoints;
    if (!CGSizeEqualToSize(pointSize, _allocatedSize))
    {
        [self destroy];
        [self contentSizeChanged];
        _contentSizeChanged = NO;
    }
	
    GLKMatrix4 transform = [self transform:parentTransform];
    
    [self draw:renderer transform:&transform];
	
	_orderOfArrival = 0;
}

-(void)configureRender
{
    // bind renderer
    _renderer = [CCRenderer currentRenderer];
	
	if(_renderer == nil)
    {
		_renderer = [[CCRenderer alloc] init];
		
		NSMutableDictionary *uniforms = [[CCDirector sharedDirector].globalShaderUniforms mutableCopy];
		uniforms[CCShaderUniformProjection] = [NSValue valueWithGLKMatrix4:_projection];
		_renderer.globalShaderUniforms = uniforms;
		
		[CCRenderer bindRenderer:_renderer];
		_privateRenderer = YES;
    }
    else if(_privateRenderer == NO)
    {
		_oldGlobalUniforms = _renderer.globalShaderUniforms;
		
		NSMutableDictionary *uniforms = [_oldGlobalUniforms mutableCopy];
		uniforms[CCShaderUniformProjection] = [NSValue valueWithGLKMatrix4:_projection];
		_renderer.globalShaderUniforms = uniforms;
	}
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    [self configureRender];

    NSAssert(_renderer == renderer, @"CCEffectNode error!");

    // Render children of this effect node into an FBO for use by the
    // remainder of the effects.
    [self begin];

    [_renderer enqueueClear:self.clearFlags color:_clearColor depth:self.clearDepth stencil:self.clearStencil globalSortOrder:NSIntegerMin];
    
    //! make sure all children are drawn
    [self sortAllChildren];
    
    for(CCNode *child in _children){
        if( child != _sprite) [child visit:renderer parentTransform:&_projection];
    }
    [self endWithDebugLabel:@"CCEffectNode: Pre-render pass"];

    // Done pre-render
    
    if (_effect)
    {
        _effectRenderer.contentSize = self.contentSizeInPoints;
        if ([_effect prepareForRendering] == CCEffectPrepareSuccess)
        {
            // Preparing an effect for rendering can modify its uniforms
            // dictionary which means we need to reinitialize our copy of the
            // uniforms.
            [self updateShaderUniformsFromEffect];
        }
        [_effectRenderer drawSprite:_sprite withEffect:_effect uniforms:_shaderUniforms renderer:_renderer transform:transform];
    }
    else
    {
        _sprite.anchorPoint = ccp(0.0f, 0.0f);
        _sprite.position = ccp(0.0f, 0.0f);
        [_sprite visit:_renderer parentTransform:transform];
    }
    
    if(_privateRenderer == NO)
        _renderer.globalShaderUniforms = _oldGlobalUniforms;
    else
        [CCRenderer bindRenderer:nil];

    _renderer = nil;
}

- (void)updateShaderUniformsFromEffect
{
    // Initialize the shader uniforms dictionary with the node's main texture and an
    // empty entry for the normal map (because effect node's don't have normal maps
    // like sprites do).
    _shaderUniforms = [@{ CCShaderUniformMainTexture : (_texture ?: [CCTexture none]),
                          CCShaderUniformNormalMapTexture : [CCTexture none]
                          } mutableCopy];
    
    // And then copy the new effect's uniforms into the node's uniforms dictionary.
    [_shaderUniforms addEntriesFromDictionary:_effect.shaderUniforms];
}

@end
