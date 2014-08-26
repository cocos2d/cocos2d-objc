/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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
 */


#import <Foundation/Foundation.h>
#import "CCRenderer.h"
#import "CCCache.h"
#import "CCRenderDispatch.h"

// TODO These should be made private to the module.
extern id CCBLENDMODE_CACHE;
extern id CCRENDERSTATE_CACHE;

/// Options dictionary for the disabled blending mode.
extern NSDictionary *CCBLEND_DISABLED_OPTIONS;


/**
 * Describes the behaviour for an command object that can be submitted to the queue of a 
 * CCRenderer in order to perform some drawing operations.
 *
 * When submitted to a renderer, render commands can be queued and executed at a later time.
 * Each implementation of CCRenderCommand encapsulates the content to be rendered.
 */
@protocol CCRenderCommand <NSObject>

@property(nonatomic, readonly) NSInteger globalSortOrder;

/**
 * Invokes this command on the specified renderer.
 *
 * When submitted to a renderer, render commands may be queued and executed at a later time.
 * Implementations should expect that this method will not be executed at the time that this
 * command is submitted to the renderer.
 */
-(void)invokeOnRenderer:(CCRenderer *)renderer;

@end


@interface CCBlendMode(){
	@public
	NSDictionary *_options;
}

@end


@interface CCRenderState(){
	@public
	CCTexture *_mainTexture;
	BOOL _immutable;
	CCBlendMode *_blendMode;
	CCShader *_shader;
	NSDictionary *_shaderUniforms;
}

-(void)transitionRenderer:(CCRenderer *)renderer FromState:(CCRenderState *)previous;

@end


typedef NS_ENUM(NSUInteger, CCRenderCommandDrawMode){
	CCRenderCommandDrawTriangles,
	CCRenderCommandDrawLines,
	// TODO more?
};


@interface CCRenderCommandDraw : NSObject<CCRenderCommand> {
	@public
	CCRenderCommandDrawMode _mode;
	CCRenderState *_renderState;
	NSInteger _globalSortOrder;
	
	NSUInteger _first;
	size_t _count;
}

@property(nonatomic, readonly) NSUInteger first;
@property(nonatomic, readonly) size_t count;

-(instancetype)initWithMode:(CCRenderCommandDrawMode)mode renderState:(CCRenderState *)renderState first:(NSUInteger)first count:(size_t)count globalSortOrder:(NSInteger)globalSortOrder;

-(void)batch:(NSUInteger)count;

@end


/// Type of a CCGraphicsBuffer object.
typedef NS_ENUM(NSUInteger, CCGraphicsBufferType){
	CCGraphicsBufferTypeVertex,
	CCGraphicsBufferTypeIndex,
//	CCGraphicsBufferTypeUniform?
};


/// Internal class used to abstract GPU buffers. (vertex, index buffers, etc)
/// This is an abstract class instead of a protocol because of CCGraphicsBufferPushElements().
@interface CCGraphicsBuffer : NSObject{
	@public
	/// Elements currently in the buffer.
	size_t _count;
	/// Element capacity of the buffer.
	size_t _capacity;
	/// Size in bytes of elements in the buffer.
	size_t _elementSize;
	
	/// Pointer to the buffer memory.
	/// Only valid between prepare and commmit method calls.
	void *_ptr;
}

-(instancetype)initWithCapacity:(NSUInteger)capacity elementSize:(size_t)elementSize type:(CCGraphicsBufferType)type;
-(void)resize:(size_t)newCapacity;

-(void)destroy;

-(void)prepare;
-(void)commit;

@end


/// Return a pointer to an array of elements that is 'requestedCount' in size.
/// The buffer is resized by calling [CCGraphicsBuffer resize:] if necessary.
static inline void *
CCGraphicsBufferPushElements(CCGraphicsBuffer *buffer, size_t requestedCount, CCRenderer *renderer)
{
	NSCAssert(requestedCount > 0, @"Requested count must be positive.");
	
	size_t required = buffer->_count + requestedCount;
	size_t capacity = buffer->_capacity;
	if(required > capacity){
		// Why 1.5? https://github.com/facebook/folly/blob/master/folly/docs/FBVector.md
		CCRenderDispatch(NO, ^{[buffer resize:required*1.5];});
	}
	
	void *array = buffer->_ptr + buffer->_count*buffer->_elementSize;
	buffer->_count += requestedCount;
	
	return array;
}


/// Internal abstract class used to wrap vertex buffer state. (GL VAOs, etc)
@protocol CCGraphicsBufferBindings
-(instancetype)initWithVertexBuffer:(CCGraphicsBuffer *)vertexBuffer indexBuffer:(CCGraphicsBuffer *)indexBuffer;
-(void)bind:(BOOL)bind;
@end


@interface CCRenderer(){
	@public
	CCGraphicsBuffer *_vertexBuffer;
	CCGraphicsBuffer *_elementBuffer;
	id<CCGraphicsBufferBindings> _bufferBindings;
	
	NSDictionary *_globalShaderUniforms;
	
	NSMutableArray *_queue;
	NSMutableArray *_queueStack;
	
	// Current renderer bindings for fast state checking.
	// Invalidated at the end of each frame.
	__unsafe_unretained CCRenderState *_renderState;
	__unsafe_unretained CCRenderCommandDraw *_lastDrawCommand;
	BOOL _buffersBound;
	
	// Currently used for associating a metal context with a given renderer.
	id _context;
}

/// Current global shader uniform values.
@property(nonatomic, copy) NSDictionary *globalShaderUniforms;

/// Retrieve the current renderer for the current thread.
+(instancetype)currentRenderer;

/// Set the current renderer for the current thread.
+(void)bindRenderer:(CCRenderer *)renderer;

/// Enqueue a general or custom render command.
-(void)enqueueRenderCommand: (id<CCRenderCommand>) renderCommand;

/// Render any currently queued commands.
-(void)flush;

@end


@interface CCRenderer(NoARCPrivate)

-(void)setRenderState:(CCRenderState *)renderState;

/// Bind the renderer's VAO if it is not currently bound.
-(void)bindBuffers:(BOOL)bind;

@end
