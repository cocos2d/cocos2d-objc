#include <metal_stdlib>
#include <simd/simd.h>


using namespace metal;


// Make aliases for GLKMath types so struct definitions can be shared.
#if __METAL_VERSION__
typedef float2 GLKVector2;
typedef float3 GLKVector3;
typedef float4 GLKVector4;
typedef float2x2 GLKMatrix2;
typedef float3x3 GLKMatrix3;
typedef float4x4 GLKMatrix4;
#endif



// Default vertex attributes.
typedef struct CCVertex {
	GLKVector4 position;
	GLKVector2 texCoord1, texCoord2;
	GLKVector4 color;
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
	GLKMatrix4 projection;
	GLKMatrix4 projectionInv;
	GLKVector2 viewSize;
	GLKVector2 viewSizeInPixels;
	GLKVector4 time;
	GLKVector4 sinTime;
	GLKVector4 cosTime;
	GLKVector4 random01;
} CCGlobalUniforms;

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
CCFragmentFunctionUnsupported(
	const CCFragData in [[stage_in]],
	texture2d<half> cc_MainTexture [[texture(0)]]
){
	return half4(1, 0, 1, 1);
}

// TODO "alpha test" shader
