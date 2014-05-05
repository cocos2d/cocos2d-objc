//
//  CCEffectNode.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/26/14.
//
//

#import "CCEffectNode.h"
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
@implementation CCEffectNode 

-(id)initWithWidth:(int)width height:(int)height
{
	if((self = [super initWithWidth:width height:height pixelFormat:CCTexturePixelFormat_Default])) {
        
	}
	return self;
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
	
    _currentRenderPass = 0;
    GLKMatrix4 transform = [self transform:parentTransform];
    //[_sprite visit:renderer parentTransform:&transform];
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
    [_textures removeAllObjects];
    [self configureRender];

    NSAssert(_renderer == renderer, @"CCEffectNode error!");
    
    CCEffectRenderPass* renderPass = [[CCEffectRenderPass alloc] init];
    renderPass.renderPassId = _currentRenderPass;
    renderPass.sprite = _sprite;
    renderPass.renderer = _renderer;
    renderPass.transform = (*transform);
    
    if(self.effect.shader && self.sprite.shader != self.effect.shader)
        self.sprite.shader = self.effect.shader;
    
    for(int i = 0; i < self.effect.renderPassesRequired; i++)
    {
        _currentRenderPass = i;
        renderPass.renderPassId = i;
        renderPass.textures = _textures;
        [self.effect renderPassBegin:renderPass defaultBlock:nil];
        [self begin];
        [self.effect renderPassUpdate:renderPass defaultBlock:^{
            [_renderer enqueueClear:self.clearFlags color:_clearColor depth:self.clearDepth stencil:self.clearStencil globalSortOrder:NSIntegerMin];
            
            //! make sure all children are drawn
            [self sortAllChildren];
            
            for(CCNode *child in _children){
                if( child != _sprite) [child visit:renderer parentTransform:&_projection];
            }
        }];
        [self end];
        [_renderer flush];
        [self.effect renderPassEnd:renderPass defaultBlock:^{
            renderPass.sprite.texture = renderPass.textures[0];
            [renderPass.sprite visit:renderPass.renderer parentTransform:transform];
        }];
    }
    
    if(_privateRenderer == NO)
        _renderer.globalShaderUniforms = _oldGlobalUniforms;
    else
        [CCRenderer bindRenderer:nil];

    _renderer = nil;
}

-(void)setEffect:(CCEffect *)effect
{
    _effect = effect;
    self.shader = effect.shader;

    self.sprite.shader = effect.shader;
    if(effect.shaderUniforms != nil) // TODO: check for duplicate uniform names
    {
        [self.sprite.shaderUniforms addEntriesFromDictionary:effect.shaderUniforms];
    }
}

-(void)assignSpriteTexture
{
    // don't do anything on effect nodes
}

@end
#endif
