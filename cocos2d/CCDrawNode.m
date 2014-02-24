/* Copyright (c) 2012 Scott Lembcke and Howling Moon Software
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Code copied & pasted from SpacePatrol game https://github.com/slembcke/SpacePatrol
 *
 * Renamed and added some changes for cocos2d
 *
 */

#import "CCDrawNode.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "Support/CGPointExtension.h"
#import "Support/OpenGL_Internal.h"
#import "CCNode_Private.h"
#import "CCColor.h"


@implementation CCDrawNode {
	GLsizei _triangleCapacity;
	GLsizei _triangleCount;
	CCTriangle *_triangles;
}

#pragma mark memory

-(CCTriangle *)bufferTriangles:(NSUInteger)requestedCount
{
	GLsizei required = _triangleCount + (GLsizei)requestedCount;
	if(required > _triangleCapacity){
		// Double the size of the buffer until it fits.
		while(required >= _triangleCapacity) _triangleCapacity *= 2;
		
		_triangles = realloc(_triangles, _triangleCapacity*sizeof(*_triangles));
	}
	
	CCTriangle *triangles =  &_triangles[_triangleCount];
	_triangleCount += requestedCount;
	
	return triangles;
}

-(id)init
{
	if((self = [super init])){
		self.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA};
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionLengthTexureColor];

		_triangleCapacity = 128;
		_triangles = calloc(_triangleCapacity, sizeof(*_triangles));
	}
	
	return self;
}

-(void)dealloc
{
	free(_triangles);
	_triangles = NULL;
}

#pragma mark Rendering

-(void)draw:(CCRenderer *)renderer transform:(GLKMatrix4)transform
{
	CCVertex *verts = (CCVertex *)[renderer bufferTriangles:_triangleCount withState:self.renderState];
	
	// TODO Try if memcpy + transforming just the verts is faster?
	// TODO Maybe it would be even better to skip the CPU transform and use a uniform matrix?
	for(int i=0; i<_triangleCount*3; i++){
		verts[i] = CCVertexApplyTransform(((CCVertex *)_triangles)[i], transform);
	}
}

#pragma mark Immediate Mode

-(void)drawDot:(CGPoint)pos radius:(CGFloat)radius color:(CCColor *)color;
{
	GLKVector4 color4 = color.glkVector4;
	GLKVector2 zero2 = GLKVector2Make(0, 0);
	
	CCVertex a = {GLKVector3Make(pos.x - radius, pos.y - radius, 0), GLKVector2Make(-1, -1), zero2, color4};
	CCVertex b = {GLKVector3Make(pos.x - radius, pos.y + radius, 0), GLKVector2Make(-1,  1), zero2, color4};
	CCVertex c = {GLKVector3Make(pos.x + radius, pos.y + radius, 0), GLKVector2Make( 1,  1), zero2, color4};
	CCVertex d = {GLKVector3Make(pos.x + radius, pos.y - radius, 0), GLKVector2Make( 1, -1), zero2, color4};
	
	CCTriangle *triangles = [self bufferTriangles:2];
	triangles[0] = (CCTriangle){a, b, c};
	triangles[1] = (CCTriangle){a, c, d};
}

static inline GLKVector2 GLKVector2Perp(GLKVector2 v){return GLKVector2Make(-v.y, v.x);}

static inline CCVertex
MakeVertex(GLKVector2 v, GLKVector2 texCoord, GLKVector4 color)
{
	return (CCVertex){GLKVector3Make(v.x, v.y, 0.0f), texCoord, GLKVector2Make(0.0f, 0.0f), color};
}

-(void)drawSegmentFrom:(CGPoint)_a to:(CGPoint)_b radius:(CGFloat)radius color:(CCColor*)color;
{
	
	GLKVector2 a = GLKVector2Make(_a.x, _a.y);
	GLKVector2 b = GLKVector2Make(_b.x, _b.y);
	
	
	GLKVector2 n = GLKVector2Normalize(GLKVector2Perp(GLKVector2Subtract(b, a)));
	GLKVector2 t = GLKVector2Perp(n);
	
	GLKVector2 nw = GLKVector2MultiplyScalar(n, radius);
	GLKVector2 tw = GLKVector2MultiplyScalar(t, radius);
	
	GLKVector4 color4 = color.glkVector4;
	CCVertex v0 = MakeVertex(GLKVector2Subtract(b, GLKVector2Add(nw, tw)), GLKVector2Negate(GLKVector2Add(n, t)), color4);
	CCVertex v1 = MakeVertex(GLKVector2Add(b, GLKVector2Subtract(nw, tw)), GLKVector2Subtract(n, t), color4);
	CCVertex v2 = MakeVertex(GLKVector2Subtract(b, nw), GLKVector2Negate(n), color4);
	CCVertex v3 = MakeVertex(GLKVector2Add(b, nw), n, color4);
	CCVertex v4 = MakeVertex(GLKVector2Subtract(a, nw), GLKVector2Negate(n), color4);
	CCVertex v5 = MakeVertex(GLKVector2Add(a, nw), n, color4);
	CCVertex v6 = MakeVertex(GLKVector2Subtract(a, GLKVector2Subtract(nw, tw)), GLKVector2Subtract(t, n), color4);
	CCVertex v7 = MakeVertex(GLKVector2Add(a, GLKVector2Add(nw, tw)), GLKVector2Add(n, t), color4);
	
	CCTriangle *triangles = [self bufferTriangles:6];
	
	triangles[0] = (CCTriangle){v0, v1, v2};
	triangles[1] = (CCTriangle){v3, v1, v2};
	triangles[2] = (CCTriangle){v3, v4, v2};
	triangles[3] = (CCTriangle){v3, v4, v5};
	triangles[4] = (CCTriangle){v6, v4, v5};
	triangles[5] = (CCTriangle){v6, v7, v5};
}

-(void)drawPolyWithVerts:(const CGPoint *)_verts count:(NSUInteger)count fillColor:(CCColor*)fill  borderWidth:(CGFloat)width borderColor:(CCColor*)line;
{
	GLKVector4 fill4 = fill.glkVector4;
	GLKVector4 line4 = line.glkVector4;
	
	GLKVector2 verts[count];
	for(int i=0; i<count; i++) verts[i] = GLKVector2Make(_verts[i].x, _verts[i].y);
	
	struct ExtrudeVerts {GLKVector2 offset, n;};
	struct ExtrudeVerts extrude[count];
	bzero(extrude, sizeof(extrude) );
	
	for(int i=0; i<count; i++){
		GLKVector2 v0 = verts[(i-1+count)%count];
		GLKVector2 v1 = verts[i];
		GLKVector2 v2 = verts[(i+1)%count];
	
		GLKVector2 n1 = GLKVector2Normalize(GLKVector2Perp(GLKVector2Subtract(v1, v0)));
		GLKVector2 n2 = GLKVector2Normalize(GLKVector2Perp(GLKVector2Subtract(v2, v1)));
		
		GLKVector2 offset = GLKVector2MultiplyScalar(GLKVector2Add(n1, n2), 1.0/(GLKVector2DotProduct(n1, n2) + 1.0));
		extrude[i] = (struct ExtrudeVerts){offset, n2};
	}
	
	BOOL outline = (line4.a > 0 && width > 0.0);
	
//	NSUInteger triangle_count = 3*count - 2;
	CCTriangle *triangles = [self bufferTriangles:3*count - 2];
	CCTriangle *cursor = triangles;
	
	const GLKVector2 zero = {{0.0f, 0.0f}};
	
	CGFloat inset = (outline == 0.0 ? 0.5 : 0.0);
	for(int i=0; i<count-2; i++){
		GLKVector2 v0 = GLKVector2Subtract( (verts[0  ]), GLKVector2MultiplyScalar(extrude[0  ].offset, inset));
		GLKVector2 v1 = GLKVector2Subtract( (verts[i+1]), GLKVector2MultiplyScalar(extrude[i+1].offset, inset));
		GLKVector2 v2 = GLKVector2Subtract( (verts[i+2]), GLKVector2MultiplyScalar(extrude[i+2].offset, inset));
		
		*cursor++ = (CCTriangle){
			MakeVertex(v0, zero, fill4),
			MakeVertex(v1, zero, fill4),
			MakeVertex(v2, zero, fill4),
		};
	}
	
	for(int i=0; i<count; i++){
		int j = (i+1)%count;
		GLKVector2 v0 = ( verts[i] );
		GLKVector2 v1 = ( verts[j] );
		
		GLKVector2 n0 = extrude[i].n;
		
		GLKVector2 offset0 = extrude[i].offset;
		GLKVector2 offset1 = extrude[j].offset;
		
		if(outline){
			GLKVector2 inner0 = GLKVector2Subtract(v0, GLKVector2MultiplyScalar(offset0, width));
			GLKVector2 inner1 = GLKVector2Subtract(v1, GLKVector2MultiplyScalar(offset1, width));
			GLKVector2 outer0 = GLKVector2Add(v0, GLKVector2MultiplyScalar(offset0, width));
			GLKVector2 outer1 = GLKVector2Add(v1, GLKVector2MultiplyScalar(offset1, width));
			
			*cursor++ = (CCTriangle){
				MakeVertex(inner0, GLKVector2Negate(n0), line4),
				MakeVertex(inner1, GLKVector2Negate(n0), line4),
				MakeVertex(outer1, n0, line4),
			};
			*cursor++ = (CCTriangle){
				MakeVertex(inner0, GLKVector2Negate(n0), line4),
				MakeVertex(outer0, n0, line4),
				MakeVertex(outer1, n0, line4),
			};
		} else {
			GLKVector2 inner0 = GLKVector2Subtract(v0, GLKVector2MultiplyScalar(offset0, 0.5));
			GLKVector2 inner1 = GLKVector2Subtract(v1, GLKVector2MultiplyScalar(offset1, 0.5));
			GLKVector2 outer0 = GLKVector2Add(v0, GLKVector2MultiplyScalar(offset0, 0.5));
			GLKVector2 outer1 = GLKVector2Add(v1, GLKVector2MultiplyScalar(offset1, 0.5));
			
			*cursor++ = (CCTriangle){
				MakeVertex(inner0, zero, fill4),
				MakeVertex(inner1, zero, fill4),
				MakeVertex(outer1, n0, fill4),
			};
			*cursor++ = (CCTriangle){
				MakeVertex(inner0, zero, fill4),
				MakeVertex(outer0, n0, fill4),
				MakeVertex(outer1, n0, fill4),
			};
		}
	}
}

-(void)clear
{
	_triangleCount = 0;
}

@end
