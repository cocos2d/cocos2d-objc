/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

// ideas taken from:
//	 . The ocean spray in your face [Jeff Lander]
//		http://www.double.co.nz/dust/col0798.pdf
//	 . Building an Advanced Particle System [John van der Burg]
//		http://www.gamasutra.com/features/20000623/vanderburg_01.htm

// opengl
#import <OpenGLES/ES1/gl.h>

// cocos2d
#import "Particle.h"
#import "Primitives.h"
#import "TextureMgr.h"

// support
#import "OpenGL_Internal.h"

#define RANDOM_FLOAT() (((float)random() / (float)0x3fffffff )-1.0f)


@implementation Emitter

@synthesize pos, angle, angleVar, speed, speedVar, emitsPerFrame, emitVar, totalParticles;

-(id) init
{
	if( ! [super init] )
		return nil;
	
	particles = malloc( sizeof(Particle) * totalParticles );
	if( ! particles ) {
		NSLog(@"Not enought memory for particle %@", self);
		return nil;
	}
	bzero( particles, sizeof(Particle) * totalParticles );
	
	return self;
}

-(void) dealloc
{
	free( particles );
	[super dealloc];
}

-(void) update
{
	Particle *p;

	int i = totalParticles - particleCount;
	if( i ) {
		int m = MIN(emitsPerFrame + emitVar * RANDOM_FLOAT(), i );
		
		for(int j=0;j<m;j++)
			[self addParticle];
	}
	
	[self preParticles];
	for( int i=0; i<totalParticles;i++ ) {
		p = &particles[i];
		[self updateParticle:p];
	}
	[self postParticles];
}

-(BOOL) addParticle
{
	if( particleCount < totalParticles ) {
		Particle * particle = &particles[ particleCount ];
		
		[self initParticle: particle];
		
		particleCount++;
				
		return YES;
	}
	return NO;
}

-(void) initParticle: (Particle*) particle
{
	// position
	particle->pos.x = posVar.x * RANDOM_FLOAT();
	particle->pos.y = posVar.y * RANDOM_FLOAT();
	
	// direction
	float ar = angle + angleVar * RANDOM_FLOAT();
	float a = DEGREES_TO_RADIANS( ar );
	cpVect v;
	v.y = sinf( a );
	v.x = cosf( a );
	float s = speed + speedVar * RANDOM_FLOAT();
	particle->dir = cpvmult( v, s );
	
	// life
	particle->life = life + lifeVar * RANDOM_FLOAT();
	
	// Color
	ColorF start;
	start.r = startColor.r + startColorVar.r * RANDOM_FLOAT();
	start.g = startColor.g + startColorVar.g * RANDOM_FLOAT();
	start.b = startColor.b + startColorVar.b * RANDOM_FLOAT();
	start.a = startColor.a + startColorVar.a * RANDOM_FLOAT();

	ColorF end;
	end.r = endColor.r + endColorVar.r * RANDOM_FLOAT();
	end.g = endColor.g + endColorVar.g * RANDOM_FLOAT();
	end.b = endColor.b + endColorVar.b * RANDOM_FLOAT();
	end.a = endColor.a + endColorVar.a * RANDOM_FLOAT();
	
	particle->color = start;
	particle->deltaColor.r = (end.r - start.r) / particle->life;
	particle->deltaColor.g = (end.g - start.g) / particle->life;
	particle->deltaColor.b = (end.b - start.b) / particle->life;
	particle->deltaColor.a = (end.a - start.a) / particle->life;

	// size
	particle->size = size + sizeVar * RANDOM_FLOAT();
	
	// alive
	particle->flags |= kLIVE;
}

-(BOOL) updateParticle: (Particle*) p
{
	if( p->life > 0 ) {
		p->pos = cpvadd( p->pos, p->dir );
		p->dir = cpvadd( p->dir, force );
		p->color.r += p->deltaColor.r;
		p->color.g += p->deltaColor.g;
		p->color.b += p->deltaColor.b;
		p->color.a += p->deltaColor.a;
		p->life--;
		
		[self drawParticle: p];
		return YES;
	}
	
	if (p->flags & kLIVE ) {
		if( flags & kRESPAWN ) {
			[self initParticle:p];
			return YES;
		} else {
			particleCount--;
			p->flags &= ~kLIVE;
		}
	}
	return NO;
}

-(void) drawParticle: (Particle*) p
{
	// overrideme
}
-(void) preParticles
{
	// overrideme
}
-(void) postParticles
{
	// overrideme
}
@end

//
// TextureEmitter
//
@implementation TextureEmitter

-(id) init
{
	if( ! [super init] )
		return nil;

	glGenBuffers(1, &verticesID);
	glGenBuffers(1, &colorsID);

	vertices = malloc( sizeof(VtxPointSprite)*totalParticles);
	colors = malloc (sizeof(ColorF)*totalParticles);
	if( ! (vertices && colors ) ) {
		NSLog(@"TextureEmitter: not enough memory");
		if( vertices )
			free(vertices);
		if( colors )
			free(colors);
		return nil;
	}
	
	glBindBuffer( GL_ARRAY_BUFFER, verticesID );
	glBufferData(GL_ARRAY_BUFFER, sizeof(VtxPointSprite)*totalParticles, vertices,GL_DYNAMIC_DRAW);

	glBindBuffer( GL_ARRAY_BUFFER, colorsID );
	glBufferData(GL_ARRAY_BUFFER, sizeof(ColorF)*totalParticles, colors,GL_DYNAMIC_DRAW);
	
	return self;
}

-(void) dealloc
{
	free(vertices);
	free(colors);
	glDeleteBuffers(1, &verticesID);
	glDeleteBuffers(1, &colorsID);
	[super dealloc];
}

-(void) preParticles
{
	particleIdx = 0;
}

-(void) drawParticle: (Particle*) p
{
	
	// relative to center
	cpVect v = cpvadd( p->pos, pos );
	
	vertices[particleIdx].x = v.x;
	vertices[particleIdx].y = v.y;
	vertices[particleIdx].size = p->size;
	
	// colors
	colors[particleIdx] = p->color;
		
	particleIdx++;
}

-(void) postParticles
{
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture.name);
	
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );

	glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(VtxPointSprite)*totalParticles, vertices,GL_DYNAMIC_DRAW);
	glVertexPointer(3,GL_FLOAT,sizeof(VtxPointSprite),0);
		
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glPointSizePointerOES(GL_FLOAT,sizeof(VtxPointSprite),(GLvoid*) (sizeof(GL_FLOAT)*2));

	glEnableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, colorsID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(ColorF)*totalParticles, colors,GL_DYNAMIC_DRAW);
	glColorPointer(4,GL_FLOAT,0,0);
		
	glDrawArrays(GL_POINTS, 0, particleIdx);

	// unbind
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);
}
@end

//
// PixelEmitter
//
@implementation PixelEmitter
-(void) drawParticle: (Particle*) p
{
	glPointSize(p->size);
	glColor4f(p->color.r, p->color.g, p->color.b, p->color.a);
	
	// relative to center
	cpVect v = cpvadd( p->pos, pos );
	drawPoint( v.x, v.y );
}
@end

//
// EmitFireworks
//
@implementation EmitFireworks
-(id) init
{
	totalParticles = 750;

	// must be called after totalParticles is set
	if( ! [super init] )
		return nil;

	// gravity
	force.x = 0;
	force.y = -0.1;
	
	// angle
	angle = 90;
	angleVar = 20;
	
	// emitter position
	pos.x = 160;
	pos.y = 240;
	
	// life of particles
	life = 100;
	lifeVar = 20;
	
	// speed of particles
	speed = 5;
	speedVar = 2;

	// emits per frame
	emitsPerFrame = 15;
	emitVar = 5;
	
	// color of particles
	startColor.r = 0.8f;
	startColor.g = 0.3f;
	startColor.b = 0.3f;
	startColor.a = 1.0f;
	startColorVar.r = 0.5;
	startColorVar.g = 0.5;
	startColorVar.b = 0.5;
	startColorVar.a = 0.1;
	endColor.r = 0.1f;
	endColor.g = 0.1f;
	endColor.b = 0.1f;
	endColor.a = 0.2f;
	endColorVar.r = 0.1f;
	endColorVar.g = 0.1f;
	endColorVar.b = 0.1f;
	endColorVar.a = 0.2f;
	
	// size, in pixels
	size = 3.0f;
	sizeVar = 2.0f;

	// respawn dead particles
	flags |= kRESPAWN;
	return self;
}
@end

//
// EmitFire
//
@implementation EmitFire
-(id) init
{
	totalParticles = 350;
	
	// must be called after totalParticles is set
	if( ! [super init] )
		return nil;
	
	// gravity
	force.x = 0;
	force.y = 0.06;
	
	// angle
	angle = 90;
	angleVar = 50;
	
	// emitter position
	pos.x = 160;
	pos.y = 0;
	posVar.x = 100;
	posVar.y = 30;
	
	// life of particles
	life = 80;
	lifeVar = 20;
	
	// speed of particles
	speed = 0.7;
	speedVar = 0.4;
		
	// size, in pixels
	size = 30.0f;
	sizeVar = 10.0f;
	
	// emits per frame
	emitsPerFrame = 6;
	emitVar = 3;
	
	// color of particles
	startColor.r = 0.76f;
	startColor.g = 0.25f;
	startColor.b = 0.12f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0;
	startColorVar.g = 0.0;
	startColorVar.b = 0.0;
	startColorVar.a = 0.0;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 1.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;
	
	texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	[texture retain];
	
	// respawn dead particles
	flags |= kRESPAWN;
	return self;
}
-(void) dealloc
{
	[texture release];
	[super dealloc];
}
-(void) preParticles
{
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	[super preParticles];
}
@end
