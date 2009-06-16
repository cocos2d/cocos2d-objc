/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Leonardo Kasperavičius
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

// opengl
#import <OpenGLES/ES1/gl.h>

// cocos2d
#import "QuadParticleSystem.h"
#import "TextureMgr.h"
#import "ccMacros.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@implementation QuadParticleSystem

// overriding the init method
-(id) initWithTotalParticles:(int) numberOfParticles
{
	// base initialization
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {
	
		// allocating data space
		quads = malloc( sizeof(quads[0]) * totalParticles );
		indices = malloc( sizeof(indices[0]) * totalParticles * 6 );
		
		if( !quads || !indices) {
			NSLog(@"Particle system: not enough memory");
			if( quads )
				free( quads );
			if(indices)
				free(indices);
			return nil;
		}
		
		// initialize only once the texCoords and the indices
		[self initTexCoords];
		[self initIndices];

		// create the VBO buffer
		glGenBuffers(1, &quadsID);
		
		// initial binding
		glBindBuffer(GL_ARRAY_BUFFER, quadsID);
		glBufferData(GL_ARRAY_BUFFER, sizeof(quads[0])*totalParticles, quads,GL_DYNAMIC_DRAW);	
		glBindBuffer(GL_ARRAY_BUFFER, 0);		
	}
		
	return self;
}

-(void) dealloc
{
	free(quads);
	free(indices);
	glDeleteBuffers(1, &quadsID);
	
	[super dealloc];
}

-(void) initTexCoords
{
	for(int i=0; i<totalParticles; i++) {
		// top-left vertex:
		quads[i].bl.texCoords.u = 0;
		quads[i].bl.texCoords.v = 0;
		// bottom-left vertex:
		quads[i].br.texCoords.u = 1;
		quads[i].br.texCoords.v = 0;
		// top-right vertex:
		quads[i].tl.texCoords.u = 0;
		quads[i].tl.texCoords.v = 1;
		// top-right vertex:
		quads[i].tr.texCoords.u = 1;
		quads[i].tr.texCoords.v = 1;
	}
}	
-(void) initIndices
{
	for( int i=0;i< totalParticles;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;
		
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;
	}
}


// XXX
// XXX: All subclasses of ParticleSystem share this code
// XXX: so some parts of this coded should be moved to the base class
// XXX
// XXX: BUT the change shall NOT DROP a single FPS
// XXX:
-(void) step: (ccTime) dt
{
	if( active && emissionRate ) {
		float rate = 1.0f / emissionRate;
		emitCounter += dt;
		while( particleCount < totalParticles && emitCounter > rate ) {
			[self addParticle];
			emitCounter -= rate;
		}
		
		elapsed += dt;
		if(duration != -1 && duration < elapsed)
			[self stopSystem];
	}
	
	particleIdx = 0;
	
	// test performance with [self absolutePosition];
//	CGPoint	absolutePosition = [self convertToWorldSpace:CGPointZero];
	CGPoint	absolutePosition = position_;
	
	while( particleIdx < particleCount )
	{
		Particle *p = &particles[particleIdx];
		
		if( p->life > 0 ) {
			
			CGPoint tmp, radial, tangential;
			
			radial = CGPointZero;
			// radial acceleration
			if(p->pos.x || p->pos.y)
				radial = ccpNormalize(p->pos);
			tangential = radial;
			radial = ccpMult(radial, p->radialAccel);
			
			// tangential acceleration
			float newy = tangential.x;
			tangential.x = -tangential.y;
			tangential.y = newy;
			tangential = ccpMult(tangential, p->tangentialAccel);
			
			// (gravity + radial + tangential) * dt
			tmp = ccpAdd( ccpAdd( radial, tangential), gravity);
			tmp = ccpMult( tmp, dt);
			p->dir = ccpAdd( p->dir, tmp);
			tmp = ccpMult(p->dir, dt);
			p->pos = ccpAdd( p->pos, tmp );
			
			p->color.r += (p->deltaColor.r * dt);
			p->color.g += (p->deltaColor.g * dt);
			p->color.b += (p->deltaColor.b * dt);
			p->color.a += (p->deltaColor.a * dt);
			
			p->size += (p->deltaSize * dt);

			p->life -= dt;
			
			//
			// update values in quad
			//

			CGPoint	newPos = p->pos;
			if( positionType_ == kPositionTypeWorld ) {
				newPos = ccpSub(absolutePosition, p->startPos);
				newPos = ccpSub( p->pos, newPos);
			}
			
			// colors
			quads[particleIdx].bl.colors = p->color;
			quads[particleIdx].br.colors = p->color;
			quads[particleIdx].tl.colors = p->color;
			quads[particleIdx].tr.colors = p->color;
			
			// vertices
			float size_2 = p->size/2;
			p->angle += (p->deltaAngle * dt);
			if( p->angle ) {
				float x1 = -size_2;
				float y1 = -size_2;
				
				float x2 = x1 + p->size;
				float y2 = y1 + p->size;
				float x = newPos.x;
				float y = newPos.y;
				
				float r = (float)-CC_DEGREES_TO_RADIANS(p->angle);
				float cr = cosf(r);
				float sr = sinf(r);
				float ax = x1 * cr - y1 * sr + x;
				float ay = x1 * sr + y1 * cr + y;
				float bx = x2 * cr - y1 * sr + x;
				float by = x2 * sr + y1 * cr + y;
				float cx = x2 * cr - y2 * sr + x;
				float cy = x2 * sr + y2 * cr + y;
				float dx = x1 * cr - y2 * sr + x;
				float dy = x1 * sr + y2 * cr + y;
				
				quads[particleIdx].bl.vertices.x = ax;
				quads[particleIdx].bl.vertices.y = ay;
				
				// bottom-left vertex:
				quads[particleIdx].br.vertices.x = bx;
				quads[particleIdx].br.vertices.y = by;
				
				// top-right vertex:
				quads[particleIdx].tl.vertices.x = dx;
				quads[particleIdx].tl.vertices.y = dy;
				
				// top-right vertex:
				quads[particleIdx].tr.vertices.x = cx;
				quads[particleIdx].tr.vertices.y = cy;
			} else {
				// top-left vertex:
				quads[particleIdx].bl.vertices.x = newPos.x - size_2;
				quads[particleIdx].bl.vertices.y = newPos.y - size_2;
				
				// bottom-left vertex:
				quads[particleIdx].br.vertices.x = newPos.x + size_2;
				quads[particleIdx].br.vertices.y = newPos.y - size_2;
				
				// top-right vertex:
				quads[particleIdx].tl.vertices.x = newPos.x - size_2;
				quads[particleIdx].tl.vertices.y = newPos.y + size_2;
				
				// top-right vertex:
				quads[particleIdx].tr.vertices.x = newPos.x + size_2;
				quads[particleIdx].tr.vertices.y = newPos.y + size_2;				
			}
			
			// update particle counter
			particleIdx++;
			
		} else {
			// life < 0
			if( particleIdx != particleCount-1 )
				particles[particleIdx] = particles[particleCount-1];
			particleCount--;
		}
	}
	glBindBuffer(GL_ARRAY_BUFFER, quadsID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(quads[0])*totalParticles, quads,GL_DYNAMIC_DRAW);	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

// overriding draw method
-(void) draw
{	
	glEnable(GL_TEXTURE_2D);
	
	glBindTexture(GL_TEXTURE_2D, texture_.name);

	glBindBuffer(GL_ARRAY_BUFFER, quadsID);

#define kPointSize sizeof(quads[0].bl)
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2,GL_FLOAT, kPointSize, 0);

	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_FLOAT, kPointSize, (GLvoid*) offsetof(ccV2F_C4F_T2F,colors) );
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, kPointSize, (GLvoid*) offsetof(ccV2F_C4F_T2F,texCoords) );
	
	
	BOOL newBlend = NO;
	if( blendAdditive )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	else if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}
	
	// save color mode
#if 0
	glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &colorMode);
	if( colorModulate )
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	else
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
#endif
	
	glDrawElements(GL_TRIANGLES, particleIdx*6, GL_UNSIGNED_SHORT, indices);	
	
	// restore blend state
	if( blendAdditive || newBlend )
		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );
	
#if 0
	// restore color mode
	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, colorMode);
#endif
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

@end


