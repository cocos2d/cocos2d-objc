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

// TODO These should be made private to the module.
extern id CCBLENDMODE_CACHE;
extern id CCRENDERSTATE_CACHE;

/// Options dictionary for the disabled blending mode.
extern NSDictionary *CCBLEND_DISABLED_OPTIONS;


/// Internal type used to abstract GPU buffers. (vertex, index buffers, etc)
typedef struct CCGraphicsBuffer {
	/// Elements currently in the buffer.
	size_t count;
	/// Element capacity of the buffer.
	size_t capacity;
	/// Size in bytes of elements in the buffer.
	size_t elementSize;
	
	/// Pointer to the buffer memory.
	void *ptr;
	
	/// Used to store GL VBO name for now.
	intptr_t data;
	/// GL_ARRAY_BUFFER, GL_ELEMENT_ARRAY_BUFFER, etc.
	intptr_t type;
} CCGraphicsBuffer;


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
	@private
	CCTexture *_mainTexture;
	BOOL _immutable;
	
	@public
	CCBlendMode *_blendMode;
	CCShader *_shader;
	NSDictionary *_shaderUniforms;
}

@end


@interface CCRenderCommandDraw : NSObject<CCRenderCommand> {
	@public
	GLenum _mode;
	CCRenderState *_renderState;
	NSInteger _globalSortOrder;
}

@property(nonatomic, readonly) GLint first;
@property(nonatomic, readonly) GLsizei elements;

-(instancetype)initWithMode:(GLenum)mode renderState:(CCRenderState *)renderState first:(GLint)first elements:(GLsizei)elements globalSortOrder:(NSInteger)globalSortOrder;

-(void)batchElements:(GLsizei)elements;

@end


@interface CCRenderer(){
	GLuint _vao;
	CCGraphicsBuffer _vertexBuffer;
	CCGraphicsBuffer _elementBuffer;
	
	NSDictionary *_globalShaderUniforms;
	
	NSMutableArray *_queue;
	NSMutableArray *_queueStack;
	
	// Current renderer bindings for fast state checking.
	// Invalidated at the end of each frame.
	__unsafe_unretained CCRenderState *_renderState;
	__unsafe_unretained NSDictionary *_blendOptions;
	__unsafe_unretained CCShader *_shader;
	__unsafe_unretained NSDictionary *_shaderUniforms;
	__unsafe_unretained CCRenderCommandDraw *_lastDrawCommand;
	BOOL _vaoBound;
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

/// Bind the renderer's VAO if it is not currently bound.
-(void)bindVAO:(BOOL)bind;

/// Resize the capacity of a graphics buffer.
-(void)resizeBuffer:(struct CCGraphicsBuffer *)buffer capacity:(size_t)capacity;

@end


@interface CCRenderer(NoARCPrivate)

-(void)setRenderState:(CCRenderState *)renderState;

@end


/// Return a pointer to an array of elements that is 'requestedCount' in size.
/// The buffer is resized by calling [CCRenderer resizeBuffer:] if necessary.
static inline void *
CCGraphicsBufferPushElements(CCGraphicsBuffer *buffer, size_t requestedCount, CCRenderer *renderer)
{
	NSCAssert(requestedCount > 0, @"Requested count must be positive.");
	
	size_t required = buffer->count + requestedCount;
	size_t capacity = buffer->capacity;
	if(required > capacity){
		// Why 1.5? https://github.com/facebook/folly/blob/master/folly/docs/FBVector.md
		[renderer resizeBuffer:buffer capacity:required*1.5];
	}
	
	void *array = buffer->ptr + buffer->count*buffer->elementSize;
	buffer->count += requestedCount;
	
	return array;
}

