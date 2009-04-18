/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

// ideas taken from:
//	 . The ocean spray in your face [Jeff Lander]
//		http://www.double.co.nz/dust/col0798.pdf
//	 . Building an Advanced Particle System [John van der Burg]
//		http://www.gamasutra.com/features/20000623/vanderburg_01.htm
//   . LOVE game engine
//      http://love.sf.net

// opengl
#import <OpenGLES/ES1/gl.h>

// cocos2d
#import "ParticleSystem.h"
#import "Primitives.h"
#import "TextureMgr.h"
#import "ccMacros.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@implementation ParticleSystem
@synthesize active, duration;
@synthesize source, posVar;
@synthesize particleCount;
@synthesize life, lifeVar;
@synthesize angle, angleVar;
@synthesize speed, speedVar;
@synthesize tangentialAccel, tangentialAccelVar;
@synthesize radialAccel, radialAccelVar;
@synthesize startColor, startColorVar;
@synthesize endColor, endColorVar;
@synthesize emissionRate;
@synthesize totalParticles;
@synthesize size, sizeVar;
@synthesize gravity;
@synthesize texture;

-(id) init {
	NSException* myException = [NSException
								exceptionWithName:@"Particle.init"
								reason:@"Particle.init shall not be called. Use initWithTotalParticles instead."
								userInfo:nil];
	@throw myException;	
}

-(id) initWithTotalParticles:(int) numberOfParticles
{
	if( (self=[super init]) ) {

		totalParticles = numberOfParticles;
		
		particles = malloc( sizeof(Particle) * totalParticles );
		vertices = malloc( sizeof(ccPointSprite) * totalParticles );

		if( ! ( particles &&vertices ) ) {
			NSLog(@"Particle system: not enough memory");
			if( particles )
				free(particles);
			if( vertices )
				free(vertices);
			return nil;
		}
		
		bzero( particles, sizeof(Particle) * totalParticles );
		
		// default, active
		active = YES;
		
		// default: additive
		blendAdditive = NO;
		
		// default: modulate
		// XXX: not used
	//	colorModulate = YES;
			
		glGenBuffers(1, &verticesID);

		[self schedule:@selector(step:)];
	}

	return self;
}

-(void) dealloc
{
	free( particles );
	free(vertices);
	glDeleteBuffers(1, &verticesID);

	[texture release];
	
	[super dealloc];
}

-(BOOL) addParticle
{
	if( [self isFull] )
		return NO;
	
	Particle * particle = &particles[ particleCount ];
		
	[self initParticle: particle];		
	particleCount++;
				
	return YES;
}

-(void) initParticle: (Particle*) particle
{
	CGPoint v;

	// position
	particle->pos.x = (int) (source.x + posVar.x * CCRANDOM_MINUS1_1());
	particle->pos.y = (int) (source.y + posVar.y * CCRANDOM_MINUS1_1());
	
	// direction
	float a = (CGFloat)CC_DEGREES_TO_RADIANS( angle + angleVar * CCRANDOM_MINUS1_1() );
	v.y = sinf( a );
	v.x = cosf( a );
	float s = speed + speedVar * CCRANDOM_MINUS1_1();
	particle->dir = ccpMult( v, s );
	
	// radial accel
	particle->radialAccel = radialAccel + radialAccelVar * CCRANDOM_MINUS1_1();
	
	// tangential accel
	particle->tangentialAccel = tangentialAccel + tangentialAccelVar * CCRANDOM_MINUS1_1();
	
	// life
	particle->life = life + lifeVar * CCRANDOM_MINUS1_1();
	
	// Color
	ccColorF start;
	start.r = startColor.r + startColorVar.r * CCRANDOM_MINUS1_1();
	start.g = startColor.g + startColorVar.g * CCRANDOM_MINUS1_1();
	start.b = startColor.b + startColorVar.b * CCRANDOM_MINUS1_1();
	start.a = startColor.a + startColorVar.a * CCRANDOM_MINUS1_1();

	ccColorF end;
	end.r = endColor.r + endColorVar.r * CCRANDOM_MINUS1_1();
	end.g = endColor.g + endColorVar.g * CCRANDOM_MINUS1_1();
	end.b = endColor.b + endColorVar.b * CCRANDOM_MINUS1_1();
	end.a = endColor.a + endColorVar.a * CCRANDOM_MINUS1_1();
	
	particle->color = start;
	particle->deltaColor.r = (end.r - start.r) / particle->life;
	particle->deltaColor.g = (end.g - start.g) / particle->life;
	particle->deltaColor.b = (end.b - start.b) / particle->life;
	particle->deltaColor.a = (end.a - start.a) / particle->life;

	// size
	particle->size = size + sizeVar * CCRANDOM_MINUS1_1();	
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

			// place vertices and colos in array
			vertices[particleIdx].x = p->pos.x;
			vertices[particleIdx].y = p->pos.y;
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

-(void) stopSystem
{
	active = NO;
	elapsed = duration;
	emitCounter = 0;
}

-(void) resetSystem
{
	active = YES;
	elapsed = 0;
	for(particleIdx = 0; particleIdx < particleCount; ++particleIdx) {
		Particle *p = &particles[particleIdx];
		p->life = 0;
	}
}

-(void) draw
{
//	int blendSrc, blendDst;
//	int colorMode;
	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture.name);
	
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glVertexPointer(2,GL_FLOAT,sizeof(ccPointSprite),0);
	
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glPointSizePointerOES(GL_FLOAT,sizeof(ccPointSprite),(GLvoid*) (sizeof(GL_FLOAT)*2));
	
	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_FLOAT, sizeof(ccPointSprite),(GLvoid*) (sizeof(GL_FLOAT)*3));

	// save blend state
//	glGetIntegerv(GL_BLEND_DST, &blendDst);
//	glGetIntegerv(GL_BLEND_SRC, &blendSrc);
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

	glDrawArrays(GL_POINTS, 0, particleIdx);
	
	// restore blend state
	glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);

#if 0
	// restore color mode
	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, colorMode);
#endif
	
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);
}

-(BOOL) isFull
{
	return (particleCount == totalParticles);
}
@end


