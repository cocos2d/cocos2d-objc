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


@class CCTexture;

/// Standard interleaved vertex format for Cocos2D.
typedef struct CCVertex {
	/// Vec4 position (x, y, z, w)
	GLKVector4 position;
	/// 2xVec2 texture coordinates (x, y)
	GLKVector2 texCoord1, texCoord2;
	/// Vec4 color (RGBA)
	GLKVector4 color;
} CCVertex;

/// Multiply the vertex's position by the given transform. Pass the rest.
static inline CCVertex
CCVertexApplyTransform(CCVertex v, const GLKMatrix4 *transform)
{
	return (CCVertex){
		GLKMatrix4MultiplyVector4(*transform, v.position),
		v.texCoord1, v.texCoord2, v.color,
	};
}

/// Interpolate between two CCVertex values.
static inline CCVertex
CCVertexLerp(CCVertex a, CCVertex b, float t)
{
	return (CCVertex){
		GLKVector4Lerp(a.position, b.position, t),
		GLKVector2Lerp(a.texCoord1, b.texCoord1, t),
		GLKVector2Lerp(a.texCoord2, b.texCoord2, t),
		GLKVector4Lerp(a.color, b.color, t),
	};
}

/// Vertex/element buffer.
/// It's recommended to use the CCRenderBuffer*() functions to manipulate this.
typedef struct CCRenderBuffer {
	/// Read only pointer to the start of the vertex buffer.
	CCVertex *vertexes;
	/// Read only pointer to the start of the element index buffer.
	GLushort *elements;
	/// Offset of the first vertex in the buffer.
	GLushort startIndex;
} CCRenderBuffer;

/// Set a vertex in the buffer.
static inline void
CCRenderBufferSetVertex(CCRenderBuffer buffer, int index, CCVertex vertex)
{
	buffer.vertexes[index] = vertex;
}

/// Set a triangle in the buffer.
/// The CCRenderBuffer must have been created using [CCRenderer enqueueTriangles:andVertexes:withState:].
static inline void
CCRenderBufferSetTriangle(CCRenderBuffer buffer, int index, GLushort a, GLushort b, GLushort c)
{
	uint16_t offset = buffer.startIndex;
	buffer.elements[3*index + 0] = a + offset;
	buffer.elements[3*index + 1] = b + offset;
	buffer.elements[3*index + 2] = c + offset;
}

/// Set a line in the buffer.
/// The CCRenderBuffer must have been created using [CCRenderer enqueueLines:andVertexes:withState:].
static inline void
CCRenderBufferSetLine(CCRenderBuffer buffer, int index, GLushort a, GLushort b)
{
	uint16_t offset = buffer.startIndex;
	buffer.elements[2*index + 0] = a + offset;
	buffer.elements[2*index + 1] = b + offset;
}

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
	float w = fabs(csc.w) + fmaxf(fabsf(extents.x*transform->m03 + extents.y*transform->m13), fabsf(extents.x*transform->m03 - extents.y*transform->m13));
	return ((fabs(csc.x) - cshx < w) && (fabs(csc.y) - cshy < w));
}


@interface NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector;
+(NSValue *)valueWithGLKVector3:(GLKVector3)vector;
+(NSValue *)valueWithGLKVector4:(GLKVector4)vector;

+(NSValue *)valueWithGLKMatrix4:(GLKMatrix4)matrix;

@end

/// Key used to set the source color factor for [CCBlendMode blendModeWithOptions:].
extern const NSString *CCBlendFuncSrcColor;
/// Key used to set the destination color factor for [CCBlendMode blendModeWithOptions:].
extern const NSString *CCBlendFuncDstColor;
/// Key used to set the color equation for [CCBlendMode blendModeWithOptions:].
extern const NSString *CCBlendEquationColor;
/// Key used to set the source alpha factor for [CCBlendMode blendModeWithOptions:].
extern const NSString *CCBlendFuncSrcAlpha;
/// Key used to set the destination alpha factor for [CCBlendMode blendModeWithOptions:].
extern const NSString *CCBlendFuncDstAlpha;
/// Key used to set the alpha equation for [CCBlendMode blendModeWithOptions:].
extern const NSString *CCBlendEquationAlpha;


/// Blending mode identifiers used with CCNode.blendMode.
@interface CCBlendMode : NSObject

/// Blending options for this mode.
@property(nonatomic, readonly) NSDictionary *options;

/// Return a cached blending mode with the given options.
+(CCBlendMode *)blendModeWithOptions:(NSDictionary *)options;

/// Disabled blending mode. Use this with fully opaque surfaces for extra performance.
+(CCBlendMode *)disabledMode;
/// Regular alpha blending.
+(CCBlendMode *)alphaMode;
/// Pre-multiplied alpha blending. (This is usually the default)
+(CCBlendMode *)premultipliedAlphaMode;
/// Additive blending. (Similar to PhotoShop's linear dodge mode)
+(CCBlendMode *)addMode;
/// Multiply blending mode. (Similar to PhotoShop's burn mode)
+(CCBlendMode *)multiplyMode;

@end


/// A render state encapsulates how an object will be draw.
/// What shader it will use, what texture, what blending mode, etc.
@interface CCRenderState : NSObject<NSCopying>

/// A simple render state you can use that draws solid colors.
+(instancetype)debugColor;

/// Create a cached blending mode for a given blending mode, shader and main texture.
+(instancetype)renderStateWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader mainTexture:(CCTexture *)mainTexture;

/// Create an uncached blending mode for a given blending mode, shader and set of uniform values.
-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms;

@end


/// A rendering queue.
/// All drawing commands in Cocos2D must be sequenced using a CCRenderer.
@interface CCRenderer : NSObject

/// Mark the renderer's cached GL state as invalid executing custom OpenGL code.
/// You only need to call this if you change the shader, texture or blending mode states.
-(void)invalidateState;

/// Enqueue a OpenGL clear operation for the given buffers and the given values.
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(void)enqueueClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil globalSortOrder:(NSInteger)globalSortOrder;

/// Enqueue a drawing command for some triangles.
/// Returns a CCRendereBuffer that you should fill using CCRenderBufferSetVertex() and CCRenderBufferSetTriangle().
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;

/// Enqueue a drawing command for some lines.
/// Returns a CCRendereBuffer that you should fill using CCRenderBufferSetVertex() and CCRenderBufferSetLine().
/// Note: These are primitive OpenGL lines that you'll only want to use for debug rendering. They are not batched.
/// Enqueued commands are sorted by their globalSortOrder value before rendering. Currently this value is 0 for everything except custom draw methods.
-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState globalSortOrder:(NSInteger)globalSortOrder;

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
