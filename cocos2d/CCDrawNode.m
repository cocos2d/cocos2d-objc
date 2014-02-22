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

static inline CCVertex
MakeVertex(GLKVector2 v, GLKVector2 texCoord, GLKVector4 color)
{
	return (CCVertex){GLKVector3Make(v.x, v.y, 0.0f), texCoord, GLKVector2Make(0.0f, 0.0f), color};
}

-(void)drawSegmentFrom:(CGPoint)_a to:(CGPoint)_b radius:(CGFloat)radius color:(CCColor*)color;
{
	
	GLKVector2 a = GLKVector2Make(_a.x, _a.y);
	GLKVector2 b = GLKVector2Make(_b.x, _b.y);
	
	GLKVector2 t = GLKVector2Normalize(GLKVector2Subtract(b, a));
	GLKVector2 n = GLKVector2Make(-t.y, t.x);
	
	GLKVector2 nw = GLKVector2MultiplyScalar(n, radius);
	GLKVector2 tw = GLKVector2MultiplyScalar(t, radius);
	GLKVector2 v0 = GLKVector2Subtract(b, GLKVector2Add(nw, tw));
	GLKVector2 v1 = GLKVector2Add(b, GLKVector2Subtract(nw, tw));
	GLKVector2 v2 = GLKVector2Subtract(b, nw);
	GLKVector2 v3 = GLKVector2Add(b, nw);
	GLKVector2 v4 = GLKVector2Subtract(a, nw);
	GLKVector2 v5 = GLKVector2Add(a, nw);
//	GLKVector2 v6 = GLKVector2Subtract(a, GLKVector2Subtract(nw, tw));
//	GLKVector2 v7 = GLKVector2Add(a, GLKVector2Add(nw, tw));
	
	GLKVector4 color4 = color.glkVector4;
	CCTriangle *triangles = [self bufferTriangles:2];
	
	triangles[0] = (CCTriangle){
		MakeVertex(v3, n, color4),
		MakeVertex(v4, GLKVector2Negate(n), color4),
		MakeVertex(v2, GLKVector2Negate(n), color4),
	};

	triangles[1] = (CCTriangle){
		MakeVertex(v3, n, color4),
		MakeVertex(v4, GLKVector2Negate(n), color4),
		MakeVertex(v5, n, color4),
	};

//	triangles[0] = (CCTriangle){
//		MakeVertex(v0, GLKVector2Negate(GLKVector2Add(n, t)), color4),
//		MakeVertex(v1, GLKVector2Subtract(n, t), color4),
//		MakeVertex(v2, GLKVector2Negate(n), color4),
//	};

//	triangles[0] = (CCTriangle) {
//		{v0, c4, __t(GLKVector2Negate(GLKVector2Add(n, t))) },
//		{v1, c4, __t(GLKVector2Subtract(n, t)) },
//		{v2, c4, __t(GLKVector2Negate(n)) },
//	};
//	
//	triangles[1] = (ccV2F_C4B_T2F_Triangle){
//		{v3, c4, __t(n)},
//		{v1, c4, __t(GLKVector2Subtract(n, t)) },
//		{v2, c4, __t(GLKVector2Negate(n)) },
//	};
//	
//	triangles[2] = (ccV2F_C4B_T2F_Triangle){
//		{v3, c4, __t(n)},
//		{v4, c4, __t(GLKVector2Negate(n)) },
//		{v2, c4, __t(GLKVector2Negate(n)) },
//	};
//	triangles[3] = (ccV2F_C4B_T2F_Triangle){
//		{v3, c4, __t(n) },
//		{v4, c4, __t(GLKVector2Negate(n)) },
//		{v5, c4, __t(n) },
//	};
//	triangles[4] = (ccV2F_C4B_T2F_Triangle){
//		{v6, c4, __t(GLKVector2Subtract(t, n))},
//		{v4, c4, __t(GLKVector2Negate(n)) },
//		{v5, c4, __t(n)},
//	};
//	triangles[5] = (ccV2F_C4B_T2F_Triangle){
//		{v6, c4, __t(GLKVector2Subtract(t, n)) },
//		{v7, c4, __t(GLKVector2Add(n, t)) },
//		{v5, c4, __t(n)},
//	};
}

-(void)drawPolyWithVerts:(const CGPoint *)verts count:(NSUInteger)count fillColor:(CCColor*)fill  borderWidth:(CGFloat)width borderColor:(CCColor*)line;
{
//    ccColor4B fill4 = fill.ccColor4b;
//    ccColor4B line4 = line.ccColor4b;
//    
//	struct ExtrudeVerts {GLKVector2 offset, n;};
//	struct ExtrudeVerts extrude[count];
//	bzero(extrude, sizeof(extrude) );
//	
//	for(int i=0; i<count; i++){
//		GLKVector2 v0 = __v2f( verts[(i-1+count)%count] );
//		GLKVector2 v1 = __v2f( verts[i] );
//		GLKVector2 v2 = __v2f( verts[(i+1)%count] );
//	
//		GLKVector2 n1 = v2fnormalize(v2fperp(GLKVector2Subtract(v1, v0)));
//		GLKVector2 n2 = v2fnormalize(v2fperp(GLKVector2Subtract(v2, v1)));
//		
//		GLKVector2 offset = v2fmult(GLKVector2Add(n1, n2), 1.0/(v2fdot(n1, n2) + 1.0));
//		extrude[i] = (struct ExtrudeVerts){offset, n2};
//	}
//	
//	BOOL outline = (line4.a > 0 && width > 0.0);
//	
//	NSUInteger triangle_count = 3*count - 2;
//	NSUInteger vertex_count = 3*triangle_count;
//	[self ensureCapacity:vertex_count];
//	
//	ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
//	ccV2F_C4B_T2F_Triangle *cursor = triangles;
//	
//	CGFloat inset = (outline == 0.0 ? 0.5 : 0.0);
//	for(int i=0; i<count-2; i++){
//		GLKVector2 v0 = GLKVector2Subtract( __v2f(verts[0  ]), v2fmult(extrude[0  ].offset, inset));
//		GLKVector2 v1 = GLKVector2Subtract( __v2f(verts[i+1]), v2fmult(extrude[i+1].offset, inset));
//		GLKVector2 v2 = GLKVector2Subtract( __v2f(verts[i+2]), v2fmult(extrude[i+2].offset, inset));
//		
//		*cursor++ = (ccV2F_C4B_T2F_Triangle){
//			{v0, fill4, __t(v2fzero) },
//			{v1, fill4, __t(v2fzero) },
//			{v2, fill4, __t(v2fzero) },
//		};
//	}
//	
//	for(int i=0; i<count; i++){
//		int j = (i+1)%count;
//		GLKVector2 v0 = __v2f( verts[i] );
//		GLKVector2 v1 = __v2f( verts[j] );
//		
//		GLKVector2 n0 = extrude[i].n;
//		
//		GLKVector2 offset0 = extrude[i].offset;
//		GLKVector2 offset1 = extrude[j].offset;
//		
//		if(outline){
//			GLKVector2 inner0 = GLKVector2Subtract(v0, v2fmult(offset0, width));
//			GLKVector2 inner1 = GLKVector2Subtract(v1, v2fmult(offset1, width));
//			GLKVector2 outer0 = GLKVector2Add(v0, v2fmult(offset0, width));
//			GLKVector2 outer1 = GLKVector2Add(v1, v2fmult(offset1, width));
//			
//			*cursor++ = (ccV2F_C4B_T2F_Triangle){
//				{inner0, line4, __t(GLKVector2Negate(n0))},
//				{inner1, line4, __t(GLKVector2Negate(n0))},
//				{outer1, line4, __t(n0)}
//			};
//			*cursor++ = (ccV2F_C4B_T2F_Triangle){
//				{inner0, line4, __t(GLKVector2Negate(n0))},
//				{outer0, line4, __t(n0)},
//				{outer1, line4, __t(n0)}
//			};
//		} else {
//			GLKVector2 inner0 = GLKVector2Subtract(v0, v2fmult(offset0, 0.5));
//			GLKVector2 inner1 = GLKVector2Subtract(v1, v2fmult(offset1, 0.5));
//			GLKVector2 outer0 = GLKVector2Add(v0, v2fmult(offset0, 0.5));
//			GLKVector2 outer1 = GLKVector2Add(v1, v2fmult(offset1, 0.5));
//			
//			*cursor++ = (ccV2F_C4B_T2F_Triangle){
//				{inner0, fill4, __t(v2fzero)},
//				{inner1, fill4, __t(v2fzero)},
//				{outer1, fill4, __t(n0)}
//			};
//			*cursor++ = (ccV2F_C4B_T2F_Triangle){
//				{inner0, fill4, __t(v2fzero)},
//				{outer0, fill4, __t(n0)},
//				{outer1, fill4, __t(n0)}
//			};
//		}
//	}
//	
//	_bufferCount += vertex_count;
}

-(void)clear
{
	_triangleCount = 0;
}

@end
