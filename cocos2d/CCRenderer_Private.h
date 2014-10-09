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
#import "CCRendererBasicTypes_Private.h"

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

/// Remove unused blend modes from the internal cache.
+(void)flushCache;

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
	
	NSUInteger _firstIndex, _vertexPage;
	size_t _count;
}

@property(nonatomic, readonly) NSUInteger first;
@property(nonatomic, readonly) size_t count;

-(instancetype)initWithMode:(CCRenderCommandDrawMode)mode renderState:(CCRenderState *)renderState firstIndex:(NSUInteger)firstIndex vertexPage:(NSUInteger)vertexPage count:(size_t)count globalSortOrder:(NSInteger)globalSortOrder;

-(void)batch:(NSUInteger)count;

@end


@interface CCRenderer(){
	@public
	CCGraphicsBufferBindings *_buffers;
	
	CCFrameBufferObject *_framebuffer;
	
	NSDictionary *_globalShaderUniforms;
	NSDictionary *_globalShaderUniformBufferOffsets;
	
	NSMutableArray *_queue;
	NSMutableArray *_queueStack;
	
	// Handle clearing specially if it's the very first command.
	GLbitfield _clearMask;
	GLKVector4 _clearColor;
	GLclampf _clearDepth;
	GLint _clearStencil;
	
	// Current renderer bindings for fast state checking.
	// Invalidated at the end of each frame.
	__unsafe_unretained CCRenderState *_renderState;
	__unsafe_unretained CCRenderCommandDraw *_lastDrawCommand;
	BOOL _buffersBound;
	NSUInteger _vertexPageBound;
}

/// Current global shader uniform values.
@property(nonatomic, readonly) NSDictionary *globalShaderUniforms;

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

-(void)prepareWithProjection:(const GLKMatrix4 *)projection framebuffer:(CCFrameBufferObject *)framebuffer;

-(void)setRenderState:(CCRenderState *)renderState;

/// Bind the renderer's VAO if it is not currently bound.
-(void)bindBuffers:(BOOL)bind vertexPage:(NSUInteger)vertexPage;

@end


// Cross-graphics API debug helpers.
// Should these be made public to replace the existing GL ones?

#if DEBUG

void CCRENDERER_DEBUG_PUSH_GROUP_MARKER(NSString *label);
void CCRENDERER_DEBUG_POP_GROUP_MARKER(void);
void CCRENDERER_DEBUG_INSERT_EVENT_MARKER(NSString *label);
void CCRENDERER_DEBUG_CHECK_ERRORS(void);

#else

#define CCRENDERER_DEBUG_PUSH_GROUP_MARKER(__label__);
#define CCRENDERER_DEBUG_POP_GROUP_MARKER();
#define CCRENDERER_DEBUG_INSERT_EVENT_MARKER(__label__);
#define CCRENDERER_DEBUG_CHECK_ERRORS();

#endif
