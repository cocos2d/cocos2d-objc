/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "ccGLStateCache.h"
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
static GLuint	_ccCurrentShaderProgram = -1;
static GLuint	_ccCurrentBoundTexture[kCCMaxActiveTexture] =  {-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, };
static GLenum	_ccBlendingSource = -1;
static GLenum	_ccBlendingDest = -1;
static ccGLServerState _ccGLServerState = 0;
static GLuint _ccVAO = 0;
#endif // CC_ENABLE_GL_STATE_CACHE

#pragma mark - GL State Cache functions

void ccGLInvalidateStateCache( void )
{
	kmGLFreeAll();
	
	_ccCurrentProjectionMatrix = -1;
	_vertexAttribPosition = NO;
	_vertexAttribColor = NO;
	_vertexAttribTexCoords = NO;
	
#if CC_ENABLE_GL_STATE_CACHE
	_ccCurrentShaderProgram = -1;
	for( NSInteger i=0; i < kCCMaxActiveTexture; i++ )
		_ccCurrentBoundTexture[i] = -1;
	_ccBlendingSource = -1;
	_ccBlendingDest = -1;
	_ccGLServerState = 0;
#endif
}

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

static void SetBlending(GLenum sfactor, GLenum dfactor)
{
	if(sfactor == GL_ONE && dfactor == GL_ZERO){
		glDisable(GL_BLEND);
	} else {
		glEnable(GL_BLEND);
		glBlendFunc( sfactor, dfactor );
	}
}

void ccGLBlendFunc(GLenum sfactor, GLenum dfactor)
{
#if CC_ENABLE_GL_STATE_CACHE
	if( sfactor != _ccBlendingSource || dfactor != _ccBlendingDest ) {
		_ccBlendingSource = sfactor;
		_ccBlendingDest = dfactor;
		SetBlending( sfactor, dfactor );
	}
#else
	SetBlending( sfactor, dfactor );
#endif // CC_ENABLE_GL_STATE_CACHE
}

void ccGLBlendResetToCache(void)
{
	glBlendEquation(GL_FUNC_ADD);
#if CC_ENABLE_GL_STATE_CACHE
	SetBlending( _ccBlendingSource, _ccBlendingDest );
#else
	SetBlending( CC_BLEND_SRC, CC_BLEND_DST );
#endif // CC_ENABLE_GL_STATE_CACHE
}

void ccGLBindTexture( GLenum target, GLuint textureId )
{
	if( target == GL_TEXTURE_2D )
		ccGLBindTexture2DN(0, textureId);
	else
		glBindTexture(target, textureId);
}

void ccGLBindTexture2D( GLuint textureId )
{
	ccGLBindTexture2DN(0, textureId);
}

void ccGLBindTexture2DN( GLuint textureUnit, GLuint textureId )
{
#if CC_ENABLE_GL_STATE_CACHE
	NSCAssert1( textureUnit < kCCMaxActiveTexture, @"cocos2d ERROR: Increase kCCMaxActiveTexture to %d!", textureUnit - GL_TEXTURE0);
	if( _ccCurrentBoundTexture[ textureUnit ] != textureId )
	{
		_ccCurrentBoundTexture[ textureUnit ] = textureId;
		glActiveTexture( GL_TEXTURE0 + textureUnit );
		glBindTexture(GL_TEXTURE_2D, textureId );
	}
#else
	glActiveTexture( GL_TEXTURE0 + textureUnit );
	glBindTexture(GL_TEXTURE_2D, textureId );
#endif
}


void ccGLDeleteTexture( GLuint textureId )
{
	ccGLDeleteTextureN( 0, textureId );
}

void ccGLDeleteTextureN( GLuint textureUnit, GLuint textureId )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( _ccCurrentBoundTexture[ textureUnit ] == textureId )
		_ccCurrentBoundTexture[ textureUnit ] = -1;
#endif // CC_ENABLE_GL_STATE_CACHE

	glDeleteTextures(1, &textureId );
}

void ccGLBindVAO(GLuint vaoId)
{
#if CC_ENABLE_GL_STATE_CACHE
	if( _ccVAO != vaoId )
	{
		_ccVAO = vaoId;
		glBindVertexArray(vaoId);
	}
#else
	glBindVertexArray(vaoId);
#endif
}

void ccGLEnable( ccGLServerState flags )
{
#if CC_ENABLE_GL_STATE_CACHE
	
//	BOOL enabled = NO;
//
//	/* GL_BLEND */
//	if( (enabled=(flags & CC_GL_BLEND)) != (_ccGLServerState & CC_GL_BLEND) ) {
//		if( enabled ) {
//			glEnable( GL_BLEND );
//			_ccGLServerState |= CC_GL_BLEND;
//		} else {
//			glDisable( GL_BLEND );
//			_ccGLServerState &=  ~CC_GL_BLEND;
//		}
//	}
	
#else
//	if( flags & CC_GL_BLEND )
//		glEnable( GL_BLEND );
//	else
//		glDisable( GL_BLEND );
#endif
}

#pragma mark - GL Vertex Attrib functions

void ccGLEnableVertexAttribs( unsigned int flags )
{
	ccGLBindVAO(0);
	
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

void ccSetProjectionMatrixDirty( void )
{
	_ccCurrentProjectionMatrix = -1;
}
