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

#include <metal_stdlib>
#include <simd/simd.h>

#include "CCRendererSharedTypes.h"

using namespace metal;

// Default vertex function.
vertex CCFragData
CCVertexFunctionDefault(
	const device CCVertex *cc_VertexAttributes [[buffer(0)]],
	unsigned int vid [[vertex_id]]
){
	CCFragData out;
	
	out.position = cc_VertexAttributes[vid].position;
	out.texCoord1 = cc_VertexAttributes[vid].texCoord1;
	out.texCoord2 = cc_VertexAttributes[vid].texCoord2;
	out.color = saturate(half4(cc_VertexAttributes[vid].color));
	
	return out;
}

fragment half4
CCFragmentFunctionDefaultColor(
	const CCFragData in [[stage_in]]
){
	return in.color;
}

fragment half4
CCFragmentFunctionDefaultTextureColor(
	const CCFragData in [[stage_in]],
	texture2d<half> cc_MainTexture [[texture(0)]],
	sampler cc_MainTextureSampler [[sampler(0)]]
){
	return in.color*cc_MainTexture.sample(cc_MainTextureSampler, in.texCoord1);
}

fragment half4
CCFragmentFunctionDefaultTextureA8Color(
	const CCFragData in [[stage_in]],
	texture2d<half> cc_MainTexture [[texture(0)]],
	sampler cc_MainTextureSampler [[sampler(0)]]
){
	return in.color*cc_MainTexture.sample(cc_MainTextureSampler, in.texCoord1).a;
}

fragment half4
CCFragmentFunctionDefaultDrawNode(
	const CCFragData in [[stage_in]]
){
	return in.color*smoothstep(0.0, length(fwidth(in.texCoord1)), 1.0 - length(in.texCoord1));
}

fragment half4
CCFragmentFunctionUnsupported(
	const CCFragData in [[stage_in]]
){
	return half4(1, 0, 1, 1);
}

// TODO "alpha test" shader
