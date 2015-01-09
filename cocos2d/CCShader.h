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

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import <Metal/Metal.h>

/// Macro to embed Metal shading language source.
#define CC_METAL(x) @#x
#endif


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
@interface CCShader : NSObject<NSCopying>

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

/** @returns A solid color shader. */
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
