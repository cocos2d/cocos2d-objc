/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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

#import "CCRenderer_private.h"

#import "CCRenderDispatch.h"


static const CCGraphicsBufferType CCGraphicsBufferGLTypes[] = {
	GL_ARRAY_BUFFER,
	GL_ELEMENT_ARRAY_BUFFER,
};


@interface CCGraphicsBufferGLBasic : CCGraphicsBuffer @end
@implementation CCGraphicsBufferGLBasic {
	@public
	GLuint _buffer;
	GLenum _type;
}

-(instancetype)initWithCapacity:(NSUInteger)capacity elementSize:(size_t)elementSize type:(CCGraphicsBufferType)type;
{
	if((self = [super initWithCapacity:capacity elementSize:elementSize type:type])){
		glGenBuffers(1, &_buffer);
		_type = CCGraphicsBufferGLTypes[type];
		
		[self setup];
	}
	
	return self;
}

-(void)setup
{
	_ptr = calloc(_capacity, _elementSize);
}

-(void)destroy
{
	free(_ptr);
	_ptr = NULL;
	
	GLuint buffer = _buffer;
	CCRenderDispatch(YES, ^{glDeleteBuffers(1, &buffer);});
}

-(void)resize:(size_t)newCapacity;
{
	_ptr = realloc(_ptr, newCapacity*_elementSize);
	_capacity = newCapacity;
}

-(void)prepare;
{
	_count = 0;
}

-(void)commit;
{
	GLenum type = (GLenum)_type;
	glBindBuffer(type, _buffer);
	glBufferData(type, (GLsizei)(_count*_elementSize), _ptr, GL_STREAM_DRAW);
	glBindBuffer(type, 0);
}

@end


#if __CC_PLATFORM_IOS

@interface CCGraphicsBufferGLUnsynchronized : CCGraphicsBufferGLBasic @end
@implementation CCGraphicsBufferGLUnsynchronized {
	GLvoid *(*_mapBufferRange)(GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access);
	GLvoid (*_flushMappedBufferRange)(GLenum target, GLintptr offset, GLsizeiptr length);
	GLboolean (*_unmapBuffer)(GLenum target);
}

#define BUFFER_ACCESS_WRITE (GL_MAP_WRITE_BIT_EXT | GL_MAP_UNSYNCHRONIZED_BIT_EXT | GL_MAP_INVALIDATE_BUFFER_BIT_EXT | GL_MAP_FLUSH_EXPLICIT_BIT_EXT)
#define BUFFER_ACCESS_READ (GL_MAP_READ_BIT_EXT)

-(instancetype)initWithCapacity:(NSUInteger)capacity elementSize:(size_t)elementSize type:(CCGraphicsBufferType)type
{
	if((self = [super initWithCapacity:capacity elementSize:elementSize type:type])){
		// TODO Does Android look up GL functions by name like Windows/Linux?
		_mapBufferRange = glMapBufferRangeEXT;
		_flushMappedBufferRange = glFlushMappedBufferRangeEXT;
		_unmapBuffer = glUnmapBufferOES;
	}
	
	return self;
}

-(void)setup
{
	glBindBuffer(_type, _buffer);
	glBufferData(_type, _capacity*_elementSize, NULL, GL_STREAM_DRAW);
	glBindBuffer(_type, 0);
	CC_CHECK_GL_ERROR_DEBUG();
}

-(void)destroy
{
	GLuint buffer = _buffer;
	CCRenderDispatch(YES, ^{glDeleteBuffers(1, &buffer);});
}

-(void)resize:(size_t)newCapacity
{
	// This is a little tricky.
	// Need to resize the existing GL buffer object without creating a new name.
	
	// Make the buffer readable.
	glBindBuffer(_type, _buffer);
	GLsizei oldLength = (GLsizei)(_count*_elementSize);
	_flushMappedBufferRange(_type, 0, oldLength);
	_unmapBuffer(_type);
	void *oldBufferPtr = _mapBufferRange(_type, 0, oldLength, BUFFER_ACCESS_READ);
	
	// Copy the old contents into a temp buffer.
	GLsizei newLength = (GLsizei)(newCapacity*_elementSize);
	void *tempBufferPtr = malloc(newLength);
	memcpy(tempBufferPtr, oldBufferPtr, oldLength);
	
	// Copy that into a new GL buffer.
	_unmapBuffer(_type);
	glBufferData(_type, newLength, tempBufferPtr, GL_STREAM_DRAW);
	void *newBufferPtr = _mapBufferRange(_type, 0, newLength, BUFFER_ACCESS_WRITE);
	
	// Cleanup.
	free(tempBufferPtr);
	glBindBuffer(_type, 0);
	CC_CHECK_GL_ERROR_DEBUG();
	
	// Update values.
	_ptr = newBufferPtr;
	_capacity = newCapacity;
}

-(void)prepare
{
	_count = 0;
	
	GLenum target = (GLenum)_type;
	glBindBuffer(_type, _buffer);
	_ptr = _mapBufferRange(target, 0, (GLsizei)(_capacity*_elementSize), BUFFER_ACCESS_WRITE);
	glBindBuffer(target, 0);
	CC_CHECK_GL_ERROR_DEBUG();
}

-(void)commit
{
	glBindBuffer(_type, _buffer);
	_flushMappedBufferRange(_type, 0, (GLsizei)(_count*_elementSize));
	_unmapBuffer(_type);
	glBindBuffer(_type, 0);
	CC_CHECK_GL_ERROR_DEBUG();
	
	_ptr = NULL;
}

@end

#endif


@interface CCGraphicsBufferBindingsGL : NSObject <CCGraphicsBufferBindings> @end
@implementation CCGraphicsBufferBindingsGL {
	GLuint _vao;
}

-(instancetype)initWithVertexBuffer:(CCGraphicsBufferGLBasic *)vertexBuffer indexBuffer:(CCGraphicsBufferGLBasic *)indexBuffer
{
	NSAssert([vertexBuffer isKindOfClass:[CCGraphicsBufferGLBasic class]], @"Wrong kind of buffer!");
	NSAssert([indexBuffer isKindOfClass:[CCGraphicsBufferGLBasic class]], @"Wrong kind of buffer!");
	
	if((self = [super init])){
		CCGL_DEBUG_PUSH_GROUP_MARKER("CCGraphicsBufferBindingsGL: Creating VAO");
		
		glGenVertexArrays(1, &_vao);
		glBindVertexArray(_vao);

		glEnableVertexAttribArray(CCShaderAttributePosition);
		glEnableVertexAttribArray(CCShaderAttributeTexCoord1);
		glEnableVertexAttribArray(CCShaderAttributeTexCoord2);
		glEnableVertexAttribArray(CCShaderAttributeColor);
		
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer->_buffer);
		glVertexAttribPointer(CCShaderAttributePosition, 4, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, position));
		glVertexAttribPointer(CCShaderAttributeTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord1));
		glVertexAttribPointer(CCShaderAttributeTexCoord2, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord2));
		glVertexAttribPointer(CCShaderAttributeColor, 4, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, color));
		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer->_buffer);

		glBindVertexArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		
		CCGL_DEBUG_POP_GROUP_MARKER();
	}
	
	return self;
}

-(void)dealloc
{
	GLuint vao = _vao;
	CCRenderDispatch(YES, ^{glDeleteVertexArrays(1, &vao);});
}

-(void)bind:(BOOL)bind
{
	CCGL_DEBUG_INSERT_EVENT_MARKER("CCGraphicsBufferBindingsGL: Bind VAO");
	glBindVertexArray(bind ? _vao : 0);
}

@end
