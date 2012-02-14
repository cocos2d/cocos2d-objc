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

#import "CCGLProgram.h"
#import "ccGLState.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"
#import "Support/OpenGL_Internal.h"
#import "kazmath.h"

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
- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file;
- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc;
@end

#pragma mark -

@implementation CCGLProgram

@synthesize uniformsLoc, uniforms, uniformsOld;

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename
{
    if ((self = [super init]) )
    {
        projMatrixDirty = -1;
        uniformsLoc = [[NSMutableDictionary alloc] initWithCapacity:5];
		uniforms = [[NSMutableDictionary alloc] initWithCapacity:5];
        uniformsOld = [[NSMutableDictionary alloc] initWithCapacity:5];
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
        
        vShaderName = [vShaderFilename retain];
        fShaderName = [fShaderFilename retain];

		if( vertShader_ ) {
			glAttachShader(program_, vertShader_);
        }

		if( fragShader_ ) {
			glAttachShader(program_, fragShader_);
        }

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

	ccGLUseProgram( self );
	glUniform1i( uniforms_[kCCUniformSampler], 0 );
}

- (void) loadUniform:(NSString*)name withValue:(void*)value withType:(NSString*)type { 
    GLuint tempLoc;
	NSNumber* oldUniform;
	
	if(!name || !value || !type) return;
	oldUniform = [uniformsLoc objectForKey:name];
	if(!oldUniform) {
		tempLoc = -1;
	}
	else {
		tempLoc = [oldUniform intValue];
	}
	
	if (-1 == tempLoc) {
		//if tempLoc is equal to -1, then the uniform has not been added yet or it cannot be found in the shader...
		tempLoc = glGetUniformLocation(self->program_, [name UTF8String]);
		if (-1 == tempLoc) {
            NSLog(@"(!)...this uniform (%@) could not be added to %@.vsh and %@.fsh...(!)", name, vShaderName, fShaderName);
			return;
		}
		NSNumber *locValue = [NSNumber numberWithInt:tempLoc]; 
		[uniformsLoc setObject:locValue forKey:name];
	}
    
    [self loadUniformLoc:tempLoc withValue:value withType:type];
}

- (void) loadUniformLoc:(GLuint)uLoc withValue:(void*)value withType:(NSString*)type {
	NSNumber* oldUniform;
    NSNumber* uLocKey = [NSNumber numberWithUnsignedInt:uLoc];
    
    BOOL updateUniform = NO;
	
	if(value == NULL || !type) { 
        return;
    }
    
    oldUniform = [uniforms objectForKey:uLocKey];
	
	if (NSOrderedSame ==[type compare:@"mat4"]) {
        kmMat4 matOld; 
        [((NSData*)oldUniform) getBytes:&matOld length:sizeof(kmMat4)];
        kmMat4* matNew = (kmMat4*)value;
        
        if(kmMat4AreEqual(&matOld, matNew) == KM_TRUE) {
            //NSLog(@"mat4 already available");
            return;
        }
        
        NSData* temp = [NSData dataWithBytes:value length:sizeof(kmMat4)];
        
		[uniforms setObject:temp forKey:uLocKey];
		glUniformMatrix4fv(uLoc, 1, GL_FALSE, matNew->mat);

	}
	else if (NSOrderedSame ==[type compare:@"vec4f"]) {
        ccColor4F oldVec;
        [((NSData*)oldUniform) getBytes:&oldVec length:sizeof(ccColor4F)];
        ccColor4F * newVec = (ccColor4F*) value;
        
        updateUniform = ((oldVec.r < (newVec->r-0.001f) || oldVec.r > (newVec->r+0.001f)) ||
                         (oldVec.g < (newVec->g-0.001f) || oldVec.g > (newVec->g+0.001f)) ||
                         (oldVec.b < (newVec->b-0.001f) || oldVec.b > (newVec->b+0.001f)) ||
                         (oldVec.a < (newVec->a-0.001f) || oldVec.a > (newVec->a+0.001f)));
        
        if(!updateUniform) {
            return;
        }
        
        NSData* temp = [NSData dataWithBytes:value length:sizeof(ccColor4F)];
		[uniforms setObject:temp forKey:uLocKey];
        glUniform4fv(uLoc, 1, (void*)newVec);

	}
	else if (NSOrderedSame ==[type compare:@"vec3f"]) {
        ccVertex3F oldVec;
        [((NSData*)oldUniform) getBytes:&oldVec length:sizeof(ccVertex3F)];
        
        ccVertex3F * newVec = (ccVertex3F*) value;
        
        updateUniform = ((oldVec.x < (newVec->x-0.001f) || oldVec.x > (newVec->x+0.001f)) ||
                         (oldVec.y < (newVec->y-0.001f) || oldVec.y > (newVec->y+0.001f)) ||
                         (oldVec.z < (newVec->z-0.001f) || oldVec.z > (newVec->z+0.001f)));
        
        if(!updateUniform) {
            return;
        }
        
        NSData* temp = [NSData dataWithBytes:value length:sizeof(ccVertex3F)];
		[uniforms setObject:temp forKey:uLocKey];
        glUniform3fv(uLoc, 1, (void*)newVec);

	}
	else if (NSOrderedSame ==[type compare:@"vec2f"]) {
        ccVertex2F oldVec;
        [((NSData*)oldUniform) getBytes:&oldVec length:sizeof(ccVertex2F)];
        
        ccVertex2F * newVec = (ccVertex2F*) value;
        
        updateUniform = ((oldVec.x < (newVec->x-0.001f) || oldVec.x > (newVec->x+0.001f)) ||
                         (oldVec.y < (newVec->y-0.001f) || oldVec.y > (newVec->y+0.001f)) );
        
        if(!updateUniform) {
            return;
        }
        
        NSData* temp = [NSData dataWithBytes:value length:sizeof(ccVertex2F)];
		[uniforms setObject:temp forKey:uLocKey];
        glUniform2fv(uLoc, 1, (void*)newVec);
	}
	else if (NSOrderedSame ==[type compare:@"sampler2D"]) {
        int newInt = [(NSNumber*)value intValue];
        if (nil == oldUniform) {
            updateUniform = YES;
        }
        else {
            int oldValue = [(NSNumber*)oldUniform intValue];
            updateUniform = (oldValue != newInt)? YES: NO;
        }
		if(updateUniform) {
            [uniforms setObject:value forKey:uLocKey];
            glUniform1i(uLoc, newInt); //each sampler should be bound to a different texture unit...
        }
	}
	else if (NSOrderedSame ==[type compare:@"float"]) {
        float newFloat = [(NSNumber*)value floatValue];
        if (nil == oldUniform) {
            updateUniform = YES;
        }
        else {
            float oldValue = [(NSNumber*)oldUniform floatValue];
            updateUniform = (oldValue < (newFloat-0.001f) || oldValue > (newFloat+0.001f))? YES: NO;
        }
		if(updateUniform) {
            [uniforms setObject:value forKey:uLocKey];
            glUniform1f(uLoc, newFloat); //each sampler should be bound to a different texture unit...
        }
	}
	else if (NSOrderedSame ==[type compare:@"BOOL"]) {
        BOOL newBOOL = [(NSNumber*)value boolValue];
        if (nil == oldUniform) {
            updateUniform = YES;
        }
        else {
            BOOL oldValue = [(NSNumber*)oldUniform intValue];
            updateUniform = (oldValue != newBOOL)? YES: NO;
        }
		if(updateUniform) {
            [uniforms setObject:value forKey:uLocKey];
            glUniform1i(uLoc, newBOOL); //each sampler should be bound to a different texture unit...
        }
	}
	else if (NSOrderedSame ==[type compare:@"int"]) {
        int newInt = [(NSNumber*)value intValue];
        if (nil == oldUniform) {
            updateUniform = YES;
        }
        else {
            int oldValue = [(NSNumber*)oldUniform intValue];
            updateUniform = (oldValue != newInt)? YES: NO;
        }
		if(updateUniform) {
            [uniforms setObject:value forKey:uLocKey];
            glUniform1i(uLoc, newInt); //each sampler should be bound to a different texture unit...
        }
	}
	else {
		NSAssert(0, @"(!)... only mat4, vec4f, vec3f, vec2f, float, int, and samplers uniforms can be loaded for now... (!)");
	}
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
		ccGLDeleteProgram( self );
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
    ccGLUseProgram(self);
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

#pragma mark -

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	// there is no need to delete the shaders. They should have been already deleted.
	NSAssert( vertShader_ == 0, @"Vertex Shaders should have been already deleted");
	NSAssert( fragShader_ == 0, @"Vertex Shaders should have been already deleted");

    if (program_) {
        ccGLDeleteProgram(self);
    }
    
    if(vShaderName) {
        [vShaderName release];
        vShaderName = nil;
    }
    if(fShaderName) {
        [fShaderName release];
        fShaderName = nil;
    }

    [super dealloc];
}
@end
