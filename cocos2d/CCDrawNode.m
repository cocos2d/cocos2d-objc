/* Copyright (c) 2012 Scott Lembcke and Howling Moon Software
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
 * araker rewritten code for OpenGLES 1.1 and cocos2d
 *
 */

#import "CCDrawNode.h"
#import "CGPointExtension.h"
#import "ccTypes.h"
#import "OpenGL_Internal.h"


// ccVertex2F == CGPoint in 32-bits, but not in 64-bits (OS X)
// that's why the "v2f" functions are needed
static ccVertex2F v2fzero = {0,0};

static inline ccVertex2F v2f( float x, float y )
{
	return (ccVertex2F){x,y};
}

static inline ccVertex2F v2fadd( ccVertex2F v0, ccVertex2F v1 )
{
	return v2f( v0.x+v1.x, v0.y+v1.y );
}

static inline ccVertex2F v2fsub( ccVertex2F v0, ccVertex2F v1 )
{
	return v2f( v0.x-v1.x, v0.y-v1.y );
}

static inline ccVertex2F v2fmult( ccVertex2F v, float s )
{
	return v2f( v.x * s, v.y * s );
}

static inline ccVertex2F v2fperp( ccVertex2F p0 )
{
	return v2f( -p0.y, p0.x );
}

static inline ccVertex2F v2fneg( ccVertex2F p0 )
{
	return v2f( -p0.x, - p0.y );
}

static inline float v2fdot(ccVertex2F p0, ccVertex2F p1)
{
	return  p0.x * p1.x + p0.y * p1.y;
}

static inline ccVertex2F v2fforangle( float _a_)
{
	return v2f( cosf(_a_), sinf(_a_) );
}

static inline ccVertex2F v2fnormalize( ccVertex2F p )
{
	CGPoint r = ccpNormalize( ccp(p.x, p.y) );
	return v2f( r.x, r.y);
}

static inline ccVertex2F __v2f(CGPoint v )
{
#ifdef __LP64__
	return v2f(v.x, v.y);
#else
	return * ((ccVertex2F*) &v);
#endif
}

static inline ccTex2F __t(ccVertex2F v )
{
	return *(ccTex2F*)&v;
}

@implementation CCDrawNode

- (id) init
{
    if (self = [super init])
    {
        total_ = 0;
        capacity_ = 512;

        triangles_ = calloc( sizeof(triangles_[0]) * capacity_, 1 );

    }
    return self;
}

- (void) dealloc
{
    free(triangles_);
    [super dealloc];
}
#pragma mark memory

-(void)ensureCapacity:(NSUInteger)count
{
    if (total_ + count > capacity_)
    {
        [self resizeCapacity: total_ + count * 2];
    }
}

-(BOOL) resizeCapacity: (NSUInteger) newCapacity
{
	if( newCapacity == capacity_ )
		return YES;

	capacity_ = newCapacity;

	void * tmpTriangles = realloc( triangles_, sizeof(triangles_[0]) * capacity_ );


	if( ! ( tmpTriangles) ) {
		CCLOG(@"cocos2d: CCDrawNode: not enough memory");
		if( tmpTriangles )
			free(tmpTriangles);

		tmpTriangles = nil;
		capacity_ = total_ = 0;
		return NO;
	}

	triangles_ = tmpTriangles;

	return YES;
}

#pragma mark Rendering

-(void)render
{
	[self draw];
}

- (void) draw
{
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);

    NSUInteger offset = (NSUInteger)triangles_;

    int triangleSize = sizeof(triangles_[0].a);
	// vertex
	NSUInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexPointer(3, GL_FLOAT, triangleSize, (GLvoid*) (offset + diff) );
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glColorPointer(4, GL_UNSIGNED_BYTE, triangleSize, (GLvoid*)(offset + diff));

    //XXX very simple batching, should be using a VBO and indices
	glDrawArrays(GL_TRIANGLES, 0, total_ * 3);

    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

#pragma mark Immediate Mode

-(void)drawDot:(CGPoint)pos radius:(CGFloat)radius color:(ccColor4F)color;
{
	NSUInteger triangleCount = 2;
	[self ensureCapacity:triangleCount];

	ccV2F_C4B_T2F a = {{pos.x - radius, pos.y - radius}, ccc4BFromccc4F(color), {-1.0, -1.0} };
	ccV2F_C4B_T2F b = {{pos.x - radius, pos.y + radius}, ccc4BFromccc4F(color), {-1.0,  1.0} };
	ccV2F_C4B_T2F c = {{pos.x + radius, pos.y + radius}, ccc4BFromccc4F(color), { 1.0,  1.0} };
	ccV2F_C4B_T2F d = {{pos.x + radius, pos.y - radius}, ccc4BFromccc4F(color), { 1.0, -1.0} };

	ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(triangles_ + total_);

	triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
	triangles[1] = (ccV2F_C4B_T2F_Triangle){a, c, d};

	total_ += triangleCount;
}

-(void)drawSegmentFrom:(CGPoint)_a to:(CGPoint)_b radius:(CGFloat)radius color:(ccColor4F)color;
{
	NSUInteger triangleCount = 6;

	ccVertex2F a = __v2f(_a);
	ccVertex2F b = __v2f(_b);


	ccVertex2F n = v2fnormalize(v2fperp(v2fsub(b, a)));
	ccVertex2F t = v2fperp(n);

	ccVertex2F nw = v2fmult(n, radius);
	ccVertex2F tw = v2fmult(t, radius);
	ccVertex2F v0 = v2fsub(b, v2fadd(nw, tw));
	ccVertex2F v1 = v2fadd(b, v2fsub(nw, tw));
	ccVertex2F v2 = v2fsub(b, nw);
	ccVertex2F v3 = v2fadd(b, nw);
	ccVertex2F v4 = v2fsub(a, nw);
	ccVertex2F v5 = v2fadd(a, nw);
	ccVertex2F v6 = v2fsub(a, v2fsub(nw, tw));
	ccVertex2F v7 = v2fadd(a, v2fadd(nw, tw));


	ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(triangles_ + total_);

	triangles[0] = (ccV2F_C4B_T2F_Triangle) {
		{v0, ccc4BFromccc4F(color), __t(v2fneg(v2fadd(n, t))) },
		{v1, ccc4BFromccc4F(color), __t(v2fsub(n, t)) },
		{v2, ccc4BFromccc4F(color), __t(v2fneg(n)) },
	};

	triangles[1] = (ccV2F_C4B_T2F_Triangle){
		{v3, ccc4BFromccc4F(color), __t(n)},
		{v1, ccc4BFromccc4F(color), __t(v2fsub(n, t)) },
		{v2, ccc4BFromccc4F(color), __t(v2fneg(n)) },
	};

	triangles[2] = (ccV2F_C4B_T2F_Triangle){
		{v3, ccc4BFromccc4F(color), __t(n)},
		{v4, ccc4BFromccc4F(color), __t(v2fneg(n)) },
		{v2, ccc4BFromccc4F(color), __t(v2fneg(n)) },
	};
	triangles[3] = (ccV2F_C4B_T2F_Triangle){
		{v3, ccc4BFromccc4F(color), __t(n) },
		{v4, ccc4BFromccc4F(color), __t(v2fneg(n)) },
		{v5, ccc4BFromccc4F(color), __t(n) },
	};
	triangles[4] = (ccV2F_C4B_T2F_Triangle){
		{v6, ccc4BFromccc4F(color), __t(v2fsub(t, n))},
		{v4, ccc4BFromccc4F(color), __t(v2fneg(n)) },
		{v5, ccc4BFromccc4F(color), __t(n)},
	};
	triangles[5] = (ccV2F_C4B_T2F_Triangle){
		{v6, ccc4BFromccc4F(color), __t(v2fsub(t, n)) },
		{v7, ccc4BFromccc4F(color), __t(v2fadd(n, t)) },
		{v5, ccc4BFromccc4F(color), __t(n)},
	};

	total_ += triangleCount;
}

-(void)drawPolyWithVerts:(CGPoint *)verts count:(NSUInteger)count fillColor:(ccColor4F)fill  borderWidth:(CGFloat)width borderColor:(ccColor4F)line;
{
	struct ExtrudeVerts {ccVertex2F offset, n;};
	struct ExtrudeVerts extrude[count];
	bzero(extrude, sizeof(extrude) );

	for(int i=0; i<count; i++){
		ccVertex2F v0 = __v2f( verts[(i-1+count)%count] );
		ccVertex2F v1 = __v2f( verts[i] );
		ccVertex2F v2 = __v2f( verts[(i+1)%count] );

		ccVertex2F n1 = v2fnormalize(v2fperp(v2fsub(v1, v0)));
		ccVertex2F n2 = v2fnormalize(v2fperp(v2fsub(v2, v1)));

		ccVertex2F offset = v2fmult(v2fadd(n1, n2), 1.0/(v2fdot(n1, n2) + 1.0));
		extrude[i] = (struct ExtrudeVerts){offset, n2};
	}

	BOOL outline = (line.a > 0.0 && width > 0.0);

	NSUInteger triangleCount = 3*count - 2;

	[self ensureCapacity:triangleCount];

	ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(triangles_ + total_);
	ccV2F_C4B_T2F_Triangle *cursor = triangles;

	CGFloat inset = (outline == 0.0 ? 0.5 : 0.0);
	for(int i=0; i<count-2; i++){
		ccVertex2F v0 = v2fsub( __v2f(verts[0  ]), v2fmult(extrude[0  ].offset, inset));
		ccVertex2F v1 = v2fsub( __v2f(verts[i+1]), v2fmult(extrude[i+1].offset, inset));
		ccVertex2F v2 = v2fsub( __v2f(verts[i+2]), v2fmult(extrude[i+2].offset, inset));

		*cursor++ = (ccV2F_C4B_T2F_Triangle){
			{v0, ccc4BFromccc4F(fill), __t(v2fzero) },
			{v1, ccc4BFromccc4F(fill), __t(v2fzero) },
			{v2, ccc4BFromccc4F(fill), __t(v2fzero) },
		};
	}

	for(int i=0; i<count; i++){
		int j = (i+1)%count;
		ccVertex2F v0 = __v2f( verts[i] );
		ccVertex2F v1 = __v2f( verts[j] );

		ccVertex2F n0 = extrude[i].n;

		ccVertex2F offset0 = extrude[i].offset;
		ccVertex2F offset1 = extrude[j].offset;

		if(outline){
			ccVertex2F inner0 = v2fsub(v0, v2fmult(offset0, width));
			ccVertex2F inner1 = v2fsub(v1, v2fmult(offset1, width));
			ccVertex2F outer0 = v2fadd(v0, v2fmult(offset0, width));
			ccVertex2F outer1 = v2fadd(v1, v2fmult(offset1, width));

			*cursor++ = (ccV2F_C4B_T2F_Triangle){
				{inner0, ccc4BFromccc4F(line), __t(v2fneg(n0))},
				{inner1, ccc4BFromccc4F(line), __t(v2fneg(n0))},
				{outer1, ccc4BFromccc4F(line), __t(n0)}
			};
			*cursor++ = (ccV2F_C4B_T2F_Triangle){
				{inner0, ccc4BFromccc4F(line), __t(v2fneg(n0))},
				{outer0, ccc4BFromccc4F(line), __t(n0)},
				{outer1, ccc4BFromccc4F(line), __t(n0)}
			};
		} else {
			ccVertex2F inner0 = v2fsub(v0, v2fmult(offset0, 0.5));
			ccVertex2F inner1 = v2fsub(v1, v2fmult(offset1, 0.5));
			ccVertex2F outer0 = v2fadd(v0, v2fmult(offset0, 0.5));
			ccVertex2F outer1 = v2fadd(v1, v2fmult(offset1, 0.5));

			*cursor++ = (ccV2F_C4B_T2F_Triangle){
				{inner0, ccc4BFromccc4F(fill), __t(v2fzero)},
				{inner1, ccc4BFromccc4F(fill), __t(v2fzero)},
				{outer1, ccc4BFromccc4F(fill), __t(n0)}
			};
			*cursor++ = (ccV2F_C4B_T2F_Triangle){
				{inner0, ccc4BFromccc4F(fill), __t(v2fzero)},
				{outer0, ccc4BFromccc4F(fill), __t(n0)},
				{outer1, ccc4BFromccc4F(fill), __t(n0)}
			};
		}
	}

	total_ += triangleCount;

}

-(void)clear
{
	total_ = 0;
}

@end
