/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
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

// This header contains type definitions that are imported into both Obj-C and Metal code.


#if __METAL_VERSION__
#include <simd/simd.h>
using namespace metal;

// Make aliases for GLKMath types so struct definitions can be shared.
typedef float2 GLKVector2;
typedef float3 GLKVector3;
typedef float4 GLKVector4;
typedef float2x2 GLKMatrix2;
typedef float3x3 GLKMatrix3;
typedef float4x4 GLKMatrix4;
#endif

/// Standard interleaved vertex format for Cocos2D.
typedef struct CCVertex {
	/// Vec4 position (x, y, z, w)
	GLKVector4 position;
	/// 2xVec2 texture coordinates (x, y)
	GLKVector2 texCoord1, texCoord2;
	/// Vec4 color (RGBA)
	GLKVector4 color;
} CCVertex;

#if __METAL_VERSION__
/// Default vertex shader output for Metal.
typedef struct CCFragData {
	float4 position [[position]];
	float2 texCoord1;
	float2 texCoord2;
	half4  color;
} CCFragData;
#endif

/// Standard set of global uniform values (used with Metal).
typedef struct CCGlobalUniforms {
	/// Projection matrix.
	GLKMatrix4 projection;
	/// Inverse of projection matrix.
	GLKMatrix4 projectionInv;
	/// Size of the render target in points.
	GLKVector2 viewSize;
	/// Size of the render target in pixels.
	GLKVector2 viewSizeInPixels;
	/// Current time [t, t/2, t/4, t/8]
	GLKVector4 time;
	/// Sine of the current time [sin(t*2), sin(t), sin(t/2), sin(t/4)]
	GLKVector4 sinTime;
	/// Cosine of the current time [cos(t*2), cos(t), cos(t/2), cos(t/4)]
	GLKVector4 cosTime;
	/// Random per-frame vec4. All components are in the range [0, 1].
	GLKVector4 random01;
} CCGlobalUniforms;
