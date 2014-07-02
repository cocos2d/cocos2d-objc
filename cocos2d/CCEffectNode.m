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

#if __CC_PLATFORM_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectNode()
{
    CCEffect *_effect;
    CCEffectRenderer *_effectRenderer;
}

@end

@implementation CCEffectNode


-(id)init
{
    return [self initWithWidth:1 height:1];
}

-(id)initWithWidth:(int)width height:(int)height
{
	if((self = [super initWithWidth:width height:height pixelFormat:CCTexturePixelFormat_Default])) {
        _effectRenderer = [[CCEffectRenderer alloc] init];
	}
	return self;
}

-(CCEffect *)effect
{
	return _effect;
}

-(void)setEffect:(CCEffect *)effect
{
    _effect = effect;
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

    [_renderer enqueueClear:GL_COLOR_BUFFER_BIT color:_clearColor depth:self.clearDepth stencil:self.clearStencil globalSortOrder:NSIntegerMin];
    
    //! make sure all children are drawn
    [self sortAllChildren];
    
    for(CCNode *child in _children){
        if( child != _sprite) [child visit:renderer parentTransform:&_projection];
    }
    [self endWithDebugLabel:@"CCEffectNode: Pre-render pass"];

    // Done pre-render
    
    _sprite.texture = self.texture;
    _effectRenderer.contentSize = self.texture.contentSize;
    [_effectRenderer drawSprite:_sprite withEffect:_effect renderer:_renderer transform:transform];
    
    if (!_effect.supportsDirectRendering || !_effect)
    {
        // XXX We may want to make this post-render step overridable by the
        // last effect in the stack. That would look like the code in the
        // pre-render override comment above.
        //
        
        // Draw accumulated results from the last textureinto the real framebuffer
        // The texture property always points to the most recently allocated
        // texture so it will contain any accumulated results for the effect stack.
        [_renderer pushGroup];
        
        if (_effect)
        {
            _sprite.texture = _effectRenderer.outputTexture;
        }
        else
        {
            _sprite.texture = self.texture;
        }
        
        _sprite.anchorPoint = ccp(0.0f, 0.0f);
        _sprite.position = ccp(0.0f, 0.0f);
        _sprite.shader = [CCShader positionTextureColorShader];
        [_sprite visit:_renderer parentTransform:transform];
        
        [_renderer popGroupWithDebugLabel:@"CCEffectNode: Post-render composite pass" globalSortOrder:0];
        
        // Done framebuffer composite
    }
    
    
    if(_privateRenderer == NO)
        _renderer.globalShaderUniforms = _oldGlobalUniforms;
    else
        [CCRenderer bindRenderer:nil];

    _renderer = nil;
}

@end
#endif
