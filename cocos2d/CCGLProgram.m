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
#import "ccGLStateCache.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"
#import "Support/uthash.h"
#import "Support/OpenGL_Internal.h"

// extern
#import "kazmath/GL/matrix.h"
#import "kazmath/kazmath.h"


typedef struct _hashUniformEntry
{
	GLvoid			*value;		// value
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
- (id)initWithVertexShaderByteArray:(const GLchar *)vShaderByteArray fragmentShaderByteArray:(const GLchar *)fShaderByteArray
{
    if ((self = [super init]) )
    {
        program_ = glCreateProgram();
		
		vertShader_ = fragShader_ = 0;
		
		if( vShaderByteArray ) {
			
			if (![self compileShader:&vertShader_
								type:GL_VERTEX_SHADER
						   byteArray:vShaderByteArray] )
				CCLOG(@"cocos2d: ERROR: Failed to compile vertex shader");
		}
		
        // Create and compile fragment shader
		if( fShaderByteArray ) {
			if (![self compileShader:&fragShader_
								type:GL_FRAGMENT_SHADER
						   byteArray:fShaderByteArray] )

				CCLOG(@"cocos2d: ERROR: Failed to compile fragment shader");
		}
		
		if( vertShader_ )
			glAttachShader(program_, vertShader_);
		
		if( fragShader_ )
			glAttachShader(program_, fragShader_);
		
		hashForUniforms_ = NULL;
    }
	
    return self;
}

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename fragmentShaderFilename:(NSString *)fShaderFilename
{
	
	const GLchar * vertexSource = (GLchar*) [[NSString stringWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:vShaderFilename] encoding:NSUTF8StringEncoding error:nil] UTF8String];
	const GLchar * fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:fShaderFilename] encoding:NSUTF8StringEncoding error:nil] UTF8String];

	return [self initWithVertexShaderByteArray:vertexSource fragmentShaderByteArray:fragmentSource];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Program = %i, VertexShader = %i, FragmentShader = %i>", [self class], self, program_, vertShader_, fragShader_];
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type byteArray:(const GLchar *)source
{
    GLint status;

    if (!source)
        return NO;
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	
	if( ! status ) {
		if( type == GL_VERTEX_SHADER )
			CCLOG(@"cocos2d: %@", [self vertexShaderLog] );
		else
			CCLOG(@"cocos2d: %@", [self fragmentShaderLog] );
		
	}
    return ( status == GL_TRUE );
}

#pragma mark -

- (void)addAttribute:(NSString *)attributeName index:(GLuint)index
{
	glBindAttribLocation(program_,
						 index,
						 [attributeName UTF8String]);
}

-(void) updateUniforms
{
	// Since sample most probably won't change, set it to 0 now.

	uniforms_[kCCUniformMVPMatrix] = glGetUniformLocation(program_, kCCUniformMVPMatrix_s);

	uniforms_[kCCUniformSampler] = glGetUniformLocation(program_, kCCUniformSampler_s);

	[self use];
	
	[self setUniformLocation:uniforms_[kCCUniformSampler] withI1:0];
}

#pragma mark -

- (BOOL)link
{
    glLinkProgram(program_);

#if DEBUG
	GLint status;
    glValidateProgram(program_);

    glGetProgramiv(program_, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
		CCLOG(@"cocos2d: ERROR: Failed to link program: %i", program_);
		if( vertShader_ )
			glDeleteShader( vertShader_ );
		if( fragShader_ )
			glDeleteShader( fragShader_ );
		ccGLDeleteProgram( program_ );
		vertShader_ = fragShader_ = program_ = 0;
        return NO;
	}
#endif

    if (vertShader_)
        glDeleteShader(vertShader_);
    if (fragShader_)
        glDeleteShader(fragShader_);

	vertShader_ = fragShader_ = 0;

    return YES;
}

- (void)use
{
    ccGLUseProgram(program_);
}

#pragma mark -

- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc
{
    GLint logLength = 0, charsWritten = 0;

    infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength < 1)
        return nil;

    char *logBytes = malloc(logLength);
    logFunc(object, logLength, &charsWritten, logBytes);
    NSString *log = [[[NSString alloc] initWithBytes:logBytes
                                              length:logLength
                                            encoding:NSUTF8StringEncoding]
                      autorelease];
    free(logBytes);
    return log;
}

- (NSString *)vertexShaderLog
{
    return [self logForOpenGLObject:vertShader_
                       infoCallback:(GLInfoFunction)&glGetShaderiv
                            logFunc:(GLLogFunction)&glGetShaderInfoLog];

}

- (NSString *)fragmentShaderLog
{
	return [self logForOpenGLObject:fragShader_
					   infoCallback:(GLInfoFunction)&glGetShaderiv
							logFunc:(GLLogFunction)&glGetShaderInfoLog];
}

- (NSString *)programLog
{
    return [self logForOpenGLObject:program_
                       infoCallback:(GLInfoFunction)&glGetProgramiv
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
}

#pragma mark - Uniform cache

-(BOOL) updateUniformLocation:(NSUInteger)location withData:(GLvoid*)data sizeOfData:(NSUInteger)bytes
{
	BOOL updated = YES;
	tHashUniformEntry *element = NULL;
	HASH_FIND_INT(hashForUniforms_, &location, element);
	
	if( ! element ) {

		element = malloc( sizeof(*element) );

		// key
		element->location = location;

		// value
		element->value = malloc( bytes );
		memcpy(element->value, data, bytes );
		
		HASH_ADD_INT(hashForUniforms_, location, element);
	}
	else
	{
		if( memcmp( element->value, data, bytes) == 0 )
			updated = NO;
		else
			memcpy( element->value, data, bytes );
	}
	
	return updated;
}

-(void) setUniformLocation:(NSUInteger)location withI1:(GLint)i1
{
	BOOL updated =  [self updateUniformLocation:location withData:&i1 sizeOfData:sizeof(i1)*1];
	
	if( updated )
		glUniform1i( (GLint)location, i1);
}

-(void) setUniformLocation:(NSUInteger)location withF1:(GLfloat)f1
{
	BOOL updated =  [self updateUniformLocation:location withData:&f1 sizeOfData:sizeof(f1)*1];
	
	if( updated )
		glUniform1f( (GLint)location, f1);
}

-(void) setUniformLocation:(NSUInteger)location withF1:(GLfloat)f1 f2:(GLfloat)f2
{
	GLfloat floats[2] = {f1,f2};
	BOOL updated =  [self updateUniformLocation:location withData:floats sizeOfData:sizeof(floats)];
	
	if( updated )
		glUniform2f( (GLint)location, f1, f2);
}

-(void) setUniformLocation:(NSUInteger)location withF1:(GLfloat)f1 f2:(GLfloat)f2 f3:(GLfloat)f3
{
	GLfloat floats[3] = {f1,f2,f3};
	BOOL updated =  [self updateUniformLocation:location withData:floats sizeOfData:sizeof(floats)];
	
	if( updated )
		glUniform3f( (GLint)location, f1, f2, f3);
}

-(void) setUniformLocation:(NSUInteger)location withF1:(GLfloat)f1 f2:(GLfloat)f2 f3:(GLfloat)f3 f4:(GLfloat)f4
{
	GLfloat floats[4] = {f1,f2,f3,f4};
	BOOL updated =  [self updateUniformLocation:location withData:floats sizeOfData:sizeof(floats)];
	
	if( updated )
		glUniform4f( (GLint)location, f1, f2, f3,f4);
}

-(void) setUniformLocation:(NSUInteger)location with2fv:(GLfloat*)floats count:(NSUInteger)numberOfArrays
{
	BOOL updated =  [self updateUniformLocation:location withData:floats sizeOfData:sizeof(float)*2*numberOfArrays];
	
	if( updated )
		glUniform2fv( (GLint)location, (GLsizei)numberOfArrays, floats );
}

-(void) setUniformLocation:(NSUInteger)location with3fv:(GLfloat*)floats count:(NSUInteger)numberOfArrays
{
	BOOL updated =  [self updateUniformLocation:location withData:floats sizeOfData:sizeof(float)*3*numberOfArrays];
	
	if( updated )
		glUniform3fv( (GLint)location, (GLsizei)numberOfArrays, floats );
}

-(void) setUniformLocation:(NSUInteger)location with4fv:(GLvoid*)floats count:(NSUInteger)numberOfArrays
{
	BOOL updated =  [self updateUniformLocation:location withData:floats sizeOfData:sizeof(float)*4*numberOfArrays];
	
	if( updated )
		glUniform4fv( (GLint)location, (GLsizei)numberOfArrays, floats );
}


-(void) setUniformLocation:(NSUInteger)location withMatrix4fv:(GLvoid*)matrixArray count:(NSUInteger)numberOfMatrices
{
	BOOL updated =  [self updateUniformLocation:location withData:matrixArray sizeOfData:sizeof(float)*16*numberOfMatrices];
	
	if( updated )
		glUniformMatrix4fv( (GLint)location, (GLsizei)numberOfMatrices, GL_FALSE, matrixArray);
}

-(void) setUniformForModelViewProjectionMatrix
{
	kmMat4 matrixP;
	kmMat4 matrixMV;
	kmMat4 matrixMVP;
	
	kmGLGetMatrix(KM_GL_PROJECTION, &matrixP );
	kmGLGetMatrix(KM_GL_MODELVIEW, &matrixMV );
	
	kmMat4Multiply(&matrixMVP, &matrixP, &matrixMV);
	
	[self setUniformLocation:uniforms_[kCCUniformMVPMatrix] withMatrix4fv:matrixMVP.mat count:1];
}


#pragma mark -

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	// there is no need to delete the shaders. They should have been already deleted.
	NSAssert( vertShader_ == 0, @"Vertex Shaders should have been already deleted");
	NSAssert( fragShader_ == 0, @"Vertex Shaders should have been already deleted");

    if (program_)
        ccGLDeleteProgram(program_);
	
	tHashUniformEntry *current_element, *tmp;
	
	// Purge uniform hash
	HASH_ITER(hh, hashForUniforms_, current_element, tmp) {
		HASH_DEL(hashForUniforms_, current_element);
		free(current_element->value);
		free(current_element);
	}

    [super dealloc];
}
@end
