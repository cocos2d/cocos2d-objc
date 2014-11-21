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
