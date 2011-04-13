/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ccGLState.h"
#import "GLProgram.h"
#import "CCDirector.h"

GLuint	_ccCurrentShaderProgram = -1;
GLuint	_ccCurrentTextureID = -1;
GLenum	_ccBlendingSource = -1;
GLenum	_ccBlendingDest = -1;
unsigned long long	_ccProjectionMatrixDirty = -1; // 64 bits / 3 = ~21 differnt shader programs supported

inline void ccglUseProgram( GLuint program )
{
	if( program != _ccCurrentShaderProgram ) {
		_ccCurrentShaderProgram = program;
		glUseProgram(program);
	}
}

inline void ccglUniformProjectionMatrix( GLProgram *shaderProgram )
{
	GLuint bitNumber = shaderProgram->program_;
	NSCAssert( shaderProgram->program_ < sizeof(_ccProjectionMatrixDirty)*8, @"Ouch. Too many shader programs. Disable this optimization");

	if( _ccProjectionMatrixDirty & (1 << bitNumber) ) {
		glUniformMatrix4fv( shaderProgram->uniforms_[kCCUniformPMatrix], 1, GL_FALSE, (GLfloat*)&ccProjectionMatrix);
		
		_ccProjectionMatrixDirty &= ~(1 << bitNumber);
	}
}

inline void ccSetProjectionMatrix( kmMat4 *matrix )
{
	// set all "bits" to dirty
	_ccProjectionMatrixDirty = -1;

	ccProjectionMatrix = *matrix;
}

inline void ccSetProjectionMatrixDirty( void )
{
	_ccProjectionMatrixDirty = -1;
}

inline void ccglBindTexture2D( GLuint textureID )
{
	if( textureID != _ccCurrentTextureID ) {
		_ccCurrentTextureID = textureID;
		glBindTexture(GL_TEXTURE_2D, textureID );
	}
}

void ccglDeleteTexture( GLuint textureID )
{
	if( _ccCurrentTextureID == textureID )
		_ccCurrentTextureID = -1;
	
	glDeleteTextures(1, &textureID);
}

inline void ccglBlendFunc(GLenum sfactor, GLenum dfactor)
{
	if( sfactor != _ccBlendingSource || dfactor != _ccBlendingDest ) {
		_ccBlendingSource = sfactor;
		_ccBlendingDest = dfactor;
		glBlendFunc( sfactor, dfactor );
	}
}
