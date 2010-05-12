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
//		http://love2d.org/
//	 . 71 squared
//		http://www.71squared.com/

// opengl
#import <OpenGLES/ES1/gl.h>

// cocos2d
#import "ccConfig.h"
#if CC_ENABLE_PROFILERS
#import "Support/CCProfiling.h"
#endif
#import "CCParticleSystem.h"
#import "CCTextureCache.h"
#import "ccMacros.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"
#import "Support/base64.h"
#import "Support/ZipUtils.h"
#import "Support/CCFileUtils.h"

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
@synthesize positionType = positionType_;
@synthesize autoRemoveOnFinish = autoRemoveOnFinish_;


+(id) particleWithFile:(NSString*) plistFile
{
	return [[[self alloc] initWithFile:plistFile] autorelease];
}

-(id) init {
	NSException* myException = [NSException
								exceptionWithName:@"Particle.init"
								reason:@"Particle.init shall not be called. Use initWithTotalParticles instead."
								userInfo:nil];
	@throw myException;	
}

-(id) initWithFile:(NSString *)plistFile
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plistFile];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	return [self initWithDictionary:dict];
}

-(id) initWithDictionary:(NSDictionary *)dictionary
{
	int maxParticles = [[dictionary valueForKey:@"maxParticles"] intValue];
	// self, not super
	if ((self=[self initWithTotalParticles:maxParticles] ) ) {
		
		// angle
		angle = [[dictionary valueForKey:@"angle"] floatValue];
		angleVar = [[dictionary valueForKey:@"angleVariance"] floatValue];
		
		// duration
		duration = [[dictionary valueForKey:@"duration"] floatValue];
		
		// blend additive ?
		if( [[dictionary valueForKey:@"blendAdditive"] boolValue] ) {
			// Particle Designer uses a different blendAdditive function than cocos2d.
			blendFunc_.src = GL_ONE_MINUS_SRC_ALPHA;
			blendFunc_.dst = GL_ONE;
		}
		
		// color
		float r,g,b,a;
		
		r = [[dictionary valueForKey:@"startColorRed"] floatValue];
		g = [[dictionary valueForKey:@"startColorGreen"] floatValue];
		b = [[dictionary valueForKey:@"startColorBlue"] floatValue];
		a = [[dictionary valueForKey:@"startColorAlpha"] floatValue];
		startColor = (ccColor4F) {r,g,b,a};
		
		r = [[dictionary valueForKey:@"startColorVarianceRed"] floatValue];
		g = [[dictionary valueForKey:@"startColorVarianceGreen"] floatValue];
		b = [[dictionary valueForKey:@"startColorVarianceBlue"] floatValue];
		a = [[dictionary valueForKey:@"startColorVarianceAlpha"] floatValue];
		startColorVar = (ccColor4F) {r,g,b,a};
		
		r = [[dictionary valueForKey:@"finishColorRed"] floatValue];
		g = [[dictionary valueForKey:@"finishColorGreen"] floatValue];
		b = [[dictionary valueForKey:@"finishColorBlue"] floatValue];
		a = [[dictionary valueForKey:@"finishColorAlpha"] floatValue];
		endColor = (ccColor4F) {r,g,b,a};
		
		r = [[dictionary valueForKey:@"finishColorVarianceRed"] floatValue];
		g = [[dictionary valueForKey:@"finishColorVarianceGreen"] floatValue];
		b = [[dictionary valueForKey:@"finishColorVarianceBlue"] floatValue];
		a = [[dictionary valueForKey:@"finishColorVarianceAlpha"] floatValue];
		endColorVar = (ccColor4F) {r,g,b,a};
		
		// particle size
		startSize = [[dictionary valueForKey:@"startParticleSize"] floatValue];
		startSizeVar = [[dictionary valueForKey:@"startParticleSizeVariance"] floatValue];
		endSize = [[dictionary valueForKey:@"finishParticleSize"] floatValue];
		endSizeVar = [[dictionary valueForKey:@"finishParticleSizeVariance"] floatValue];
		
		// Mode A: Gravity + tangential accel + radial accel
		// gravity
		gravity.x = [[dictionary valueForKey:@"gravityx"] floatValue];
		gravity.y = [[dictionary valueForKey:@"gravityy"] floatValue];
		
		
		// or Mode B: radius movement
		maxRadius = [[dictionary valueForKey:@"maxRadius"] floatValue];
		maxRadiusVar = [[dictionary valueForKey:@"maxRadiusVariance"] floatValue];
		minRadius = [[dictionary valueForKey:@"minRadius"] floatValue];
		rotatePerSecond = [[dictionary valueForKey:@"rotatePerSecond"] floatValue];
		rotatePerSecondVar = [[dictionary valueForKey:@"rotatePerSecondVariance"] floatValue];		
		
		
		// life span
		life = [[dictionary valueForKey:@"particleLifespan"] floatValue];
		lifeVar = [[dictionary valueForKey:@"particleLifespanVariance"] floatValue];
		
		// position
		float x = [[dictionary valueForKey:@"sourcePositionx"] floatValue];
		float y = [[dictionary valueForKey:@"sourcePositiony"] floatValue];
		if( maxRadius > 0 || maxRadiusVar > 0 )
			centerOfGravity = ccp(x,y);
		else
			position_ = ccp(x,y);
		
		posVar.x = [[dictionary valueForKey:@"sourcePositionVariancex"] floatValue];
		posVar.y = [[dictionary valueForKey:@"sourcePositionVariancey"] floatValue];
		
		//
		// speed
		speed = [[dictionary valueForKey:@"speed"] floatValue];
		speedVar = [[dictionary valueForKey:@"speedVariance"] floatValue];
		
		// emission Rate
		emissionRate = totalParticles/life;

		// texture		
		// Try to get the texture from the cache
		NSString *textureName = [dictionary valueForKey:@"textureFileName"];
		NSString *textureData = [dictionary valueForKey:@"textureImageData"];

		self.texture = [[CCTextureCache sharedTextureCache] addImage:textureName];

		if ( ! self.texture && textureData) {
			
			// if it fails, try to get it from the base64-gzipped data			
			unsigned char *buffer = NULL;
			int len = base64Decode((unsigned char*)[textureData UTF8String], [textureData length], &buffer);
			NSAssert( buffer != NULL, @"CCParticleSystem: error decoding textureImageData");
				
			unsigned char *deflated = NULL;
			int deflatedLen = inflateMemory(buffer, len, &deflated);
			free( buffer );
				
			NSAssert( deflated != NULL, @"CCParticleSystem: error ungzipping textureImageData");
			NSData *data = [[NSData alloc] initWithBytes:deflated length:deflatedLen];
			UIImage *image = [[UIImage alloc] initWithData:data];
			
			self.texture = [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:textureName];
			[data release];
			[image release];
		}
		
		NSAssert( [self texture] != NULL, @"CCParticleSystem: error loading the texture");
		
	}
	
	return self;
}

-(id) initWithTotalParticles:(int) numberOfParticles
{
	if( (self=[super init]) ) {

		totalParticles = numberOfParticles;
		
		particles = calloc( totalParticles, sizeof(tCCParticle) );

		if( ! particles ) {
			NSLog(@"Particle system: not enough memory");
			[self release];
			return nil;
		}
		
		// default, active
		active = YES;
		
		// default blend function
		blendFunc_ = (ccBlendFunc) { CC_BLEND_SRC, CC_BLEND_DST };
		
		// default movement type;
		positionType_ = kCCPositionTypeFree;
		
		// By default use Mode A (gravity + radial accel + tangential accel).
		// Mode B is only activated when maxRadius > 0
		maxRadius = minRadius = 0;
		maxRadiusVar = 0;
		
		// default: modulate
		// XXX: not used
	//	colorModulate = YES;
		
		autoRemoveOnFinish_ = NO;

		// profiling
#if CC_ENABLE_PROFILERS
		_profilingTimer = [[CCProfiler timerWithName:@"particle system" andInstance:self] retain];
#endif
		[self scheduleUpdate];
		
	}

	return self;
}

-(void) dealloc
{
	free( particles );

	[texture_ release];
	// profiling
#if CC_ENABLE_PROFILERS
	[CCProfiler releaseTimer:_profilingTimer];
#endif
	
	[super dealloc];
}

-(BOOL) addParticle
{
	if( [self isFull] )
		return NO;
	
	tCCParticle * particle = &particles[ particleCount ];
		
	[self initParticle: particle];		
	particleCount++;
				
	return YES;
}

-(void) initParticle: (tCCParticle*) particle
{
	CGPoint v;

	// position
	particle->pos.x = (int) (centerOfGravity.x + posVar.x * CCRANDOM_MINUS1_1());
	particle->pos.y = (int) (centerOfGravity.y + posVar.y * CCRANDOM_MINUS1_1());
	
	// direction
	float a = CC_DEGREES_TO_RADIANS( angle + angleVar * CCRANDOM_MINUS1_1() );
	v.y = sinf( a );
	v.x = cosf( a );
	float s = speed + speedVar * CCRANDOM_MINUS1_1();
	
	// Mode A
	if( maxRadius == 0 && maxRadiusVar == 0 ) {
		particle->mode.A.dir = ccpMult( v, s );
		
		// radial accel
		particle->mode.A.radialAccel = radialAccel + radialAccelVar * CCRANDOM_MINUS1_1();
		
		// tangential accel
		particle->mode.A.tangentialAccel = tangentialAccel + tangentialAccelVar * CCRANDOM_MINUS1_1();
	}
	
	// Mode B
	else {
		// Set the default diameter of the particle from the source position
		particle->mode.B.radius = maxRadius + maxRadiusVar * CCRANDOM_MINUS1_1();	
		particle->mode.B.deltaRadius = (maxRadius / life) * (1.0f / 30);
		particle->mode.B.angle = CC_DEGREES_TO_RADIANS(angle + angleVar * CCRANDOM_MINUS1_1());
		particle->mode.B.degreesPerSecond = CC_DEGREES_TO_RADIANS(rotatePerSecond + rotatePerSecondVar * CCRANDOM_MINUS1_1());
		
	}
	
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
	if( endSize == kCCParticleStartSizeEqualToEndSize )
		particle->deltaSize = 0;
	else {
		float endS = endSize + endSizeVar * CCRANDOM_MINUS1_1();
		particle->deltaSize = (endS - startS) / particle->life;
	}
	
	// angle
	float startA = startSpin + startSpinVar * CCRANDOM_MINUS1_1();
	float endA = endSpin + endSpinVar * CCRANDOM_MINUS1_1();
	particle->rotation = startA;
	particle->deltaRotation = (endA - startA) / particle->life;
	
	// position
	if( positionType_ == kCCPositionTypeFree )
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
		tCCParticle *p = &particles[particleIdx];
		p->life = 0;
	}
}

-(BOOL) isFull
{
	return (particleCount == totalParticles);
}

#pragma mark ParticleSystem - MainLoop
-(void) update: (ccTime) dt
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
	if( positionType_ == kCCPositionTypeFree )
		absolutePosition = [self convertToWorldSpace:CGPointZero];
	
#if CC_ENABLE_PROFILERS
	CCProfilingBeginTimingBlock(_profilingTimer);
#endif
	
	while( particleIdx < particleCount )
	{
		tCCParticle *p = &particles[particleIdx];
		
		if( p->life > 0 ) {
			
			// Mode A: gravity, tangential accel & radial accel
			if( maxRadius == 0 && maxRadiusVar == 0 ) {
				CGPoint tmp, radial, tangential;
				
				radial = CGPointZero;
				// radial acceleration
				if(p->pos.x || p->pos.y)
					radial = ccpNormalize(p->pos);
				tangential = radial;
				radial = ccpMult(radial, p->mode.A.radialAccel);
				
				// tangential acceleration
				float newy = tangential.x;
				tangential.x = -tangential.y;
				tangential.y = newy;
				tangential = ccpMult(tangential, p->mode.A.tangentialAccel);
				
				// (gravity + radial + tangential) * dt
				tmp = ccpAdd( ccpAdd( radial, tangential), gravity);
				tmp = ccpMult( tmp, dt);
				p->mode.A.dir = ccpAdd( p->mode.A.dir, tmp);
				tmp = ccpMult(p->mode.A.dir, dt);
				p->pos = ccpAdd( p->pos, tmp );
			}
			
			// Mode B: radius movement
			else {
				p->pos.x = centerOfGravity.x - cosf(p->mode.B.angle) * p->mode.B.radius;
				p->pos.y = centerOfGravity.y - sinf(p->mode.B.angle) * p->mode.B.radius;
				
				// Update the angle of the particle from the sourcePosition and the radius.  This is only
				// done of the particles are rotating
				p->mode.B.angle += p->mode.B.degreesPerSecond * dt;
				p->mode.B.radius -= p->mode.B.deltaRadius;
				if (p->mode.B.radius < minRadius)
					p->life = 0;				
			}

			
			// color
			p->color.r += (p->deltaColor.r * dt);
			p->color.g += (p->deltaColor.g * dt);
			p->color.b += (p->deltaColor.b * dt);
			p->color.a += (p->deltaColor.a * dt);
			
			// size
			p->size += (p->deltaSize * dt);
			p->size = MAX( 0, p->size );
			
			// angle
			p->rotation += (p->deltaRotation * dt);
			
			// life
			p->life -= dt;
			
			//
			// update values in quad
			//
			
			CGPoint	newPos = p->pos;
			if( positionType_ == kCCPositionTypeFree ) {
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
				[self unscheduleUpdate];
				[[self parent] removeChild:self cleanup:YES];
				return;
			}
		}
	}
	
#if CC_ENABLE_PROFILERS
	CCProfilingEndTimingBlock(_profilingTimer);
#endif
	
	[self postStep];
}

-(void) updateQuadWithParticle:(tCCParticle*)particle position:(CGPoint)position
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

	// If the new texture has No premultiplied alpha, AND the blendFunc hasn't been changed, then update it
	if( ! [texture hasPremultipliedAlpha] &&		
	   ( blendFunc_.src == CC_BLEND_SRC && blendFunc_.dst == CC_BLEND_DST ) ) {
	
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(CCTexture2D*) texture
{
	return texture_;
}

#pragma mark ParticleSystem - Additive Blending
-(void) setBlendAdditive:(BOOL)additive
{
	if( additive ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE;
	} else {
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
	}
}

-(BOOL) blendAdditive
{
	return( blendFunc_.src == GL_SRC_ALPHA && blendFunc_.dst == GL_ONE);
}
@end


