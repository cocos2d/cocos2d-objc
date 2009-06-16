/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
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
#import "PointParticleSystem.h"
#import "TextureMgr.h"
#import "ccMacros.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@implementation PointParticleSystem

-(id) initWithTotalParticles:(int) numberOfParticles
{
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {

		vertices = malloc( sizeof(ccPointSprite) * totalParticles );

		if( ! vertices ) {
			NSLog(@"Particle system: not enough memory");
			if( vertices )
				free(vertices);
			return nil;
		}

		glGenBuffers(1, &verticesID);
		
		// initial binding
		glBindBuffer(GL_ARRAY_BUFFER, verticesID);
		glBufferData(GL_ARRAY_BUFFER, sizeof(ccPointSprite)*totalParticles, vertices,GL_DYNAMIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);		
	}

	return self;
}

-(void) dealloc
{
	free(vertices);
	glDeleteBuffers(1, &verticesID);
	
	[super dealloc];
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
			// update values in point
			//
			CGPoint	newPos = p->pos;
			if( positionType_ == kPositionTypeWorld ) {
				newPos = ccpSub(absolutePosition, p->startPos);
				newPos = ccpSub( p->pos, newPos);
			}
			
			// place vertices and colos in array
			vertices[particleIdx].pos = newPos;
			vertices[particleIdx].size = p->size;
			vertices[particleIdx].colors = p->color;

			// update particle counter
			particleIdx++;
			
		} else {
			// life < 0
			if( particleIdx != particleCount-1 )
				particles[particleIdx] = particles[particleCount-1];
			particleCount--;
		}
	}
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(ccPointSprite)*totalParticles, vertices,GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void) draw
{
//	int blendSrc, blendDst;
//	int colorMode;
	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture_.name);
	
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);

	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2,GL_FLOAT,sizeof(vertices[0]),0);

	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_FLOAT, sizeof(vertices[0]),(GLvoid*) offsetof(ccPointSprite,colors) );

	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glPointSizePointerOES(GL_FLOAT,sizeof(vertices[0]),(GLvoid*) offsetof(ccPointSprite,size) );
	

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

	glDrawArrays(GL_POINTS, 0, particleIdx);
	
	// restore blend state
	if( blendAdditive || newBlend )
		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);

#if 0
	// restore color mode
	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, colorMode);
#endif
	
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);
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
	NSAssert(size <= 64, @"PointParticleSystem doesn't support size > 64");
	[super setStartSize:size];
}
@end


