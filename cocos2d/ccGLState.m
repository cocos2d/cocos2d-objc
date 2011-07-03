/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

// extern
#import "kazmath/GL/matrix.h"

GLuint	_ccCurrentShaderProgram = -1;
GLuint	_ccCurrentTextureID = -1;
GLuint	_ccCurrentProjectionMatrix = -1;
GLenum	_ccBlendingSource = -1;
GLenum	_ccBlendingDest = -1;

inline void ccGLDeleteProgram( GLuint program )
{
	if( program == _ccCurrentShaderProgram )
		_ccCurrentShaderProgram = -1;
	glDeleteProgram( program );
}

inline void ccGLUseProgram( GLuint program )
{
	if( program != _ccCurrentShaderProgram ) {
		_ccCurrentShaderProgram = program;
		glUseProgram(program);
	}
}

inline void ccGLUniformProjectionMatrix( GLProgram *shaderProgram )
{
	if( shaderProgram->program_ != _ccCurrentProjectionMatrix ) {
		kmMat4 projectionMatrix;
		kmGLGetMatrix(KM_GL_PROJECTION, &projectionMatrix );
		glUniformMatrix4fv( shaderProgram->uniforms_[kCCUniformPMatrix], 1, GL_FALSE, projectionMatrix.mat);
		
		_ccCurrentProjectionMatrix = shaderProgram->program_;
	}
}

inline void ccGLUniformModelViewMatrix( GLProgram *shaderProgram )
{
	kmMat4 matrixMV;
	kmGLGetMatrix(KM_GL_MODELVIEW, &matrixMV );
	glUniformMatrix4fv( shaderProgram->uniforms_[kCCUniformMVMatrix], 1, GL_FALSE, matrixMV.mat);
}

inline void ccSetProjectionMatrixDirty( void )
{
	_ccCurrentProjectionMatrix = -1;
}

inline void ccGLBindTexture2D( GLuint textureID )
{
	if( textureID != _ccCurrentTextureID ) {
		_ccCurrentTextureID = textureID;
		glBindTexture(GL_TEXTURE_2D, textureID );
	}
}

void ccGLDeleteTexture( GLuint textureID )
{
	if( _ccCurrentTextureID == textureID )
		_ccCurrentTextureID = -1;
	
	glDeleteTextures(1, &textureID);
}

inline void ccGLBlendFunc(GLenum sfactor, GLenum dfactor)
{
	if( sfactor != _ccBlendingSource || dfactor != _ccBlendingDest ) {
		_ccBlendingSource = sfactor;
		_ccBlendingDest = dfactor;
		glBlendFunc( sfactor, dfactor );
	}
}
