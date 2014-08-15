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

@implementation CCMetalContext {
	@public
	id<MTLRenderPipelineState> _tempPiplelineState;
}

-(instancetype)init
{
	if((self = [super init])){
		_device = MTLCreateSystemDefaultDevice();
		_library = [_device newDefaultLibrary];
		
		_commandQueue = [_device newCommandQueue];
		_currentCommandBuffer = [_commandQueue commandBuffer];
		
		#warning Temporary
    id <MTLFunction> vertexProgram = [_library newFunctionWithName:@"CCVertexFunctionDefault"];
    id <MTLFunction> fragmentProgram = [_library newFunctionWithName:@"CCFragmentFunctionDefaultColor"];
		
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    [pipelineStateDescriptor setSampleCount: 1];
    [pipelineStateDescriptor setVertexFunction:vertexProgram];
    [pipelineStateDescriptor setFragmentFunction:fragmentProgram];
    
    MTLRenderPipelineColorAttachmentDescriptor *colorDescriptor = [MTLRenderPipelineColorAttachmentDescriptor new];
    colorDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
		colorDescriptor.blendingEnabled = NO;
		pipelineStateDescriptor.colorAttachments[0] = colorDescriptor;
		
    _tempPiplelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
	}
	
	return self;
}

NSString *CURRENT_CONTEXT_KEY = @"CURRENT_CONTEXT_KEY";

+(instancetype)currentContext
{
	return [NSThread currentThread].threadDictionary[CURRENT_CONTEXT_KEY];
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
		_buffer = [[CCMetalContext currentContext].device newBufferWithLength:capacity*elementSize options:MTLResourceOptionCPUCacheModeDefault];
		
		_ptr = _buffer.contents;
	}
	
	return self;
}

-(void)destroy {}

-(void)resize:(size_t)newCapacity;
{
	id<MTLBuffer> newBuffer = [[CCMetalContext currentContext].device newBufferWithLength:newCapacity*_elementSize options:MTLResourceOptionCPUCacheModeDefault];
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
	id<MTLRenderCommandEncoder> renderEncoder = [CCMetalContext currentContext].currentRenderCommandEncoder;
	
	CCMTL_DEBUG_INSERT_EVENT_MARKER(renderEncoder, @"CCGraphicsBufferBindingsMetal: Bind vertex array.");
	[renderEncoder setVertexBuffer:_vertexBuffer->_buffer offset:0 atIndex:0];
}

@end


@implementation CCRenderCommandDrawMetal

static const MTLPrimitiveType MetalDrawModes[] = {
	MTLPrimitiveTypeTriangle,
	MTLPrimitiveTypeLine,
};

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	CCMetalContext *context = [CCMetalContext currentContext];
	id<MTLRenderCommandEncoder> renderEncoder = context.currentRenderCommandEncoder;
	id<MTLBuffer> indexBuffer = ((CCGraphicsBufferMetal *)renderer->_elementBuffer)->_buffer;
	
	CCMTL_DEBUG_PUSH_GROUP_MARKER(renderEncoder, @"CCRendererCommandDraw: Invoke");
	[renderer bindBuffers:YES];
//	[renderer setRenderState:_renderState];
	[renderEncoder setRenderPipelineState:context->_tempPiplelineState];
	[renderEncoder drawIndexedPrimitives:MetalDrawModes[_mode] indexCount:_count indexType:MTLIndexTypeUInt16 indexBuffer:indexBuffer indexBufferOffset:2*_first];
	CCMTL_DEBUG_POP_GROUP_MARKER(renderEncoder);
}

@end

#else

// Temporary
#warning Metal disabled

#endif
