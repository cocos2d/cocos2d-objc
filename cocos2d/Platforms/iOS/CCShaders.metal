#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Default vertex attributes.
typedef struct CCVertex {
	float4 position;
	float2 texCoord1, texCoord2;
	float4 color;
} CCVertex;

// Default fragment varyings.
typedef struct CCFragData {
	float4 position [[position]];
	float2 texCoord1;
	float2 texCoord2;
	half4  color;
} CCFragData;

// Standard set of global uniform values.
// NOTE: Must match the definition in CCRenderer_Private.h!
typedef struct CCGlobalUniforms {
	float4x4 projection;
	float4x4 projectionInv;
	float2 viewSize;
	float2 viewSizeInPixels;
	float4 time;
	float4 sinTime;
	float4 cosTime;
	float4 random01;
} CCGlobalUniforms;

// Default vertex function.
vertex CCFragData
CCVertexFunctionDefault(
	const device CCVertex* verts [[buffer(0)]],
	const device CCGlobalUniforms *globalUniforms [[buffer(1)]],
	const device CCGlobalUniforms *uniforms [[buffer(2)]],
	unsigned int vid [[vertex_id]]
){
	CCFragData out;
	
	out.position = verts[vid].position;
	out.texCoord1 = verts[vid].texCoord1;
	out.texCoord2 = verts[vid].texCoord2;
	out.color = clamp(half4(verts[vid].color), half4(0.0), half4(1.0));
	
	return out;
}

fragment half4
CCFragmentFunctionDefaultColor(
	const CCFragData in [[stage_in]],
	const device CCGlobalUniforms *globals [[buffer(0)]]
){
	return in.color;
}

fragment half4
CCFragmentFunctionDefaultTextureColor(
	const CCFragData in [[stage_in]],
	const device CCGlobalUniforms *globalUniforms [[buffer(1)]],
	const device CCGlobalUniforms *uniforms [[buffer(2)]],
	texture2d<half> mainTexture [[texture(0)]],
	sampler mainTextureSampler [[sampler(0)]]
){
	return in.color*mainTexture.sample(mainTextureSampler, in.texCoord1);
}

fragment half4
CCFragmentFunctionDefaultTextureA8Color(
	const CCFragData in [[stage_in]],
	const device CCGlobalUniforms *globalUniforms [[buffer(1)]],
	const device CCGlobalUniforms *uniforms [[buffer(2)]],
	texture2d<half> mainTexture [[texture(0)]],
	sampler mainTextureSampler [[sampler(0)]]
){
	return in.color*mainTexture.sample(mainTextureSampler, in.texCoord1).a;
}

fragment half4
CCFragmentFunctionUnsupported(
	const CCFragData in [[stage_in]],
	const device CCGlobalUniforms *globalUniforms [[buffer(1)]],
	const device CCGlobalUniforms *uniforms [[buffer(2)]],
	texture2d<half> mainTexture [[texture(0)]],
	sampler mainTextureSampler [[sampler(0)]]
){
	return half4(1, 0, 1, 1);
}

// TODO "alpha test" shader
