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


static constant float SQRT_3 = 1.73205080756888;

static float2 rotate(float2 v, float t){
	const float2x2 m1 = float2x2(float2(1.0, 0.0), float2(0.0, 1.0));
	const float2x2 m2 = float2x2(float2(-0.5, SQRT_3*0.5), float2(-SQRT_3*0.5, -0.5));
	const float2x2 m = m1*(1.0 - t) + m2*t;
	const float det = m[0][0]*m[1][1] - m[1][0]*m[0][1];
	return m*v/det;
}

static float tri_dist(float2 uv){
	return max(uv.y, abs(uv.x)*SQRT_3*0.5 - uv.y*0.5);
}

fragment half4
TrippyTrianglesFS(
	const CCFragData in [[stage_in]],
	const device CCGlobalUniforms *cc_DefaultGlobals [[buffer(1)]]
){
	const float3x3 RECT_TO_TRI = float3x3(
		float3(2.0*SQRT_3, 0.0, 0.0),
		float3(-SQRT_3, -3.0, 0.0),
		float3(-SQRT_3, 1.0, 1.0)
	);
	
	const float3x3 TRI_TO_RECT = float3x3(
		float3(SQRT_3/6.0, 0.0, 0.0),
		float3(-1.0/6.0, -1.0/3.0, 0.0),
		float3(2.0/3.0, 1.0/3.0, 1.0)
	);
	
	float scale = 32.0;
	float2 uv = in.position.xy/(scale*in.position.w);
	
	// Some fun pointless distortion.
	float t1 = cc_DefaultGlobals->time[0]/10.0;
	uv = float2(uv.x + 5.0*sin(t1 + uv.y/10.0), uv.y + 5.0*sin(1.3*t1 + uv.x/10.0));
	
	// Some fun pointless rotation.
	float2 rot = float2(cos(t1), sin(t1));
	uv = float2x2(float2(rot.x, rot.y), float2(-rot.y, rot.x))*uv;
	
	// Convert to rectangular UVs and reflect over y=x
	float2 rect = (TRI_TO_RECT*float3(uv, 1.0)).xy;
	float2 wrap = rect - floor(rect);
	float2 flip = float2(max(wrap.x, wrap.y), min(wrap.x, wrap.y));
	
	// Convert back to screen space
	float2 uv2 = (RECT_TO_TRI*float3(flip, 1.0)).xy;
	
	float2 t2 = cc_DefaultGlobals->time[0]*float2(1.0, 1.3);
	float phase = dot(sin(uv/5.0 + t2), float2(1.0))/4.0;
	
	// Rotate the UVs of the triangles.
	float t3 = fmod(cc_DefaultGlobals->time[0]/16.0 + phase, 1.0);
	float d = tri_dist(rotate(uv2, t3));
	
	// Trace the d = 1.0 contour! \o/
	half fw = fwidth(d)*0.5;
	half mask = smoothstep(1.0 - fw, 1.0 + fw, d);
//	float mask = step(d, 1.0);
	
	float t4 = 0.0;//pow(abs(2.0*mod(t3 + 0.95, 1.0) - 1.0), 3.0);
	half3 color1 = half3(t4, t4, 0.0);
	half3 color2 = half3(1.0, 1.0 - t3, 0.0);
	half3 color = mix(color1, color2, mask);
	return half4(color, 1.0);
}
