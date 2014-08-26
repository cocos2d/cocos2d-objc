#import "CCTexture_Private.h"
#import "CCNode_Private.h"
#import "CCSprite_Private.h"
#import "CCRenderer_Private.h"
#import "CCShader_Private.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import "CCMetalSupport_Private.h"
#endif


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
		_effectRenderer.contentSize = self.contentSize;
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
	NSUInteger firstVertex = _vertexBuffer->_count;
	NSUInteger firstElement = _elementBuffer->_count;
	
	NSUInteger elementCount = 3*triangleCount;
	CCVertex *vertexes = CCGraphicsBufferPushElements(_vertexBuffer, vertexCount, self);
	uint16_t *elements = CCGraphicsBufferPushElements(_elementBuffer, elementCount, self);
	
	CCRenderCommandDraw *previous = _lastDrawCommand;
	if(previous && previous->_renderState == renderState && previous->_globalSortOrder == globalSortOrder){
		// Batch with the previous command.
		[previous batch:elementCount];
	} else {
		// Start a new command.
		CCRenderCommandDraw *command = [[CCRenderCommandDrawClass alloc] initWithMode:CCRenderCommandDrawTriangles renderState:renderState first:firstElement count:elementCount globalSortOrder:globalSortOrder];
		[_queue addObject:command];
		[command release];
		
		_lastDrawCommand = command;
	}
	
	return (CCRenderBuffer){vertexes, elements, firstVertex};
}

-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
{
	// Need to record the first vertex or element index before pushing more vertexes.
	NSUInteger firstVertex = _vertexBuffer->_count;
	NSUInteger firstElement = _elementBuffer->_count;
	
	NSUInteger elementCount = 2*lineCount;
	CCVertex *vertexes = CCGraphicsBufferPushElements(_vertexBuffer, vertexCount, self);
	uint16_t *elements = CCGraphicsBufferPushElements(_elementBuffer, elementCount, self);
	
	CCRenderCommandDraw *command = [[CCRenderCommandDrawClass alloc] initWithMode:CCRenderCommandDrawLines renderState:renderState first:firstElement count:elementCount globalSortOrder:globalSortOrder];
	[_queue addObject:command];
	[command release];
	
	// Line drawing commands are currently intended for debugging and cannot be batched.
	_lastDrawCommand = nil;
	
	return(CCRenderBuffer){vertexes, elements, firstVertex};
}

static inline void
CCRendererBindBuffers(CCRenderer *self, BOOL bind)
{
 	if(bind != self->_buffersBound){
		[self->_bufferBindings bind:bind];
		self->_buffersBound = bind;
	}
}

-(void)bindBuffers:(BOOL)bind
{
	CCRendererBindBuffers(self, bind);
}


-(void)setRenderState:(CCRenderState *)renderState
{
	if(renderState != _renderState){
		[renderState transitionRenderer:self FromState:_renderState];
		_renderState = renderState;
	}
}

@end

@interface CCRenderStateGL : CCRenderState @end
@implementation CCRenderStateGL

static void
CCRenderStateGLTransition(CCRenderStateGL *self, CCRenderer *renderer, CCRenderStateGL *previous)
{
	CCGL_DEBUG_PUSH_GROUP_MARKER("CCRenderStateGL: Transition");
	
	// Set the blending state.
	if(previous ==  nil || self->_blendMode != previous->_blendMode){
		CCGL_DEBUG_INSERT_EVENT_MARKER("Blending mode");
		
		NSDictionary *blendOptions = self->_blendMode->_options;
		if(blendOptions == CCBLEND_DISABLED_OPTIONS){
			glDisable(GL_BLEND);
		} else {
			glEnable(GL_BLEND);
			
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
	}
	
	// Bind the shader.
	if(previous == nil || self->_shader != previous->_shader){
		CCGL_DEBUG_INSERT_EVENT_MARKER("Shader");
		
		glUseProgram(self->_shader->_program);
	}
	
	// Set the shader's uniform state.
	if(previous == nil || self->_shaderUniforms != previous->_shaderUniforms){
		CCGL_DEBUG_INSERT_EVENT_MARKER("Uniforms");
		
		NSDictionary *globalShaderUniforms = renderer->_globalShaderUniforms;
		NSDictionary *setters = self->_shader->_uniformSetters;
		for(NSString *uniformName in setters){
			CCUniformSetter setter = setters[uniformName];
			setter(renderer, self->_shaderUniforms, globalShaderUniforms);
		}
	}
	
	CCGL_DEBUG_POP_GROUP_MARKER();
	CC_CHECK_GL_ERROR_DEBUG();
}

-(void)transitionRenderer:(CCRenderer *)renderer FromState:(CCRenderStateGL *)previous
{
	CCRenderStateGLTransition(self, renderer, previous);
}

@end

@interface CCRenderCommandDrawGL : CCRenderCommandDraw @end
@implementation CCRenderCommandDrawGL

static const CCRenderCommandDrawMode GLDrawModes[] = {
	GL_TRIANGLES,
	GL_LINES,
};

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	CCGL_DEBUG_PUSH_GROUP_MARKER("CCRendererCommandDraw: Invoke");
	
	CCRendererBindBuffers(renderer, YES);
	CCRenderStateGLTransition((CCRenderStateGL *)_renderState, renderer, (CCRenderStateGL *)renderer->_renderState);
	renderer->_renderState = _renderState;
	
	glDrawElements(GLDrawModes[_mode], (GLsizei)_count, GL_UNSIGNED_SHORT, (GLvoid *)(_first*sizeof(GLushort)));
	CC_INCREMENT_GL_DRAWS(1);
	
	CCGL_DEBUG_POP_GROUP_MARKER();
}

@end


#if __CC_METAL_SUPPORTED_AND_ENABLED

// This is effectively hardcoded to 10 by Apple's docs and there is no API to query capabilities...
// Seems like an oversight, but whatever.
#define CCMTL_MAX_TEXTURES 10


@interface CCRenderStateMetal : CCRenderState @end
@implementation CCRenderStateMetal {
	id<MTLRenderPipelineState> _renderPipelineState;
	
	NSRange _textureRange;
	id<MTLSamplerState> _samplers[CCMTL_MAX_TEXTURES];
	id<MTLTexture> _textures[CCMTL_MAX_TEXTURES];
	
	@public
	BOOL _uniformsPrepared;
}

// Using GL enums for CCBlendMode types should never have happened. Oops.
static NSUInteger
GLBLEND_TO_METAL(NSNumber *glenum)
{
	switch(glenum.unsignedIntValue){
		case GL_ZERO: return MTLBlendFactorZero;
		case GL_ONE: return MTLBlendFactorOne;
		case GL_SRC_COLOR: return MTLBlendFactorSourceColor;
		case GL_ONE_MINUS_SRC_COLOR: return MTLBlendFactorOneMinusSourceColor;
		case GL_SRC_ALPHA: return MTLBlendFactorSourceAlpha;
		case GL_ONE_MINUS_SRC_ALPHA: return MTLBlendFactorOneMinusSourceAlpha;
		case GL_DST_COLOR: return MTLBlendFactorDestinationColor;
		case GL_ONE_MINUS_DST_COLOR: return MTLBlendFactorOneMinusDestinationColor;
		case GL_DST_ALPHA: return MTLBlendFactorDestinationAlpha;
		case GL_ONE_MINUS_DST_ALPHA: return MTLBlendFactorOneMinusDestinationAlpha;
		case GL_FUNC_ADD: return MTLBlendOperationAdd;
		case GL_FUNC_SUBTRACT: return MTLBlendOperationSubtract;
		case GL_FUNC_REVERSE_SUBTRACT: return MTLBlendOperationReverseSubtract;
		case GL_MIN_EXT: return MTLBlendOperationMin;
		case GL_MAX_EXT: return MTLBlendOperationMax;
		default:
			NSCAssert(NO, @"Bad enumeration detected in a CCBlendMode. 0x%X", glenum.unsignedIntValue);
			return 0;
	}
}

static void
CCRenderStateMetalPrepare(CCRenderStateMetal *self)
{
	if(self->_renderPipelineState == nil){
		#warning Should get this from the renderer somehow.
		CCMetalContext *context = [CCMetalContext currentContext];
		
		MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
		pipelineStateDescriptor.sampleCount = 1;
		
		id<MTLLibrary> library = context.library;
		#warning TEMP Hard coded shaders.
		pipelineStateDescriptor.vertexFunction = [library newFunctionWithName:@"CCVertexFunctionDefault"];
		if(self->_shader == [CCShader positionColorShader]){
	    pipelineStateDescriptor.fragmentFunction = [library newFunctionWithName:@"CCFragmentFunctionDefaultColor"];
		} else if(self->_shader == [CCShader positionTextureColorShader]){
	    pipelineStateDescriptor.fragmentFunction = [library newFunctionWithName:@"CCFragmentFunctionDefaultTextureColor"];
		} else if(self->_shader == [CCShader positionTextureA8ColorShader]){
	    pipelineStateDescriptor.fragmentFunction = [library newFunctionWithName:@"CCFragmentFunctionDefaultTextureA8Color"];
		} else {
	    pipelineStateDescriptor.fragmentFunction = [library newFunctionWithName:@"TempUnsupported"];
		}
		
		NSDictionary *blendOptions = self->_blendMode.options;
		MTLRenderPipelineColorAttachmentDescriptor *colorDescriptor = [MTLRenderPipelineColorAttachmentDescriptor new];
		colorDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
		colorDescriptor.blendingEnabled = (blendOptions != CCBLEND_DISABLED_OPTIONS);
		colorDescriptor.sourceRGBBlendFactor = GLBLEND_TO_METAL(blendOptions[CCBlendFuncSrcColor]);
		colorDescriptor.sourceAlphaBlendFactor = GLBLEND_TO_METAL(blendOptions[CCBlendFuncSrcAlpha]);
		colorDescriptor.destinationRGBBlendFactor = GLBLEND_TO_METAL(blendOptions[CCBlendFuncDstColor]);
		colorDescriptor.destinationAlphaBlendFactor = GLBLEND_TO_METAL(blendOptions[CCBlendFuncDstAlpha]);
		colorDescriptor.rgbBlendOperation = GLBLEND_TO_METAL(blendOptions[CCBlendEquationColor]);
		colorDescriptor.alphaBlendOperation = GLBLEND_TO_METAL(blendOptions[CCBlendEquationAlpha]);
		pipelineStateDescriptor.colorAttachments[0] = colorDescriptor;
		
		self->_renderPipelineState = [[context.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil] retain];
	}
	
	if(!self->_uniformsPrepared){
		CCTexture *mainTexture = self->_shaderUniforms[CCShaderUniformMainTexture];
		
		self->_textureRange = NSMakeRange(0, 1);
		self->_samplers[0] = mainTexture.metalSampler;
		self->_textures[0] = mainTexture.metalTexture;
		
		self->_uniformsPrepared = YES;
	}
}

static void
CCRenderStateMetalTransition(CCRenderStateMetal *self, CCRenderer *renderer, CCRenderStateMetal *previous)
{
	CCMetalContext *context = renderer->_context;
	id<MTLRenderCommandEncoder> renderEncoder = context->_currentRenderCommandEncoder;
	[renderEncoder setRenderPipelineState:self->_renderPipelineState];
	
	NSRange range = self->_textureRange;
	[renderEncoder setFragmentSamplerStates:self->_samplers withRange:range];
	[renderEncoder setFragmentTextures:self->_textures withRange:range];
}

-(void)transitionRenderer:(CCRenderer *)renderer FromState:(CCRenderState *)previous
{
	CCRenderStateMetalTransition((CCRenderStateMetal *)self, renderer, (CCRenderStateMetal *)previous);
}

@end

@implementation CCRenderCommandDrawMetal

static const MTLPrimitiveType MetalDrawModes[] = {
	MTLPrimitiveTypeTriangle,
	MTLPrimitiveTypeLine,
};

-(instancetype)initWithMode:(CCRenderCommandDrawMode)mode renderState:(CCRenderState *)renderState first:(NSUInteger)first count:(size_t)count globalSortOrder:(NSInteger)globalSortOrder
{
	if((self = [super initWithMode:mode renderState:renderState first:first count:count globalSortOrder:globalSortOrder])){
		CCRenderStateMetalPrepare((CCRenderStateMetal *)renderState);
	}
	
	return self;
}

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	CCMetalContext *context = renderer->_context;
	id<MTLRenderCommandEncoder> renderEncoder = context->_currentRenderCommandEncoder;
	id<MTLBuffer> indexBuffer = ((CCGraphicsBufferMetal *)renderer->_elementBuffer)->_buffer;
	
	CCMTL_DEBUG_PUSH_GROUP_MARKER(renderEncoder, @"CCRendererCommandDraw: Invoke");
	CCRendererBindBuffers(renderer, YES);
	CCRenderStateMetalTransition((CCRenderStateMetal *)_renderState, renderer, (CCRenderStateMetal *)renderer->_renderState);
	renderer->_renderState = _renderState;
	
	[renderEncoder drawIndexedPrimitives:MetalDrawModes[_mode] indexCount:_count indexType:MTLIndexTypeUInt16 indexBuffer:indexBuffer indexBufferOffset:2*_first];
	CCMTL_DEBUG_POP_GROUP_MARKER(renderEncoder);
	
	if(!_renderState->_immutable){
		// This is sort of a weird place to put this, but couldn't find somewhere better.
		// Mutable render states need to have their uniforms redone at least once per frame.
		// Putting it here ensures that it's been after all render commands for the frame have prepared it.
		((CCRenderStateMetal *)_renderState)->_uniformsPrepared = NO;
	}
	
	CC_INCREMENT_GL_DRAWS(1);
}

@end

#endif
