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
#import "CCParticleSystem.h"
#import "CCTextureCache.h"
#import "ccMacros.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@implementation CCParticleSystem
@synthesize active, duration;
@synthesize centerOfGravity, posVar;
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
@synthesize autoRemoveOnFinish = autoRemoveOnFinish_;

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
		
		// default movement type;
		positionType_ = kPositionTypeFree;
		
		// default: modulate
		// XXX: not used
	//	colorModulate = YES;
		
		autoRemoveOnFinish_ = NO;

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
	particle->pos.x = (int) (centerOfGravity.x + posVar.x * CCRANDOM_MINUS1_1());
	particle->pos.y = (int) (centerOfGravity.y + posVar.y * CCRANDOM_MINUS1_1());
	
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
	particle->life = MAX(0, particle->life);  // no negative life
	
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
	startS = MAX(0, startS);	// no negative size
	
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
	if( positionType_ == kPositionTypeFree )
		particle->startPos = [self convertToWorldSpace:CGPointZero];
	else
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

#pragma mark ParticleSystem - MainLoop
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
	
	CGPoint	absolutePosition;
	if( positionType_ == kPositionTypeFree )
		absolutePosition = [self convertToWorldSpace:CGPointZero];
	
	
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
			
			// color
			p->color.r += (p->deltaColor.r * dt);
			p->color.g += (p->deltaColor.g * dt);
			p->color.b += (p->deltaColor.b * dt);
			p->color.a += (p->deltaColor.a * dt);
			
			// size
			p->size += (p->deltaSize * dt);
			p->size = MAX( 0, p->size );
			
			// angle
			p->angle += (p->deltaAngle * dt);
			
			// life
			p->life -= dt;
			
			//
			// update values in quad
			//
			
			CGPoint	newPos = p->pos;
			if( positionType_ == kPositionTypeFree ) {
				newPos = ccpSub(absolutePosition, p->startPos);
				newPos = ccpSub( p->pos, newPos);
			}
			
			[self updateQuadWithParticle:p position:newPos];
			
			// update particle counter
			particleIdx++;
			
		} else {
			// life < 0
			if( particleIdx != particleCount-1 )
				particles[particleIdx] = particles[particleCount-1];
			particleCount--;
			
			if( particleCount == 0 && autoRemoveOnFinish_ ) {
				[self unschedule:@selector(step:)];
				[[self parent] removeChild:self cleanup:YES];
				return;
			}
		}
	}
	[self postStep];
}

-(void) updateQuadWithParticle:(Particle*)particle position:(CGPoint)position
{
	// should be overriden
}

-(void) postStep
{
	// should be overriden
}

#pragma mark ParticleSystem - CCTexture protocol

-(void) setTexture:(CCTexture2D*) texture
{
	[texture_ release];
	texture_ = [texture retain];
	if( ! [texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(CCTexture2D*) texture
{
	return texture_;
}
@end


