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
#import "CCRendererSharedTypes.h"


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


/// Key used to set the source color factor for [CCBlendMode blendModeWithOptions:].
extern NSString * const CCBlendFuncSrcColor;
/// Key used to set the destination color factor for [CCBlendMode blendModeWithOptions:].
extern NSString * const CCBlendFuncDstColor;
/// Key used to set the color equation for [CCBlendMode blendModeWithOptions:].
extern NSString * const CCBlendEquationColor;
/// Key used to set the source alpha factor for [CCBlendMode blendModeWithOptions:].
extern NSString * const CCBlendFuncSrcAlpha;
/// Key used to set the destination alpha factor for [CCBlendMode blendModeWithOptions:].
extern NSString * const CCBlendFuncDstAlpha;
/// Key used to set the alpha equation for [CCBlendMode blendModeWithOptions:].
extern NSString * const CCBlendEquationAlpha;


/// Blending modes used with certain node's `blendMode` property. CCBlendMode treats blend modes by descriptive name rather
/// than a nondescriptive combination of blend mode identifiers.
@interface CCBlendMode : NSObject

/// @name Blend Mode Options

/// Blending options for this mode.
@property(nonatomic, readonly) NSDictionary *options;

/// @name Getting a Blend Mode with Options

/// Return a cached blending mode with the given options.
/// @param options dictionary with blend mode options
+(CCBlendMode *)blendModeWithOptions:(NSDictionary *)options;

/// @name Getting a Built-In Blend Mode

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


@class CCTexture;
@class CCShader;


/// A render state encapsulates how an object will be drawn.
/// For example what shader it will use, the texture, the blending mode, etc.
@interface CCRenderState : NSObject<NSCopying>

/// @name Creating a Custom Render State

/// Creates a **cached** blending mode for a given blending mode, shader and main texture.
/// @param blendMode A blend mode.
/// @param shader The shader to use.
/// @param mainTexture The mainTexture to use.
/// @see CCBlendMode
/// @see CCShader
/// @see CCTexture
+(instancetype)renderStateWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader mainTexture:(CCTexture *)mainTexture;

/// Creates an **uncached** blending mode for a given blending mode, shader and set of uniform values.
/// Allowing the uniform dictionary to be copied allows the render state to be immutable, which is more efficient.
/// @param blendMode A blend mode.
/// @param shader The shader to use.
/// @param shaderUniforms The shader uniforms.
/// @param copyUniforms Whether to copy the uniforms. If set to YES the render state is assumed to be immutable which is more efficient.
/// @see CCBlendMode
/// @see CCShader
+(instancetype)renderStateWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms copyUniforms:(BOOL)copyUniforms;

// Purposefully undocumented: marked as deprecated
// Initialize an uncached blending mode for a given blending mode, shader and set of uncopied uniform values.
// @note Use [CCRenderState renderStateWithBlendMode:blendMode shader:shader shaderUniforms:shaderUniforms copyUniforms:NO] instead.
// @param blendMode A blend mode.
// @param shader The shader to use.
// @param shaderUniforms The shader uniforms.
// @see CCBlendMode
// @see CCShader
-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms __deprecated;

/// @name Obtaining the Debug Render State

/// A simple render state you can use that draws solid colors.
+(instancetype)debugColor;

@end
