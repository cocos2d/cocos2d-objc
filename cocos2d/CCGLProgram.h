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
#import "ccTypes.h"
#import "ccMacros.h"
#import "Platforms/CCGL.h"

//#define kCCShader_PositionTextureColor			@"ShaderPositionTextureColor"
//#define kCCShader_PositionTextureColorAlphaTest	@"ShaderPositionTextureColorAlphaTest"
//#define kCCShader_PositionColor					@"ShaderPositionColor"
//#define kCCShader_PositionTexture				@"ShaderPositionTexture"
//#define kCCShader_PositionTexture_uColor		@"ShaderPositionTexture_uColor"
//#define kCCShader_PositionTextureA8Color		@"ShaderPositionTextureA8Color"
//#define kCCShader_Position_uColor				@"ShaderPosition_uColor"
//#define kCCShader_PositionLengthTexureColor		@"ShaderPositionLengthTextureColor"

#define CC_GLSL(x) #x

/* CCGLProgram
 Class that implements a glProgram
 */
@interface CCGLProgram : NSObject

@property(nonatomic, readonly) GLuint program;

/* creates the CCGLProgram with a vertex and fragment from byte arrays */
+ (id)programWithVertexShaderByteArray:(const GLchar*)vShaderByteArray fragmentShaderByteArray:(const GLchar*)fShaderByteArray;

/* creates the CCGLProgram with a vertex and fragment with contents of filenames */
+ (id)programWithVertexShaderFilename:(NSString *)vShaderFilename fragmentShaderFilename:(NSString *)fShaderFilename;

/* Initializes the CCGLProgram with a vertex and fragment with bytes array */
- (id)initWithVertexShaderByteArray:(const GLchar*)vShaderByteArray fragmentShaderByteArray:(const GLchar*)fShaderByteArray;

/* Initializes the CCGLProgram with a vertex and fragment with contents of filenames */
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename fragmentShaderFilename:(NSString *)fShaderFilename;

/* it will call glUseProgram() */
- (void)use;

+(instancetype)positionColorShader;
+(instancetype)positionTextureColorShader;
+(instancetype)positionTextureA8ColorShader;

@end
