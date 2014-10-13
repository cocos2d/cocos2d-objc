//
// Copyright 2011 Jeff Lamarche
//
// Copyright 2012 Goffredo Marocchi
//
// Copyright 2012 Ricardo Quesada
//
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided
// that the following conditions are met:
//	1. Redistributions of source code must retain the above copyright notice, this list of conditions and
//		the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//		and the following disclaimer in the documentation and/or other materials provided with the
//		distribution.
//
//	THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT
//	OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//	OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//	AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

#import <Foundation/Foundation.h>
#import "ccTypes.h"
#import "ccMacros.h"
#import "Platforms/CCGL.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import <Metal/Metal.h>

/// Macro to embed Metal shading language source.
#define CC_METAL(x) @#x
#endif


/// Macro to embed GLSL source.
#define CC_GLSL(x) @#x


/// GL attribute locations for built-in Cocos2D vertex attributes.
typedef NS_ENUM(NSUInteger, CCShaderAttribute){
	CCShaderAttributePosition,
	CCShaderAttributeTexCoord1,
	CCShaderAttributeTexCoord2,
	CCShaderAttributeColor,
};


extern NSString * const CCShaderUniformDefaultGlobals;
extern NSString * const CCShaderUniformProjection;
extern NSString * const CCShaderUniformProjectionInv;
extern NSString * const CCShaderUniformViewSize;
extern NSString * const CCShaderUniformViewSizeInPixels;
extern NSString * const CCShaderUniformTime;
extern NSString * const CCShaderUniformSinTime;
extern NSString * const CCShaderUniformCosTime;
extern NSString * const CCShaderUniformRandom01;
extern NSString * const CCShaderUniformMainTexture;
extern NSString * const CCShaderUniformNormalMapTexture;
extern NSString * const CCShaderUniformAlphaTestValue;


@interface CCShader : NSObject<NSCopying>

@property(nonatomic, copy) NSString *debugName;

+(instancetype)shaderNamed:(NSString *)shaderName;

-(instancetype)initWithVertexShaderSource:(NSString *)vertexSource fragmentShaderSource:(NSString *)fragmentSource;
-(instancetype)initWithFragmentShaderSource:(NSString *)source;

#if __CC_METAL_SUPPORTED_AND_ENABLED
-(instancetype)initWithMetalVertexFunction:(id<MTLFunction>)vertexFunction fragmentFunction:(id<MTLFunction>)fragmentFunction;
#endif

+(instancetype)positionColorShader;
+(instancetype)positionTextureColorShader;
+(instancetype)positionTextureColorAlphaTestShader;
+(instancetype)positionTextureA8ColorShader;

@end
