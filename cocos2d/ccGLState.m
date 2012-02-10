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
#import "CCGLProgram.h"
#import "CCDirector.h"
#import "ccConfig.h"

// extern
#import "kazmath/GL/matrix.h"
#import "kazmath/kazmath.h"

static GLuint	_ccCurrentProjectionMatrix = -1;
static BOOL		_vertexAttribPosition = NO;
static BOOL		_vertexAttribColor = NO;
static BOOL		_vertexAttribTexCoords = NO;

#if CC_ENABLE_GL_STATE_CACHE
#define kCCMaxActiveTexture 16
static CCGLProgram * _ccCurrentCCGLProgram = nil;
static GLuint	_ccCurrentShaderProgram = -1;
static GLuint	_ccCurrentBoundTexture[kCCMaxActiveTexture] =  {-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, };
static GLenum	_ccCurrentActiveTexture = (GL_TEXTURE0 - GL_TEXTURE0);
static GLenum	_ccBlendingSource = -1;
static GLenum	_ccBlendingDest = -1;
static ccGLServerState _ccGLServerState = 0;

static GLint x_ = 0;
static GLint y_ = 0; 
static GLsizei width_ = 0;
static GLsizei height_ = 0;

#endif // CC_ENABLE_GL_STATE_CACHE

#pragma mark - GL State Cache functions

void ccGLInvalidateStateCache( void )
{
	kmGLFreeAll();
    
#if CC_ENABLE_GL_STATE_CACHE
	_ccCurrentShaderProgram = -1;
	for( NSInteger i=0; i < kCCMaxActiveTexture; i++ )
		_ccCurrentBoundTexture[i] = -1;
	_ccCurrentActiveTexture = (GL_TEXTURE0 - GL_TEXTURE0);
	_ccBlendingSource = -1;
	_ccBlendingDest = -1;
	_ccGLServerState = 0;
    
    x_ = 0;
    y_ = 0; 
    width_ = 0;
    height_ = 0;
#endif
    
    ccSetProjectionMatrixDirty();
}

void ccGLDeleteProgram( CCGLProgram *shaderProgram  )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( shaderProgram->program_ == _ccCurrentShaderProgram ) {
		_ccCurrentShaderProgram = -1;
        _ccCurrentCCGLProgram = nil;
    }
#endif // CC_ENABLE_GL_STATE_CACHE
    
    ccSetProjectionMatrixDirty();
	glDeleteProgram( shaderProgram->program_ );
}

void ccGLUseProgram( CCGLProgram *shaderProgram )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( shaderProgram->program_ != _ccCurrentShaderProgram ) {
		_ccCurrentShaderProgram = shaderProgram->program_;
        _ccCurrentCCGLProgram = shaderProgram;
		glUseProgram(shaderProgram->program_);
	}
#else
	glUseProgram(shaderProgram->program_);
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

GLenum ccGLGetActiveTexture( void )
{
#if CC_ENABLE_GL_STATE_CACHE
	return _ccCurrentActiveTexture + GL_TEXTURE0;
#else
	GLenum activeTexture;
	glGetIntegerv(GL_ACTIVE_TEXTURE, (GLint*)&activeTexture);
	return activeTexture;
#endif
}

void ccGLActiveTexture( GLenum textureEnum )
{
#if CC_ENABLE_GL_STATE_CACHE
	NSCAssert1( (textureEnum - GL_TEXTURE0) < kCCMaxActiveTexture, @"cocos2d ERROR: Increase kCCMaxActiveTexture to %d!", (textureEnum-GL_TEXTURE0) );
	if( (textureEnum - GL_TEXTURE0) != _ccCurrentActiveTexture ) {
		_ccCurrentActiveTexture = (textureEnum - GL_TEXTURE0);
		glActiveTexture( textureEnum );
	}
#else
	glActiveTexture( textureEnum );
#endif
}

void ccGLBindTexture2D( GLuint textureId )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( _ccCurrentBoundTexture[ _ccCurrentActiveTexture ] != textureId )
	{
		_ccCurrentBoundTexture[ _ccCurrentActiveTexture ] = textureId;
		glBindTexture(GL_TEXTURE_2D, textureId );
	}
#else
	glBindTexture(GL_TEXTURE_2D, textureId );
#endif
}


void ccGLDeleteTexture( GLuint textureId )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( textureId == _ccCurrentBoundTexture[ _ccCurrentActiveTexture ] )
        _ccCurrentBoundTexture[ _ccCurrentActiveTexture ] = -1;
#endif
	glDeleteTextures(1, &textureId );
}

void ccGLEnable( ccGLServerState flags )
{
#if CC_ENABLE_GL_STATE_CACHE
    
	BOOL enabled = NO;
    
	/* GL_BLEND */
	if( (enabled=(flags & CC_GL_BLEND)) != (_ccGLServerState & CC_GL_BLEND) ) {
		if( enabled ) {
			glEnable( GL_BLEND );
			_ccGLServerState |= CC_GL_BLEND;
		} else {
			glDisable( GL_BLEND );
			_ccGLServerState &=  ~CC_GL_BLEND;
		}
	}
    
#else
	if( flags & CC_GL_BLEND )
		glEnable( GL_BLEND );
	else
		glDisable( GL_BLEND );
#endif
}

#pragma mark - GL Vertex Attrib functions

void ccGLEnableVertexAttribs( unsigned int flags )
{
	/* Position */
	BOOL enablePosition = flags & kCCVertexAttribFlag_Position;
    
	if( enablePosition != _vertexAttribPosition ) {
		if( enablePosition )
			glEnableVertexAttribArray( kCCVertexAttrib_Position );
		else
			glDisableVertexAttribArray( kCCVertexAttrib_Position );
        
		_vertexAttribPosition = enablePosition;
	}
    
	/* Color */
	BOOL enableColor = flags & kCCVertexAttribFlag_Color;
    
	if( enableColor != _vertexAttribColor ) {
		if( enableColor )
			glEnableVertexAttribArray( kCCVertexAttrib_Color );
		else
			glDisableVertexAttribArray( kCCVertexAttrib_Color );
        
		_vertexAttribColor = enableColor;
	}
    
	/* Tex Coords */
	BOOL enableTexCoords = flags & kCCVertexAttribFlag_TexCoords;
    
	if( enableTexCoords != _vertexAttribTexCoords ) {
		if( enableTexCoords )
			glEnableVertexAttribArray( kCCVertexAttrib_TexCoords );
		else
			glDisableVertexAttribArray( kCCVertexAttrib_TexCoords );
        
		_vertexAttribTexCoords = enableTexCoords;
	}
}

#pragma mark - GL Uniforms functions

void ccGLUniformModelViewProjectionMatrix( CCGLProgram *shaderProgram )
{
    //if (_ccCurrentCCGLProgram->projMatrixDirty  == -1 || _ccCurrentProjectionMatrix == -1) {
        kmMat4 matrixP;
        kmMat4 matrixMV;
        kmMat4 matrixMVP;
        
        kmGLGetMatrix(KM_GL_PROJECTION, &matrixP );
        kmGLGetMatrix(KM_GL_MODELVIEW, &matrixMV );
        
        kmMat4Multiply(&matrixMVP, &matrixP, &matrixMV);
    
        [_ccCurrentCCGLProgram loadUniformLoc:shaderProgram->uniforms_[kCCUniformMVPMatrix] 
                            withValue:&matrixMVP withType:@"mat4"];
        
        //glUniformMatrix4fv( shaderProgram->uniforms_[kCCUniformMVPMatrix], 1, GL_FALSE, matrixMVP.mat);
      //  _ccCurrentProjectionMatrix = 0;
      //  _ccCurrentCCGLProgram->projMatrixDirty=0;
    //}
}

void ccGLViewport (GLint x, GLint y, GLsizei width, GLsizei height) {
#if CC_ENABLE_GL_STATE_CACHE
    if (x_ != x || y_!= y || width_ != width || height_ != height) {
        glViewport(x, y, width, height);
        x_ = x;
        y_ = y;
        width_ = width;
        height_ = height;
    }
#else
	glViewport(x, y, width, height);
#endif
}

void ccSetProjectionMatrixDirty( void )
{
	_ccCurrentProjectionMatrix = -1;
    if(_ccCurrentCCGLProgram) {
        _ccCurrentCCGLProgram->projMatrixDirty=-1;
    }
}
