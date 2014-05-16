//
//  CCEffectNode.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/26/14.
//
//

#import "CCEffectNode.h"
#import "CCEffectStack.h"
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
    CCEffectStack *_effectStack;
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
        _effectStack = [[CCEffectStack alloc] init];
	}
	return self;
}

-(void)addEffect:(CCEffect *)effect
{
    [_effectStack addEffect:effect];
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

-(void)end
{
    [_renderer enqueueBlock:^{
		glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
		glViewport(_oldViewport.v[0], _oldViewport.v[1], _oldViewport.v[2], _oldViewport.v[3]);
	} globalSortOrder:NSIntegerMax debugLabel:@"CCEffectNode: Restore FBO" threadSafe:NO];
	
	[_renderer popGroupWithDebugLabel:@"CCEffectNode" globalSortOrder:0];
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
    [self destroy];
    [self configureRender];

    NSAssert(_renderer == renderer, @"CCEffectNode error!");
    
    _currentRenderPass = 0;
    
    // XXX We may want to make this pre-render step overridable by the
    // first effect in the stack. That would look something like this:
    //
    // CCEffect *firstEffect = [_effectStack effectAtIndex:0];
    // if (firstEffect.overridesPrerender)
    //   [firstEffect prerender]
    // else
    //   Do all the stuff below.

    // Render children of this effect node into an FBO for use by the
    // remainder of the effects.
    [self begin];
    
    [_renderer enqueueClear:self.clearFlags color:_clearColor depth:self.clearDepth stencil:self.clearStencil globalSortOrder:NSIntegerMin];
    
    //! make sure all children are drawn
    [self sortAllChildren];
    
    for(CCNode *child in _children){
        if( child != _sprite) [child visit:renderer parentTransform:&_projection];
    }
    [self end];

    // Done pre-render
    
    
    CCEffectRenderPass* renderPass = [[CCEffectRenderPass alloc] init];
    renderPass.sprite = _sprite;
    renderPass.renderer = _renderer;
    
    NSInteger globalPassIndex = 0;
    for (NSUInteger e = 0; e < _effectStack.effectCount; e++)
    {
        CCEffect *effect = [_effectStack effectAtIndex:e];
        if(effect.shader && self.sprite.shader != effect.shader)
        {
            self.sprite.shader = effect.shader;
            [self.sprite.shaderUniforms removeAllObjects];
            [self.sprite.shaderUniforms addEntriesFromDictionary:effect.shaderUniforms];
        }

        renderPass.sprite.shaderUniforms[@"cc_MainTexture"] = _textures[globalPassIndex];
        
        for(int i = 0; i < effect.renderPassesRequired; i++)
        {
            _currentRenderPass = globalPassIndex + 1;

            renderPass.transform = _projection;
            renderPass.renderPassId = i;
            renderPass.textures = _textures;
            
            renderPass.sprite.shaderUniforms[@"cc_PreviousPassTexture"] = _textures[globalPassIndex];
            
            [effect renderPassBegin:renderPass defaultBlock:nil];
            [self begin];
            
            [effect renderPassUpdate:renderPass defaultBlock:^{
                GLKMatrix4 xform = renderPass.transform;
                GLKVector4 clearColor;
                
                renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
                [renderPass.renderer enqueueClear:0 color:clearColor depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
                [renderPass.sprite visit:renderPass.renderer parentTransform:&xform];
            }];

            [self end];
            [effect renderPassEnd:renderPass defaultBlock:nil];
            
            ++globalPassIndex;
        }
    }
    
    
    
    // XXX We may want to make this post-render step overridable by the
    // last effect in the stack. That would look like the code in the
    // pre-render override comment above.
    //
    
    // Draw accumulated results from the last textureinto the real framebuffer
    // The texture property always points to the most recently allocated
    // texture so it will contain any accumulated results for the effect stack.
    _sprite.texture = self.texture;
    _sprite.shader = [CCShader positionTextureColorShader];
    [_sprite visit:_renderer parentTransform:transform];
    
    // Done framebuffer composite

    
    
    if(_privateRenderer == NO)
        _renderer.globalShaderUniforms = _oldGlobalUniforms;
    else
        [CCRenderer bindRenderer:nil];

    _renderer = nil;
}

//-(void)setEffect:(CCEffect *)effect
//{
//    _effect = effect;
//    self.shader = effect.shader;
//
//    self.sprite.shader = effect.shader;
//    if(effect.shaderUniforms != nil) // TODO: check for duplicate uniform names
//    {
//        [self.sprite.shaderUniforms addEntriesFromDictionary:effect.shaderUniforms];
//    }
//}

-(void)assignSpriteTexture
{
    // don't do anything on effect nodes
}

@end
#endif
