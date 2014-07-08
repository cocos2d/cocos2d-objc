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
#import "CCGL.h"


@interface CCShader()
+(GLuint)createVAOforCCVertexBuffer:(GLuint)vbo elementBuffer:(GLuint)ebo;
@end

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


@implementation CCBlendMode {
	@public
	NSDictionary *_options;
}

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

static NSDictionary *CCBLEND_DISABLED_OPTIONS = nil;

+(void)initialize
{
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


@implementation CCRenderState {
	CCTexture *_mainTexture;
	BOOL _immutable;
	
	@public
	CCBlendMode *_blendMode;
	CCShader *_shader;
	NSDictionary *_shaderUniforms;
}

CCRenderStateCache *CCRENDERSTATE_CACHE = nil;
CCRenderState *CCRENDERSTATE_DEBUGCOLOR = nil;

+(void)initialize
{
	CCRENDERSTATE_CACHE = [[CCRenderStateCache alloc] init];
	CCRENDERSTATE_DEBUGCOLOR = [[self alloc] initWithBlendMode:CCBLEND_DISABLED shader:[CCShader positionColorShader] shaderUniforms:@{}];
}

-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms
{
	return [self initWithBlendMode:blendMode shader:shader shaderUniforms:shaderUniforms copyUniforms:NO];
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
	
	CCRenderState *renderState = [[self alloc] initWithBlendMode:blendMode shader:shader shaderUniforms:@{CCShaderUniformMainTexture: mainTexture} copyUniforms:YES];
	renderState->_mainTexture = mainTexture;
	
	return [CCRENDERSTATE_CACHE objectForKey:renderState];
}

-(id)copyWithZone:(NSZone *)zone
{
	if(_immutable){
		return self;
	} else {
		return [[CCRenderState allocWithZone:zone] initWithBlendMode:_blendMode shader:_shader shaderUniforms:_shaderUniforms copyUniforms:YES];
	}
}

-(NSUInteger)hash
{
	NSAssert(_mainTexture, @"Attempting to cache a renderstate that was nort created with renderStateWithBlendMode.");
	
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

@end


@interface CCRenderer()
-(void)bindVAO:(BOOL)bind;
-(void)setRenderState:(CCRenderState *)renderState;
@end


//MARK: Draw Command.
@interface CCRenderCommandDraw : NSObject<CCRenderCommand>

//@property(nonatomic, readonly) NSDictionary *renderOptions;
@property(nonatomic, readonly) GLint first;
@property(nonatomic, readonly) GLsizei elements;

@end


@implementation CCRenderCommandDraw {
	GLenum _mode;
	
	@public
	CCRenderState *_renderState;
	NSInteger _globalSortOrder;
}

-(instancetype)initWithMode:(GLenum)mode renderState:(CCRenderState *)renderState first:(GLint)first elements:(GLsizei)elements globalSortOrder:(NSInteger)globalSortOrder
{
	if((self = [super init])){
		_mode = mode;
		_renderState = [renderState copy];
		_first = first;
		_elements = elements;
		_globalSortOrder = globalSortOrder;
	}
	
	return self;
}

-(NSInteger)globalSortOrder
{
	return _globalSortOrder;
}

-(void)batchElements:(GLsizei)elements
{
	_elements += elements;
}

-(void)invokeOnRenderer:(CCRenderer *)renderer
{
	glPushGroupMarkerEXT(0, "CCRendererCommandDraw: Invoke");
	
	[renderer setRenderState:_renderState];
	glDrawElements(_mode, _elements, GL_UNSIGNED_SHORT, (GLvoid *)(_first*sizeof(GLushort)));
	CC_INCREMENT_GL_DRAWS(1);
	
	glPopGroupMarkerEXT();
}

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
	glPushGroupMarkerEXT(0, _debugLabel.UTF8String);
	
	[renderer bindVAO:NO];
	_block();
	
	glPopGroupMarkerEXT();
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
	
	glPushGroupMarkerEXT(0, _debugLabel.UTF8String);
	for(id<CCRenderCommand> command in _queue) [command invokeOnRenderer:renderer];
	glPopGroupMarkerEXT();
}

-(NSInteger)globalSortOrder
{
	return _globalSortOrder;
}

@end


//MARK: Render Queue


@implementation CCRenderer {
	GLuint _vao;
	GLuint _vbo;
	GLuint _ebo;
	
	CCRenderState *_renderState;
	NSDictionary *_blendOptions;
	
	CCShader *_shader;
	NSDictionary *_shaderUniforms;
	
	BOOL _vaoBound;
	
	NSMutableArray *_queue;
	NSMutableArray *_queueStack;
	__unsafe_unretained CCRenderCommandDraw *_lastDrawCommand;
	
	CCVertex *_vertexes;
	GLsizei _vertexCount, _vertexCapacity;
	
	GLushort *_elements;
	GLsizei _elementCount, _elementCapacity;
	
	NSUInteger _statDrawCommands;
}

-(void)invalidateState
{
	_lastDrawCommand = nil;
	_renderState = nil;
	_blendOptions = nil;
	_shader = nil;
	_shaderUniforms = nil;
	_vaoBound = NO;
}

-(instancetype)init
{
	if((self = [super init])){
		glPushGroupMarkerEXT(0, "CCRenderer: Init");
		
		glGenBuffers(1, &_vbo);
		glGenBuffers(1, &_ebo);
		
		_vao = [CCShader createVAOforCCVertexBuffer:_vbo elementBuffer:_ebo];
		
		glPopGroupMarkerEXT();
		
		_queue = [NSMutableArray array];
		
		_vertexCapacity = 2*1024;
		_vertexes = calloc(_vertexCapacity, sizeof(*_vertexes));
		
		_elementCapacity = 2*1024;
		_elements = calloc(_elementCapacity, sizeof(*_elements));
	}
	
	return self;
}

-(void)dealloc
{
	glPushGroupMarkerEXT(0, "CCRenderer: Dealloc");
	
	glDeleteVertexArrays(1, &_vao);
	glDeleteBuffers(1, &_vbo);
	glDeleteBuffers(1, &_ebo);
	
	glPopGroupMarkerEXT();
	
	free(_vertexes);
	free(_elements);
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

#if defined(__CC_PLATFORM_IOS)
#define glBindVertexArray glBindVertexArrayOES
#endif

-(void)bindVAO:(BOOL)bind
{
	if(bind != _vaoBound){
		glInsertEventMarkerEXT(0, "CCRenderer: Bind VAO");
		glBindVertexArray(bind ? _vao : 0);
		
		_vaoBound = bind;
	}
}

-(void)setRenderState:(CCRenderState *)renderState
{
	[self bindVAO:YES];
	if(renderState == _renderState) return;
	
	glPushGroupMarkerEXT(0, "CCRenderer: Render State");
	
	// Set the blending state.
	__unsafe_unretained NSDictionary *blendOptions = renderState->_blendMode->_options;
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
	__unsafe_unretained CCShader *shader = renderState->_shader;
	if(shader != _shader){
		glInsertEventMarkerEXT(0, "Shader");
		
		glUseProgram(shader->_program);
		
		_shader = shader;
		_shaderUniforms = nil;
	}
	
	// Set the shader's uniform state.
	__unsafe_unretained NSDictionary *shaderUniforms = renderState->_shaderUniforms;
	__unsafe_unretained NSDictionary *globalShaderUniforms = _globalShaderUniforms;
	if(shaderUniforms != _shaderUniforms){
		glInsertEventMarkerEXT(0, "Uniforms");
		
		__unsafe_unretained NSDictionary *setters = shader->_uniformSetters;
		for(NSString *uniformName in setters){
			__unsafe_unretained CCUniformSetter setter = setters[uniformName];
			setter(self, shaderUniforms, globalShaderUniforms);
		}
		_shaderUniforms = shaderUniforms;
	}
	
	CC_CHECK_GL_ERROR_DEBUG();
	glPopGroupMarkerEXT();
	
	_renderState = renderState;
	return;
}

-(void)enqueueClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil globalSortOrder:(NSInteger)globalSortOrder
{
	[self enqueueBlock:^{
		if(mask & GL_COLOR_BUFFER_BIT) glClearColor(color4.r, color4.g, color4.b, color4.a);
		if(mask & GL_DEPTH_BUFFER_BIT) glClearDepth(depth);
		if(mask & GL_STENCIL_BUFFER_BIT) glClearStencil(stencil);
		
		glClear(mask);
	} globalSortOrder:globalSortOrder debugLabel:@"CCRenderer: Clear" threadSafe:YES];
}

-(CCVertex *)ensureVertexCapacity:(NSUInteger)requestedCount
{
	NSAssert(requestedCount > 0, @"Vertex count must be positive.");
	
	GLsizei required = _vertexCount + (GLsizei)requestedCount;
	if(required > _vertexCapacity){
		// Double the size of the buffer until it fits.
		while(required >= _vertexCapacity) _vertexCapacity *= 2;
		
		_vertexes = realloc(_vertexes, _vertexCapacity*sizeof(*_vertexes));
	}
	
	// Return the triangle buffer pointer.
	return &_vertexes[_vertexCount];
}

-(GLushort *)ensureElementCapacity:(NSUInteger)requestedCount
{
	NSAssert(requestedCount > 0, @"Element count must be positive.");
	
	GLsizei required = _elementCount + (GLsizei)requestedCount;
	if(required > _elementCapacity){
		// Double the size of the buffer until it fits.
		while(required >= _elementCapacity) _elementCapacity *= 2;
		
		_elements = realloc(_elements, _elementCapacity*sizeof(*_elements));
	}
	
	// Return the triangle buffer pointer.
	return &_elements[_elementCount];
}

-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
{
	__unsafe_unretained CCRenderCommandDraw *previous = _lastDrawCommand;
	CCVertex *vertexes = [self ensureVertexCapacity:vertexCount];
	GLushort *elements = [self ensureElementCapacity:3*triangleCount];
	
	if(previous && previous->_renderState == renderState && previous->_globalSortOrder == globalSortOrder){
		// Batch with the previous command.
		[previous batchElements:(GLsizei)(3*triangleCount)];
	} else {
		// Start a new command.
		CCRenderCommandDraw *command = [[CCRenderCommandDraw alloc] initWithMode:GL_TRIANGLES renderState:renderState first:(GLint)_elementCount elements:(GLsizei)(3*triangleCount) globalSortOrder:globalSortOrder];
		[_queue addObject:command];
		_lastDrawCommand = command;
	}
	
	CCRenderBuffer buffer = {vertexes, elements, _vertexCount};
	_vertexCount += vertexCount;
	_elementCount += 3*triangleCount;
	
	_statDrawCommands++;
	return buffer;
}

-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;
{
	CCVertex *vertexes = [self ensureVertexCapacity:vertexCount];
	GLushort *elements = [self ensureElementCapacity:2*lineCount];
	
	CCRenderCommandDraw *command = [[CCRenderCommandDraw alloc] initWithMode:GL_LINES renderState:renderState first:(GLint)_elementCount elements:(GLsizei)(2*lineCount) globalSortOrder:globalSortOrder];
	[_queue addObject:command];
	
	// Line drawing commands are currently intended for debugging and cannot be batched.
	_lastDrawCommand = nil;
	
	CCRenderBuffer buffer = {vertexes, elements, _vertexCount};
	_vertexCount += vertexCount;
	_elementCount += 2*lineCount;
	
	_statDrawCommands++;
	return buffer;
}

-(void)enqueueBlock:(void (^)())block globalSortOrder:(NSInteger)globalSortOrder debugLabel:(NSString *)debugLabel threadSafe:(BOOL)threadsafe
{
	[_queue addObject:[[CCRenderCommandCustom alloc] initWithBlock:block debugLabel:debugLabel globalSortOrder:globalSortOrder]];
	_lastDrawCommand = nil;
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
	glPushGroupMarkerEXT(0, "CCRenderer: Flush");
	
	glInsertEventMarkerEXT(0, "Buffering");
	
	glBindBuffer(GL_ARRAY_BUFFER, _vbo);
	glBufferData(GL_ARRAY_BUFFER, _vertexCount*sizeof(*_vertexes), _vertexes, GL_STREAM_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, _elementCount*sizeof(*_elements), _elements, GL_STREAM_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	CC_CHECK_GL_ERROR_DEBUG();
	
	SortQueue(_queue);
	for(id<CCRenderCommand> command in _queue) [command invokeOnRenderer:self];
	[self bindVAO:NO];
	
//	NSLog(@"Draw commands: %d, Draw calls: %d", _statDrawCommands, _queue.count);
	_statDrawCommands = 0;
	_queue = [[NSMutableArray alloc] init];
	
	_vertexCount = 0;
	_elementCount = 0;
	
	glPopGroupMarkerEXT();
	CC_CHECK_GL_ERROR_DEBUG();
	
//	CC_INCREMENT_GL_DRAWS(1);
}

@end
