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

@interface CCRenderState(){
	@public
	BOOL _immutable;
	CCBlendMode *_blendMode;
	CCShader *_shader;
	NSDictionary *_shaderUniforms;
}

/// Remove unused render states from the internal cache.
/// This is might be made public in the future.
+(void)flushCache;

-(void)transitionRenderer:(CCRenderer *)renderer FromState:(CCRenderState *)previous;

@end

/// Type of a CCGraphicsBuffer object.
typedef NS_ENUM(NSUInteger, CCGraphicsBufferType){
	CCGraphicsBufferTypeVertex,
	CCGraphicsBufferTypeIndex,
	CCGraphicsBufferTypeUniform,
};


/// Internal class used to abstract GPU buffers. (vertex, index buffers, etc)
/// This is an abstract class instead of a protocol because of CCGraphicsBufferPushElements().
@interface CCGraphicsBuffer : NSObject{
	@public
	/// Elements currently in the buffer.
	size_t _count;
	/// Element capacity of the buffer.
	size_t _capacity;
	/// Size in bytes of elements in the buffer.
	size_t _elementSize;
	
	/// Pointer to the buffer memory.
	/// Only valid between prepare and commmit method calls.
	void *_ptr;
}

-(instancetype)initWithCapacity:(NSUInteger)capacity elementSize:(size_t)elementSize type:(CCGraphicsBufferType)type;
-(void)resize:(size_t)newCapacity;

-(void)destroy;

-(void)prepare;
-(void)commit;

@end


/// Return a pointer to an array of elements that is 'requestedCount' in size.
/// The buffer is resized by calling [CCGraphicsBuffer resize:] if necessary.
static inline void *
CCGraphicsBufferPushElements(CCGraphicsBuffer *buffer, size_t requestedCount)
{
	NSCAssert(requestedCount > 0, @"Requested count must be positive.");
	
	size_t required = buffer->_count + requestedCount;
	size_t capacity = buffer->_capacity;
	if(required > capacity){
		// Why 1.5? https://github.com/facebook/folly/blob/master/folly/docs/FBVector.md
		CCRenderDispatch(NO, ^{[buffer resize:required*1.5];});
	}
	
	void *array = buffer->_ptr + buffer->_count*buffer->_elementSize;
	buffer->_count += requestedCount;
	
	return array;
}


/// Internal abstract class used to wrap vertex buffer state. (GL VAOs, etc)
@interface CCGraphicsBufferBindings : NSObject {
	@public
	CCGraphicsBuffer *_vertexBuffer;
	CCGraphicsBuffer *_indexBuffer;
	
	// Not used by the GL2 renderer.
	CCGraphicsBuffer *_uniformBuffer;
}

/// Make the buffers ready to use by drawing commands.
-(void)bind:(BOOL)bind vertexPage:(NSUInteger)vertexPage;

/// Prepare buffers for changes.
-(void)prepare;

/// Commit changes to buffers.
-(void)commit;

@end


@interface CCFrameBufferObject : NSObject {
	GLuint _depthStencilFormat;
}

// Setters should be treated as protected.
@property(nonatomic, readonly) CCTexture *texture;
@property(nonatomic, assign) CGSize sizeInPixels;
@property(nonatomic, assign) CGFloat contentScale;

-(instancetype)initWithTexture:(CCTexture *)texture depthStencilFormat:(GLuint)depthStencilFormat;

-(void)syncWithView:(CC_VIEW<CCDirectorView> *)view;

// Not ideal to use GL enumerations here.
// It's out of convenience, and it's a private API.
-(void)bindWithClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil;

@end
