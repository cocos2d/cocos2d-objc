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

#if __CC_PLATFORM_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif



@implementation CCEffectNode {
    CGSize _size;
    GLenum _pixelFormat;
	GLuint _depthStencilFormat;
	
	CCRenderer *_renderer;
	BOOL _privateRenderer;
    
	GLuint _FBO;
	GLuint _depthRenderBufffer;
	GLKVector4 _clearColor;
	
	GLKVector4 _oldViewport;
	GLint _oldFBO;
	NSDictionary *_oldGlobalUniforms;

}

-(id)initWithWidth:(int)width height:(int)height
{
	if((self = [super init])){
        
        _pixelFormat = CCTexturePixelFormat_Default;
        _depthStencilFormat = 0;

		CCDirector *director = [CCDirector sharedDirector];
        
		// XXX multithread
		if( [director runningThread] != [NSThread currentThread] )
			CCLOGWARN(@"cocos2d: WARNING. CCEffectNode is running on its own thread. Make sure that an OpenGL context is being used on this thread!");
        
		_contentScale = [CCDirector sharedDirector].contentScaleFactor;
		_size = CGSizeMake(width, height);
        
		// Flip the projection matrix on the y-axis since Cocos2D uses upside down textures.
		_projection = GLKMatrix4MakeOrtho(0.0f, width, height, 0.0f, -1024.0f, 1024.0f);
		
		_sprite = [CCSprite spriteWithTexture:[CCTexture none]];
	}
	return self;
}

-(void)create
{
	glPushGroupMarkerEXT(0, "CCEffectNode: Create");
	
	int pixelW = _size.width*_contentScale;
	int pixelH = _size.height*_contentScale;
    
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
    
	// textures must be power of two
	NSUInteger powW;
	NSUInteger powH;
    
	if( [[CCConfiguration sharedConfiguration] supportsNPOT] ) {
		powW = pixelW;
		powH = pixelH;
	} else {
		powW = CCNextPOT(pixelW);
		powH = CCNextPOT(pixelH);
	}
    
	void *data = calloc(powW*powH, 4);
    
	CCTexture *texture = [[CCTexture alloc] initWithData:data pixelFormat:_pixelFormat pixelsWide:powW pixelsHigh:powH contentSizeInPixels:CGSizeMake(pixelW, pixelH) contentScale:_contentScale];
	self.texture = texture;
	
	free(data);
    
	GLint oldRBO;
	glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);
    
	// generate FBO
	glGenFramebuffers(1, &_FBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    
	// associate texture with FBO
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.texture.name, 0);
    
	if(_depthStencilFormat) {
		//create and attach depth buffer
		glGenRenderbuffers(1, &_depthRenderBufffer);
		glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBufffer);
		glRenderbufferStorage(GL_RENDERBUFFER, _depthStencilFormat, (GLsizei)powW, (GLsizei)powH);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBufffer);
        
		// if depth format is the one with stencil part, bind same render buffer as stencil attachment
		if(_depthStencilFormat == GL_DEPTH24_STENCIL8){
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBufffer);
		}
	}
    
	// check if it worked (probably worth doing :) )
	NSAssert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Could not attach texture to framebuffer");
    
	[self.texture setAliasTexParameters];
	
	glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
	
	CC_CHECK_GL_ERROR_DEBUG();
	glPopGroupMarkerEXT();
	
	CGRect rect = CGRectMake(0, 0, _size.width, _size.height);
	_sprite.texture = self.texture;
	[_sprite setTextureRect:rect];
}

-(void)setContentScale:(float)contentScale
{
	if(_contentScale != contentScale){
		_contentScale = contentScale;
		
		[self destroy];
		self.texture = nil;
	}
}

-(void)destroy
{
	glDeleteFramebuffers(1, &_FBO);
	_FBO = 0;
	
	if(_depthRenderBufffer){
		glDeleteRenderbuffers(1, &_depthRenderBufffer);
		_depthRenderBufffer = 0;
	}
}

-(void)dealloc
{
	[self destroy];
}

-(CCTexture *)texture
{
	if(super.texture == nil){
		[self create];
	}
	
	return super.texture;
}

-(GLuint)fbo
{
	if(super.texture == nil){
		[self create];
	}
	
	return _FBO;
}

-(void)begin
{
	_renderer = [CCRenderer currentRenderer];
	
	if(_renderer == nil){
		_renderer = [[CCRenderer alloc] init];
		
		NSMutableDictionary *uniforms = [[CCDirector sharedDirector].globalShaderUniforms mutableCopy];
		uniforms[CCShaderUniformProjection] = [NSValue valueWithGLKMatrix4:_projection];
		_renderer.globalShaderUniforms = uniforms;
		
		[CCRenderer bindRenderer:_renderer];
		_privateRenderer = YES;
	} else {
		_oldGlobalUniforms = _renderer.globalShaderUniforms;
		
		NSMutableDictionary *uniforms = [_oldGlobalUniforms mutableCopy];
		uniforms[CCShaderUniformProjection] = [NSValue valueWithGLKMatrix4:_projection];
		_renderer.globalShaderUniforms = uniforms;
	}
	
	CGSize pixelSize = self.texture.contentSizeInPixels;
	GLuint fbo = [self fbo];
	

    
	[_renderer enqueueBlock:^{
		glGetFloatv(GL_VIEWPORT, _oldViewport.v);
		glViewport(0, 0, pixelSize.width, pixelSize.height );
		
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
		glBindFramebuffer(GL_FRAMEBUFFER, fbo);

	} debugLabel:@"CCEffectNode: Bind FBO"];
}

-(void)end
{
	[_renderer enqueueBlock:^{
		glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
		glViewport(_oldViewport.v[0], _oldViewport.v[1], _oldViewport.v[2], _oldViewport.v[3]);
	} debugLabel:@"CCEffectNode: Restore FBO"];
	
	if(_privateRenderer){
		[_renderer flush];
		[CCRenderer bindRenderer:nil];
		_privateRenderer = NO;
	} else {
		_renderer.globalShaderUniforms = _oldGlobalUniforms;
	}
	
	_renderer = nil;
}

#pragma mark RenderTexture - "auto" update

- (void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	// override visit.
	// Don't call visit on its children
	if(!_visible) return;
	
	GLKMatrix4 transform = [self transform:parentTransform];
	[_sprite visit:renderer parentTransform:&transform];
	[self draw:renderer transform:&transform];
	
	_orderOfArrival = 0;
}

- (void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    [self begin];
    
    NSAssert(_renderer == renderer, @"CCEffectNode error!");

    [_renderer enqueueClear:0 color:_clearColor depth:0.0f stencil:0];
    
    //! make sure all children are drawn
    [self sortAllChildren];
    
    for(CCNode *child in _children){
        if( child != _sprite) [child visit:renderer parentTransform:&_projection];
    }
    
    [self end];
}

- (CCColor*)clearColor
{
    return [CCColor colorWithGLKVector4:_clearColor];
}

- (void)setClearColor:(CCColor *)clearColor
{
    _clearColor = clearColor.glkVector4;
}

-(void)setEffect:(CCEffect *)effect
{
    self.sprite.shader = effect.shader;
    if(effect.shaderUniforms != nil) // TODO: check for duplicate uniform names
        [self.sprite.shaderUniforms addEntriesFromDictionary:effect.shaderUniforms];
}

//-(void)addEffect
//{
//    // TODO: replace this with CCEffect
//	CCShader *shader = [[CCShader alloc] initWithFragmentShaderSource:CC_GLSL(
//        void main(void){
//            gl_FragColor = texture2D(cc_MainTexture, cc_FragTexCoord1) + vec4(1.0, 0.0, 0.0, 1.0);
//        }
//    )];
//	
//    self.sprite.shader = shader;
//}

@end
