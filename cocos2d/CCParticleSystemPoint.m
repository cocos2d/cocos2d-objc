/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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

#import <Availability.h>
#import "CCParticleSystemPoint.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

// opengl
#import "Platforms/CCGL.h"

// cocos2d
#import "CCTextureCache.h"
#import "ccMacros.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@implementation CCParticleSystemPoint

-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {

		vertices = malloc( sizeof(ccPointSprite) * totalParticles );

		if( ! vertices ) {
			NSLog(@"cocos2d: Particle system: not enough memory");
			[self release];
			return nil;
		}

#if CC_USES_VBO
		glGenBuffers(1, &verticesID);
		
		// initial binding
		glBindBuffer(GL_ARRAY_BUFFER, verticesID);
		glBufferData(GL_ARRAY_BUFFER, sizeof(ccPointSprite)*totalParticles, vertices, GL_DYNAMIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif
	}

	return self;
}

-(void) dealloc
{
	free(vertices);
#if CC_USES_VBO
	glDeleteBuffers(1, &verticesID);
#endif
	
	[super dealloc];
}

-(void) updateQuadWithParticle:(tCCParticle*)p newPosition:(CGPoint)newPos
{	
	// place vertices and colos in array
	vertices[particleIdx].pos = (ccVertex2F) {newPos.x, newPos.y};
	vertices[particleIdx].size = p->size;
	ccColor4B color =  { p->color.r*255, p->color.g*255, p->color.b*255, p->color.a*255 };
	vertices[particleIdx].color = color;
}

-(void) postStep
{
#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(ccPointSprite)*particleCount, vertices);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif
}

-(void) draw
{
    if (particleIdx==0)
        return;
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY
	// Unneeded states: GL_TEXTURE_COORD_ARRAY
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glBindTexture(GL_TEXTURE_2D, texture_.name);
	
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
#define kPointSize sizeof(vertices[0])

#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);

	glVertexPointer(2,GL_FLOAT, kPointSize, 0);

	glColorPointer(4, GL_UNSIGNED_BYTE, kPointSize, (GLvoid*) offsetof(ccPointSprite, color) );

	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glPointSizePointerOES(GL_FLOAT, kPointSize, (GLvoid*) offsetof(ccPointSprite, size) );
#else // Uses Vertex Array List
	int offset = (int)vertices;
	glVertexPointer(2,GL_FLOAT, kPointSize, (GLvoid*) offset);
	
	int diff = offsetof(ccPointSprite, color);
	glColorPointer(4, GL_UNSIGNED_BYTE, kPointSize, (GLvoid*) (offset+diff));
	
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	diff = offsetof(ccPointSprite, size);
	glPointSizePointerOES(GL_FLOAT, kPointSize, (GLvoid*) (offset+diff));
#endif

	BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );


	glDrawArrays(GL_POINTS, 0, particleIdx);
	
	// restore blend state
	if( newBlend )
		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);

	
#if CC_USES_VBO
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif
	
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisable(GL_POINT_SPRITE_OES);

	// restore GL default state
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

#pragma mark Non supported properties

//
// SPIN IS NOT SUPPORTED
//
-(void) setStartSpin:(float)a
{
	NSAssert(a == 0, @"PointParticleSystem doesn't support spinning");
	[super setStartSpin:a];
}
-(void) setStartSpinVar:(float)a
{
	NSAssert(a == 0, @"PointParticleSystem doesn't support spinning");
	[super setStartSpin:a];
}
-(void) setEndSpin:(float)a
{
	NSAssert(a == 0, @"PointParticleSystem doesn't support spinning");
	[super setStartSpin:a];
}
-(void) setEndSpinVar:(float)a
{
	NSAssert(a == 0, @"PointParticleSystem doesn't support spinning");
	[super setStartSpin:a];
}

//
// SIZE > 64 IS NOT SUPPORTED
//
-(void) setStartSize:(float)size
{
	NSAssert(size >= 0 && size <= CC_MAX_PARTICLE_SIZE, @"PointParticleSystem only supports 0 <= size <= 64");
	[super setStartSize:size];
}

-(void) setEndSize:(float)size
{
	NSAssert( (size == kCCParticleStartSizeEqualToEndSize) ||
			 ( size >= 0 && size <= CC_MAX_PARTICLE_SIZE), @"PointParticleSystem only supports 0 <= size <= 64");
	[super setEndSize:size];
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@implementation CCParticleSystemPoint
@end

#endif // __MAC_OS_X_VERSION_MAX_ALLOWED


