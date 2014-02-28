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

#import "CCDirector.h"


typedef struct _hashUniformEntry
{
	GLvoid			*value;		// value
    size_t          length;
	NSUInteger		location;	// Key
	UT_hash_handle  hh;			// hash entry
} tHashUniformEntry;


#pragma mark Function Pointer Definitions
typedef void (*GLInfoFunction)(GLuint program,
                               GLenum pname,
                               GLint* params);
typedef void (*GLLogFunction) (GLuint program,
                               GLsizei bufsize,
                               GLsizei* length,
                               GLchar* infolog);
#pragma mark -
#pragma mark Private Extension Method Declaration

@interface CCGLProgram()
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type byteArray:(const GLchar*)byteArray;

- (NSString *)logForOpenGLObject:(GLuint)object infoCallback:(GLInfoFunction)infoFunc logFunc:(GLLogFunction)logFunc;
@end

#pragma mark -

@implementation CCGLProgram

@synthesize program = _program;

+ (id)programWithVertexShaderByteArray:(const GLchar*)vShaderByteArray fragmentShaderByteArray:(const GLchar*)fShaderByteArray
{
	return [[self alloc] initWithVertexShaderByteArray:vShaderByteArray fragmentShaderByteArray:fShaderByteArray];
}

+ (id)programWithVertexShaderFilename:(NSString *)vShaderFilename fragmentShaderFilename:(NSString *)fShaderFilename
{
	return [[self alloc] initWithVertexShaderFilename:vShaderFilename fragmentShaderFilename:fShaderFilename];
}

#define	kCCAttributeNameColor			@"a_color"
#define	kCCAttributeNamePosition		@"a_position"
#define	kCCAttributeNameTexCoord		@"a_texCoord"

- (id)initWithVertexShaderByteArray:(const GLchar *)vShaderByteArray fragmentShaderByteArray:(const GLchar *)fShaderByteArray
{
    if ((self = [super init]) )
    {
        _program = glCreateProgram();
		
		_vertShader = _fragShader = 0;
		
		if( vShaderByteArray ) {
			
			if (![self compileShader:&_vertShader
								type:GL_VERTEX_SHADER
						   byteArray:vShaderByteArray] )
				CCLOG(@"cocos2d: ERROR: Failed to compile vertex shader");
		}
		
        // Create and compile fragment shader
		if( fShaderByteArray ) {
			if (![self compileShader:&_fragShader
								type:GL_FRAGMENT_SHADER
						   byteArray:fShaderByteArray] )

				CCLOG(@"cocos2d: ERROR: Failed to compile fragment shader");
		}
		
		if( _vertShader )
			glAttachShader(_program, _vertShader);
		
		if( _fragShader )
			glAttachShader(_program, _fragShader);
		
		_hashForUniforms = NULL;
		
		[self addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
		[self addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
		[self addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];

		[self link];
    }
	
    return self;
}

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename fragmentShaderFilename:(NSString *)fShaderFilename
{
	NSString *v = [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:vShaderFilename];
	NSString *f = [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:fShaderFilename];
	if( !(v || f) ) {
		if(!v)
			CCLOGWARN(@"Could not open vertex shader: %@", vShaderFilename);
		if(!f)
			CCLOGWARN(@"Could not open fragment shader: %@", fShaderFilename);
		return nil;
	}
	const GLchar * vertexSource = (GLchar*) [[NSString stringWithContentsOfFile:v encoding:NSUTF8StringEncoding error:nil] UTF8String];
	const GLchar * fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:f encoding:NSUTF8StringEncoding error:nil] UTF8String];

	return [self initWithVertexShaderByteArray:vertexSource fragmentShaderByteArray:fragmentSource];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Program = %i, VertexShader = %i, FragmentShader = %i>", [self class], self, _program, _vertShader, _fragShader];
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type byteArray:(const GLchar *)source
{
    GLint status;

    if (!source)
        return NO;
		
		const GLchar *sources[] = {
#ifdef __CC_PLATFORM_IOS
			(type == GL_VERTEX_SHADER ? "precision highp float;\n" : "precision mediump float;\n"),
#endif
			"uniform mat4 CC_PMatrix;\n"
			"uniform mat4 CC_MVMatrix;\n"
			"uniform mat4 CC_MVPMatrix;\n"
			"uniform vec4 CC_Time;\n"
			"uniform vec4 CC_SinTime;\n"
			"uniform vec4 CC_CosTime;\n"
			"uniform vec4 CC_Random01;\n"
			"//CC INCLUDES END\n\n",
			source,
		};
		
    *shader = glCreateShader(type);
    glShaderSource(*shader, sizeof(sources)/sizeof(*sources), sources, NULL);
    glCompileShader(*shader);
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	
	if( ! status ) {
		GLsizei length;
		glGetShaderiv(*shader, GL_SHADER_SOURCE_LENGTH, &length);
		GLchar src[length];
		
		glGetShaderSource(*shader, length, NULL, src);
		CCLOG(@"cocos2d: ERROR: Failed to compile shader:\n%s", src);
		
		if( type == GL_VERTEX_SHADER )
			CCLOG(@"cocos2d: %@", [self vertexShaderLog] );
		else
			CCLOG(@"cocos2d: %@", [self fragmentShaderLog] );
		
		abort();
	}
    return ( status == GL_TRUE );
}

#pragma mark -

- (void)addAttribute:(NSString *)attributeName index:(GLuint)index
{
	glBindAttribLocation(_program,
						 index,
						 [attributeName UTF8String]);
}

#pragma mark -

-(BOOL) link
{
    NSAssert(_program != 0, @"Cannot link invalid program");
	
    GLint status = GL_TRUE;
    glLinkProgram(_program);
	
    if (_vertShader)
        glDeleteShader(_vertShader);

    if (_fragShader)
        glDeleteShader(_fragShader);

    _vertShader = _fragShader = 0;
	
#if DEBUG
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    NSString* log = self.programLog;
	
    if (status == GL_FALSE) {
        NSLog(@"cocos2d: ERROR: Failed to link program: %i - %@", _program, log);
        glDeleteProgram(_program);
        _program = 0;
    }
#endif
	
    return (status == GL_TRUE);
}

-(void) use
{
	glUseProgram(_program);
}

#pragma mark -

-(NSString *) logForOpenGLObject:(GLuint)object
					infoCallback:(GLInfoFunction)infoFunc
						 logFunc:(GLLogFunction)logFunc
{
	GLint logLength = 0, charsWritten = 0;

	infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength < 1)
		return nil;

	char *logBytes = malloc(logLength);
	logFunc(object, logLength, &charsWritten, logBytes);
	NSString *log = [[NSString alloc] initWithBytes:logBytes
											  length:logLength
											encoding:NSUTF8StringEncoding];
	free(logBytes);
	return log;
}

#pragma mark -

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	// there is no need to delete the shaders. They should have been already deleted.
	NSAssert( _vertShader == 0, @"Vertex Shaders should have been already deleted");
	NSAssert( _fragShader == 0, @"Fragment Shaders should have been already deleted");

	if (_program)
		glDeleteProgram(_program);

	tHashUniformEntry *current_element, *tmp;

	// Purge uniform hash
	HASH_ITER(hh, _hashForUniforms, current_element, tmp) {
		HASH_DEL(_hashForUniforms, current_element);
		free(current_element->value);
		free(current_element);
	}

}
@end
