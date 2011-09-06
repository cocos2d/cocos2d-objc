//
// Copyright 2011 Jeff Lamarche
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
//
// Adapted for cocos2d http://www.cocos2d-iphone.org

#import "GLProgram.h"
#import "ccGLState.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"
#import "Support/OpenGL_Internal.h"

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

@interface GLProgram()
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
                 file:(NSString *)file;
- (NSString *)logForOpenGLObject:(GLuint)object 
                    infoCallback:(GLInfoFunction)infoFunc 
                         logFunc:(GLLogFunction)logFunc;
@end

#pragma mark -

@implementation GLProgram
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename
{
    if ((self = [super init]) )
    {
        program_ = glCreateProgram();
        
		vertShader_ = fragShader_ = 0;

		if( vShaderFilename ) {
			NSString *fullname = [CCFileUtils fullPathFromRelativePath:vShaderFilename]; 

			if (![self compileShader:&vertShader_
								type:GL_VERTEX_SHADER 
								file:fullname])
				CCLOG(@"cocos2d: ERROR: Failed to compile vertex shader: %@", vShaderFilename);
		}
        
        // Create and compile fragment shader
		if( fShaderFilename ) {
			NSString *fullname = [CCFileUtils fullPathFromRelativePath:fShaderFilename];

			if (![self compileShader:&fragShader_
								type:GL_FRAGMENT_SHADER 
								file:fullname])
				CCLOG(@"cocos2d: ERROR: Failed to compile fragment shader: %@", fShaderFilename);
		}
        
		if( vertShader_ )
			glAttachShader(program_, vertShader_);
		
		if( fragShader_ )
			glAttachShader(program_, fragShader_);
		
    }
    
    return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Program = %i, VertexShader = %i, FragmentShader = %i>", [self class], self, program_, vertShader_, fragShader_];
}


- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
                 file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = 
      (GLchar *)[[NSString stringWithContentsOfFile:file 
                                           encoding:NSUTF8StringEncoding 
                                              error:nil] UTF8String];
    if (!source)
        return NO;
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	
	if( ! status ) {
		if( type == GL_VERTEX_SHADER )
			CCLOG(@"cocos2d: %@: %@", file, [self vertexShaderLog] );
		else
			CCLOG(@"cocos2d: %@: %@", file, [self fragmentShaderLog] );

	}
    return status == GL_TRUE;
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
	
	ccGLUseProgram( program_ );
	glUniform1i( uniforms_[kCCUniformSampler], 0 );
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
                       infoCallback:(GLInfoFunction)&glGetProgramiv 
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
    
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

#pragma mark -

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	// there is no need to delete the shaders. They should have been already deleted.
	NSAssert( vertShader_ == 0, @"Vertex Shaders should have been already deleted");
	NSAssert( fragShader_ == 0, @"Vertex Shaders should have been already deleted");
	
    if (program_)
        ccGLDeleteProgram(program_);
       
    [super dealloc];
}
@end
