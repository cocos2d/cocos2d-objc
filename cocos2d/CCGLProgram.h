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
//
//

#import <Foundation/Foundation.h>
#import "ccMacros.h"
#import "Platforms/CCGL.h"

enum {
	kCCVertexAttrib_Position,
	kCCVertexAttrib_Color,
	kCCVertexAttrib_TexCoords,

	kCCVertexAttrib_MAX,
};

enum {
	kCCUniformPMatrix,
	kCCUniformMVMatrix,
	kCCUniformMVPMatrix,
	kCCUniformTime,
	kCCUniformSinTime,
	kCCUniformCosTime,
	kCCUniformRandom01,
	kCCUniformSampler,

	kCCUniform_MAX,
};

#define kCCShader_PositionTextureColor			@"ShaderPositionTextureColor"
#define kCCShader_PositionTextureColorAlphaTest	@"ShaderPositionTextureColorAlphaTest"
#define kCCShader_PositionColor					@"ShaderPositionColor"
#define kCCShader_PositionTexture				@"ShaderPositionTexture"
#define kCCShader_PositionTexture_uColor		@"ShaderPositionTexture_uColor"
#define kCCShader_PositionTextureA8Color		@"ShaderPositionTextureA8Color"
#define kCCShader_Position_uColor				@"ShaderPosition_uColor"
#define kCCShader_PositionLengthTexureColor		@"ShaderPositionLengthTextureColor"

// uniform names
#define kCCUniformPMatrix_s				"CC_PMatrix"
#define kCCUniformMVMatrix_s			"CC_MVMatrix"
#define kCCUniformMVPMatrix_s			"CC_MVPMatrix"
#define kCCUniformTime_s				"CC_Time"
#define kCCUniformSinTime_s				"CC_SinTime"
#define kCCUniformCosTime_s				"CC_CosTime"
#define kCCUniformRandom01_s			"CC_Random01"
#define kCCUniformSampler_s				"CC_Texture0"
#define kCCUniformAlphaTestValue		"CC_alpha_value"

// Attribute names
#define	kCCAttributeNameColor			@"a_color"
#define	kCCAttributeNamePosition		@"a_position"
#define	kCCAttributeNameTexCoord		@"a_texCoord"


struct _hashUniformEntry;

/** CCGLProgram
 Class that implements a glProgram
 
 
 @since v2.0.0
 */
@interface CCGLProgram : NSObject
{
	struct _hashUniformEntry	*hashForUniforms_;

@public
	GLuint          program_,
					vertShader_,
					fragShader_;

	GLint			uniforms_[kCCUniform_MAX];
	BOOL usesTime_;
}

@property(nonatomic, readonly) GLuint program;

/** Initializes the CCGLProgram with a vertex and fragment with bytes array */
- (id)initWithVertexShaderByteArray:(const GLchar*)vShaderByteArray fragmentShaderByteArray:(const GLchar*)fShaderByteArray;

/** Initializes the CCGLProgram with a vertex and fragment with contents of filenames */
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename fragmentShaderFilename:(NSString *)fShaderFilename;

/**  It will add a new attribute to the shader */
- (void)addAttribute:(NSString *)attributeName index:(GLuint)index;

/** links the glProgram */
- (BOOL)link;

/** it will call glUseProgram() */
- (void)use;

/** It will create 4 uniforms:
	- kCCUniformPMatrix
	- kCCUniformMVMatrix
	- kCCUniformMVPMatrix
	- kCCUniformSampler

 And it will bind "kCCUniformSampler" to 0
 */
- (void) updateUniforms;

/** calls glUniform1i only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location withI1:(GLint)i1;

/** calls glUniform1f only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location withF1:(GLfloat)f1;

/** calls glUniform2f only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location withF1:(GLfloat)f1 f2:(GLfloat)f2;

/** calls glUniform3f only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location withF1:(GLfloat)f1 f2:(GLfloat)f2 f3:(GLfloat)f3;

/** calls glUniform4f only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location withF1:(GLfloat)f1 f2:(GLfloat)f2 f3:(GLfloat)f3 f4:(GLfloat)f4;

/** calls glUniform2fv only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location with2fv:(GLfloat*)floats count:(NSUInteger)numberOfArrays;

/** calls glUniform3fv only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location with3fv:(GLfloat*)floats count:(NSUInteger)numberOfArrays;

/** calls glUniform4fv only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location with4fv:(GLvoid*)floats count:(NSUInteger)numberOfArrays;

/** calls glUniformMatrix4fv only if the values are different than the previous call for this same shader program. */
-(void) setUniformLocation:(GLint)location withMatrix4fv:(GLvoid*)matrix_array count:(NSUInteger)numberOfMatrix;

/** will update the builtin uniforms if they are different than the previous call for this same shader program. */
-(void) setUniformsForBuiltins;

/** Deprecated alias for setUniformsForBuiltins */
-(void)setUniformForModelViewProjectionMatrix __attribute__((__deprecated__));

/** returns the vertexShader error log */
- (NSString *)vertexShaderLog;

/** returns the fragmentShader error log */
- (NSString *)fragmentShaderLog;

/** returns the program error log */
- (NSString *)programLog;
@end
