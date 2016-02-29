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

#import "objc/message.h"

#import "cocos2d.h"
#import "CCRenderer_Private.h"
#import "CCCache.h"
#import "CCDirector.h"
#import "CCRenderDispatch.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import "CCMetalSupport_Private.h"
#endif

@interface NSValue()

// Defined in NSValue+CCRenderer.m.
-(size_t)CCRendererSizeOf;

@end


//MARK: Graphics Debug Helpers:

#if DEBUG

void CCRENDERER_DEBUG_PUSH_GROUP_MARKER(NSString *label){
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		[[CCMetalContext currentContext].currentRenderCommandEncoder pushDebugGroup:label];
	} else
#endif
	{
		CCGL_DEBUG_PUSH_GROUP_MARKER(label.UTF8String);
	}
}

void CCRENDERER_DEBUG_POP_GROUP_MARKER(void){
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		[[CCMetalContext currentContext].currentRenderCommandEncoder popDebugGroup];
	} else
#endif
	{
		CCGL_DEBUG_POP_GROUP_MARKER();
	}
}

void CCRENDERER_DEBUG_INSERT_EVENT_MARKER(NSString *label){
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		[[CCMetalContext currentContext].currentRenderCommandEncoder insertDebugSignpost:label];
	} else
#endif
	{
		CCGL_DEBUG_INSERT_EVENT_MARKER(label.UTF8String);
	}
}

void CCRENDERER_DEBUG_CHECK_ERRORS(void){
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
	} else
#endif
	{
		CC_CHECK_GL_ERROR_DEBUG();
	}
}

#endif


//MARK: Draw Command.


@implementation CCRenderCommandDraw

-(instancetype)initWithMode:(CCRenderCommandDrawMode)mode renderState:(CCRenderState *)renderState firstIndex:(NSUInteger)firstIndex vertexPage:(NSUInteger)vertexPage count:(size_t)count globalSortOrder:(NSInteger)globalSortOrder;
{
	if((self = [super init])){
		_mode = mode;
#if CC_DIRECTOR_IOS_THREADED_RENDERING
		_renderState = [renderState copy];
#else
		_renderState = renderState;
#endif
		_firstIndex = firstIndex;
		_vertexPage = vertexPage;
		_count = count;
		_globalSortOrder = globalSortOrder;
	}
	
	return self;
}

-(NSInteger)globalSortOrder
{
	return _globalSortOrder;
}

-(void)batch:(NSUInteger)count
{
	_count += count;
}

-(void)invokeOnRenderer:(CCRenderer *)renderer
{NSAssert(NO, @"Must be overridden.");}

@end


//MARK: Custom Block Command.
@interface CCRenderCommandCustom : NSObject<CCRenderCommand>
@end


@implementation CCRenderCommandCustom
{
	void (^_block)();
	NSString *_debugLabel;
	
	NSInteger _globalSortOrder;
}

-(instancetype)initWithBlock:(void (^)())block debugLabel:(NSString *)debugLabel globalSortOrder:(NSInteger)globalSortOrder
{
	if((self = [super init])){
		_block = block;
		_debugLabel = debugLabel;
		
		_globalSortOrder = globalSortOrder;
	}
	
	return self;
}

-(NSInteger)globalSortOrder
{
	return _globalSortOrder;
}

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	CCRENDERER_DEBUG_PUSH_GROUP_MARKER(_debugLabel);
	
	[renderer bindBuffers:NO vertexPage:0];
	_block();
	
	CCRENDERER_DEBUG_POP_GROUP_MARKER();
}

@end


//MARK: Rendering group command.

static void
SortQueue(NSMutableArray *queue)
{
	[queue sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id<CCRenderCommand> obj1, id<CCRenderCommand> obj2) {
		NSInteger sort1 = obj1.globalSortOrder;
		NSInteger sort2 = obj2.globalSortOrder;
		
		if(sort1 < sort2) return NSOrderedAscending;
		if(sort1 > sort2) return NSOrderedDescending;
		return NSOrderedSame;
	}];
}

@interface CCRenderCommandGroup : NSObject<CCRenderCommand>
@end


@implementation CCRenderCommandGroup {
	NSMutableArray *_queue;
	NSString *_debugLabel;
	
	NSInteger _globalSortOrder;
}

-(instancetype)initWithQueue:(NSMutableArray *)queue debugLabel:(NSString *)debugLabel globalSortOrder:(NSInteger)globalSortOrder
{
	if((self = [super init])){
		_queue = queue;
		_debugLabel = debugLabel;
		
		_globalSortOrder = globalSortOrder;
	}
	
	return self;
}

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	SortQueue(_queue);
	
	CCRENDERER_DEBUG_PUSH_GROUP_MARKER(_debugLabel);
	for(id<CCRenderCommand> command in _queue) [command invokeOnRenderer:renderer];
	CCRENDERER_DEBUG_POP_GROUP_MARKER();
}

-(NSInteger)globalSortOrder
{
	return _globalSortOrder;
}

@end


//MARK: Render Queue


@implementation CCRenderer

-(void)invalidateState
{
	_lastDrawCommand = nil;
	_renderState = nil;
	_buffersBound = NO;
}

-(instancetype)init
{
	if((self = [super init])){
		_buffers = [[CCGraphicsBufferBindingsClass alloc] init];
				
		_threadsafe = YES;
		_queue = [NSMutableArray array];
	}
	
	return self;
}

static NSString *CURRENT_RENDERER_KEY = @"CCRendererCurrent";

+(instancetype)currentRenderer
{
	return [NSThread currentThread].threadDictionary[CURRENT_RENDERER_KEY];
}

+(void)bindRenderer:(CCRenderer *)renderer
{
	if(renderer){
		[NSThread currentThread].threadDictionary[CURRENT_RENDERER_KEY] = renderer;
	} else {
		[[NSThread currentThread].threadDictionary removeObjectForKey:CURRENT_RENDERER_KEY];
	}
}

-(void)prepareWithProjection:(const GLKMatrix4 *)projection framebuffer:(CCFrameBufferObject *)framebuffer
{
	NSAssert(framebuffer, @"Framebuffer cannot be nil.");
	CCDirector *director = [CCDirector sharedDirector];
	
	// Copy in the globals from the director.
	NSMutableDictionary *globalShaderUniforms = [director.globalShaderUniforms mutableCopy];
	
	// Group all of the standard globals into one value.
	// Used by Metal, will be used eventually by a GL3 renderer.
	CCGlobalUniforms globals = {};
	
	globals.projection = *projection;
	globals.projectionInv = GLKMatrix4Invert(globals.projection, NULL);
	globalShaderUniforms[CCShaderUniformProjection] = [NSValue valueWithGLKMatrix4:globals.projection];
	globalShaderUniforms[CCShaderUniformProjectionInv] = [NSValue valueWithGLKMatrix4:globals.projectionInv];
	
	CGSize pixelSize = framebuffer.sizeInPixels;
	globals.viewSizeInPixels = GLKVector2Make(pixelSize.width, pixelSize.height);
	globalShaderUniforms[CCShaderUniformViewSizeInPixels] = [NSValue valueWithGLKVector2:globals.viewSizeInPixels];
	
	float coef = 1.0/framebuffer.contentScale;
	globals.viewSize = GLKVector2Make(coef*pixelSize.width, coef*pixelSize.height);
	globalShaderUniforms[CCShaderUniformViewSize] = [NSValue valueWithGLKVector2:globals.viewSize];
	
	CCTime t = director.scheduler.currentTime;
	globals.time = GLKVector4Make(t, t/2.0f, t/4.0f, t/8.0f);
	globals.sinTime = GLKVector4Make(sinf(t*2.0f), sinf(t), sinf(t/2.0f), sinf(t/4.0f));
	globals.cosTime = GLKVector4Make(cosf(t*2.0f), cosf(t), cosf(t/2.0f), cosf(t/4.0f));
	globalShaderUniforms[CCShaderUniformTime] = [NSValue valueWithGLKVector4:globals.time];
	globalShaderUniforms[CCShaderUniformSinTime] = [NSValue valueWithGLKVector4:globals.sinTime];
	globalShaderUniforms[CCShaderUniformCosTime] = [NSValue valueWithGLKVector4:globals.cosTime];
	
	globals.random01 = GLKVector4Make(CCRANDOM_0_1(), CCRANDOM_0_1(), CCRANDOM_0_1(), CCRANDOM_0_1());
	globalShaderUniforms[CCShaderUniformRandom01] = [NSValue valueWithGLKVector4:globals.random01];
	
	globalShaderUniforms[CCShaderUniformDefaultGlobals] = [NSValue valueWithBytes:&globals objCType:@encode(CCGlobalUniforms)];
	
	_globalShaderUniforms = globalShaderUniforms;
		
	// If we are using a uniform buffer (ex: Metal) copy the global uniforms into it.
	CCGraphicsBuffer *uniformBuffer = _buffers->_uniformBuffer;
	if(uniformBuffer){
		NSMutableDictionary *offsets = [NSMutableDictionary dictionary];
		size_t offset = 0;
		
		for(NSString *name in _globalShaderUniforms){
			NSValue *value = _globalShaderUniforms[name];
			
			// Round up to the next multiple of 16 since Metal types have an alignment of 16 bytes at most.
			size_t alignedBytes = ((value.CCRendererSizeOf - 1) | 0xF) + 1;
			
			void * buff = CCGraphicsBufferPushElements(uniformBuffer, alignedBytes);
			[value getValue:buff];
			offsets[name] = @(offset);
			
			offset += alignedBytes;
		}
		
		_globalShaderUniformBufferOffsets = offsets;
	}
	
	_framebuffer = framebuffer;
}

//Implemented in CCNoARC.m
//-(void)bindBuffers:(BOOL)bind
//-(void)setRenderState:(CCRenderState *)renderState
//-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
//-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;

-(void)enqueueClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil globalSortOrder:(NSInteger)globalSortOrder
{
	// If a clear is the very first command, then handle it specially.
	if(globalSortOrder == NSIntegerMin && _queue.count == 0 && _queueStack.count == 0){
		_clearMask = mask;
		_clearColor = color4;
		_clearDepth = depth;
		_clearStencil = stencil;
	} else {
		NSAssert([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIGL, @"Clear commands must be the first command in the queue unless using GL.");
		
		[self enqueueBlock:^{
			if(mask & GL_COLOR_BUFFER_BIT) glClearColor(color4.r, color4.g, color4.b, color4.a);
			if(mask & GL_DEPTH_BUFFER_BIT) glClearDepth(depth);
			if(mask & GL_STENCIL_BUFFER_BIT) glClearStencil(stencil);
			
			glClear(mask);
		} globalSortOrder:globalSortOrder debugLabel:@"CCRenderer: Clear" threadSafe:YES];
	}
}

-(void)enqueueBlock:(void (^)())block globalSortOrder:(NSInteger)globalSortOrder debugLabel:(NSString *)debugLabel threadSafe:(BOOL)threadsafe
{
	[_queue addObject:[[CCRenderCommandCustom alloc] initWithBlock:block debugLabel:debugLabel globalSortOrder:globalSortOrder]];
	_lastDrawCommand = nil;
	
	if(!threadsafe) _threadsafe = NO;
}

-(void)enqueueMethod:(SEL)selector target:(id)target
{
	[self enqueueBlock:^{
    typedef void (*Func)(id, SEL);
    ((Func)objc_msgSend)(target, selector);
	} globalSortOrder:0 debugLabel:NSStringFromSelector(selector) threadSafe:NO];
}

-(void)enqueueRenderCommand: (id<CCRenderCommand>) renderCommand {
	[_queue addObject: renderCommand];
	_lastDrawCommand = nil;
	
	_threadsafe = NO;
}

-(void)pushGroup;
{
	if(_queueStack == nil){
		// Allocate the stack lazily.
		_queueStack = [[NSMutableArray alloc] init];
	}
	
	[_queueStack addObject:_queue];
	_queue = [[NSMutableArray alloc] init];
	_lastDrawCommand = nil;
}

-(void)popGroupWithDebugLabel:(NSString *)debugLabel globalSortOrder:(NSInteger)globalSortOrder
{
	NSAssert(_queueStack.count > 0, @"Render queue stack underflow. (Unmatched pushQueue/popQueue calls.)");
	
	NSMutableArray *groupQueue = _queue;
	_queue = [_queueStack lastObject];
	[_queueStack removeLastObject];
	
	[_queue addObject:[[CCRenderCommandGroup alloc] initWithQueue:groupQueue debugLabel:debugLabel globalSortOrder:globalSortOrder]];
	_lastDrawCommand = nil;
}

-(void)flush
{
	CCRENDERER_DEBUG_PUSH_GROUP_MARKER(@"CCRenderer: Flush");
	
	[_framebuffer bindWithClear:_clearMask color:_clearColor depth:_clearDepth stencil:_clearStencil];
	
	// Commit the buffers.
	[_buffers commit];
		
	// Execute the rendering commands.
	SortQueue(_queue);
	for(id<CCRenderCommand> command in _queue) [command invokeOnRenderer:self];
	[self bindBuffers:NO vertexPage:0];
	
	[_queue removeAllObjects];
	
	// Prepare the buffers.
	[_buffers prepare];
	
	CCRENDERER_DEBUG_POP_GROUP_MARKER();
	CCRENDERER_DEBUG_CHECK_ERRORS();
	
	// Reset the renderer's state.
	[self invalidateState];
	_threadsafe = YES;
	_framebuffer = nil;
	_clearMask = 0;
}

@end
