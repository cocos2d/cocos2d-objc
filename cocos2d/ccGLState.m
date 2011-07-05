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
#import "ccConfig.h"

// extern
#import "kazmath/GL/matrix.h"
#import "kazmath/kazmath.h"

static GLuint	_ccCurrentProjectionMatrix = -1;

#if CC_ENABLE_GL_STATE_CACHE
static GLuint	_ccCurrentShaderProgram = -1;
static GLenum	_ccBlendingSource = -1;
static GLenum	_ccBlendingDest = -1;
#endif // CC_ENABLE_GL_STATE_CACHE

#pragma mark - GL State Cache functions

void ccGLDeleteProgram( GLuint program )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( program == _ccCurrentShaderProgram )
		_ccCurrentShaderProgram = -1;
#endif // CC_ENABLE_GL_STATE_CACHE

	glDeleteProgram( program );
}

void ccGLUseProgram( GLuint program )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( program != _ccCurrentShaderProgram ) {
		_ccCurrentShaderProgram = program;
		glUseProgram(program);
	}
#else
	glUseProgram(program);	
#endif // CC_ENABLE_GL_STATE_CACHE
}


void ccGLBlendFunc(GLenum sfactor, GLenum dfactor)
{
#if CC_ENABLE_GL_STATE_CACHE
	if( sfactor != _ccBlendingSource || dfactor != _ccBlendingDest ) {
		_ccBlendingSource = sfactor;
		_ccBlendingDest = dfactor;
		glBlendFunc( sfactor, dfactor );
	}
#else
	glBlendFunc( sfactor, dfactor );
#endif // CC_ENABLE_GL_STATE_CACHE
}

#pragma mark - GL Uniforms functions

void ccGLUniformProjectionMatrix( GLProgram *shaderProgram )
{
	if( shaderProgram->program_ != _ccCurrentProjectionMatrix ) {
		kmMat4 projectionMatrix;
		kmGLGetMatrix(KM_GL_PROJECTION, &projectionMatrix );
		glUniformMatrix4fv( shaderProgram->uniforms_[kCCUniformPMatrix], 1, GL_FALSE, projectionMatrix.mat);
		
		_ccCurrentProjectionMatrix = shaderProgram->program_;
	}
}

void ccGLUniformModelViewMatrix( GLProgram *shaderProgram )
{
	kmMat4 matrixMV;
	kmGLGetMatrix(KM_GL_MODELVIEW, &matrixMV );
	glUniformMatrix4fv( shaderProgram->uniforms_[kCCUniformMVMatrix], 1, GL_FALSE, matrixMV.mat);
}

void ccSetProjectionMatrixDirty( void )
{

	_ccCurrentProjectionMatrix = -1;
}
