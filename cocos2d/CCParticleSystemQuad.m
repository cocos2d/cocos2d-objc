/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Leonardo Kasperavičius
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


// opengl
#import "Platforms/CCGL.h"

// cocos2d
#import "ccConfig.h"
#import "CCParticleSystemQuad.h"
#import "CCTextureCache.h"
#import "ccMacros.h"
#import "CCSpriteFrame.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@implementation CCParticleSystemQuad


// overriding the init method
-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
	// base initialization
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {
	
		// allocating data space
		quads_ = calloc( sizeof(quads_[0]) * totalParticles, 1 );
		indices_ = calloc( sizeof(indices_[0]) * totalParticles * 6, 1 );
		
		if( !quads_ || !indices_) {
			NSLog(@"cocos2d: Particle system: not enough memory");
			if( quads_ )
				free( quads_ );
			if(indices_)
				free(indices_);
			
			[self release];
			return nil;
		}
		
		// initialize only once the texCoords and the indices
		[self initTexCoordsWithRect:CGRectMake(0, 0, [texture_ pixelsWide], [texture_ pixelsHigh])];
		[self initIndices];

#if CC_USES_VBO
		// create the VBO buffer
		glGenBuffers(1, &quadsID_);
		
		// initial binding
		glBindBuffer(GL_ARRAY_BUFFER, quadsID_);
		glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0])*totalParticles, quads_,GL_DYNAMIC_DRAW);	
		glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif
	}
		
	return self;
}

-(void) dealloc
{
	free(quads_);
	free(indices_);
#if CC_USES_VBO
	glDeleteBuffers(1, &quadsID_);
#endif
	
	[super dealloc];
}

// pointRect is in Points coordinates.
-(void) initTexCoordsWithRect:(CGRect)pointRect
{
	// convert to pixels coords
	CGRect rect = CGRectMake(
							 pointRect.origin.x * CC_CONTENT_SCALE_FACTOR(),
							 pointRect.origin.y * CC_CONTENT_SCALE_FACTOR(),
							 pointRect.size.width * CC_CONTENT_SCALE_FACTOR(),
							 pointRect.size.height * CC_CONTENT_SCALE_FACTOR() );

	GLfloat wide = [texture_ pixelsWide];
	GLfloat high = [texture_ pixelsHigh];

#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	GLfloat left = (rect.origin.x*2+1) / (wide*2);
	GLfloat bottom = (rect.origin.y*2+1) / (high*2);
	GLfloat right = left + (rect.size.width*2-2) / (wide*2);
	GLfloat top = bottom + (rect.size.height*2-2) / (high*2);
#else
	GLfloat left = rect.origin.x / wide;
	GLfloat bottom = rect.origin.y / high;
	GLfloat right = left + rect.size.width / wide;
	GLfloat top = bottom + rect.size.height / high;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	
	// Important. Texture in cocos2d are inverted, so the Y component should be inverted
	CC_SWAP( top, bottom);
	
	for(NSUInteger i=0; i<totalParticles; i++) {
		// bottom-left vertex:
		quads_[i].bl.texCoords.u = left;
		quads_[i].bl.texCoords.v = bottom;
		// bottom-right vertex:
		quads_[i].br.texCoords.u = right;
		quads_[i].br.texCoords.v = bottom;
		// top-left vertex:
		quads_[i].tl.texCoords.u = left;
		quads_[i].tl.texCoords.v = top;
		// top-right vertex:
		quads_[i].tr.texCoords.u = right;
		quads_[i].tr.texCoords.v = top;
	}
}

-(void) setTexture:(CCTexture2D *)texture withRect:(CGRect)rect
{
	// Only update the texture if is different from the current one
	if( [texture name] != [texture_ name] )
		[super setTexture:texture];
	
	[self initTexCoordsWithRect:rect];
}

-(void) setTexture:(CCTexture2D *)texture
{
	CGSize s = [texture contentSize];
	[self setTexture:texture withRect:CGRectMake(0,0, s.width, s.height)];
}

-(void) setDisplayFrame:(CCSpriteFrame *)spriteFrame
{

	NSAssert( CGPointEqualToPoint( spriteFrame.offsetInPixels , CGPointZero ), @"QuadParticle only supports SpriteFrames with no offsets");

	// update texture before updating texture rect
	if ( spriteFrame.texture.name != texture_.name )
		[self setTexture: spriteFrame.texture];	
}

-(void) initIndices
{
	for( NSUInteger i=0;i< totalParticles;i++) {
		const NSUInteger i6 = i*6;
		const NSUInteger i4 = i*4;
		indices_[i6+0] = (GLushort) i4+0;
		indices_[i6+1] = (GLushort) i4+1;
		indices_[i6+2] = (GLushort) i4+2;
		
		indices_[i6+5] = (GLushort) i4+1;
		indices_[i6+4] = (GLushort) i4+2;
		indices_[i6+3] = (GLushort) i4+3;
	}
}

-(void) updateQuadWithParticle:(tCCParticle*)p newPosition:(CGPoint)newPos
{
	// colors
	ccV2F_C4B_T2F_Quad *quad = &(quads_[particleIdx]);
	
	ccColor4B color = { p->color.r*255, p->color.g*255, p->color.b*255, p->color.a*255};
	quad->bl.colors = color;
	quad->br.colors = color;
	quad->tl.colors = color;
	quad->tr.colors = color;
	
	// vertices
	GLfloat size_2 = p->size/2;
	if( p->rotation ) {
		GLfloat x1 = -size_2;
		GLfloat y1 = -size_2;
		
		GLfloat x2 = size_2;
		GLfloat y2 = size_2;
		GLfloat x = newPos.x;
		GLfloat y = newPos.y;
		
		GLfloat r = (GLfloat)-CC_DEGREES_TO_RADIANS(p->rotation);
		GLfloat cr = cosf(r);
		GLfloat sr = sinf(r);
		GLfloat ax = x1 * cr - y1 * sr + x;
		GLfloat ay = x1 * sr + y1 * cr + y;
		GLfloat bx = x2 * cr - y1 * sr + x;
		GLfloat by = x2 * sr + y1 * cr + y;
		GLfloat cx = x2 * cr - y2 * sr + x;
		GLfloat cy = x2 * sr + y2 * cr + y;
		GLfloat dx = x1 * cr - y2 * sr + x;
		GLfloat dy = x1 * sr + y2 * cr + y;
		
		// bottom-left
		quad->bl.vertices.x = ax;
		quad->bl.vertices.y = ay;
		
		// bottom-right vertex:
		quad->br.vertices.x = bx;
		quad->br.vertices.y = by;
		
		// top-left vertex:
		quad->tl.vertices.x = dx;
		quad->tl.vertices.y = dy;
		
		// top-right vertex:
		quad->tr.vertices.x = cx;
		quad->tr.vertices.y = cy;
	} else {
		// bottom-left vertex:
		quad->bl.vertices.x = newPos.x - size_2;
		quad->bl.vertices.y = newPos.y - size_2;
		
		// bottom-right vertex:
		quad->br.vertices.x = newPos.x + size_2;
		quad->br.vertices.y = newPos.y - size_2;
		
		// top-left vertex:
		quad->tl.vertices.x = newPos.x - size_2;
		quad->tl.vertices.y = newPos.y + size_2;
		
		// top-right vertex:
		quad->tr.vertices.x = newPos.x + size_2;
		quad->tr.vertices.y = newPos.y + size_2;				
	}
}

-(void) postStep
{
#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, quadsID_);
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(quads_[0])*particleCount, quads_);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif
}

// overriding draw method
-(void) draw
{	
	[super draw];

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: -

	glBindTexture(GL_TEXTURE_2D, [texture_ name]);

#define kQuadSize sizeof(quads_[0].bl)

#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, quadsID_);

	glVertexPointer(2,GL_FLOAT, kQuadSize, 0);

	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (GLvoid*) offsetof(ccV2F_C4B_T2F,colors) );
	
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (GLvoid*) offsetof(ccV2F_C4B_T2F,texCoords) );
#else // vertex array list

	NSUInteger offset = (NSUInteger) quads_;

	// vertex
	NSUInteger diff = offsetof( ccV2F_C4B_T2F, vertices);
	glVertexPointer(2,GL_FLOAT, kQuadSize, (GLvoid*) (offset+diff) );
	
	// color
	diff = offsetof( ccV2F_C4B_T2F, colors);
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (GLvoid*)(offset + diff));
	
	// tex coords
	diff = offsetof( ccV2F_C4B_T2F, texCoords);
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (GLvoid*)(offset + diff));		

#endif // ! CC_USES_VBO
	
	BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	NSAssert( particleIdx == particleCount, @"Abnormal error in particle quad");
	glDrawElements(GL_TRIANGLES, (GLsizei) particleIdx*6, GL_UNSIGNED_SHORT, indices_);
	
	// restore blend state
	if( newBlend )
		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );

#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif

	// restore GL default state
	// -
}

@end


