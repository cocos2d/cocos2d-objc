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

#import "ccTypes.h"
#import "CCShader.h"

#import "NSValue+CCRenderer.h"
#import "CCRendererBasicTypes.h"


/// Check if the given bounding box as specified by it's center and extents (half with/height) is visible onscreen.	
static inline BOOL
CCRenderCheckVisbility(const GLKMatrix4 *transform, GLKVector2 center, GLKVector2 extents)
{
	// Center point in clip coordinates.
	GLKVector4 csc = GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(center.x, center.y, 0.0f, 1.0f));
	
	// x, y in clip space.
	float cshx = fmaxf(fabsf(extents.x*transform->m00 + extents.y*transform->m10), fabsf(extents.x*transform->m00 - extents.y*transform->m10));
	float cshy = fmaxf(fabsf(extents.x*transform->m01 + extents.y*transform->m11), fabsf(extents.x*transform->m01 - extents.y*transform->m11));
	
	// Check the bounds against the clip space viewport using a conservative w-value.
	float w = fabsf(csc.w) + fmaxf(fabsf(extents.x*transform->m03 + extents.y*transform->m13), fabsf(extents.x*transform->m03 - extents.y*transform->m13));
	return ((fabsf(csc.x) - cshx < w) && (fabsf(csc.y) - cshy < w));
}


/// A rendering queue.
/// All drawing commands in Cocos2D must be sequenced using a CCRenderer.
@interface CCRenderer : NSObject

/// YES if the renderer contains only threadsafe rendering commands.
@property(nonatomic, readonly) BOOL threadsafe;

/// Mark the renderer's cached GL state as invalid executing custom OpenGL code.
/// You only need to call this if you change the shader, texture or blending mode states.
-(void)invalidateState;

/// Enqueue a OpenGL clear operation for the given buffers and the given values.
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(void)enqueueClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil globalSortOrder:(NSInteger)globalSortOrder;

/// Enqueue a block that performs GL commands. The debugLabel is optional and will show up in in the GLES frame debugger.
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(void)enqueueBlock:(void (^)())block globalSortOrder:(NSInteger)globalSortOrder debugLabel:(NSString *)debugLabel threadSafe:(BOOL)threadSafe;

/// Enqueue a method that performs GL commands.
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(void)enqueueMethod:(SEL)selector target:(id)target;

/// Begin a rendering group. Must be matched with a call to popGroup:. Can be nested.
/// Commands in the group are sorted relative to each other.
-(void)pushGroup;

/// End the most recent group started using pushGroup.
/// The grouped commands are sorted together using the gives sorting order.
-(void)popGroupWithDebugLabel:(NSString *)debugLabel globalSortOrder:(NSInteger)globalSortOrder;

@end

@interface CCRenderer(NoARC)

/// Enqueue a drawing command for some triangles.
/// Returns a CCRendereBuffer that you should fill using CCRenderBufferSetVertex() and CCRenderBufferSetTriangle().
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;

/// Enqueue a drawing command for some lines.
/// Returns a CCRendereBuffer that you should fill using CCRenderBufferSetVertex() and CCRenderBufferSetLine().
/// Note: These are primitive OpenGL lines that you'll only want to use for debug rendering. They are not batched.
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;

@end

