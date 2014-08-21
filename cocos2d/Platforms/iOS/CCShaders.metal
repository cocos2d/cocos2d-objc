#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct CCVertex {
	float4 position;
	float2 texCoord1, texCoord2;
	float4 color;
} CCVertex;

typedef struct CCFragData {
	float4 position [[position]];
	float2 texCoord1;
	float2 texCoord2;
	half4  color;
} CCFragData;

vertex CCFragData
CCVertexFunctionDefault(
	device CCVertex* verts [[buffer(0)]],
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
	CCFragData in [[stage_in]]
){
	return in.color;
}

fragment half4
CCFragmentFunctionDefaultTextureColor(
	CCFragData in [[stage_in]],
	texture2d<half> mainTexture [[texture(0)]],
	sampler mainTextureSampler [[sampler(0)]]
){
	return in.color*mainTexture.sample(mainTextureSampler, in.texCoord1);
}

fragment half4
CCFragmentFunctionDefaultTextureA8Color(
	CCFragData in [[stage_in]],
	texture2d<half> mainTexture [[texture(0)]],
	sampler mainTextureSampler [[sampler(0)]]
){
	return in.color*mainTexture.sample(mainTextureSampler, in.texCoord1).a;
}

fragment half4
TempUnsupported(
	CCFragData in [[stage_in]],
	texture2d<half> mainTexture [[texture(0)]],
	sampler mainTextureSampler [[sampler(0)]]
){
	return half4(1, 0, 1, 1);
}

// TODO "alpha test" shader
