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
#import "CCRenderer_private.h"
#import "CCCache.h"
#import "CCTexture_Private.h"
#import "CCShader_private.h"
#import "CCDirector_Private.h"
#import "CCRenderDispatch.h"

//MARK: NSValue Additions.
@implementation NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector2)];
}

+(NSValue *)valueWithGLKVector3:(GLKVector3)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector3)];
}

+(NSValue *)valueWithGLKVector4:(GLKVector4)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector4)];
}

+(NSValue *)valueWithGLKMatrix4:(GLKMatrix4)matrix
{
	return [NSValue valueWithBytes:&matrix objCType:@encode(GLKMatrix4)];
}

@end

//MARK: Option Keys.
const NSString *CCRenderStateBlendMode = @"CCRenderStateBlendMode";
const NSString *CCRenderStateShader = @"CCRenderStateShader";
const NSString *CCRenderStateShaderUniforms = @"CCRenderStateShaderUniforms";

const NSString *CCBlendFuncSrcColor = @"CCBlendFuncSrcColor";
const NSString *CCBlendFuncDstColor = @"CCBlendFuncDstColor";
const NSString *CCBlendEquationColor = @"CCBlendEquationColor";
const NSString *CCBlendFuncSrcAlpha = @"CCBlendFuncSrcAlpha";
const NSString *CCBlendFuncDstAlpha = @"CCBlendFuncDstAlpha";
const NSString *CCBlendEquationAlpha = @"CCBlendEquationAlpha";


//MARK: Blend Modes.
@interface CCBlendMode()

-(instancetype)initWithOptions:(NSDictionary *)options;

@end


@interface CCBlendModeCache : CCCache
@end


@implementation CCBlendModeCache

-(id)objectForKey:(id<NSCopying>)options
{
	CCBlendMode *blendMode = [self rawObjectForKey:options];
	if(blendMode) return blendMode;
	
	// Normalize the blending mode to use for the key.
	id src = (options[CCBlendFuncSrcColor] ?: @(GL_ONE));
	id dst = (options[CCBlendFuncDstColor] ?: @(GL_ZERO));
	id equation = (options[CCBlendEquationColor] ?: @(GL_FUNC_ADD));
	
	NSDictionary *normalized = @{
		CCBlendFuncSrcColor: src,
		CCBlendFuncDstColor: dst,
		CCBlendEquationColor: equation,
		
		// Assume they meant non-separate blending if they didn't fill in the keys.
		CCBlendFuncSrcAlpha: (options[CCBlendFuncSrcAlpha] ?: src),
		CCBlendFuncDstAlpha: (options[CCBlendFuncDstAlpha] ?: dst),
		CCBlendEquationAlpha: (options[CCBlendEquationAlpha] ?: equation),
	};
	
	// Create the key using the normalized blending mode.
	blendMode = [super objectForKey:normalized];
	
	// Make an alias for the unnormalized version
	[self makeAlias:options forKey:normalized];
	
	return blendMode;
}

-(id)createSharedDataForKey:(NSDictionary *)options
{
	return options;
}

-(id)createPublicObjectForSharedData:(NSDictionary *)options
{
	return [[CCBlendMode alloc] initWithOptions:options];
}

// Nothing special
-(void)disposeOfSharedData:(id)data {}

-(void)flush
{
	// Since blending modes are used for keys, need to wrap the flush call in a pool.
	@autoreleasepool {
		[super flush];
	}
}

@end


@implementation CCBlendMode

-(instancetype)initWithOptions:(NSDictionary *)options
{
	if((self = [super init])){
		_options = options;
	}
	
	return self;
}

CCBlendModeCache *CCBLENDMODE_CACHE = nil;

// Default modes
static CCBlendMode *CCBLEND_DISABLED = nil;
static CCBlendMode *CCBLEND_ALPHA = nil;
static CCBlendMode *CCBLEND_PREMULTIPLIED_ALPHA = nil;
static CCBlendMode *CCBLEND_ADD = nil;
static CCBlendMode *CCBLEND_MULTIPLY = nil;

NSDictionary *CCBLEND_DISABLED_OPTIONS = nil;

+(void)initialize
{
	// +initialize may be called due to loading a subclass.
	if(self != [CCBlendMode class]) return;
	
	CCBLENDMODE_CACHE = [[CCBlendModeCache alloc] init];
	
	// Add the default modes
	CCBLEND_DISABLED = [self blendModeWithOptions:@{}];
	CCBLEND_DISABLED_OPTIONS = CCBLEND_DISABLED.options;
	
	CCBLEND_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_SRC_ALPHA),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_PREMULTIPLIED_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_ADD = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE),
	}];
	
	CCBLEND_MULTIPLY = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_DST_COLOR),
		CCBlendFuncDstColor: @(GL_ZERO),
	}];
}

+(CCBlendMode *)blendModeWithOptions:(NSDictionary *)options
{
	return [CCBLENDMODE_CACHE objectForKey:options];
}

+(CCBlendMode *)disabledMode
{
	return CCBLEND_DISABLED;
}

+(CCBlendMode *)alphaMode
{
	return CCBLEND_ALPHA;
}

+(CCBlendMode *)premultipliedAlphaMode
{
	return CCBLEND_PREMULTIPLIED_ALPHA;
}

+(CCBlendMode *)addMode
{
	return CCBLEND_ADD;
}

+(CCBlendMode *)multiplyMode
{
	return CCBLEND_MULTIPLY;
}

@end


//MARK: Render States.
@interface CCRenderStateCache : CCCache
@end


@implementation CCRenderStateCache

-(id)createSharedDataForKey:(CCRenderState *)renderState
{
	return renderState;
}

-(id)createPublicObjectForSharedData:(CCRenderState *)renderState
{
	return [renderState copy];
}

// Nothing special
-(void)disposeOfSharedData:(id)data {}

-(void)flush
{
	// Since render states are used for keys, need to wrap the flush call in a pool.
	@autoreleasepool {
		[super flush];
	}
}

@end


@implementation CCRenderState

CCRenderStateCache *CCRENDERSTATE_CACHE = nil;
CCRenderState *CCRENDERSTATE_DEBUGCOLOR = nil;

+(void)initialize
{
	// +initialize may be called due to loading a subclass.
	if(self != [CCRenderState class]) return;
	
	CCRENDERSTATE_CACHE = [[CCRenderStateCache alloc] init];
	CCRENDERSTATE_DEBUGCOLOR = [[CCRenderStateClass alloc] initWithBlendMode:CCBLEND_DISABLED shader:[CCShader positionColorShader] shaderUniforms:@{}];
}

-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms
{
	// Allocate a new instance of the correct class instead of self. (This method was already deprecated).
	return [[CCRenderStateClass alloc] initWithBlendMode:blendMode shader:shader shaderUniforms:shaderUniforms copyUniforms:NO];
}

-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms copyUniforms:(BOOL)copyUniforms
{
	if((self = [super init])){
		_blendMode = blendMode;
		_shader = shader;
		_shaderUniforms = (copyUniforms ? [shaderUniforms copy] : shaderUniforms);
		
		// The renderstate as a whole is immutable if the uniforms are copied.
		_immutable = copyUniforms;
	}
	
	return self;
}

+(instancetype)renderStateWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader mainTexture:(CCTexture *)mainTexture;
{
	if(mainTexture == nil){
		CCLOGWARN(@"nil Texture passed to CCRenderState");
		mainTexture = [CCTexture none];
	}
	
	CCRenderState *renderState = [[CCRenderStateClass alloc] initWithBlendMode:blendMode shader:shader shaderUniforms:@{CCShaderUniformMainTexture: mainTexture} copyUniforms:YES];
	renderState->_mainTexture = mainTexture;
	
	return [CCRENDERSTATE_CACHE objectForKey:renderState];
}

+(instancetype)renderStateWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms copyUniforms:(BOOL)copyUniforms
{
	return [[CCRenderStateClass alloc] initWithBlendMode:blendMode shader:shader shaderUniforms:shaderUniforms copyUniforms:copyUniforms];
}

-(id)copyWithZone:(NSZone *)zone
{
	if(_immutable){
		return self;
	} else {
		return [[CCRenderStateClass allocWithZone:zone] initWithBlendMode:_blendMode shader:_shader shaderUniforms:_shaderUniforms copyUniforms:YES];
	}
}

-(NSUInteger)hash
{
	// Not great, but acceptable. All values are unique by pointer.
	return ((NSUInteger)_blendMode ^ (NSUInteger)_shader ^ (NSUInteger)_mainTexture);
}

-(BOOL)isEqual:(id)object
{
	CCRenderState *other = object;
	
	return (
		[other isKindOfClass:[CCRenderState class]] &&
		_blendMode == other->_blendMode &&
		_shader == other->_shader &&
		_mainTexture == other->_mainTexture
	);
}

+(instancetype)debugColor
{
	return CCRENDERSTATE_DEBUGCOLOR;
}

-(void)transitionRenderer:(CCRenderer *)renderer FromState:(CCRenderer *)previous
{
	NSAssert(NO, @"Must be overridden.");
}

@end


//MARK: Draw Command.


@implementation CCRenderCommandDraw

-(instancetype)initWithMode:(CCRenderCommandDrawMode)mode renderState:(CCRenderState *)renderState first:(NSUInteger)first count:(size_t)count globalSortOrder:(NSInteger)globalSortOrder
{
	if((self = [super init])){
		_mode = mode;
		_renderState = [renderState copy];
		_first = first;
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
	CCGL_DEBUG_PUSH_GROUP_MARKER(_debugLabel.UTF8String);
	
	[renderer bindBuffers:NO];
	_block();
	
	CCGL_DEBUG_POP_GROUP_MARKER();
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
	
	CCGL_DEBUG_PUSH_GROUP_MARKER(_debugLabel.UTF8String);
	for(id<CCRenderCommand> command in _queue) [command invokeOnRenderer:renderer];
	CCGL_DEBUG_POP_GROUP_MARKER();
}

-(NSInteger)globalSortOrder
{
	return _globalSortOrder;
}

@end


// MARK: CCGraphicsBuffer


@implementation CCGraphicsBuffer

-(instancetype)initWithCapacity:(NSUInteger)capacity elementSize:(size_t)elementSize type:(CCGraphicsBufferType)type
{
	if((self = [super init])){
		_count = 0;
		_capacity = capacity;
		_elementSize = elementSize;
	}
	
	return self;
}

-(void)resize:(size_t)newCapacity
{NSAssert(NO, @"Must be overridden.");}

-(void)destroy
{NSAssert(NO, @"Must be overridden.");}

-(void)prepare
{NSAssert(NO, @"Must be overridden.");}

-(void)commit
{NSAssert(NO, @"Must be overridden.");}

-(void)dealloc
{
	[self destroy];
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
		CCRenderDispatch(NO, ^{
			const NSUInteger CCRENDERER_INITIAL_VERTEX_CAPACITY = 16*1024;
			_vertexBuffer = [[CCGraphicsBufferClass alloc] initWithCapacity:CCRENDERER_INITIAL_VERTEX_CAPACITY elementSize:sizeof(CCVertex) type:CCGraphicsBufferTypeVertex];
			[_vertexBuffer prepare];
			
			_elementBuffer = [[CCGraphicsBufferClass alloc] initWithCapacity:CCRENDERER_INITIAL_VERTEX_CAPACITY*1.5 elementSize:sizeof(uint16_t) type:CCGraphicsBufferTypeIndex];
			[_elementBuffer prepare];
			
			_bufferBindings = [CCGraphicsBufferBindingsClass alloc];
			_bufferBindings = [_bufferBindings initWithVertexBuffer:_vertexBuffer indexBuffer:_elementBuffer];
		});
		
		_threadsafe = YES;
		_queue = [NSMutableArray array];
		
		#warning TEMP
		// Should probably change the init method to pass this in?
		_context = [NSClassFromString(@"CCMetalContext") currentContext];
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
		NSAssert(self.currentRenderer == nil, @"Internal Error: Already have a renderer bound.");
		[NSThread currentThread].threadDictionary[CURRENT_RENDERER_KEY] = renderer;
	} else {
		[[NSThread currentThread].threadDictionary removeObjectForKey:CURRENT_RENDERER_KEY];
	}
}

-(void)setGlobalShaderUniforms:(NSDictionary *)globalShaderUniforms
{
	_globalShaderUniforms = [globalShaderUniforms copy];
	[self invalidateState];
}

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
#define glBindVertexArray glBindVertexArrayOES
#endif

//Implemented in CCNoARC.m
//-(void)bindBuffers:(BOOL)bind
//-(void)setRenderState:(CCRenderState *)renderState
//-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
//-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;

-(void)enqueueClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil globalSortOrder:(NSInteger)globalSortOrder
{
	[self enqueueBlock:^{
		if(mask & GL_COLOR_BUFFER_BIT) glClearColor(color4.r, color4.g, color4.b, color4.a);
		if(mask & GL_DEPTH_BUFFER_BIT) glClearDepth(depth);
		if(mask & GL_STENCIL_BUFFER_BIT) glClearStencil(stencil);
		
		glClear(mask);
	} globalSortOrder:globalSortOrder debugLabel:@"CCRenderer: Clear" threadSafe:YES];
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
	CCGL_DEBUG_PUSH_GROUP_MARKER("CCRenderer: Flush");
	
	CCGL_DEBUG_INSERT_EVENT_MARKER("Buffering");
	[_vertexBuffer commit];
	[_elementBuffer commit];
	CC_CHECK_GL_ERROR_DEBUG();
	
	SortQueue(_queue);
	for(id<CCRenderCommand> command in _queue) [command invokeOnRenderer:self];
	[self bindBuffers:NO];
	
	[_queue removeAllObjects];
	
	[_vertexBuffer prepare];
	[_elementBuffer prepare];
	
	CCGL_DEBUG_POP_GROUP_MARKER();
	CC_CHECK_GL_ERROR_DEBUG();
	
	[self invalidateState];
	_threadsafe = YES;
}

@end
