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
@synthesize startColor, startColorVar, endColor, endColorVar;
@synthesize startSpin, startSpinVar, endSpin, endSpinVar;
@synthesize emissionRate;
@synthesize totalParticles;
@synthesize startSize, startSizeVar;
@synthesize endSize, endSizeVar;
@synthesize gravity;
@synthesize blendFunc = blendFunc_;
@synthesize blendAdditive;
@synthesize positionType = positionType_;

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

		if( ! particles ) {
			NSLog(@"Particle system: not enough memory");
			if( particles )
				free(particles);
			return nil;
		}
		
		bzero( particles, sizeof(Particle) * totalParticles );
		
		// default, active
		active = YES;
		
		// default: additive
		blendAdditive = NO;
		
		// blend function
		blendFunc_ = (ccBlendFunc) { CC_BLEND_SRC, CC_BLEND_DST };
		
		// default position type;
		positionType_ = kPositionTypeWorld;
		
		// default: modulate
		// XXX: not used
	//	colorModulate = YES;

		[self schedule:@selector(step:)];
	}

	return self;
}

-(void) dealloc
{
	free( particles );

	[texture_ release];
	
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
	// XXX: source should be deprecated.
	particle->pos.x = (int) (source.x + posVar.x * CCRANDOM_MINUS1_1());
	particle->pos.y = (int) (source.y + posVar.y * CCRANDOM_MINUS1_1());
	
	// direction
	float a = CC_DEGREES_TO_RADIANS( angle + angleVar * CCRANDOM_MINUS1_1() );
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
	ccColor4F start;
	start.r = startColor.r + startColorVar.r * CCRANDOM_MINUS1_1();
	start.g = startColor.g + startColorVar.g * CCRANDOM_MINUS1_1();
	start.b = startColor.b + startColorVar.b * CCRANDOM_MINUS1_1();
	start.a = startColor.a + startColorVar.a * CCRANDOM_MINUS1_1();

	ccColor4F end;
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
	float startS = startSize + startSizeVar * CCRANDOM_MINUS1_1();
	particle->size = startS;
	if( endSize == kParticleStartSizeEqualToEndSize )
		particle->deltaSize = 0;
	else {
		float endS = endSize + endSizeVar * CCRANDOM_MINUS1_1();
		particle->deltaSize = (endS - startS) / particle->life;
	}
	
	// angle
	float startA = startSpin + startSpinVar * CCRANDOM_MINUS1_1();
	float endA = endSpin + endSpinVar * CCRANDOM_MINUS1_1();
	particle->angle = startA;
	particle->deltaAngle = (endA - startA) / particle->life;
	
	// position
	particle->startPos = self.position;
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

-(BOOL) isFull
{
	return (particleCount == totalParticles);
}

#pragma mark ParticleSystem - CocosNodeTexture protocol

-(void) setTexture:(Texture2D*) texture
{
	[texture_ release];
	texture_ = [texture retain];
	if( ! [texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(Texture2D*) texture
{
	return texture_;
}
@end


