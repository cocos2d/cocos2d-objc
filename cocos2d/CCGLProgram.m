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


#import "CCGLProgram.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"
#import "Support/uthash.h"
#import "Support/OpenGL_Internal.h"
#import "CCRenderer_private.h"
#import "CCTexture_private.h"

#import "CCDirector.h"


enum {
	CCAttributePosition,
	CCAttributeTexCoord0,
	CCAttributeTexCoord1,
	CCAttributeColor,
};


@implementation CCGLProgram {
	NSMutableDictionary *_uniformSetters;
}

+(GLuint)createVAOforCCVertexBuffer:(GLuint)vbo
{
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	
	GLuint vao = 0;
	glGenVertexArraysOES(1, &vao);
	glBindVertexArrayOES(vao);

	glEnableVertexAttribArray(CCAttributePosition);
	glEnableVertexAttribArray(CCAttributeTexCoord0);
	glEnableVertexAttribArray(CCAttributeTexCoord1);
	glEnableVertexAttribArray(CCAttributeColor);
	
	glVertexAttribPointer(CCAttributePosition, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, position));
	glVertexAttribPointer(CCAttributeTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord1));
	glVertexAttribPointer(CCAttributeTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord1));
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
	"uniform highp vec4 cc_Time;\n"
	"uniform highp vec4 cc_SinTime;\n"
	"uniform highp vec4 cc_CosTime;\n"
	"uniform highp vec4 cc_Random01;\n\n"
	"uniform sampler2D cc_MainTexture;\n\n"
	"varying lowp vec4 cc_FragColor;\n"
	"varying highp vec2 cc_FragTexCoord0;\n"
	"varying highp vec2 cc_FragTexCoord1;\n\n"
	"// End Cocos2D shader header.\n\n";

static const GLchar *CCVertexShaderHeader =
	"precision highp float;\n\n"
	"attribute vec4 cc_Position;\n"
	"attribute vec2 cc_TexCoord0;\n"
	"attribute vec2 cc_TexCoord1;\n"
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

static void
LinkProgram(GLint program, GLint vshader, GLint fshader)
{
	glAttachShader(program, vshader);
	glAttachShader(program, fshader);
	glLinkProgram(program);
	
	// todo return placeholder program instead?
	NSCAssert(CCCheckShaderError(program, GL_LINK_STATUS, glGetProgramiv, glGetProgramInfoLog), @"Error linking shader program");
}

- (id)initWithVertexShaderByteArray:(const GLchar *)vShaderByteArray fragmentShaderByteArray:(const GLchar *)fShaderByteArray
{
	if((self = [super init])){
		GLint vshader = CompileShader(GL_VERTEX_SHADER, vShaderByteArray);
		GLint fshader = CompileShader(GL_FRAGMENT_SHADER, fShaderByteArray);
		
		_program = glCreateProgram();
		glBindAttribLocation(_program, CCAttributePosition, "cc_Position");
		glBindAttribLocation(_program, CCAttributeTexCoord0, "cc_TexCoord0");
		glBindAttribLocation(_program, CCAttributeTexCoord1, "cc_TexCoord1");
		glBindAttribLocation(_program, CCAttributeColor, "cc_Color");
		LinkProgram(_program, vshader, fshader);
		
		glDeleteShader(vshader);
		glDeleteShader(fshader);
		
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
			
			if(type == GL_FLOAT){
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, id value){
					glUniform1f(i, [value floatValue]);
				};
			} else if(type == GL_FLOAT_VEC2){
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, id value){
					GLKVector2 v; [(NSValue *)value getValue:&v];
					glUniform2f(i, v.x, v.y);
				};
			} else if(type == GL_FLOAT_VEC3){
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, id value){
					GLKVector3 v; [(NSValue *)value getValue:&v];
					glUniform3f(i, v.x, v.y, v.z);
				};
			} else if(type == GL_FLOAT_VEC4){
				_uniformSetters[@(name)] = ^(CCRenderer *renderer, id value){
					GLKVector4 v; [(NSValue *)value getValue:&v];
					glUniform4f(i, v.x, v.y, v.z, v.w);
				};
//			} else if(type == GL_FLOAT_MAT4){
//				_uniformSetters[@(name)] = ^(CCRenderer *renderer, id value){glUniform1f(i, [value floatValue]);};
			} else if(type == GL_SAMPLER_2D){
				_uniformSetters[@(name)] = [^(CCRenderer *renderer, id value){
					glActiveTexture(GL_TEXTURE0 + textureUnit);
					glBindTexture(GL_TEXTURE_2D, [(CCTexture *)value name]);
				} copy];
				
				glUniform1i(i, textureUnit);
				textureUnit++;
			} else {
				NSAssert(NO, @"Uniform type not supported. (yet?)");
			}
		}
	}
	
	return self;
}

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	if(_program) glDeleteProgram(_program);
}

static const char CCDefaultVShader[] = CC_GLSL(
	void main()
	{
		gl_Position = cc_Position;
		cc_FragColor = cc_Color;
		cc_FragTexCoord0 = cc_TexCoord0;
		cc_FragTexCoord1 = cc_TexCoord1;
	}
);

+(instancetype)positionColorShader
{
	static CCGLProgram *shader = nil;
	if(!shader){
		GLchar *fragShader = "void main(){gl_FragColor = cc_FragColor;}";
		shader = [[self alloc] initWithVertexShaderByteArray:CCDefaultVShader fragmentShaderByteArray:fragShader];
	}
	
	return shader;
}

+(instancetype)positionTextureColorShader
{
	static CCGLProgram *shader = nil;
	if(!shader){
		GLchar *fragShader = "void main(){gl_FragColor = cc_FragColor * texture2D(cc_MainTexture, cc_FragTexCoord0);}";
		shader = [[self alloc] initWithVertexShaderByteArray:CCDefaultVShader fragmentShaderByteArray:fragShader];
	}
	
	return shader;
}

+(instancetype)positionTextureA8ColorShader
{
	static CCGLProgram *shader = nil;
	if(!shader){
		GLchar *fragShader = "void main(){gl_FragColor = vec4(cc_FragColor.rgb, cc_FragColor.a * texture2D(cc_MainTexture, cc_FragTexCoord0).a);}";
		shader = [[self alloc] initWithVertexShaderByteArray:CCDefaultVShader fragmentShaderByteArray:fragShader];
	}
	
	return shader;
}

-(void)use
{
	glUseProgram(_program);
}

@end
