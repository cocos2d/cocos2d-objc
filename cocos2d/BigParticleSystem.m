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
	if( !(self=[super initWithTotalParticles:numberOfParticles]) )
		return nil;
	
	// allocating data space
	faces = malloc( sizeof(ccVertex3D) * totalParticles * 4 ); // two triangles for each face
	texcoords = malloc( sizeof(ccTexCoord) * totalParticles * 4 );
	colors = malloc( sizeof(ccColorF)*totalParticles*4);
	
	if( ! ( faces ) || ! ( texcoords ) || ! ( colors )) {
		NSLog(@"Particle system: not enough memory");
		return nil;
	}
	
	// putting the tex coordinates on array (only once)
	for(int i=0; i<totalParticles; i++){
		// top-left vertex:
		texcoords[i*4].u = 0;
		texcoords[i*4].v = 0;
		// bottom-left vertex:
		texcoords[i*4+1].u = 1;
		texcoords[i*4+1].v = 0;
		// top-right vertex:
		texcoords[i*4+2].u = 0;
		texcoords[i*4+2].v = 1;
		// top-right vertex:
		texcoords[i*4+3].u = 1;
		texcoords[i*4+3].v = 1;
	}
	// creating the buffers on opengl
	glGenBuffers(1, &facesID);
	glGenBuffers(1, &texCoordsID);
	glGenBuffers(1, &colorsID);
	
	return self;
}

-(void) dealloc
{
	free(faces);
	free(texcoords);
	free(colors);
	glDeleteBuffers(1, &facesID);
	glDeleteBuffers(1, &texCoordsID);
	glDeleteBuffers(1, &colorsID);
	
	[super dealloc];
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
			
			// place vertices and colors in array
			vertices[particleIdx].x = p->pos.x;
			vertices[particleIdx].y = p->pos.y;
			vertices[particleIdx].size = p->size;
			vertices[particleIdx].colors = p->color;
			
			// colors
			colors[particleIdx*4] = p->color;
			colors[particleIdx*4+1] = p->color;
			colors[particleIdx*4+2] = p->color;
			colors[particleIdx*4+3] = p->color;
			
			// place the triangles in arrays
			
			// top-left vertex:
			faces[particleIdx*4].x = p->pos.x - (p->size/2);
			faces[particleIdx*4].y = p->pos.y - (p->size/2);
			faces[particleIdx*4].z = 0;
			// bottom-left vertex:
			faces[particleIdx*4+1].x = p->pos.x + (p->size/2);
			faces[particleIdx*4+1].y = p->pos.y - (p->size/2);
			faces[particleIdx*4+1].z = 0;
			// top-right vertex:
			faces[particleIdx*4+2].x = p->pos.x - (p->size/2);
			faces[particleIdx*4+2].y = p->pos.y + (p->size/2);
			faces[particleIdx*4+2].z = 0;
			// top-right vertex:
			faces[particleIdx*4+3].x = p->pos.x + (p->size/2);
			faces[particleIdx*4+3].y = p->pos.y + (p->size/2);
			faces[particleIdx*4+3].z = 0;
			
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
	int blendSrc, blendDst;
	
	glEnable(GL_TEXTURE_2D);
	
	glBindTexture(GL_TEXTURE_2D, texture.name);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, facesID); // the faces
	glBufferData(GL_ARRAY_BUFFER, sizeof(ccVertex3D)*totalParticles*4, faces,GL_DYNAMIC_DRAW);
	glVertexPointer(3,GL_FLOAT,sizeof(ccVertex3D),0);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, texCoordsID); // the texture coords
	glBufferData(GL_ARRAY_BUFFER, sizeof(ccTexCoord)*totalParticles*4, texcoords, GL_DYNAMIC_DRAW);
	glTexCoordPointer(2, GL_FLOAT, sizeof(ccTexCoord), 0);
	
	glEnableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, colorsID); // the colors
	glBufferData(GL_ARRAY_BUFFER, sizeof(ccColorF)*totalParticles*4, colors,GL_DYNAMIC_DRAW);
	glColorPointer(4,GL_FLOAT,0,0);
	
	
	// save blend state
	glGetIntegerv(GL_BLEND_DST, &blendDst);
	glGetIntegerv(GL_BLEND_SRC, &blendSrc);
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
	
	for(int i=0; i<particleCount; i++){
		glDrawArrays(GL_TRIANGLE_STRIP, i*4, 4); // each face has two triangles in fact...
	}
	
	// restore blend state
	glBlendFunc( blendSrc, blendDst );
	
#if 0
	// restore color mode
	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, colorMode);
#endif
	
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

@end


