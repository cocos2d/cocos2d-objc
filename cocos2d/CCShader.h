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

#import <Metal/Metal.h>
#import "CCMetalSupport_Private.h"
#endif

@class CCRenderer;
typedef void (^CCUniformSetter)(
                                __unsafe_unretained CCRenderer *renderer,
                                __unsafe_unretained NSDictionary *shaderUniforms,
                                __unsafe_unretained NSDictionary *globalShaderUniforms
                                );

/// Macro to embed GLSL source.
#define CC_GLSL(x) @#x

/// GL attribute locations for built-in Cocos2D vertex attributes. Used by CCShader.
typedef NS_ENUM(NSUInteger, CCShaderAttribute){
    /** Position */
	CCShaderAttributePosition,
    /** Texture Coordinate 1 (main) */
	CCShaderAttributeTexCoord1,
    /** Texture Coordinate 2 (extra) */
	CCShaderAttributeTexCoord2,
    /** Color */
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


/** A wrapper for OpenGL or Metal shader programs. Also gives you access to the built-in shaders used by Cocos2D. */
@interface CCShader : NSObject<NSCopying> {
@public
    GLuint _program;
    NSDictionary *_uniformSetters;
    
    // TODO This should really be split into a separate subclass somehow.
#if __CC_METAL_SUPPORTED_AND_ENABLED
    id<MTLFunction> _vertexFunction, _fragmentFunction;
#endif
}

/** @name Creating a OpenGL Shader */

/** Creates a shader with the given vertex and fragment shader source code as strings.
 When the GL renderer is running, GLSL source is expected. When the Metal renderer is running, Metal shading language source is expected.
 @param vertexSource The vertex shader's source code string. Must not be nil.
 @param fragmentSource The fragment shader's source code string. Must not be nil.
 @returns The created CCShader instance, or nil if there was a compile error in either of the two shader programs.
 */
-(instancetype)initWithVertexShaderSource:(NSString *)vertexSource fragmentShaderSource:(NSString *)fragmentSource;
/** Creates a shader with the given fragment shader source code as string.
 When the GL renderer is running, GLSL source is expected. When the Metal renderer is running, Metal shading language source is expected.
 @param source The fragment shader's source code string. Must not be nil.
 @returns The created CCShader instance, or nil if there was a compile error in the shader programs.
 */
-(instancetype)initWithFragmentShaderSource:(NSString *)source;

-(instancetype)initWithRawVertexShaderSource:(NSString *)vertexSource rawFragmentShaderSource:(NSString *)fragmentSource;

#if __CC_METAL_SUPPORTED_AND_ENABLED
/** @name Creating a Metal Shader */

/** Creates a Metal shader with the given vertex and fragment shader functions.
 @param vertexFunction A vertex shader object that implements the MTLFunction protocol.
 @param fragmentFunction A fragment shader object that implements the MTLFunction protocol.
 @returns The created CCShader instance, or nil if there was a compile error in the shader programs.
 @see [Metal's MTLFunction Protocol Reference](https://developer.apple.com/LIBRARY/ios/documentation/Metal/Reference/MTLFunction_Ref/index.html)
 @since v3.3 and later. Only available on supported devices with Cocos2D Metal rendering enabled. Not available when building for iOS Simulator.
 */
-(instancetype)initWithMetalVertexFunction:(id<MTLFunction>)vertexFunction fragmentFunction:(id<MTLFunction>)fragmentFunction;
#endif

/** @name Getting a Shader by its Name */

/** Returns the shader with the given name. Returns nil if there's no shader for this name.
 When the GL renderer is running, this searches for a file name "shaderName.fsh" for the fragment shader, and optionally "shaderName.vsh" for the vertex shader.
 When the Metal renderer is running it searces in CCShaders.metallib for a fragment function named "shaderNameFS" and optionally a vertex function named "shaderNameVS".
 @param shaderName The shader's unique name. */
+(instancetype)shaderNamed:(NSString *)shaderName;

/** @name Obtaining a Built-In Shader */

/** @returns A solide color shader. */
+(instancetype)positionColorShader;
/** @returns A texture shader with vertex colors. */
+(instancetype)positionTextureColorShader;
/** @returns A texture shader with vertex colors and alpha testing. */
+(instancetype)positionTextureColorAlphaTestShader;
/** @returns An 8-bit color texture shader. */
+(instancetype)positionTextureA8ColorShader;

/** @name Setting a Shader's Debug Name */

/** The shader's name for debugging purposes. */
@property(nonatomic, copy) NSString *debugName;

@end
