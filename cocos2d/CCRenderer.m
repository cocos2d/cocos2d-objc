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


@interface CCShader()
+(GLuint)createVAOforCCVertexBuffer:(GLuint)vbo;
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
@interface CCRenderState()
-(instancetype)initWithOptions:(NSDictionary *)options;
@end


@interface CCRenderStateCache : CCCache
@end


@implementation CCRenderStateCache

-(id)objectForKey:(id<NSCopying>)options
{
	CCRenderState *renderState = [self rawObjectForKey:options];
	if(renderState) return renderState;
	
	// Normalize the render state to use for the key.
	id blendMode = (options[CCRenderStateBlendMode] ?: CCBLEND_DISABLED);
	NSAssert([blendMode isKindOfClass:[CCBlendMode class]], @"CCRenderStateBlendMode value is not a CCBlendMode object.");
	
	id shader = (options[CCRenderStateShader] ?: [NSNull null]);
	NSAssert([shader isKindOfClass:[CCShader class]], @"CCRenderStateShader value is not a CCShader object.");
	
	id uniforms = ([options[CCRenderStateShaderUniforms] copy] ?: @{});
	NSAssert([uniforms isKindOfClass:[NSDictionary class]], @"CCRenderStateShaderUniforms value is not a NSDictionary object.");
	
	NSDictionary *normalized = @{
		CCRenderStateBlendMode: blendMode,
		CCRenderStateShader: shader,
		CCRenderStateShaderUniforms: uniforms,
	};
	
	// Create the key using the normalized blending mode.
	renderState = [super objectForKey:normalized];
	
	// Make an alias for the unnormalized version
	[self makeAlias:options forKey:normalized];
	
	return renderState;
}

-(id)createSharedDataForKey:(NSDictionary *)options
{
	return options;
}

-(id)createPublicObjectForSharedData:(NSDictionary *)options
{
	return [[CCRenderState alloc] initWithOptions:options];
}

// Nothing special
-(void)disposeOfSharedData:(id)data {}

@end


@implementation CCRenderState {
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

CCRenderStateCache *CCRENDERSTATE_CACHE = nil;

+(void)initialize
{
	CCRENDERSTATE_CACHE = [[CCRenderStateCache alloc] init];
}

+(CCRenderState *)renderStateWithOptions:(NSDictionary *)options
{
	return [CCRENDERSTATE_CACHE objectForKey:options];
}

@end


//MARK: Render Command Protocol
@protocol CCRenderCommand <NSObject>
-(void)invoke:(CCRenderer *)renderer;
@end


//MARK: Draw Command.
@interface CCRenderCommandDraw : NSObject<CCRenderCommand>

//@property(nonatomic, readonly) NSDictionary *renderOptions;
@property(nonatomic, readonly) GLint first;
@property(nonatomic, readonly) GLsizei count;

@end


@implementation CCRenderCommandDraw {
	@public
	NSDictionary *_renderOptions;
}

-(instancetype)initWithRenderOptions:(NSDictionary *)renderOptions first:(GLint)first count:(GLsizei)count
{
	if((self = [super init])){
		_renderOptions = renderOptions;
		_first = first;
		_count = count;
	}
	
	return self;
}

-(void)batchTriangles:(GLsizei)count
{
	_count += count;
}

-(void)invoke:(CCRenderer *)renderer
{
	[renderer setRenderOptions:_renderOptions];
	glDrawArrays(GL_TRIANGLES, 3*_first, 3*_count);
}

@end


//MARK: Custom Block Command.
@interface CCRenderCommandCustom : NSObject<CCRenderCommand>
@end


@implementation CCRenderCommandCustom
{
	void (^_block)();
}

-(instancetype)initWithBlock:(void (^)())block
{
	if((self = [super init])){
		_block = block;
	}
	
	return self;
}

-(void)invoke:(CCRenderer *)renderer
{
	_block();
}

@end


//MARK: Render Queue


/*
TODO

Things to try if sorting isn't implemented:
* Regular CPU buffer -> VBO buffer. Can be flushed for each state change.
* Transform directly into a mapped buffer.

Things to try if sorting is implemented:
*
*/

@implementation CCRenderer {
	GLuint _vao;
	GLuint _vbo;
	
	NSDictionary *_renderOptions;
	NSDictionary *_blendOptions;
	
	CCShader *_shader;
	NSDictionary *_uniforms;
	
	NSMutableArray *_queue;
	__unsafe_unretained CCRenderCommandDraw *_lastDrawCommand;
	
	CCTriangle *_triangles;
	GLsizei _triangleCount, _triangleCapacity;
	
	NSUInteger _statDrawCommands;
}

-(void)invalidateState
{
	_lastDrawCommand = nil;
	_renderOptions = nil;
	_blendOptions = nil;
	_shader = nil;
	_uniforms = nil;
}

-(instancetype)init
{
	if((self = [super init])){
		glGenBuffers(1, &_vbo);
		_vao = [CCShader createVAOforCCVertexBuffer:_vbo];
		
		_queue = [NSMutableArray array];
		
		_triangleCapacity = 2*1024;
		_triangles = calloc(_triangleCapacity, sizeof(*_triangles));
	}
	
	return self;
}

-(void)dealloc
{
	free(_triangles);
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

-(BOOL)setRenderOptions:(__unsafe_unretained NSDictionary *)renderOptions
{
	if(renderOptions == _renderOptions) return NO;
	
	// Set the blending state.
	__unsafe_unretained NSDictionary *blendOptions = ((CCBlendMode *)renderOptions[CCRenderStateBlendMode])->_options;
	if(blendOptions != _blendOptions){
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
	__unsafe_unretained CCShader *shader = renderOptions[CCRenderStateShader];
	if(shader != _shader){
		glUseProgram(shader->_program);
		
		_shader = shader;
		_uniforms = nil;
	}
	
	// Set the shader's uniform state.
	__unsafe_unretained NSDictionary *uniforms = renderOptions[CCRenderStateShaderUniforms];
	if(uniforms != _uniforms){
		__unsafe_unretained NSDictionary *setters = shader->_uniformSetters;
		for(NSString *uniform in setters){
			__unsafe_unretained CCUniformSetter setter = setters[uniform];
			setter(self, uniforms[uniform] ?: _globalShaderUniforms[uniform]);
		}
		_uniforms = uniforms;
	}
	
	CHECK_GL_ERROR_DEBUG();
	
	_renderOptions = renderOptions;
	return YES;
}

-(CCTriangle *)ensureBufferCapacity:(NSUInteger)requestedCount
{
	GLsizei required = _triangleCount + (GLsizei)requestedCount;
	if(required > _triangleCapacity){
		// Double the size of the buffer until it fits.
		while(required >= _triangleCapacity) _triangleCapacity *= 2;
		
		_triangles = realloc(_triangles, _triangleCapacity*sizeof(*_triangles));
	}
	
	// Return the triangle buffer pointer.
	return &_triangles[_triangleCount];
}

-(CCTriangle *)bufferTriangles:(NSUInteger)count withState:(CCRenderState *)renderState;
{
	__unsafe_unretained NSDictionary *renderOptions = renderState->_options;
	__unsafe_unretained CCRenderCommandDraw *previous = _lastDrawCommand;
	CCTriangle *buffer = [self ensureBufferCapacity:count];
	
	if(previous && renderOptions == previous->_renderOptions){
		// Batch with the previous command.
		[previous batchTriangles:(GLsizei)count];
	} else {
		// Start a new command.
		CCRenderCommandDraw *command = [[CCRenderCommandDraw alloc] initWithRenderOptions:renderOptions first:(GLint)_triangleCount count:(GLsizei)count];
		[_queue addObject:command];
		_lastDrawCommand = command;
	}
	
	_statDrawCommands++;
	_triangleCount += count;
	return buffer;
}

-(void)customBlock:(void (^)())block
{
	[_queue addObject:[[CCRenderCommandCustom alloc] initWithBlock:block]];
	_lastDrawCommand = nil;
}

-(void)customMethod:(SEL)selector target:(id)target
{
	[self customBlock:^{
    typedef void (*Func)(id, SEL);
    ((Func)objc_msgSend)(target, selector);
	}];
}

-(void)flush
{
	glBindBuffer(GL_ARRAY_BUFFER, _vbo);
	glBufferData(GL_ARRAY_BUFFER, _triangleCount*sizeof(CCTriangle), _triangles, GL_STREAM_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glBindVertexArrayOES(_vao);
	for(CCRenderCommandDraw *command in _queue) [command invoke:self];
	glBindVertexArrayOES(0);
	
//	NSLog(@"Draw commands: %d, Draw calls: %d", _statDrawCommands, _queue.count);
	_statDrawCommands = 0;
	[_queue removeAllObjects];
	
	_triangleCount = 0;
	
	CHECK_GL_ERROR_DEBUG();
//	CC_INCREMENT_GL_DRAWS(1);
}

@end
