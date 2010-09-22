/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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


// ideas taken from:
//	 . The ocean spray in your face [Jeff Lander]
//		http://www.double.co.nz/dust/col0798.pdf
//	 . Building an Advanced Particle System [John van der Burg]
//		http://www.gamasutra.com/features/20000623/vanderburg_01.htm
//   . LOVE game engine
//		http://love2d.org/
//
//
// Radius mode support, from 71 squared
//		http://particledesigner.71squared.com/
//
// IMPORTANT: Particle Designer is supported by cocos2d, but
// 'Radius Mode' in Particle Designer uses a fixed emit rate of 30 hz. Since that can't be guarateed in cocos2d,
//  cocos2d uses a another approach, but the results are almost identical. 
//

// opengl
#import "Platforms/CCGL.h"

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
@synthesize startColor, startColorVar, endColor, endColorVar;
@synthesize startSpin, startSpinVar, endSpin, endSpinVar;
@synthesize emissionRate;
@synthesize totalParticles;
@synthesize startSize, startSizeVar;
@synthesize endSize, endSizeVar;
@synthesize blendFunc = blendFunc_;
@synthesize positionType = positionType_;
@synthesize autoRemoveOnFinish = autoRemoveOnFinish_;
@synthesize emitterMode = emitterMode_;


+(id) particleWithFile:(NSString*) plistFile
{
	return [[[self alloc] initWithFile:plistFile] autorelease];
}

-(id) init {
	NSAssert(NO, @"CCParticleSystem: Init not supported.");
	[self release];
	return nil;	
}

-(id) initWithFile:(NSString *)plistFile
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plistFile];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSAssert( dict != nil, @"Particles: file not found");
	return [self initWithDictionary:dict];
}

-(id) initWithDictionary:(NSDictionary *)dictionary
{
	NSUInteger maxParticles = [[dictionary valueForKey:@"maxParticles"] intValue];
	// self, not super
	if ((self=[self initWithTotalParticles:maxParticles] ) ) {
		
		// angle
		angle = [[dictionary valueForKey:@"angle"] floatValue];
		angleVar = [[dictionary valueForKey:@"angleVariance"] floatValue];
		
		// duration
		duration = [[dictionary valueForKey:@"duration"] floatValue];
		
		// blend function 
		blendFunc_.src = [[dictionary valueForKey:@"blendFuncSource"] intValue];
		blendFunc_.dst = [[dictionary valueForKey:@"blendFuncDestination"] intValue];
		
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
		
		
		// position
		float x = [[dictionary valueForKey:@"sourcePositionx"] floatValue];
		float y = [[dictionary valueForKey:@"sourcePositiony"] floatValue];
		self.position = ccp(x,y);
		posVar.x = [[dictionary valueForKey:@"sourcePositionVariancex"] floatValue];
		posVar.y = [[dictionary valueForKey:@"sourcePositionVariancey"] floatValue];
				
		
		emitterMode_ = [[dictionary valueForKey:@"emitterType"] intValue];

		// Mode A: Gravity + tangential accel + radial accel
		if( emitterMode_ == kCCParticleModeGravity ) {
			// gravity
			mode.A.gravity.x = [[dictionary valueForKey:@"gravityx"] floatValue];
			mode.A.gravity.y = [[dictionary valueForKey:@"gravityy"] floatValue];
			
			//
			// speed
			mode.A.speed = [[dictionary valueForKey:@"speed"] floatValue];
			mode.A.speedVar = [[dictionary valueForKey:@"speedVariance"] floatValue];
			
			// radial acceleration			
			NSString *tmp = [dictionary valueForKey:@"radialAcceleration"];
			mode.A.radialAccel = tmp ? [tmp floatValue] : 0;
			
			tmp = [dictionary valueForKey:@"radialAccelVariance"];
			mode.A.radialAccelVar = tmp ? [tmp floatValue] : 0;
						
			// tangential acceleration
			tmp = [dictionary valueForKey:@"tangentialAcceleration"];
			mode.A.tangentialAccel = tmp ? [tmp floatValue] : 0;
			
			tmp = [dictionary valueForKey:@"tangentialAccelVariance"];
			mode.A.tangentialAccelVar = tmp ? [tmp floatValue] : 0;
		}
		
		
		// or Mode B: radius movement
		else if( emitterMode_ == kCCParticleModeRadius ) {
			float maxRadius = [[dictionary valueForKey:@"maxRadius"] floatValue];
			float maxRadiusVar = [[dictionary valueForKey:@"maxRadiusVariance"] floatValue];
			float minRadius = [[dictionary valueForKey:@"minRadius"] floatValue];
			
			mode.B.startRadius = maxRadius;
			mode.B.startRadiusVar = maxRadiusVar;
			mode.B.endRadius = minRadius;
			mode.B.endRadiusVar = 0;
			mode.B.rotatePerSecond = [[dictionary valueForKey:@"rotatePerSecond"] floatValue];
			mode.B.rotatePerSecondVar = [[dictionary valueForKey:@"rotatePerSecondVariance"] floatValue];

		} else {
			NSAssert( NO, @"Invalid emitterType in config file");
		}
		
		// life span
		life = [[dictionary valueForKey:@"particleLifespan"] floatValue];
		lifeVar = [[dictionary valueForKey:@"particleLifespanVariance"] floatValue];				
		
		// emission Rate
		emissionRate = totalParticles/life;

		// texture		
		// Try to get the texture from the cache
		NSString *textureName = [dictionary valueForKey:@"textureFileName"];

		self.texture = [[CCTextureCache sharedTextureCache] addImage:textureName];

		NSString *textureData = [dictionary valueForKey:@"textureImageData"];

		if ( ! texture_ && textureData) {
			
			// if it fails, try to get it from the base64-gzipped data			
			unsigned char *buffer = NULL;
			NSUInteger len = base64Decode((unsigned char*)[textureData UTF8String], [textureData length], &buffer);
			NSAssert( buffer != NULL, @"CCParticleSystem: error decoding textureImageData");
				
			unsigned char *deflated = NULL;
			NSUInteger deflatedLen = inflateMemory(buffer, len, &deflated);
			free( buffer );
				
			NSAssert( deflated != NULL, @"CCParticleSystem: error ungzipping textureImageData");
			NSData *data = [[NSData alloc] initWithBytes:deflated length:deflatedLen];
			
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
			UIImage *image = [[UIImage alloc] initWithData:data];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
			NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:data];
#endif
			
			free(deflated); deflated = NULL;

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
		
		// by default be in mode A:
		emitterMode_ = kCCParticleModeGravity;
				
		// default: modulate
		// XXX: not used
	//	colorModulate = YES;
		
		autoRemoveOnFinish_ = NO;

		// profiling
#if CC_ENABLE_PROFILERS
		_profilingTimer = [[CCProfiler timerWithName:@"particle system" andInstance:self] retain];
#endif
		
		// Optimization: compile udpateParticle method
		updateParticleSel = @selector(updateQuadWithParticle:newPosition:);
		updateParticleImp = (CC_UPDATE_PARTICLE_IMP) [self methodForSelector:updateParticleSel];

		// udpate after action in run!
		[self scheduleUpdateWithPriority:1];
		
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

	// timeToLive
	// no negative life. prevent division by 0
	particle->timeToLive = MAX(0, life + lifeVar * CCRANDOM_MINUS1_1() );

	// position
	particle->pos.x = centerOfGravity.x + posVar.x * CCRANDOM_MINUS1_1();
	particle->pos.x *= CC_CONTENT_SCALE_FACTOR();
	particle->pos.y = centerOfGravity.y + posVar.y * CCRANDOM_MINUS1_1();
	particle->pos.y *= CC_CONTENT_SCALE_FACTOR();
	
	// Color
	ccColor4F start;
	start.r = MIN(1, MAX(0, startColor.r + startColorVar.r * CCRANDOM_MINUS1_1() ) );
	start.g = MIN(1, MAX(0, startColor.g + startColorVar.g * CCRANDOM_MINUS1_1() ) );
	start.b = MIN(1, MAX(0, startColor.b + startColorVar.b * CCRANDOM_MINUS1_1() ) );
	start.a = MIN(1, MAX(0, startColor.a + startColorVar.a * CCRANDOM_MINUS1_1() ) );
	
	ccColor4F end;
	end.r = MIN(1, MAX(0, endColor.r + endColorVar.r * CCRANDOM_MINUS1_1() ) );
	end.g = MIN(1, MAX(0, endColor.g + endColorVar.g * CCRANDOM_MINUS1_1() ) );
	end.b = MIN(1, MAX(0, endColor.b + endColorVar.b * CCRANDOM_MINUS1_1() ) );
	end.a = MIN(1, MAX(0, endColor.a + endColorVar.a * CCRANDOM_MINUS1_1() ) );
	
	particle->color = start;
	particle->deltaColor.r = (end.r - start.r) / particle->timeToLive;
	particle->deltaColor.g = (end.g - start.g) / particle->timeToLive;
	particle->deltaColor.b = (end.b - start.b) / particle->timeToLive;
	particle->deltaColor.a = (end.a - start.a) / particle->timeToLive;
	
	// size
	float startS = MAX(0, startSize + startSizeVar * CCRANDOM_MINUS1_1() ); // no negative size
	startS *= CC_CONTENT_SCALE_FACTOR();
	
	particle->size = startS;
	if( endSize == kCCParticleStartSizeEqualToEndSize )
		particle->deltaSize = 0;
	else {
		float endS = endSize + endSizeVar * CCRANDOM_MINUS1_1();
		endS = MAX(0, endS);
		endS *= CC_CONTENT_SCALE_FACTOR();
		particle->deltaSize = (endS - startS) / particle->timeToLive;
	}
	
	// rotation
	float startA = startSpin + startSpinVar * CCRANDOM_MINUS1_1();
	float endA = endSpin + endSpinVar * CCRANDOM_MINUS1_1();
	particle->rotation = startA;
	particle->deltaRotation = (endA - startA) / particle->timeToLive;
	
	// position
	if( positionType_ == kCCPositionTypeFree ) {
		CGPoint p = [self convertToWorldSpace:CGPointZero];
		particle->startPos = ccp( p.x * CC_CONTENT_SCALE_FACTOR(), p.y * CC_CONTENT_SCALE_FACTOR() );
	}
	
	// direction
	float a = CC_DEGREES_TO_RADIANS( angle + angleVar * CCRANDOM_MINUS1_1() );	
	
	// Mode Gravity: A
	if( emitterMode_ == kCCParticleModeGravity ) {

		
		CGPoint v;
		v.y = sinf( a );
		v.x = cosf( a );
		float s = mode.A.speed + mode.A.speedVar * CCRANDOM_MINUS1_1();
		s *= CC_CONTENT_SCALE_FACTOR();
		
		// direction
		particle->mode.A.dir = ccpMult( v, s );
		
		// radial accel
		particle->mode.A.radialAccel = mode.A.radialAccel + mode.A.radialAccelVar * CCRANDOM_MINUS1_1();
		particle->mode.A.radialAccel *= CC_CONTENT_SCALE_FACTOR();
		
		// tangential accel
		particle->mode.A.tangentialAccel = mode.A.tangentialAccel + mode.A.tangentialAccelVar * CCRANDOM_MINUS1_1();
		particle->mode.A.tangentialAccel *= CC_CONTENT_SCALE_FACTOR();

	}
	
	// Mode Radius: B
	else {
		// Set the default diameter of the particle from the source position
		float startRadius = mode.B.startRadius + mode.B.startRadiusVar * CCRANDOM_MINUS1_1();
		float endRadius = mode.B.endRadius + mode.B.endRadiusVar * CCRANDOM_MINUS1_1();

		startRadius *= CC_CONTENT_SCALE_FACTOR();
		endRadius *= CC_CONTENT_SCALE_FACTOR();
		
		particle->mode.B.radius = startRadius;

		if( mode.B.endRadius == kCCParticleStartRadiusEqualToEndRadius )
			particle->mode.B.deltaRadius = 0;
		else
			particle->mode.B.deltaRadius = (endRadius - startRadius) / particle->timeToLive;
	
		particle->mode.B.angle = a;
		particle->mode.B.degreesPerSecond = CC_DEGREES_TO_RADIANS(mode.B.rotatePerSecond + mode.B.rotatePerSecondVar * CCRANDOM_MINUS1_1());
	}	
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
		p->timeToLive = 0;
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
	
	
#if CC_ENABLE_PROFILERS
	CCProfilingBeginTimingBlock(_profilingTimer);
#endif
	
	
	CGPoint currentPosition = CGPointZero;
	if( positionType_ == kCCPositionTypeFree ) {
		currentPosition = [self convertToWorldSpace:CGPointZero];
		currentPosition.x *= CC_CONTENT_SCALE_FACTOR();
		currentPosition.y *= CC_CONTENT_SCALE_FACTOR();
	}
	
	while( particleIdx < particleCount )
	{
		tCCParticle *p = &particles[particleIdx];
		
		// life
		p->timeToLive -= dt;

		if( p->timeToLive > 0 ) {
			
			// Mode A: gravity, direction, tangential accel & radial accel
			if( emitterMode_ == kCCParticleModeGravity ) {
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
				tmp = ccpAdd( ccpAdd( radial, tangential), mode.A.gravity);
				tmp = ccpMult( tmp, dt);
				p->mode.A.dir = ccpAdd( p->mode.A.dir, tmp);
				tmp = ccpMult(p->mode.A.dir, dt);
				p->pos = ccpAdd( p->pos, tmp );
			}
			
			// Mode B: radius movement
			else {				
				// Update the angle and radius of the particle.
				p->mode.B.angle += p->mode.B.degreesPerSecond * dt;
				p->mode.B.radius += p->mode.B.deltaRadius * dt;
				
				p->pos.x = - cosf(p->mode.B.angle) * p->mode.B.radius;
				p->pos.y = - sinf(p->mode.B.angle) * p->mode.B.radius;
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
						
			//
			// update values in quad
			//
			
			CGPoint	newPos;
			
			if( positionType_ == kCCPositionTypeFree ) {
				CGPoint diff = ccpSub( currentPosition, p->startPos );
				newPos = ccpSub(p->pos, diff);
				
			} else
				newPos = p->pos;

			
			updateParticleImp(self, updateParticleSel, p, newPos);
			
			// update particle counter
			particleIdx++;
			
		} else {
			// life < 0
			if( particleIdx != particleCount-1 )
				particles[particleIdx] = particles[particleCount-1];
			particleCount--;
			
			if( particleCount == 0 && autoRemoveOnFinish_ ) {
				[self unscheduleUpdate];
				[parent_ removeChild:self cleanup:YES];
				return;
			}
		}
	}
	
#if CC_ENABLE_PROFILERS
	CCProfilingEndTimingBlock(_profilingTimer);
#endif
	
#ifdef CC_USES_VBO
	[self postStep];
#endif
}

-(void) updateQuadWithParticle:(tCCParticle*)particle newPosition:(CGPoint)pos;
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
	if( texture_ && ! [texture hasPremultipliedAlpha] &&		
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
		
		if( texture_ && ! [texture_ hasPremultipliedAlpha] ) {
			blendFunc_.src = GL_SRC_ALPHA;
			blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
		} else {
			blendFunc_.src = CC_BLEND_SRC;
			blendFunc_.dst = CC_BLEND_DST;
		}
	}
}

-(BOOL) blendAdditive
{
	return( blendFunc_.src == GL_SRC_ALPHA && blendFunc_.dst == GL_ONE);
}

#pragma mark ParticleSystem - Properties of Gravity Mode 
-(void) setTangentialAccel:(float)t
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	mode.A.tangentialAccel = t;
}
-(float) tangentialAccel
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	return mode.A.tangentialAccel;
}

-(void) setTangentialAccelVar:(float)t
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	mode.A.tangentialAccelVar = t;
}
-(float) tangentialAccelVar
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	return mode.A.tangentialAccelVar;
}

-(void) setRadialAccel:(float)t
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	mode.A.radialAccel = t;
}
-(float) radialAccel
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	return mode.A.radialAccel;
}

-(void) setRadialAccelVar:(float)t
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	mode.A.radialAccelVar = t;
}
-(float) radialAccelVar
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	return mode.A.radialAccelVar;
}

-(void) setGravity:(CGPoint)g
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	mode.A.gravity = g;
}
-(CGPoint) gravity
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	return mode.A.gravity;
}

-(void) setSpeed:(float)speed
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	mode.A.speed = speed;
}
-(float) speed
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	return mode.A.speed;
}

-(void) setSpeedVar:(float)speedVar
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	mode.A.speedVar = speedVar;
}
-(float) speedVar
{
	NSAssert( emitterMode_ == kCCParticleModeGravity, @"Particle Mode should be Gravity");
	return mode.A.speedVar;
}

#pragma mark ParticleSystem - Properties of Radius Mode

-(void) setStartRadius:(float)startRadius
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	mode.B.startRadius = startRadius;
}
-(float) startRadius
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	return mode.B.startRadius;
}

-(void) setStartRadiusVar:(float)startRadiusVar
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	mode.B.startRadiusVar = startRadiusVar;
}
-(float) startRadiusVar
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	return mode.B.startRadiusVar;
}

-(void) setEndRadius:(float)endRadius
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	mode.B.endRadius = endRadius;
}
-(float) endRadius
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	return mode.B.endRadius;
}

-(void) setEndRadiusVar:(float)endRadiusVar
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	mode.B.endRadiusVar = endRadiusVar;
}
-(float) endRadiusVar
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	return mode.B.endRadiusVar;
}

-(void) setRotatePerSecond:(float)degrees
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	mode.B.rotatePerSecond = degrees;
}
-(float) rotatePerSecond
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	return mode.B.rotatePerSecond;
}

-(void) setRotatePerSecondVar:(float)degrees
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	mode.B.rotatePerSecondVar = degrees;
}
-(float) rotatePerSecondVar
{
	NSAssert( emitterMode_ == kCCParticleModeRadius, @"Particle Mode should be Radius");
	return mode.B.rotatePerSecondVar;
}
@end


