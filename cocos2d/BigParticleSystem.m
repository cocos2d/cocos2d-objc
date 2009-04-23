/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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
#import "BigParticleSystem.h"
#import "TextureMgr.h"
#import "ccMacros.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@implementation BigParticleSystem

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
		quads[i].point[0].texCoords.u = 0;
		quads[i].point[0].texCoords.v = 0;
		// bottom-left vertex:
		quads[i].point[1].texCoords.u = 1;
		quads[i].point[1].texCoords.v = 0;
		// top-right vertex:
		quads[i].point[2].texCoords.u = 0;
		quads[i].point[2].texCoords.v = 1;
		// top-right vertex:
		quads[i].point[3].texCoords.u = 1;
		quads[i].point[3].texCoords.v = 1;
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
			
			p->life -= dt;
			
			//
			// update values in quad
			//
			
			// colors
			for(int i=0;i<4;i++)
				quads[particleIdx].point[i].colors = p->color;
			
			// vertices
			// top-left vertex:
			quads[particleIdx].point[0].vertices.x = p->pos.x - (p->size/2);
			quads[particleIdx].point[0].vertices.y = p->pos.y - (p->size/2);

			// bottom-left vertex:
			quads[particleIdx].point[1].vertices.x = p->pos.x + (p->size/2);
			quads[particleIdx].point[1].vertices.y = p->pos.y - (p->size/2);

			// top-right vertex:
			quads[particleIdx].point[2].vertices.x = p->pos.x - (p->size/2);
			quads[particleIdx].point[2].vertices.y = p->pos.y + (p->size/2);

			// top-right vertex:
			quads[particleIdx].point[3].vertices.x = p->pos.x + (p->size/2);
			quads[particleIdx].point[3].vertices.y = p->pos.y + (p->size/2);
			
			// update particle counter
			particleIdx++;
			
		} else {
			// life < 0
			if( particleIdx != particleCount-1 )
				particles[particleIdx] = particles[particleCount-1];
			particleCount--;
		}
	}
}

// overriding draw method
-(void) draw
{	
	glEnable(GL_TEXTURE_2D);
	
	glBindTexture(GL_TEXTURE_2D, texture.name);

	glBindBuffer(GL_ARRAY_BUFFER, quadsID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(quads[0])*totalParticles, quads,GL_DYNAMIC_DRAW);	

	int pointSize = sizeof( quads[0].point[0]);
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2,GL_FLOAT,pointSize, 0);
	
	int s = sizeof(quads[0].point[0].vertices);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, pointSize, (GLvoid*) s );
	
	s += sizeof( quads[0].point[0].texCoords );
	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_FLOAT, pointSize, (GLvoid*) s );
	
	
	if( blendAdditive )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	else
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	// save color mode
#if 0
	glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &colorMode);
	if( colorModulate )
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	else
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
#endif
	
	glDrawElements(GL_TRIANGLES, totalParticles*6, GL_UNSIGNED_SHORT, indices);	
	
	// restore blend state
	glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );
	
#if 0
	// restore color mode
	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, colorMode);
#endif
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

@end


