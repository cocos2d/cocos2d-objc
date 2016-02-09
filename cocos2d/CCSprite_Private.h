/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
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
 *
 */

#import "CCSprite.h"
#if CC_EFFECTS
#import "CCEffectRenderer.h"
#import "CCEffect_Private.h"
#endif
@interface CCSprite () {
	@private
	
	// Vertex coords, texture coords and color info.
	CCSpriteVertexes _verts;
	
	// Center of extents (half width/height) of the sprite for culling purposes.
	GLKVector2 _vertexCenter, _vertexExtents;
#if CC_EFFECTS
	CCEffect *_effect;
	CCEffectRenderer *_effectRenderer;
#endif
}

+ (CCSpriteTexCoordSet)textureCoordsForTexture:(CCTexture *)texture withRect:(CGRect)rect rotated:(BOOL)rotated xFlipped:(BOOL)flipX yFlipped:(BOOL)flipY;
#if CC_EFFECTS
- (void)updateShaderUniformsFromEffect;
#endif
@end


@interface CCSprite(NoARC)

-(void)enqueueTriangles:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;

@end
