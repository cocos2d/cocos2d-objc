/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


// cocos2d
#import "CCParticleExamples.h"
#import "CCTextureCache.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"

//
// ParticleFireworks
//
@implementation CCParticleFireworks
-(id) init
{
	return [self initWithTotalParticles:1500];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
	if( (self=[super initWithTotalParticles:p]) ) {
		// _duration
		_duration = kCCParticleDurationInfinity;

		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,-90);

		// Gravity Mode:  radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;

		//  Gravity Mode: speed of particles
		self.speed = 180;
		self.speedVar = 50;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);

		// angle
		_angle = 90;
		_angleVar = 20;

		// life of particles
		_life = 3.5f;
		_lifeVar = 1;

		// emits per frame
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.5f;
		_startColor.g = 0.5f;
		_startColor.b = 0.5f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.5f;
		_startColorVar.g = 0.5f;
		_startColorVar.b = 0.5f;
		_startColorVar.a = 0.1f;
		_endColor.r = 0.1f;
		_endColor.g = 0.1f;
		_endColor.b = 0.1f;
		_endColor.a = 0.2f;
		_endColorVar.r = 0.1f;
		_endColorVar.g = 0.1f;
		_endColorVar.b = 0.1f;
		_endColorVar.a = 0.2f;

		// size, in pixels
		_startSize = 8.0f;
		_startSizeVar = 2.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = NO;
	}

	return self;
}
@end

//
// ParticleFire
//
@implementation CCParticleFire
-(id) init
{
	return [self initWithTotalParticles:250];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,0);

		// Gravity Mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;

		// Gravity Mode: speed of particles
		self.speed = 60;
		self.speedVar = 20;

		// starting _angle
		_angle = 90;
		_angleVar = 10;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, 60);
		self.posVar = ccp(40, 20);

		// _life of particles
		_life = 3;
		_lifeVar = 0.25f;


		// size, in pixels
		_startSize = 54.0f;
		_startSizeVar = 10.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per frame
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.76f;
		_startColor.g = 0.25f;
		_startColor.b = 0.12f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.0f;
		_startColorVar.g = 0.0f;
		_startColorVar.b = 0.0f;
		_startColorVar.a = 0.0f;
		_endColor.r = 0.0f;
		_endColor.g = 0.0f;
		_endColor.b = 0.0f;
		_endColor.a = 1.0f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = YES;
	}

	return self;
}
@end

//
// ParticleSun
//
@implementation CCParticleSun
-(id) init
{
	return [self initWithTotalParticles:350];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// additive
		self.blendAdditive = YES;

		// _duration
		_duration = kCCParticleDurationInfinity;

		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,0);

		// Gravity mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;

		// Gravity mode: speed of particles
		self.speed = 20;
		self.speedVar = 5;


		// _angle
		_angle = 90;
		_angleVar = 360;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		self.posVar = CGPointZero;

		// _life of particles
		_life = 1;
		_lifeVar = 0.5f;

		// size, in pixels
		_startSize = 30.0f;
		_startSizeVar = 10.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per seconds
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.76f;
		_startColor.g = 0.25f;
		_startColor.b = 0.12f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.0f;
		_startColorVar.g = 0.0f;
		_startColorVar.b = 0.0f;
		_startColorVar.a = 0.0f;
		_endColor.r = 0.0f;
		_endColor.g = 0.0f;
		_endColor.b = 0.0f;
		_endColor.a = 1.0f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
	}

	return self;
}
@end

//
// ParticleGalaxy
//
@implementation CCParticleGalaxy
-(id) init
{
	return [self initWithTotalParticles:200];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,0);

		// Gravity Mode: speed of particles
		self.speed = 60;
		self.speedVar = 10;

		// Gravity Mode: radial
		self.radialAccel = -80;
		self.radialAccelVar = 0;

		// Gravity Mode: tagential
		self.tangentialAccel = 80;
		self.tangentialAccelVar = 0;

		// _angle
		_angle = 90;
		_angleVar = 360;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		self.posVar = CGPointZero;

		// _life of particles
		_life = 4;
		_lifeVar = 1;

		// size, in pixels
		_startSize = 37.0f;
		_startSizeVar = 10.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.12f;
		_startColor.g = 0.25f;
		_startColor.b = 0.76f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.0f;
		_startColorVar.g = 0.0f;
		_startColorVar.b = 0.0f;
		_startColorVar.a = 0.0f;
		_endColor.r = 0.0f;
		_endColor.g = 0.0f;
		_endColor.b = 0.0f;
		_endColor.a = 1.0f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = YES;
	}

	return self;
}
@end

//
// ParticleFlower
//
@implementation CCParticleFlower
-(id) init
{
	return [self initWithTotalParticles:250];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,0);

		// Gravity Mode: speed of particles
		self.speed = 80;
		self.speedVar = 10;

		// Gravity Mode: radial
		self.radialAccel = -60;
		self.radialAccelVar = 0;

		// Gravity Mode: tagential
		self.tangentialAccel = 15;
		self.tangentialAccelVar = 0;

		// _angle
		_angle = 90;
		_angleVar = 360;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		self.posVar = CGPointZero;

		// _life of particles
		_life = 4;
		_lifeVar = 1;

		// size, in pixels
		_startSize = 30.0f;
		_startSizeVar = 10.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.50f;
		_startColor.g = 0.50f;
		_startColor.b = 0.50f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.5f;
		_startColorVar.g = 0.5f;
		_startColorVar.b = 0.5f;
		_startColorVar.a = 0.5f;
		_endColor.r = 0.0f;
		_endColor.g = 0.0f;
		_endColor.b = 0.0f;
		_endColor.a = 1.0f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = YES;
	}

	return self;
}
@end

//
// ParticleMeteor
//
@implementation CCParticleMeteor
-(id) init
{
	return [self initWithTotalParticles:150];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(-200,200);

		// Gravity Mode: speed of particles
		self.speed = 15;
		self.speedVar = 5;

		// Gravity Mode: radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;

		// Gravity Mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;

		// _angle
		_angle = 90;
		_angleVar = 360;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		self.posVar = CGPointZero;

		// _life of particles
		_life = 2;
		_lifeVar = 1;

		// size, in pixels
		_startSize = 60.0f;
		_startSizeVar = 10.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.2f;
		_startColor.g = 0.4f;
		_startColor.b = 0.7f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.0f;
		_startColorVar.g = 0.0f;
		_startColorVar.b = 0.2f;
		_startColorVar.a = 0.1f;
		_endColor.r = 0.0f;
		_endColor.g = 0.0f;
		_endColor.b = 0.0f;
		_endColor.a = 1.0f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = YES;
	}

	return self;
}
@end

//
// ParticleSpiral
//
@implementation CCParticleSpiral
-(id) init
{
	return [self initWithTotalParticles:500];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,0);

		// Gravity Mode: speed of particles
		self.speed = 150;
		self.speedVar = 0;

		// Gravity Mode: radial
		self.radialAccel = -380;
		self.radialAccelVar = 0;

		// Gravity Mode: tagential
		self.tangentialAccel = 45;
		self.tangentialAccelVar = 0;

		// _angle
		_angle = 90;
		_angleVar = 0;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		self.posVar = CGPointZero;

		// _life of particles
		_life = 12;
		_lifeVar = 0;

		// size, in pixels
		_startSize = 20.0f;
		_startSizeVar = 0.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.5f;
		_startColor.g = 0.5f;
		_startColor.b = 0.5f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.5f;
		_startColorVar.g = 0.5f;
		_startColorVar.b = 0.5f;
		_startColorVar.a = 0.0f;
		_endColor.r = 0.5f;
		_endColor.g = 0.5f;
		_endColor.b = 0.5f;
		_endColor.a = 1.0f;
		_endColorVar.r = 0.5f;
		_endColorVar.g = 0.5f;
		_endColorVar.b = 0.5f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = NO;
	}

	return self;
}
@end

//
// ParticleExplosion
//
@implementation CCParticleExplosion
-(id) init
{
	return [self initWithTotalParticles:700];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = 0.1f;

		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,0);

		// Gravity Mode: speed of particles
		self.speed = 70;
		self.speedVar = 40;

		// Gravity Mode: radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;

		// Gravity Mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;

		// _angle
		_angle = 90;
		_angleVar = 360;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		self.posVar = CGPointZero;

		// _life of particles
		_life = 5.0f;
		_lifeVar = 2;

		// size, in pixels
		_startSize = 15.0f;
		_startSizeVar = 10.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		_emissionRate = _totalParticles/_duration;

		// color of particles
		_startColor.r = 0.7f;
		_startColor.g = 0.1f;
		_startColor.b = 0.2f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.5f;
		_startColorVar.g = 0.5f;
		_startColorVar.b = 0.5f;
		_startColorVar.a = 0.0f;
		_endColor.r = 0.5f;
		_endColor.g = 0.5f;
		_endColor.b = 0.5f;
		_endColor.a = 0.0f;
		_endColorVar.r = 0.5f;
		_endColorVar.g = 0.5f;
		_endColorVar.b = 0.5f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = NO;
	}

	return self;
}
@end

//
// ParticleSmoke
//
@implementation CCParticleSmoke
-(id) init
{
	return [self initWithTotalParticles:200];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		// Emitter mode: Gravity Mode
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,0);

		// Gravity Mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;

		// Gravity Mode: speed of particles
		self.speed = 25;
		self.speedVar = 10;

		// _angle
		_angle = 90;
		_angleVar = 5;

		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, 0);
		self.posVar = ccp(20, 0);

		// _life of particles
		_life = 4;
		_lifeVar = 1;

		// size, in pixels
		_startSize = 60.0f;
		_startSizeVar = 10.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per frame
		_emissionRate = _totalParticles/_life;

		// color of particles
		_startColor.r = 0.8f;
		_startColor.g = 0.8f;
		_startColor.b = 0.8f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.02f;
		_startColorVar.g = 0.02f;
		_startColorVar.b = 0.02f;
		_startColorVar.a = 0.0f;
		_endColor.r = 0.0f;
		_endColor.g = 0.0f;
		_endColor.b = 0.0f;
		_endColor.a = 1.0f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = NO;
	}

	return self;
}
@end

@implementation CCParticleSnow
-(id) init
{
	return [self initWithTotalParticles:700];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		// set gravity mode.
		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(0,-1);

		// Gravity Mode: speed of particles
		self.speed = 5;
		self.speedVar = 1;

		// Gravity Mode: radial
		self.radialAccel = 0;
		self.radialAccelVar = 1;

		// Gravity mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 1;

		// emitter position
		self.position = (CGPoint) {
			[[CCDirector sharedDirector] winSize].width / 2,
			[[CCDirector sharedDirector] winSize].height + 10
		};
		self.posVar = ccp( [[CCDirector sharedDirector] winSize].width / 2, 0 );

		// _angle
		_angle = -90;
		_angleVar = 5;

		// _life of particles
		_life = 45;
		_lifeVar = 15;

		// size, in pixels
		_startSize = 10.0f;
		_startSizeVar = 5.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		_emissionRate = 10;

		// color of particles
		_startColor.r = 1.0f;
		_startColor.g = 1.0f;
		_startColor.b = 1.0f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.0f;
		_startColorVar.g = 0.0f;
		_startColorVar.b = 0.0f;
		_startColorVar.a = 0.0f;
		_endColor.r = 1.0f;
		_endColor.g = 1.0f;
		_endColor.b = 1.0f;
		_endColor.a = 0.0f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = NO;
	}

	return self;
}
@end

@implementation CCParticleRain
-(id) init
{
	return [self initWithTotalParticles:1000];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// _duration
		_duration = kCCParticleDurationInfinity;

		self.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		self.gravity = ccp(10,-10);

		// Gravity Mode: radial
		self.radialAccel = 0;
		self.radialAccelVar = 1;

		// Gravity Mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 1;

		// Gravity Mode: speed of particles
		self.speed = 130;
		self.speedVar = 30;

		// _angle
		_angle = -90;
		_angleVar = 5;


		// emitter position
		self.position = (CGPoint) {
			[[CCDirector sharedDirector] winSize].width / 2,
			[[CCDirector sharedDirector] winSize].height
		};
		self.posVar = ccp( [[CCDirector sharedDirector] winSize].width / 2, 0 );

		// _life of particles
		_life = 4.5f;
		_lifeVar = 0;

		// size, in pixels
		_startSize = 4.0f;
		_startSizeVar = 2.0f;
		_endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		_emissionRate = 20;

		// color of particles
		_startColor.r = 0.7f;
		_startColor.g = 0.8f;
		_startColor.b = 1.0f;
		_startColor.a = 1.0f;
		_startColorVar.r = 0.0f;
		_startColorVar.g = 0.0f;
		_startColorVar.b = 0.0f;
		_startColorVar.a = 0.0f;
		_endColor.r = 0.7f;
		_endColor.g = 0.8f;
		_endColor.b = 1.0f;
		_endColor.a = 0.5f;
		_endColorVar.r = 0.0f;
		_endColorVar.g = 0.0f;
		_endColorVar.b = 0.0f;
		_endColorVar.a = 0.0f;

		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];

		// additive
		self.blendAdditive = NO;
	}

	return self;
}
@end
