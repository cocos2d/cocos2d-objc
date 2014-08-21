/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCMetalSupport_Private.h"
#if __CC_METAL_SUPPORTED_AND_ENABLED

#import "CCTexture_Private.h"

@implementation CCMetalContext

-(instancetype)init
{
	if((self = [super init])){
		_device = MTLCreateSystemDefaultDevice();
		_library = [_device newDefaultLibrary];
		
		_commandQueue = [_device newCommandQueue];
		_currentCommandBuffer = [_commandQueue commandBuffer];
	}
	
	return self;
}

NSString *CURRENT_CONTEXT_KEY = @"CURRENT_CONTEXT_KEY";

#warning TODO
// This uses a pretty measurable piece of CPU time.
// Access through the CCRenderer when possible somehow?
static inline CCMetalContext *
CCMetalContextCurrent(void)
{
	return [NSThread currentThread].threadDictionary[CURRENT_CONTEXT_KEY];
}

+(instancetype)currentContext
{
	return CCMetalContextCurrent();
}

+(void)setCurrentContext:(CCMetalContext *)context
{
	if(context){
		[NSThread currentThread].threadDictionary[CURRENT_CONTEXT_KEY] = context;
	} else {
		[[NSThread currentThread].threadDictionary removeObjectForKey:CURRENT_CONTEXT_KEY];
	}
}

-(void)setDestinationTexture:(id<MTLTexture>)destinationTexture
{
	if(_destinationTexture != destinationTexture){
		MTLRenderPassColorAttachmentDescriptor *colorAttachment = [MTLRenderPassColorAttachmentDescriptor new];
		colorAttachment.texture = destinationTexture;
		colorAttachment.loadAction = MTLLoadActionClear;
		colorAttachment.clearColor = MTLClearColorMake(0, 0, 0, 0);
		colorAttachment.storeAction = MTLStoreActionStore;

		MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
		renderPassDescriptor.colorAttachments[0] = colorAttachment;

		_currentRenderCommandEncoder = [self.currentCommandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		_destinationTexture = destinationTexture;
	}
}

-(void)prepareCommandBuffer
{
	_currentCommandBuffer = [_commandQueue commandBuffer];
	_currentCommandBuffer.label = @"Main Cocos2D Command Buffer";
}

-(void)commitCurrentCommandBuffer
{
	[_currentRenderCommandEncoder endEncoding];
	
	[_currentCommandBuffer commit];
	_currentCommandBuffer = nil;
}

@end


@implementation CCGraphicsBufferMetal {
	@public
	id<MTLBuffer> _buffer;
}

-(instancetype)initWithCapacity:(NSUInteger)capacity elementSize:(size_t)elementSize type:(CCGraphicsBufferType)type;
{
	if((self = [super initWithCapacity:capacity elementSize:elementSize type:type])){
		// Use write combining? Buffers are already write only for the GL renderer.
		_buffer = [CCMetalContextCurrent().device newBufferWithLength:capacity*elementSize options:MTLResourceOptionCPUCacheModeDefault];
		
		_ptr = _buffer.contents;
	}
	
	return self;
}

-(void)destroy {}

-(void)resize:(size_t)newCapacity;
{
	id<MTLBuffer> newBuffer = [CCMetalContextCurrent().device newBufferWithLength:newCapacity*_elementSize options:MTLResourceOptionCPUCacheModeDefault];
	memcpy(newBuffer.contents, _ptr, _capacity*_elementSize);
	
	_capacity = newCapacity;
	_buffer = newBuffer;
	_ptr = _buffer.contents;
}

-(void)prepare;
{
	_count = 0;
}

-(void)commit; {}

@end


@interface CCGraphicsBufferBindingsMetal : NSObject <CCGraphicsBufferBindings> @end
@implementation CCGraphicsBufferBindingsMetal {
	CCGraphicsBufferMetal *_vertexBuffer;
	CCGraphicsBufferMetal *_indexBuffer;
}

-(instancetype)initWithVertexBuffer:(CCGraphicsBufferMetal *)vertexBuffer indexBuffer:(CCGraphicsBufferMetal *)indexBuffer
{
	if((self = [super init])){
		_vertexBuffer = vertexBuffer;
		_indexBuffer = indexBuffer;
	}
	
	return self;
}

-(void)bind:(BOOL)bind
{
	id<MTLRenderCommandEncoder> renderEncoder = CCMetalContextCurrent().currentRenderCommandEncoder;
	
	CCMTL_DEBUG_INSERT_EVENT_MARKER(renderEncoder, @"CCGraphicsBufferBindingsMetal: Bind vertex array.");
	[renderEncoder setVertexBuffer:_vertexBuffer->_buffer offset:0 atIndex:0];
}

@end


// This is effectively hardcoded to 10 by Apple's docs and there is no API to query capabilities...
// Seems like an oversight, but whatever.
#define CCMTL_MAX_TEXTURES 10


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

-(void)prepare
{
	if(_renderPipelineState == nil){
		CCMetalContext *context = CCMetalContextCurrent();
		
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.sampleCount = 1;
		
		id<MTLLibrary> library = context.library;
		#warning TEMP Hard coded shaders.
		pipelineStateDescriptor.vertexFunction = [library newFunctionWithName:@"CCVertexFunctionDefault"];
    pipelineStateDescriptor.fragmentFunction = [library newFunctionWithName:@"CCFragmentFunctionDefaultTextureColor"];
    
		NSDictionary *blendOptions = _blendMode.options;
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
		
    _renderPipelineState = [context.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
	}
}

-(void)transitionRenderer:(CCRenderer *)renderer FromState:(CCRenderState *)previous
{
	id<MTLRenderCommandEncoder> renderEncoder = CCMetalContextCurrent().currentRenderCommandEncoder;
	[renderEncoder setRenderPipelineState:_renderPipelineState];
	
	CCTexture *mainTexture = _shaderUniforms[CCShaderUniformMainTexture];
	[renderEncoder setFragmentSamplerState:mainTexture.metalSampler atIndex:0];
	[renderEncoder setFragmentTexture:mainTexture.metalTexture atIndex:0];
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
		[(CCRenderStateMetal *)_renderState prepare];
	}
	
	return self;
}

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	CCMetalContext *context = CCMetalContextCurrent();
	id<MTLRenderCommandEncoder> renderEncoder = context.currentRenderCommandEncoder;
	id<MTLBuffer> indexBuffer = ((CCGraphicsBufferMetal *)renderer->_elementBuffer)->_buffer;
	
	CCMTL_DEBUG_PUSH_GROUP_MARKER(renderEncoder, @"CCRendererCommandDraw: Invoke");
	[renderer bindBuffers:YES];
	[renderer setRenderState:_renderState];
	[renderEncoder drawIndexedPrimitives:MetalDrawModes[_mode] indexCount:_count indexType:MTLIndexTypeUInt16 indexBuffer:indexBuffer indexBufferOffset:2*_first];
	CCMTL_DEBUG_POP_GROUP_MARKER(renderEncoder);
	
	CC_INCREMENT_GL_DRAWS(1);
}

@end

#else

// Temporary
#warning Metal disabled

#endif
