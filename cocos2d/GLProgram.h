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
//
// Adapted for cocos2d http://www.cocos2d-iphone.org

#import <Foundation/Foundation.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import <OpenGL/gl.h>
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

enum {
	kCCAttribVertex,
	kCCAttribColor,
	kCCAttribTexCoords,
	
	kCCAttrib_MAX,
};

enum {
	kCCUniformPMatrix,
	kCCUniformMVMatrix,
	kCCUniformSampler,
	
	kCCUniform_MAX,
};

extern GLint ccUniforms[kCCUniform_MAX];

#define kCCShader_VertexTextureColor	@"ShaderVertexTextureColor"
#define kCCShader_VertexColor			@"ShaderVertexColor"
#define kCCShader_VertexTexture			@"ShaderVertexTexture"

// uniform names
#define kCCUniformMVMatrix_s			"uMVMatrix"
#define kCCUniformPMatrix_s				"uPMatrix"
#define kCCUniformSampler_s				"uTexture"


/** GLProgram
 */
@interface GLProgram : NSObject 
{
@public
	GLuint          program_,
					vertShader_,
					fragShader_;
	
	GLint			uniforms_[kCCUniform_MAX];
}

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename;
- (void)addAttribute:(NSString *)attributeName index:(GLuint)index;
- (BOOL)link;
- (void)use;
- (void) updateUniforms;

- (NSString *)vertexShaderLog;
- (NSString *)fragmentShaderLog;
- (NSString *)programLog;
@end
