//
// Copyright 2011 Jeff Lamarche
//
// Copyright 2012 Goffredo Marocchi
//
// Copyright 2012 Ricardo Quesada
//
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided
// that the following conditions are met:
//	1. Redistributions of source code must retain the above copyright notice, this list of conditions and
//		the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//		and the following disclaimer in the documentation and/or other materials provided with the
//		distribution.
//
//	THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT
//	OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//	OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//	AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "CCShader_private.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"
#import "Support/uthash.h"
#import "CCRenderer_Private.h"
#import "CCTexture_private.h"
#import "CCDirector.h"
#import "CCCache.h"
#import "CCGL.h"
#import "CCRenderDispatch.h"
#import "CCMetalSupport_Private.h"


NSString * const CCShaderUniformDefaultGlobals = @"cc_GlobalUniforms";
NSString * const CCShaderUniformProjection = @"cc_Projection";
NSString * const CCShaderUniformProjectionInv = @"cc_ProjectionInv";
NSString * const CCShaderUniformViewSize = @"cc_ViewSize";
NSString * const CCShaderUniformViewSizeInPixels = @"cc_ViewSizeInPixels";
NSString * const CCShaderUniformTime = @"cc_Time";
NSString * const CCShaderUniformSinTime = @"cc_SinTime";
NSString * const CCShaderUniformCosTime = @"cc_CosTime";
NSString * const CCShaderUniformRandom01 = @"cc_Random01";
NSString * const CCShaderUniformMainTexture = @"cc_MainTexture";
NSString * const CCShaderUniformNormalMapTexture = @"cc_NormalMapTexture";
NSString * const CCShaderUniformAlphaTestValue = @"cc_AlphaTestValue";


// Stringify macros
#define STR(s) #s
#define XSTR(s) STR(s)

/*
	main texture size points/pixels?
*/
static const GLchar *CCShaderHeader =
	"#ifndef GL_ES\n"
	"#define lowp\n"
	"#define mediump\n"
	"#define highp\n"
	"#endif\n\n"
	"uniform highp mat4 cc_Projection;\n"
	"uniform highp mat4 cc_ProjectionInv;\n"
	"uniform highp vec2 cc_ViewSize;\n"
	"uniform highp vec2 cc_ViewSizeInPixels;\n"
	"uniform highp vec4 cc_Time;\n"
	"uniform highp vec4 cc_SinTime;\n"
	"uniform highp vec4 cc_CosTime;\n"
	"uniform highp vec4 cc_Random01;\n\n"
	"uniform " XSTR(CC_SHADER_COLOR_PRECISION) " sampler2D cc_MainTexture;\n\n"
	"uniform " XSTR(CC_SHADER_COLOR_PRECISION) " sampler2D cc_NormalMapTexture;\n\n"
	"varying " XSTR(CC_SHADER_COLOR_PRECISION) " vec4 cc_FragColor;\n"
	"varying highp vec2 cc_FragTexCoord1;\n"
	"varying highp vec2 cc_FragTexCoord2;\n\n"
	"// End Cocos2D shader header.\n\n";

static const GLchar *CCVertexShaderHeader =
	"#ifdef GL_ES\n"
	"precision highp float;\n"
	"#endif\n\n"
	"#define CC_NODE_RENDER_SUBPIXEL " XSTR(CC_NODE_RENDER_SUBPIXEL) "\n"
	"attribute highp vec4 cc_Position;\n"
	"attribute highp vec2 cc_TexCoord1;\n"
	"attribute highp vec2 cc_TexCoord2;\n"
	"attribute highp vec4 cc_Color;\n\n"
	"// End Cocos2D vertex shader header.\n\n";

static const GLchar *CCFragmentShaderHeader =
	"#ifdef GL_ES\n"
	"precision " XSTR(CC_SHADER_DEFAULT_FRAGMENT_PRECISION) " float;\n"
	"#endif\n\n"
	"// End Cocos2D fragment shader header.\n\n";

static NSString *CCDefaultVShader =
	@"void main(){\n"
	@"	gl_Position = cc_Position;\n"
	@"#if !CC_NODE_RENDER_SUBPIXEL\n"
	@"	vec2 pixelPos = (0.5*gl_Position.xy/gl_Position.w + 0.5)*cc_ViewSizeInPixels;\n"
	@"	gl_Position.xy = (2.0*floor(pixelPos)/cc_ViewSizeInPixels - 1.0)*gl_Position.w;\n"
	@"#endif\n\n"
	@"	cc_FragColor = clamp(cc_Color, 0.0, 1.0);\n"
	@"	cc_FragTexCoord1 = cc_TexCoord1;\n"
	@"	cc_FragTexCoord2 = cc_TexCoord2;\n"
	@"}\n";

static NSString *CCMetalShaderHeader = 
	@"using namespace metal;\n\n"
	@"typedef struct CCVertex {\n"
	@"	float4 position;\n"
	@"	float2 texCoord1;\n"
	@"	float2 texCoord2;\n"
	@"	float4 color;\n"
	@"} CCVertex;\n\n"
	@"typedef struct CCFragData {\n"
	@"	float4 position [[position]];\n"
	@"	float2 texCoord1;\n"
	@"	float2 texCoord2;\n"
	@"	half4  color;\n"
	@"} CCFragData;\n\n"
	@"typedef struct CCGlobalUniforms {\n"
	@"	float4x4 projection;\n"
	@"	float4x4 projectionInv;\n"
	@"	float2 viewSize;\n"
	@"	float2 viewSizeInPixels;\n"
	@"	float4 time;\n"
	@"	float4 sinTime;\n"
	@"	float4 cosTime;\n"
	@"	float4 random01;\n"
	@"} CCGlobalUniforms;\n";

typedef void (* GetShaderivFunc) (GLuint shader, GLenum pname, GLint* param);
typedef void (* GetShaderInfoLogFunc) (GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* infoLog);

// Returns NO if there is an error
static BOOL
CCCheckShaderError(GLint obj, GLenum status, GetShaderivFunc getiv, GetShaderInfoLogFunc getInfoLog)
{
	GLint success;
	getiv(obj, status, &success);
	
	if(!success){
		GLint length;
		getiv(obj, GL_INFO_LOG_LENGTH, &length);
		
		char *log = (char *)alloca(length);
		getInfoLog(obj, length, NULL, log);
		
		fprintf(stderr, "Shader compile error for 0x%04X: %s\n", status, log);
		return NO;
	} else {
		return YES;
	}
}

static const GLchar *
CCShaderTypeHeader(GLenum type)
{
	switch(type){
		case GL_VERTEX_SHADER: return CCVertexShaderHeader;
		case GL_FRAGMENT_SHADER: return CCFragmentShaderHeader;
		default: NSCAssert(NO, @"Bad shader type enumeration."); return NULL;
	}
}

static GLint
CompileShader(GLenum type, const char *source)
{
	GLint shader = glCreateShader(type);
	
	const GLchar *sources[] = {
		CCShaderHeader,
		CCShaderTypeHeader(type),
		source,
	};

	glShaderSource(shader, 3, sources, NULL);
	glCompileShader(shader);
	    
	if(CCCheckShaderError(shader, GL_COMPILE_STATUS, glGetShaderiv, glGetShaderInfoLog)){
		return shader;
	} else {
		glDeleteShader(shader);
		return 0;
	}
}


@interface CCShaderCache : CCCache @end
@implementation CCShaderCache

-(id)createSharedDataForKey:(id<NSCopying>)key
{
	NSString *shaderName = (NSString *)key;
	
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		id<MTLLibrary> library = [CCMetalContext currentContext].library;
		
		NSString *fragmentName = [shaderName stringByAppendingString:@"FS"];
		id<MTLFunction> fragmentFunction = [library newFunctionWithName:fragmentName];
		NSAssert(fragmentFunction, @"CCShader: Fragment function named %@ not found in the default library.", fragmentName);
		
		NSString *vertexName = [shaderName stringByAppendingPathExtension:@"VS"];
		id<MTLFunction> vertexFunction = ([library newFunctionWithName:vertexName] ?: [library newFunctionWithName:@"CCVertexFunctionDefault"]);
		
		CCShader *shader = [[CCShader alloc] initWithMetalVertexFunction:vertexFunction fragmentFunction:fragmentFunction];
		shader.debugName = shaderName;
		
		return shader;
	} else
#endif
	{
		NSString *fragmentName = [shaderName stringByAppendingPathExtension:@"fsh"];
		NSString *fragmentPath = [[CCFileUtils sharedFileUtils] fullPathForFilename:fragmentName];
		NSAssert(fragmentPath, @"Failed to find '%@'.", fragmentName);
		NSString *fragmentSource = [NSString stringWithContentsOfFile:fragmentPath encoding:NSUTF8StringEncoding error:nil];
		
		NSString *vertexName = [shaderName stringByAppendingPathExtension:@"vsh"];
		NSString *vertexPath = [[CCFileUtils sharedFileUtils] fullPathForFilename:vertexName];
		NSString *vertexSource = (vertexPath ? [NSString stringWithContentsOfFile:vertexPath encoding:NSUTF8StringEncoding error:nil] : CCDefaultVShader);
		
		CCShader *shader = [[CCShader alloc] initWithVertexShaderSource:vertexSource fragmentShaderSource:fragmentSource];
		shader.debugName = shaderName;
		
		return shader;
	}
}

-(id)createPublicObjectForSharedData:(id)data
{
	return [data copy];
}

@end


@implementation CCShader {
	BOOL _ownsProgram;
}

//MARK: GL Uniform Setters:

static CCUniformSetter
GLUniformSetFloat(NSString *name, GLint location)
{
	return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
		NSNumber *value = shaderUniforms[name] ?: globalShaderUniforms[name] ?: @(0.0);
		NSCAssert([value isKindOfClass:[NSNumber class]], @"Shader uniform '%@' value must be wrapped in a NSNumber.", name);
		
		glUniform1f(location, value.floatValue);
	};
}

static CCUniformSetter
GLUniformSetVec2(NSString *name, GLint location)
{
	NSString *textureName = nil;
	bool pixelSize = [name hasSuffix:@"PixelSize"];
	if(pixelSize){
		textureName = [name substringToIndex:name.length - @"PixelSize".length];
	} else if([name hasSuffix:@"Size"]){
		textureName = [name substringToIndex:name.length - @"Size".length];
	}
	
	return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
		NSValue *value = shaderUniforms[name] ?: globalShaderUniforms[name];
		
		// Fall back on looking up the actual texture size if the name matches a texture.
		if(value == nil && textureName){
			CCTexture *texture = shaderUniforms[textureName] ?: globalShaderUniforms[textureName];
			GLKVector2 sizeInPixels = GLKVector2Make(texture.pixelWidth, texture.pixelHeight);
			
			GLKVector2 size = GLKVector2MultiplyScalar(sizeInPixels, pixelSize ? 1.0 : 1.0/texture.contentScale);
			value = [NSValue valueWithGLKVector2:size];
		}
		
		// Finally fall back on 0.
		if(value == nil) value = [NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)];
		
		NSCAssert([value isKindOfClass:[NSValue class]], @"Shader uniform '%@' value must be wrapped in a NSValue.", name);
		
		if(strcmp(value.objCType, @encode(GLKVector2)) == 0){
			GLKVector2 v; [value getValue:&v];
			glUniform2f(location, v.x, v.y);
		} else if(strcmp(value.objCType, @encode(CGPoint)) == 0){
			CGPoint v = {}; [value getValue:&v];
			glUniform2f(location, v.x, v.y);
		} else if(strcmp(value.objCType, @encode(CGSize)) == 0){
			CGSize v = {}; [value getValue:&v];
			glUniform2f(location, v.width, v.height);
		} else {
			NSCAssert(NO, @"Shader uniformm 'vec2 %@' value must be passed using [NSValue valueWithGLKVector2:], [NSValue valueWithCGPoint:], or [NSValue valueWithCGSize:]", name);
		}
	};
}

static CCUniformSetter
GLUniformSetVec3(NSString *name, GLint location)
{
	return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
		NSValue *value = shaderUniforms[name] ?: globalShaderUniforms[name] ?: [NSValue valueWithGLKVector3:GLKVector3Make(0.0f, 0.0f, 0.0f)];
		NSCAssert([value isKindOfClass:[NSValue class]], @"Shader uniform '%@' value must be wrapped in a NSValue.", name);
		NSCAssert(strcmp(value.objCType, @encode(GLKVector3)) == 0, @"Shader uniformm 'vec3 %@' value must be passed using [NSValue valueWithGLKVector3:]", name);
		
		GLKVector3 v; [value getValue:&v];
		glUniform3f(location, v.x, v.y, v.z);
	};
}

static CCUniformSetter
GLUniformSetVec4(NSString *name, GLint location)
{
	return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
		NSValue *value = shaderUniforms[name] ?: globalShaderUniforms[name] ?: [NSValue valueWithGLKVector4:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];
		
		if([value isKindOfClass:[NSValue class]]){
			NSCAssert(strcmp([(NSValue *)value objCType], @encode(GLKVector4)) == 0, @"Shader uniformm 'vec4 %@' value must be passed using [NSValue valueWithGLKVector4:].", name);
			
			GLKVector4 v; [value getValue:&v];
			glUniform4f(location, v.x, v.y, v.z, v.w);
		} else if([value isKindOfClass:[CCColor class]]){
			GLKVector4 v = [(CCColor *)value glkVector4];
			glUniform4f(location, v.x, v.y, v.z, v.w);
		} else {
			NSCAssert(NO, @"Shader uniformm 'vec4 %@' value must be passed using [NSValue valueWithGLKVector4:] or a CCColor object.", name);
		}
	};
}

static CCUniformSetter
GLUniformSetMat4(NSString *name, GLint location)
{
	return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
		NSValue *value = shaderUniforms[name] ?: globalShaderUniforms[name] ?: [NSValue valueWithGLKMatrix4:GLKMatrix4Identity];
		NSCAssert([value isKindOfClass:[NSValue class]], @"Shader uniform '%@' value must be wrapped in a NSValue.", name);
		NSCAssert(strcmp(value.objCType, @encode(GLKMatrix4)) == 0, @"Shader uniformm 'mat4 %@' value must be passed using [NSValue valueWithGLKMatrix4:]", name);
		
		GLKMatrix4 m; [value getValue:&m];
		glUniformMatrix4fv(location, 1, GL_FALSE, m.m);
	};
}

static NSDictionary *
GLUniformSettersForProgram(GLuint program)
{
	NSMutableDictionary *uniformSetters = [NSMutableDictionary dictionary];
	
	glUseProgram(program);
	
	GLint count = 0;
	glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &count);
	
	int textureUnit = 0;
	
	for(int i=0; i<count; i++){
		GLchar cname[256];
		GLsizei length = 0;
		GLsizei size = 0;
		GLenum type = 0;
		
		glGetActiveUniform(program, i, sizeof(cname), &length, &size, &type, cname);
		NSCAssert(size == 1, @"Uniform arrays not supported. (yet?)");
		
		NSString *name = @(cname);
		GLint location = glGetUniformLocation(program, cname);
		
		// Setup a block that is responsible for binding that uniform variable's value.
		switch(type){
			default: NSCAssert(NO, @"Uniform type not supported. (yet?)");
			case GL_FLOAT: uniformSetters[name] = GLUniformSetFloat(name, location); break;
			case GL_FLOAT_VEC2: uniformSetters[name] = GLUniformSetVec2(name, location); break;
			case GL_FLOAT_VEC3: uniformSetters[name] = GLUniformSetVec3(name, location); break;
			case GL_FLOAT_VEC4: uniformSetters[name] = GLUniformSetVec4(name, location); break;
			case GL_FLOAT_MAT4: uniformSetters[name] = GLUniformSetMat4(name, location); break;
			case GL_SAMPLER_2D: {
				// Sampler setters are handled a differently since the real work is binding the texture and not setting the uniform value.
				uniformSetters[name] = ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
					CCTexture *texture = shaderUniforms[name] ?: globalShaderUniforms[name] ?: [CCTexture none];
					NSCAssert([texture isKindOfClass:[CCTexture class]], @"Shader uniform '%@' value must be a CCTexture object.", name);
					
					// Bind the texture to the texture unit for the uniform.
					glActiveTexture(GL_TEXTURE0 + textureUnit);
					glBindTexture(GL_TEXTURE_2D, texture.name);
				};
				
				// Bind the texture unit at init time.
				glUniform1i(location, textureUnit);
				textureUnit++;
			}
		}
	}
	
	return uniformSetters;
}

//MARK: Init Methods:

-(instancetype)initWithGLProgram:(GLuint)program uniformSetters:(NSDictionary *)uniformSetters ownsProgram:(BOOL)ownsProgram
{
	NSAssert([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIGL, @"GL graphics not configured.");
	
	if((self = [super init])){
		_program = program;
		_uniformSetters = uniformSetters;
		_ownsProgram = ownsProgram;
	}
	
	return self;
}

#if __CC_METAL_SUPPORTED_AND_ENABLED

static CCUniformSetter
MetalUniformSetBuffer(NSString *name, MTLArgument *vertexArg, MTLArgument *fragmentArg)
{
	NSUInteger vertexIndex = vertexArg.index;
	NSUInteger fragmentIndex = fragmentArg.index;
	
	// vertexArg may be nil.
	size_t bytes = (vertexArg.bufferDataSize ?: fragmentArg.bufferDataSize);
	
	CCMetalContext *context = [CCMetalContext currentContext];
	
	// Handle cc_VertexAttributes specially.
	if([name isEqualToString:@"cc_VertexAttributes"]){
		NSCAssert(vertexArg && !fragmentArg, @"cc_VertexAttributes should only be used by vertex functions.");
		NSCAssert(bytes == sizeof(CCVertex), @"cc_VertexAttributes data size is not sizeof(CCVertex).");
		
		return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
			CCGraphicsBufferMetal *vertexBuffer = (CCGraphicsBufferMetal *)renderer->_buffers->_vertexBuffer;
			id<MTLBuffer> metalBuffer = vertexBuffer->_buffer;
			
			NSUInteger pageOffset = renderer->_vertexPageBound*(1<<16)*sizeof(CCVertex);
			[context->_currentRenderCommandEncoder setVertexBuffer:metalBuffer offset:pageOffset atIndex:vertexIndex];
		};
	} else {
		// If both args are active, they must match.
		NSCAssert(!vertexArg || !fragmentArg || vertexArg.bufferDataSize == fragmentArg.bufferDataSize, @"Vertex and fragment argument type don't match for '%@'.", vertexArg.name);
		
		// Round up to the next multiple of 16 since Metal types have an alignment of 16 bytes at most.
		size_t alignedBytes = ((bytes - 1) | 0xF) + 1;
		
		return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
			CCGraphicsBufferMetal *uniformBuffer = (CCGraphicsBufferMetal *)renderer->_buffers->_uniformBuffer;
			id<MTLBuffer> metalBuffer = uniformBuffer->_buffer;
			
			NSUInteger offset = 0;
			
			NSValue *value = shaderUniforms[name];
			if(value){
				// Try finding a per-node value first and append it to the uniform buffer.
				void *buff = CCGraphicsBufferPushElements(uniformBuffer, alignedBytes);
				[value getValue:buff];
				
				offset = buff - uniformBuffer->_ptr;
			} else {
				// Look for a global offset instead.
				NSNumber *globalOffset = renderer->_globalShaderUniformBufferOffsets[name];
				NSCAssert(globalOffset, @"Shader value named '%@' not found.", name);
				
				offset = globalOffset.unsignedIntegerValue;
			}
			
			id<MTLRenderCommandEncoder> renderEncoder = context->_currentRenderCommandEncoder;
			if(vertexArg) [renderEncoder setVertexBuffer:metalBuffer offset:offset atIndex:vertexIndex];
			if(fragmentArg) [renderEncoder setFragmentBuffer:metalBuffer offset:offset atIndex:fragmentIndex];
		};
	}
}

static CCUniformSetter
MetalUniformSetSampler(NSString *name, MTLArgument *vertexArg, MTLArgument *fragmentArg)
{
	NSUInteger vertexIndex = vertexArg.index;
	NSUInteger fragmentIndex = fragmentArg.index;
	
	// For now, samplers and textures are locked together like in GL.
	NSString *textureName = [name substringToIndex:name.length - @"Sampler".length];
	
	CCMetalContext *context = [CCMetalContext currentContext];
	
	return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
		CCTexture *texture = shaderUniforms[textureName] ?: globalShaderUniforms[textureName] ?: [CCTexture none];
		NSCAssert([texture isKindOfClass:[CCTexture class]], @"Shader uniform '%@' value must be a CCTexture object.", name);
		
		id<MTLSamplerState> sampler = texture.metalSampler;
		
		id<MTLRenderCommandEncoder> renderEncoder = context->_currentRenderCommandEncoder;
		if(vertexArg) [renderEncoder setVertexSamplerState:sampler atIndex:vertexIndex];
		if(fragmentArg) [renderEncoder setFragmentSamplerState:sampler atIndex:fragmentIndex];
	};
}

static CCUniformSetter
MetalUniformSetTexture(NSString *name, MTLArgument *vertexArg, MTLArgument *fragmentArg)
{
	NSUInteger vertexIndex = vertexArg.index;
	NSUInteger fragmentIndex = fragmentArg.index;
	
	CCMetalContext *context = [CCMetalContext currentContext];
	
	return ^(CCRenderer *renderer, NSDictionary *shaderUniforms, NSDictionary *globalShaderUniforms){
		CCTexture *texture = shaderUniforms[name] ?: globalShaderUniforms[name] ?: [CCTexture none];
		NSCAssert([texture isKindOfClass:[CCTexture class]], @"Shader uniform '%@' value must be a CCTexture object.", name);
		
		id<MTLTexture> metalTexture = texture.metalTexture;
		
		id<MTLRenderCommandEncoder> renderEncoder = context->_currentRenderCommandEncoder;
		if(vertexArg) [renderEncoder setVertexTexture:metalTexture atIndex:vertexIndex];
		if(fragmentArg) [renderEncoder setFragmentTexture:metalTexture atIndex:fragmentIndex];
	};
}

static NSDictionary *
MetalUniformSettersForFunctions(id<MTLFunction> vertexFunction, id<MTLFunction> fragmentFunction)
{
	// Get the shader reflection information by making a dummy render pipeline state.
	MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
	descriptor.vertexFunction = vertexFunction;
	descriptor.fragmentFunction = fragmentFunction;
	
	NSError *error = nil;
	MTLRenderPipelineReflection *reflection = nil;
	[[CCMetalContext currentContext].device newRenderPipelineStateWithDescriptor:descriptor options:MTLPipelineOptionArgumentInfo reflection:&reflection error:&error];
	
	NSCAssert(!error, @"Error getting Metal shader arguments.");
	
	// Collect all of the arguments.
	NSMutableDictionary *vertexArgs = [NSMutableDictionary dictionary];
	for(MTLArgument *arg in reflection.vertexArguments){ if(arg.active){ vertexArgs[arg.name] = arg; }}
	
	NSMutableDictionary *fragmentArgs = [NSMutableDictionary dictionary];
	for(MTLArgument *arg in reflection.fragmentArguments){ if(arg.active){ fragmentArgs[arg.name] = arg; }}
	
	NSSet *argSet = [[NSSet setWithArray:vertexArgs.allKeys] setByAddingObjectsFromArray:fragmentArgs.allKeys];
	
	// Make uniform setters.
	NSMutableDictionary *uniformSetters = [NSMutableDictionary dictionary];
	
	for(NSString *name in argSet){
		MTLArgument *vertexArg = vertexArgs[name];
		MTLArgument *fragmentArg = fragmentArgs[name];
		
		// If neither argument is active. Skip.
		if(!vertexArg.active && !fragmentArg.active) continue;
		
		MTLArgumentType type = (vertexArg ? vertexArg.type : fragmentArg.type);
		NSCAssert(!vertexArg || !fragmentArg || type == fragmentArg.type, @"Vertex and fragment argument type don't match for '%@'.", name);
		
		switch(type){
			case MTLArgumentTypeBuffer: uniformSetters[name] = MetalUniformSetBuffer(name, vertexArg, fragmentArg); break;
			case MTLArgumentTypeSampler: uniformSetters[name] = MetalUniformSetSampler(name, vertexArg, fragmentArg); break;
			case MTLArgumentTypeTexture: uniformSetters[name] = MetalUniformSetTexture(name, vertexArg, fragmentArg); break;
			case MTLArgumentTypeThreadgroupMemory: NSCAssert(NO, @"Compute memory not supported. (yet?)"); break;
		}
	}
	
	return uniformSetters;
}

-(instancetype)initWithMetalVertexFunction:(id<MTLFunction>)vertexFunction fragmentFunction:(id<MTLFunction>)fragmentFunction
{
	if((self = [super init])){
		NSAssert(vertexFunction && fragmentFunction, @"Must have both a vertex and fragment function to make a CCShader.");
		
		_vertexFunction = vertexFunction;
		_fragmentFunction = fragmentFunction;
		
		_uniformSetters = MetalUniformSettersForFunctions(vertexFunction, fragmentFunction);
	}
	
	return self;
}

-(instancetype)initWithMetalVertexShaderSource:(NSString *)vertexSource fragmentShaderSource:(NSString *)fragmentSource
{
	CCMetalContext *context = [CCMetalContext currentContext];
	
	id<MTLFunction> vertexFunction = nil;
	if(vertexSource == CCDefaultVShader){
		// Use the default vertex shader.
		vertexFunction = [context.library newFunctionWithName:@"CCVertexFunctionDefault"];
	} else {
		// Append on the standard header since JIT compiled shaders can't use #import
		vertexSource = [CCMetalShaderHeader stringByAppendingString:vertexSource];
		
		// Compile the vertex shader.
		NSError *verr = nil;
		id<MTLLibrary> vlib = [context.device newLibraryWithSource:vertexSource options:nil error:&verr];
		if(verr) CCLOG(@"Error compiling metal vertex shader: %@", verr);
		
		vertexFunction = [vlib newFunctionWithName:@"ShaderMain"];
	}
	
	// Append on the standard header since JIT compiled shaders can't use #import
	fragmentSource = [CCMetalShaderHeader stringByAppendingString:fragmentSource];
	
	// compile the fragment shader.
	NSError *ferr = nil;
	id<MTLLibrary> flib = [context.device newLibraryWithSource:fragmentSource options:nil error:&ferr];
	if(ferr) CCLOG(@"Error compiling metal fragment shader: %@", ferr);
	
	id<MTLFunction> fragmentFunction = [flib newFunctionWithName:@"ShaderMain"];
	
	// Done!
	return [self initWithMetalVertexFunction:vertexFunction fragmentFunction:fragmentFunction];
}
#endif

-(instancetype)initWithGLVertexShaderSource:(NSString *)vertexSource fragmentShaderSource:(NSString *)fragmentSource
{
	__block typeof(self) blockself = self;
	
	CCRenderDispatch(NO, ^{
		CCGL_DEBUG_PUSH_GROUP_MARKER("CCShader: Init");
		
		GLuint program = glCreateProgram();
		glBindAttribLocation(program, CCShaderAttributePosition, "cc_Position");
		glBindAttribLocation(program, CCShaderAttributeTexCoord1, "cc_TexCoord1");
		glBindAttribLocation(program, CCShaderAttributeTexCoord2, "cc_TexCoord2");
		glBindAttribLocation(program, CCShaderAttributeColor, "cc_Color");
		
		GLint vshader = CompileShader(GL_VERTEX_SHADER, vertexSource.UTF8String);
		glAttachShader(program, vshader);
		
		GLint fshader = CompileShader(GL_FRAGMENT_SHADER, fragmentSource.UTF8String);
		glAttachShader(program, fshader);
		
		glLinkProgram(program);
		
		glDeleteShader(vshader);
		glDeleteShader(fshader);
		
		CCGL_DEBUG_POP_GROUP_MARKER();
		
		if(CCCheckShaderError(program, GL_LINK_STATUS, glGetProgramiv, glGetProgramInfoLog)){
			blockself = [blockself initWithGLProgram:program uniformSetters:GLUniformSettersForProgram(program) ownsProgram:YES];
		} else {
			glDeleteProgram(program);
			blockself = nil;
		}
	});
	
	return blockself;
}

-(instancetype)initWithVertexShaderSource:(NSString *)vertexSource fragmentShaderSource:(NSString *)fragmentSource
{
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		return [self initWithMetalVertexShaderSource:vertexSource fragmentShaderSource:fragmentSource];
	}
#endif
	{
		return [self initWithGLVertexShaderSource:vertexSource fragmentShaderSource:fragmentSource];
	}
}

-(instancetype)initWithFragmentShaderSource:(NSString *)source
{
	return [self initWithVertexShaderSource:CCDefaultVShader fragmentShaderSource:source];
}

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	GLuint program = _program;
	if(_ownsProgram && program){
		CCRenderDispatch(YES, ^{
			glDeleteProgram(program);
		});
	}
}

-(instancetype)copyWithZone:(NSZone *)zone
{
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		return [[CCShader allocWithZone:zone] initWithMetalVertexFunction:_vertexFunction fragmentFunction:_fragmentFunction];
	} else
#endif
	{
		return [[CCShader allocWithZone:zone] initWithGLProgram:_program uniformSetters:_uniformSetters ownsProgram:NO];
	}
}

static CCShaderCache *CC_SHADER_CACHE = nil;
static CCShader *CC_SHADER_POS_COLOR = nil;
static CCShader *CC_SHADER_POS_TEX_COLOR = nil;
static CCShader *CC_SHADER_POS_TEXA8_COLOR = nil;
static CCShader *CC_SHADER_POS_TEX_COLOR_ALPHA_TEST = nil;

+(void)initialize
{
	// +initialize may be called due to loading a subclass.
	if(self != [CCShader class]) return;
	
	NSAssert([CCConfiguration sharedConfiguration].graphicsAPI != CCGraphicsAPIInvalid, @"Graphics API not configured.");
	CC_SHADER_CACHE = [[CCShaderCache alloc] init];
	
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		id<MTLLibrary> library = [CCMetalContext currentContext].library;
		NSAssert(library, @"Metal shader library not found.");
		
		id<MTLFunction> vertex = [library newFunctionWithName:@"CCVertexFunctionDefault"];
		
		CC_SHADER_POS_COLOR = [[self alloc] initWithMetalVertexFunction:vertex fragmentFunction:[library newFunctionWithName:@"CCFragmentFunctionDefaultColor"]];
		CC_SHADER_POS_COLOR.debugName = @"CCPositionColorShader";
		
		CC_SHADER_POS_TEX_COLOR = [[self alloc] initWithMetalVertexFunction:vertex fragmentFunction:[library newFunctionWithName:@"CCFragmentFunctionDefaultTextureColor"]];
		CC_SHADER_POS_TEX_COLOR.debugName = @"CCPositionTextureColorShader";
		
		CC_SHADER_POS_TEXA8_COLOR = [[self alloc] initWithMetalVertexFunction:vertex fragmentFunction:[library newFunctionWithName:@"CCFragmentFunctionDefaultTextureA8Color"]];
		CC_SHADER_POS_TEXA8_COLOR.debugName = @"CCPositionTextureA8ColorShader";
		
		CC_SHADER_POS_TEX_COLOR_ALPHA_TEST = [[self alloc] initWithMetalVertexFunction:vertex fragmentFunction:[library newFunctionWithName:@"CCFragmentFunctionUnsupported"]];
		CC_SHADER_POS_TEX_COLOR_ALPHA_TEST.debugName = @"CCPositionTextureColorAlphaTestShader";
	} else
#endif
	{
		// Setup the builtin shaders.
		CC_SHADER_POS_COLOR = [[self alloc] initWithFragmentShaderSource:@"void main(){gl_FragColor = cc_FragColor;}"];
		CC_SHADER_POS_COLOR.debugName = @"CCPositionColorShader";
		
		CC_SHADER_POS_TEX_COLOR = [[self alloc] initWithFragmentShaderSource:@"void main(){gl_FragColor = cc_FragColor*texture2D(cc_MainTexture, cc_FragTexCoord1);}"];
		CC_SHADER_POS_TEX_COLOR.debugName = @"CCPositionTextureColorShader";
		
		CC_SHADER_POS_TEXA8_COLOR = [[self alloc] initWithFragmentShaderSource:@"void main(){gl_FragColor = cc_FragColor*texture2D(cc_MainTexture, cc_FragTexCoord1).a;}"];
		CC_SHADER_POS_TEXA8_COLOR.debugName = @"CCPositionTextureA8ColorShader";
		
		CC_SHADER_POS_TEX_COLOR_ALPHA_TEST = [[self alloc] initWithFragmentShaderSource:CC_GLSL(
			uniform float cc_AlphaTestValue;
			void main(){
				vec4 tex = texture2D(cc_MainTexture, cc_FragTexCoord1);
				if(tex.a <= cc_AlphaTestValue) discard;
				gl_FragColor = cc_FragColor*tex;
			}
		)];
		CC_SHADER_POS_TEX_COLOR_ALPHA_TEST.debugName = @"CCPositionTextureColorAlphaTestShader";
	}
}

+(instancetype)positionColorShader
{
	return CC_SHADER_POS_COLOR;
}

+(instancetype)positionTextureColorShader
{
	return CC_SHADER_POS_TEX_COLOR;
}

+(instancetype)positionTextureColorAlphaTestShader
{
	return CC_SHADER_POS_TEX_COLOR_ALPHA_TEST;
}

+(instancetype)positionTextureA8ColorShader
{
	return CC_SHADER_POS_TEXA8_COLOR;
}

+(instancetype)shaderNamed:(NSString *)shaderName
{
	return [CC_SHADER_CACHE objectForKey:shaderName];
}

@end
