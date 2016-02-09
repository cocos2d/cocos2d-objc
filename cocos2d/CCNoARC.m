#import "CCTexture_Private.h"
#import "CCNode_Private.h"
#import "CCSprite_Private.h"
#import "CCRenderer_Private.h"
#import "CCShader_Private.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import "CCMetalSupport_Private.h"
#endif

// -----------------------------------------------------------------
// NOTE !
// If you get performance problems, due to high CPU loads, setting this flag might unload the CPU a little bit
// If you set the flag, you have to go into "Build Phases" + "Compile Sources" in your target,
// - and add the compiler flag -fno-objc-arc, to this file
#define NO_ARC 0
// -----------------------------------------------------------------

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
#if CC_EFFECTS
	if (_effect)
	{
		_effectRenderer.contentSize = self.contentSizeInPoints;
        
        CCEffectPrepareResult prepResult = [self.effect prepareForRenderingWithSprite:self];
        NSAssert(prepResult.status == CCEffectPrepareSuccess, @"Effect preparation failed.");
        
        if (prepResult.changes & CCEffectPrepareUniformsChanged)
		{
			// Preparing an effect for rendering can modify its uniforms
			// dictionary which means we need to reinitialize our copy of the
			// uniforms.
			[self updateShaderUniformsFromEffect];
		}
		[_effectRenderer drawSprite:self withEffect:self.effect uniforms:_shaderUniforms renderer:renderer transform:transform];
	}
	else
#endif
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

// Positive offset of the vertex allocation to prevent overlapping a boundary.
static inline NSUInteger
PageOffset(NSUInteger firstVertex, NSUInteger vertexCount)
{
	NSCAssert(vertexCount < UINT16_MAX + 1, @"Too many vertexes for a single draw count.");
	
	// Space remaining on the current vertex page.
	NSUInteger remain = (firstVertex | UINT16_MAX) - firstVertex + 1;
	
	if(remain >= vertexCount){
		// Allocation will not overlap a page boundary. 
		return 0;
	} else {
		return remain;
	}
}

-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
{
	// Need to record the first vertex or element index before pushing more vertexes.
	NSUInteger firstVertex = _buffers->_vertexBuffer->_count;
	NSUInteger firstIndex = _buffers->_indexBuffer->_count;
	
	// Value is 0 unless there a page boundary overlap would occur.
	NSUInteger vertexPageOffset = PageOffset(firstVertex, vertexCount);
	
	// Split vertexes into pages of 2^16 vertexes since GLES2 requires indexing with shorts.
	NSUInteger vertexPage = (firstVertex + vertexPageOffset) >> 16;
	NSUInteger vertexPageIndex = (firstVertex + vertexPageOffset) & 0xFFFF;
	
	// Ensure that the buffers have enough storage space.
	NSUInteger indexCount = 3*triangleCount;
	CCVertex *vertexes = CCGraphicsBufferPushElements(_buffers->_vertexBuffer, vertexCount + vertexPageOffset);
	uint16_t *elements = CCGraphicsBufferPushElements(_buffers->_indexBuffer, indexCount);
	
	CCRenderCommandDraw *previous = _lastDrawCommand;
	if(previous && previous->_renderState == renderState && previous->_globalSortOrder == globalSortOrder && previous->_vertexPage == vertexPage){
		// Batch with the previous command.
		[previous batch:indexCount];
	} else {
		// Start a new command.
		CCRenderCommandDraw *command = [[CCRenderCommandDrawClass alloc] initWithMode:CCRenderCommandDrawTriangles renderState:renderState firstIndex:firstIndex vertexPage:vertexPage count:indexCount globalSortOrder:globalSortOrder];
		[_queue addObject:command];
#if NO_ARC != 0
		[command release];
#endif
		_lastDrawCommand = command;
	}
	
	return (CCRenderBuffer){vertexes, elements, vertexPageIndex};
}

-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
{
	// Need to record the first vertex or element index before pushing more vertexes.
	NSUInteger firstVertex = _buffers->_vertexBuffer->_count;
	NSUInteger firstIndex = _buffers->_indexBuffer->_count;
	
	// Value is 0 unless a page boundary overlap would occur.
	NSUInteger vertexPageOffset = PageOffset(firstVertex, vertexCount);
	
	// Split vertexes into pages of 2^16 vertexes since GLES2 requires indexing with shorts.
	NSUInteger vertexPage = (firstVertex + vertexPageOffset) >> 16;
	NSUInteger vertexPageIndex = (firstVertex + vertexPageOffset) & 0xFFFF;
	
	// Ensure that the buffers have enough storage space.
	NSUInteger indexCount = 2*lineCount;
	CCVertex *vertexes = CCGraphicsBufferPushElements(_buffers->_vertexBuffer, vertexCount + vertexPageOffset);
	uint16_t *elements = CCGraphicsBufferPushElements(_buffers->_indexBuffer, indexCount);
	
	CCRenderCommandDraw *command = [[CCRenderCommandDrawClass alloc] initWithMode:CCRenderCommandDrawLines renderState:renderState firstIndex:firstIndex vertexPage:vertexPage count:indexCount globalSortOrder:globalSortOrder];
	[_queue addObject:command];
#if NO_ARC != 0
	[command release];
#endif
	// Line drawing commands are currently intended for debugging and cannot be batched.
	_lastDrawCommand = nil;
	
	return(CCRenderBuffer){vertexes, elements, vertexPageIndex};
}

static inline void
CCRendererBindBuffers(CCRenderer *self, BOOL bind, NSUInteger vertexPage)
{
 	if(bind != self->_buffersBound || vertexPage != self->_vertexPageBound){
		[self->_buffers bind:bind vertexPage:vertexPage];
		self->_buffersBound = bind;
		self->_vertexPageBound = vertexPage;
	}
}

-(void)bindBuffers:(BOOL)bind vertexPage:(NSUInteger)vertexPage
{
	CCRendererBindBuffers(self, bind, vertexPage);
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
	BOOL bindShader = (previous == nil || self->_shader != previous->_shader);
	if(bindShader){
		CCGL_DEBUG_INSERT_EVENT_MARKER("Shader");
		
		glUseProgram(self->_shader->_program);
	}
	
	// Set the shader's uniform state.
	if(bindShader || self->_shaderUniforms != previous->_shaderUniforms){
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
	
	CCRendererBindBuffers(renderer, YES, _vertexPage);
	CCRenderStateGLTransition((CCRenderStateGL *)_renderState, renderer, (CCRenderStateGL *)renderer->_renderState);
	renderer->_renderState = _renderState;
	
	glDrawElements(GLDrawModes[_mode], (GLsizei)_count, GL_UNSIGNED_SHORT, (GLvoid *)(_firstIndex*sizeof(GLushort)));
	CC_INCREMENT_GL_DRAWS(1);
	
	CCGL_DEBUG_POP_GROUP_MARKER();
}

@end


#if __CC_METAL_SUPPORTED_AND_ENABLED

@interface CCRenderStateMetal : CCRenderState @end
@implementation CCRenderStateMetal {
	id<MTLRenderPipelineState> _renderPipelineState;
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
		// TODO Should get this from the renderer somehow?
		CCMetalContext *context = [CCMetalContext currentContext];
		
		MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
		pipelineStateDescriptor.sampleCount = 1;
		
		pipelineStateDescriptor.vertexFunction = self->_shader->_vertexFunction;
		pipelineStateDescriptor.fragmentFunction = self->_shader->_fragmentFunction;
		
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
		
		NSError *err = nil;
		self->_renderPipelineState = [context.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&err];
		
		if(err) CCLOG(@"Error creating metal render pipeline state. %@", err);
		NSCAssert(self->_renderPipelineState, @"Could not create render pipeline state.");
	}
}

static void
CCRenderStateMetalTransition(CCRenderStateMetal *self, CCRenderer *renderer, CCRenderStateMetal *previous)
{
	CCGraphicsBufferBindingsMetal *buffers = (CCGraphicsBufferBindingsMetal *)renderer->_buffers;
	CCMetalContext *context = buffers->_context;
	id<MTLRenderCommandEncoder> renderEncoder = context->_currentRenderCommandEncoder;
	
	// Bind pipeline state.
	[renderEncoder setRenderPipelineState:self->_renderPipelineState];
	
	// Set shader arguments.
	NSDictionary *globalShaderUniforms = renderer->_globalShaderUniforms;
	NSDictionary *setters = self->_shader->_uniformSetters;
	for(NSString *uniformName in setters){
		CCUniformSetter setter = setters[uniformName];
		setter(renderer, self->_shaderUniforms, globalShaderUniforms);
	}
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

-(instancetype)initWithMode:(CCRenderCommandDrawMode)mode renderState:(CCRenderState *)renderState firstIndex:(NSUInteger)firstIndex vertexPage:(NSUInteger)vertexPage count:(size_t)count globalSortOrder:(NSInteger)globalSortOrder;
{
	if((self = [super initWithMode:mode renderState:renderState firstIndex:firstIndex vertexPage:vertexPage count:count globalSortOrder:globalSortOrder])){
		// The renderer may have copied the render state, use the ivar.
		CCRenderStateMetalPrepare((CCRenderStateMetal *)_renderState);
	}
	
	return self;
}

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	CCGraphicsBufferBindingsMetal *buffers = (CCGraphicsBufferBindingsMetal *)renderer->_buffers;
	CCMetalContext *context = buffers->_context;
	id<MTLRenderCommandEncoder> renderEncoder = context->_currentRenderCommandEncoder;
	id<MTLBuffer> indexBuffer = ((CCGraphicsBufferMetal *)buffers->_indexBuffer)->_buffer;
	
	CCMTL_DEBUG_PUSH_GROUP_MARKER(renderEncoder, @"CCRendererCommandDraw: Invoke");
	CCRendererBindBuffers(renderer, YES, _vertexPage);
	CCRenderStateMetalTransition((CCRenderStateMetal *)_renderState, renderer, (CCRenderStateMetal *)renderer->_renderState);
	renderer->_renderState = _renderState;
	
	[renderEncoder drawIndexedPrimitives:MetalDrawModes[_mode] indexCount:_count indexType:MTLIndexTypeUInt16 indexBuffer:indexBuffer indexBufferOffset:2*_firstIndex];
	CCMTL_DEBUG_POP_GROUP_MARKER(renderEncoder);
	
	CC_INCREMENT_GL_DRAWS(1);
}

@end

#endif
