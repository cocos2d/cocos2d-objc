#import "CCTexture.h"
#import "CCNode_Private.h"
#import "CCSprite_Private.h"
#import "CCRenderer_Private.h"
#import "CCShader_Private.h"


@implementation CCNode(NoARC)

static inline GLKMatrix4
CCNodeTransform(CCNode *node, GLKMatrix4 parentTransform)
{
	CGAffineTransform t = [node nodeToParentTransform];
	float z = node->_vertexZ;
	
	// Convert to 4x4 column major GLK matrix.
	return GLKMatrix4Multiply(parentTransform, GLKMatrix4Make(
		 t.a,  t.b, 0.0f, 0.0f,
		 t.c,  t.d, 0.0f, 0.0f,
		0.0f, 0.0f, 1.0f, 0.0f,
		t.tx, t.ty,    z, 1.0f
	));
}

-(GLKMatrix4)transform:(const GLKMatrix4 *)parentTransform
{
	return CCNodeTransform(self, *parentTransform);
}

-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	// quick return if not visible. children won't be drawn.
	if (!_visible) return;
	
	[self sortAllChildren];
	
	GLKMatrix4 transform = CCNodeTransform(self, *parentTransform);
	BOOL drawn = NO;
	
	for(CCNode *child in _children){
		if(!drawn && child.zOrder >= 0){
			[self draw:renderer transform:&transform];
			drawn = YES;
		}
		
		[child visit:renderer parentTransform:&transform];
	}
	
	if(!drawn) [self draw:renderer transform:&transform];

	// reset for next frame
	_orderOfArrival = 0;
}

@end


@implementation CCSprite(NoARC)

static inline void
EnqueueTriangles(CCSprite *self, CCRenderer *renderer, const GLKMatrix4 *transform)
{
	CCRenderState *state = self->_renderState ?: self.renderState;
	CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:state globalSortOrder:0];
	
	CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(self->_verts.bl, transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(self->_verts.br, transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(self->_verts.tr, transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(self->_verts.tl, transform));

	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;
{
	if(!CCRenderCheckVisbility(transform, _vertexCenter, _vertexExtents)) return;
	
	if (_effect)
	{
		_effectRenderer.contentSize = self.contentSizeInPoints;
		if ([self.effect prepareForRendering] == CCEffectPrepareSuccess)
		{
			// Preparing an effect for rendering can modify its uniforms
			// dictionary which means we need to reinitialize our copy of the
			// uniforms.
			[self updateShaderUniformsFromEffect];
		}
		[_effectRenderer drawSprite:self withEffect:self.effect uniforms:_shaderUniforms renderer:renderer transform:transform];
	}
	else
	{
		EnqueueTriangles(self, renderer, transform);
	}
    
#if CC_SPRITE_DEBUG_DRAW
	const GLKVector2 zero = {{0, 0}};
	const GLKVector4 white = {{1, 1, 1, 1}};
	
	CCRenderBuffer debug = [renderer enqueueLines:4 andVertexes:4 withState:[CCRenderState debugColor] globalSortOrder:0];
	CCRenderBufferSetVertex(debug, 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.bl.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.br.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.tr.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.tl.position), zero, zero, white});
	
	CCRenderBufferSetLine(debug, 0, 0, 1);
	CCRenderBufferSetLine(debug, 1, 1, 2);
	CCRenderBufferSetLine(debug, 2, 2, 3);
	CCRenderBufferSetLine(debug, 3, 3, 0);
#endif
}

-(void)enqueueTriangles:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	EnqueueTriangles(self, renderer, transform);
}

@end


@implementation CCRenderer(NoARC)

-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
{
	// Need to record the first vertex or element index before pushing more vertexes.
	size_t firstVertex = _vertexBuffer.count;
	size_t firstElement = _elementBuffer.count;
	
	size_t elementCount = 3*triangleCount;
	CCVertex *vertexes = CCGraphicsBufferPushElements(&_vertexBuffer, vertexCount, self);
	GLushort *elements = CCGraphicsBufferPushElements(&_elementBuffer, elementCount, self);
	
	CCRenderCommandDraw *previous = _lastDrawCommand;
	if(previous && previous->_renderState == renderState && previous->_globalSortOrder == globalSortOrder){
		// Batch with the previous command.
		[previous batchElements:(GLsizei)elementCount];
	} else {
		// Start a new command.
		CCRenderCommandDraw *command = [[CCRenderCommandDraw alloc] initWithMode:GL_TRIANGLES renderState:renderState first:(GLint)firstElement elements:(GLsizei)elementCount globalSortOrder:globalSortOrder];
		[_queue addObject:command];
		[command release];
		
		_lastDrawCommand = command;
	}
	
	return (CCRenderBuffer){vertexes, elements, firstVertex};
}

-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
{
	// Need to record the first vertex or element index before pushing more vertexes.
	size_t firstVertex = _vertexBuffer.count;
	size_t firstElement = _elementBuffer.count;
	
	size_t elementCount = 2*lineCount;
	CCVertex *vertexes = CCGraphicsBufferPushElements(&_vertexBuffer, vertexCount, self);
	GLushort *elements = CCGraphicsBufferPushElements(&_elementBuffer, elementCount, self);
	
	CCRenderCommandDraw *command = [[CCRenderCommandDraw alloc] initWithMode:GL_LINES renderState:renderState first:(GLint)firstElement elements:(GLsizei)elementCount globalSortOrder:globalSortOrder];
	[_queue addObject:command];
	[command release];
	
	// Line drawing commands are currently intended for debugging and cannot be batched.
	_lastDrawCommand = nil;
	
	return(CCRenderBuffer){vertexes, elements, firstVertex};
}

@end


@implementation CCRenderer(NoARCPrivate)

-(void)setRenderState:(CCRenderState *)renderState
{
	[self bindVAO:YES];
	if(renderState == _renderState) return;
	
	glPushGroupMarkerEXT(0, "CCRenderer: Render State");
	
	// Set the blending state.
	NSDictionary *blendOptions = renderState->_blendMode->_options;
	if(blendOptions != _blendOptions){
		glInsertEventMarkerEXT(0, "Blending mode");
		
		if(blendOptions == CCBLEND_DISABLED_OPTIONS){
			if(_blendOptions != CCBLEND_DISABLED_OPTIONS) glDisable(GL_BLEND);
		} else {
			if(_blendOptions == nil || _blendOptions == CCBLEND_DISABLED_OPTIONS) glEnable(GL_BLEND);
			
			glBlendFuncSeparate(
				[blendOptions[CCBlendFuncSrcColor] unsignedIntValue],
				[blendOptions[CCBlendFuncDstColor] unsignedIntValue],
				[blendOptions[CCBlendFuncSrcAlpha] unsignedIntValue],
				[blendOptions[CCBlendFuncDstAlpha] unsignedIntValue]
			);
			
			glBlendEquationSeparate(
				[blendOptions[CCBlendEquationColor] unsignedIntValue],
				[blendOptions[CCBlendEquationAlpha] unsignedIntValue]
			);
		}
		
		_blendOptions = blendOptions;
	}
	
	// Bind the shader.
	CCShader *shader = renderState->_shader;
	if(shader != _shader){
		glInsertEventMarkerEXT(0, "Shader");
		
		glUseProgram(shader->_program);
		
		_shader = shader;
		_shaderUniforms = nil;
	}
	
	// Set the shader's uniform state.
	NSDictionary *shaderUniforms = renderState->_shaderUniforms;
	NSDictionary *globalShaderUniforms = _globalShaderUniforms;
	if(shaderUniforms != _shaderUniforms){
		glInsertEventMarkerEXT(0, "Uniforms");
		
		NSDictionary *setters = shader->_uniformSetters;
		for(NSString *uniformName in setters){
			CCUniformSetter setter = setters[uniformName];
			setter(self, shaderUniforms, globalShaderUniforms);
		}
		_shaderUniforms = shaderUniforms;
	}
	
	CC_CHECK_GL_ERROR_DEBUG();
	glPopGroupMarkerEXT();
	
	_renderState = renderState;
	return;
}

@end
