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

#import <ccTypes.h>

typedef struct CCVertex {
	GLKVector3 position;
	GLKVector2 texCoord1, texCoord2;
	GLKVector4 color;
} CCVertex;

static inline CCVertex
CCVertexApplyTransform(CCVertex v, const GLKMatrix4 *transform)
{
	return (CCVertex){
		GLKMatrix4MultiplyAndProjectVector3(*transform, v.position),
		v.texCoord1, v.texCoord2, v.color,
	};
}

static inline CCVertex
CCVertexLerp(CCVertex a, CCVertex b, float t)
{
	return (CCVertex){
		GLKVector3Lerp(a.position, b.position, t),
		GLKVector2Lerp(a.texCoord1, b.texCoord1, t),
		GLKVector2Lerp(a.texCoord2, b.texCoord2, t),
		GLKVector4Lerp(a.color, b.color, t),
	};
}

typedef struct CCTriangle {
	CCVertex a, b, c;
} CCTriangle;


static inline BOOL
CCCheckVisbility(const GLKMatrix4 *transform, CGSize contentSize)
{
	float hw = contentSize.width*0.5f;
	float hh = contentSize.height*0.5f;
	
	// Bounding box center point in clip coordinates.
	GLKVector4 center = GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(hw, hh, 0.0f, 1.0f));
	center = GLKVector4MultiplyScalar(center, 1.0f/center.w);
	
	// Half width/height in clip space.
	float cshw = hw*fmaxf(fabsf(transform->m00 + transform->m10), fabsf(transform->m00 - transform->m10));
	float cshh = hh*fmaxf(fabsf(transform->m01 + transform->m11), fabsf(transform->m01 - transform->m11));
	
	// Check the bounds against the viewport.
	return (fabsf(center.x) - cshw < 1.0f && fabsf(center.y) - cshh < 1.0f);
}


@interface NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector;
+(NSValue *)valueWithGLKVector3:(GLKVector3)vector;
+(NSValue *)valueWithGLKVector4:(GLKVector4)vector;

+(NSValue *)valueWithGLKMatrix4:(GLKMatrix4)matrix;

@end


extern const NSString *CCRenderStateBlendMode;
extern const NSString *CCRenderStateShader;
extern const NSString *CCRenderStateShaderUniforms;

extern const NSString *CCBlendFuncSrcColor;
extern const NSString *CCBlendFuncDstColor;
extern const NSString *CCBlendEquationColor;
extern const NSString *CCBlendFuncSrcAlpha;
extern const NSString *CCBlendFuncDstAlpha;
extern const NSString *CCBlendEquationAlpha;


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

/// Mark the renderer's cached GL state as invalid.
-(void)invalidateState;

/// Enqueue a basic drawing command, and returns a buffer for the geometry.
/// IMPORTANT! The buffer should be considered write-only. Attempting to read from the buffer could crash your game.
-(CCTriangle *)enqueueTriangles:(NSUInteger)count withState:(CCRenderState *)renderState;

/// Enqueue a block that performs GL commands.
-(void)enqueueBlock:(void (^)())block;

/// Enqueue a method that performs GL commands.
-(void)enqueueMethod:(SEL)selector target:(id)target;

@end
