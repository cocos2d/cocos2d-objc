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


typedef struct CCVertex {
	GLKVector3 position;
	GLKVector2 texCoord1, texCoord2;
	GLKVector4 color;
} CCVertex;

typedef struct CCTriangle {
	CCVertex a, b, c;
} CCTriangle;


@interface NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector;
+(NSValue *)valueWithGLKVector3:(GLKVector3)vector;
+(NSValue *)valueWithGLKVector4:(GLKVector4)vector;

@end


extern const NSString *CCRenderStateBlendMode;
extern const NSString *CCRenderStateShader;
extern const NSString *CCRenderStateUniforms;

extern const NSString *CCBlendFuncSrcColor;
extern const NSString *CCBlendFuncDstColor;
extern const NSString *CCBlendEquationColor;
extern const NSString *CCBlendFuncSrcAlpha;
extern const NSString *CCBlendFuncDstAlpha;
extern const NSString *CCBlendEquationAlpha;

extern const NSString *CCMainTexture;


@interface CCBlendMode : NSObject

@property(nonatomic, readonly) NSDictionary *options;

+(CCBlendMode *)blendModeWithOptions:(NSDictionary *)options;

+(CCBlendMode *)disabledMode;
+(CCBlendMode *)alphaMode;
+(CCBlendMode *)premultipliedAlphaMode;
+(CCBlendMode *)addMode;
+(CCBlendMode *)multiplyMode;

@end


@interface CCRenderState : NSObject

@property(nonatomic, readonly) NSDictionary *options;

+(CCRenderState *)renderStateWithOptions:(NSDictionary *)options;

@end


@interface CCRenderer : NSObject

-(CCTriangle *)bufferTriangles:(NSUInteger)count withState:(CCRenderState *)renderState;

@end
