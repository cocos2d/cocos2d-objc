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


#import "CCGLProgram_private.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"
#import "Support/uthash.h"
#import "Support/OpenGL_Internal.h"
#import "CCRenderer_private.h"
#import "CCTexture_private.h"

#import "CCDirector.h"


enum {
	CCAttributePosition,
	CCAttributeTexCoord1,
	CCAttributeTexCoord2,
	CCAttributeColor,
};


@implementation CCGLProgram

+(GLuint)createVAOforCCVertexBuffer:(GLuint)vbo
{
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	
	GLuint vao = 0;
	glGenVertexArraysOES(1, &vao);
	glBindVertexArrayOES(vao);

	glEnableVertexAttribArray(CCAttributePosition);
	glEnableVertexAttribArray(CCAttributeTexCoord1);
	glEnableVertexAttribArray(CCAttributeTexCoord2);
	glEnableVertexAttribArray(CCAttributeColor);
	
	glVertexAttribPointer(CCAttributePosition, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, position));
	glVertexAttribPointer(CCAttributeTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord1));
	glVertexAttribPointer(CCAttributeTexCoord2, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord2));
	glVertexAttribPointer(CCAttributeColor, 4, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, color));

	glBindVertexArrayOES(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	return vao;
}

typedef void (* GetShaderivFunc) (GLuint shader, GLenum pname, GLint* param);
typedef void (* GetShaderInfoLogFunc) (GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* infoLog);

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

/*
	viewport size points/pixels
	main texture size points/pixels
*/
static const GLchar *CCShaderHeader =
	"uniform highp vec2 cc_Projection;\n"
	"uniform highp vec2 cc_ProjectionInv;\n"
	"uniform highp vec2 cc_ViewSize;\n"
	"uniform highp vec2 cc_ViewSizeInPixels;\n"
	"uniform highp vec4 cc_Time;\n"
	"uniform highp vec4 cc_SinTime;\n"
	"uniform highp vec4 cc_CosTime;\n"
	"uniform highp vec4 cc_Random01;\n\n"
	"uniform sampler2D cc_MainTexture;\n\n"
	"varying lowp vec4 cc_FragColor;\n"
	"varying highp vec2 cc_FragTexCoord1;\n"
	"varying highp vec2 cc_FragTexCoord2;\n\n"
	"// End Cocos2D shader header.\n\n";

static const GLchar *CCVertexShaderHeader =
	"precision highp float;\n\n"
	"attribute vec4 cc_Position;\n"
	"attribute vec2 cc_TexCoord1;\n"
	"attribute vec2 cc_TexCoord2;\n"
	"attribute vec4 cc_Color;\n\n"
	"// End Cocos2D vertex shader header.\n\n";

static const GLchar *CCFragmentShaderHeader =
	"precision lowp float;\n\n"
	"// End Cocos2D fragment shader header.\n\n";

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
	
	NSCAssert(CCCheckShaderError(shader, GL_COMPILE_STATUS, glGetShaderiv, glGetShaderInfoLog), @"Error compiling shader");
	
	return shader;
}

-(void)setupUniforms
{
	_uniformSetters = [NSMutableDictionary dictionary];
	
	glUseProgram(_program);
	
	GLint count = 0;
	glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &count);
	
	int textureUnit = 0;
	
	for(int i=0; i<count; i++){
		GLchar name[256];
		GLsizei length = 0;
		GLsizei size = 0;
		GLenum type = 0;
		
		glGetActiveUniform(_program, i, sizeof(name), &length, &size, &type, name);
		NSAssert(size == 1, @"Uniform arrays not supported. (yet?)");
		
		// Setup a block that is responsible for binding that uniform variable's value.
		switch(type){
			case GL_FLOAT: {
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, NSNumber *value){
					glUniform1f(i, value.floatValue);
				};
			}; break;
			case GL_FLOAT_VEC2: {
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, NSValue *value){
					GLKVector2 v; [(NSValue *)value getValue:&v];
					glUniform2f(i, v.x, v.y);
				};
			}; break;
			case GL_FLOAT_VEC3: {
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, NSValue *value){
					GLKVector3 v; [(NSValue *)value getValue:&v];
					glUniform3f(i, v.x, v.y, v.z);
				};
			}; break;
			case GL_FLOAT_VEC4: {
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, NSValue *value){
					GLKVector4 v; [(NSValue *)value getValue:&v];
					glUniform4f(i, v.x, v.y, v.z, v.w);
				};
			}; break;
#warning TODO
//			case GL_FLOAT_MAT4: {
//			}; break;
			case GL_SAMPLER_2D: {
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, CCTexture *texture){
					// Bind the texture to the texture unit for the uniform.
					glActiveTexture(GL_TEXTURE0 + textureUnit);
					glBindTexture(GL_TEXTURE_2D, texture.name);
				};
				
				// Bind the texture unit at init time.
				glUniform1i(i, textureUnit);
				textureUnit++;
			}; break;
			default: NSAssert(NO, @"Uniform type not supported. (yet?)");
		}
	}
}

-(instancetype)initWithVertexShaderSource:(NSString *)vertexSource fragmentShaderSource:(NSString *)fragmentSource
{
	if((self = [super init])){
		_program = glCreateProgram();
		glBindAttribLocation(_program, CCAttributePosition, "cc_Position");
		glBindAttribLocation(_program, CCAttributeTexCoord1, "cc_TexCoord1");
		glBindAttribLocation(_program, CCAttributeTexCoord2, "cc_TexCoord2");
		glBindAttribLocation(_program, CCAttributeColor, "cc_Color");
		
		GLint vshader = CompileShader(GL_VERTEX_SHADER, vertexSource.UTF8String);
		glAttachShader(_program, vshader);
		
		GLint fshader = CompileShader(GL_FRAGMENT_SHADER, fragmentSource.UTF8String);
		glAttachShader(_program, fshader);
		
		glLinkProgram(_program);
		NSCAssert(CCCheckShaderError(_program, GL_LINK_STATUS, glGetProgramiv, glGetProgramInfoLog), @"Error linking shader program");
		
		glDeleteShader(vshader);
		glDeleteShader(fshader);
		
		[self setupUniforms];
	}
	
	return self;
}

static NSString *CCDefaultVShader =
	@"void main(){\n"
	@"	gl_Position = cc_Position;\n"
	@"	cc_FragColor = cc_Color;\n"
	@"	cc_FragTexCoord1 = cc_TexCoord1;\n"
	@"	cc_FragTexCoord2 = cc_TexCoord2;\n"
	@"}\n";

-(instancetype)initWithFragmentShaderSource:(NSString *)source
{
	return [self initWithVertexShaderSource:CCDefaultVShader fragmentShaderSource:source];
}

//-(instancetype)initWithShaderNamed:(NSString *)shader
//{
//	
//	NSString *v = [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:vShaderFilename];
//	NSString *f = [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:fShaderFilename];
//	if( !(v || f) ) {
//		if(!v)
//			CCLOGWARN(@"Could not open vertex shader: %@", vShaderFilename);
//		if(!f)
//			CCLOGWARN(@"Could not open fragment shader: %@", fShaderFilename);
//		return nil;
//	}
//	const GLchar * vertexSource = (GLchar*) [[NSString stringWithContentsOfFile:v encoding:NSUTF8StringEncoding error:nil] UTF8String];
//	const GLchar * fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:f encoding:NSUTF8StringEncoding error:nil] UTF8String];
//
//	return [self initWithVertexShaderByteArray:vertexSource fragmentShaderByteArray:fragmentSource];
//}

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	if(_program) glDeleteProgram(_program);
}

static CCGLProgram *CC_SHADER_POS_COLOR = nil;
static CCGLProgram *CC_SHADER_POS_TEX_COLOR = nil;
static CCGLProgram *CC_SHADER_POS_TEXA8_COLOR = nil;

+(void)initialize
{
	// Setup the builtin shaders.
	CC_SHADER_POS_COLOR = [[self alloc] initWithVertexShaderSource:CCDefaultVShader fragmentShaderSource:
		@"void main(){gl_FragColor = cc_FragColor;}"];
	
	CC_SHADER_POS_TEX_COLOR = [[self alloc] initWithVertexShaderSource:CCDefaultVShader fragmentShaderSource:
		@"void main(){gl_FragColor = cc_FragColor * texture2D(cc_MainTexture, cc_FragTexCoord1);}"];
	
	CC_SHADER_POS_TEXA8_COLOR = [[self alloc] initWithVertexShaderSource:CCDefaultVShader fragmentShaderSource:
		@"void main(){gl_FragColor = vec4(cc_FragColor.rgb, cc_FragColor.a * texture2D(cc_MainTexture, cc_FragTexCoord1).a);}"];
}

+(instancetype)positionColorShader
{
	return CC_SHADER_POS_COLOR;
}

+(instancetype)positionTextureColorShader
{
	return CC_SHADER_POS_TEX_COLOR;
}

+(instancetype)positionTextureA8ColorShader
{
	return CC_SHADER_POS_TEXA8_COLOR;
}

@end
