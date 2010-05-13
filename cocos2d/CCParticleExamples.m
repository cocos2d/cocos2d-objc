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

-(id) initWithTotalParticles:(int)p
{
	if( (self=[super initWithTotalParticles:p]) ) {
		// duration
		duration = -1;

		// gravity
		self.gravity = ccp(0,-90);
		
		// angle
		angle = 90;
		angleVar = 20;
		
		// radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;

		// speed of particles
		speed = 180;
		speedVar = 50;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		
		// life of particles
		life = 3.5f;
		lifeVar = 1;
			
		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.5f;
		startColor.g = 0.5f;
		startColor.b = 0.5f;
		startColor.a = 1.0f;
		startColorVar.r = 0.5f;
		startColorVar.g = 0.5f;
		startColorVar.b = 0.5f;
		startColorVar.a = 0.1f;
		endColor.r = 0.1f;
		endColor.g = 0.1f;
		endColor.b = 0.1f;
		endColor.a = 0.2f;
		endColorVar.r = 0.1f;
		endColorVar.g = 0.1f;
		endColorVar.b = 0.1f;
		endColorVar.a = 0.2f;
		
		// size, in pixels
		startSize = 8.0f;
		startSizeVar = 2.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

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

-(id) initWithTotalParticles:(int) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// duration
		duration = -1;

		// gravity
		self.gravity = ccp(0,0);
		
		// angle
		self.angle = 90;
		self.angleVar = 10;

		// radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, 60);
		posVar = ccp(40, 20);
		
		// life of particles
		life = 3;
		lifeVar = 0.25f;
		
		// speed of particles
		speed = 60;
		speedVar = 20;
			
		// size, in pixels
		startSize = 54.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.76f;
		startColor.g = 0.25f;
		startColor.b = 0.12f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// additive
		self.blendAdditive = YES;
			
		// duration
		duration = -1;
		
		// gravity
		self.gravity = ccp(0,0);
		
		// angle
		angle = 90;
		angleVar = 360;
		
		// radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;	
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 1;
		lifeVar = 0.5f;
		
		// speed of particles
		speed = 20;
		speedVar = 5;
		
		// size, in pixels
		startSize = 30.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per seconds
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.76f;
		startColor.g = 0.25f;
		startColor.b = 0.12f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int)p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// duration
		duration = -1;

		// gravity
		self.gravity = ccp(0,0);
		
		// angle
		angle = 90;
		angleVar = 360;
		
		// speed of particles
		speed = 60;
		speedVar = 10;
			
		// radial
		self.radialAccel = -80;
		self.radialAccelVar = 0;
		
		// tagential
		self.tangentialAccel = 80;
		self.tangentialAccelVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 4;
		lifeVar = 1;
		
		// size, in pixels
		startSize = 37.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;
		
		// emits per second
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.12f;
		startColor.g = 0.25f;
		startColor.b = 0.76f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
	
		// duration
		duration = -1;

		// gravity
		self.gravity = ccp(0,0);
		
		// angle
		angle = 90;
		angleVar = 360;
		
		// speed of particles
		speed = 80;
		speedVar = 10;
		
		// radial
		self.radialAccel = -60;
		self.radialAccelVar = 0;
		
		// tagential
		self.tangentialAccel = 15;
		self.tangentialAccelVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 4;
		lifeVar = 1;
		
		// size, in pixels
		startSize = 30.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.50f;
		startColor.g = 0.50f;
		startColor.b = 0.50f;
		startColor.a = 1.0f;
		startColorVar.r = 0.5f;
		startColorVar.g = 0.5f;
		startColorVar.b = 0.5f;
		startColorVar.a = 0.5f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int) p
{
	if( (self=[super initWithTotalParticles:p]) ) {

		// duration
		duration = -1;
		
		// gravity
		self.gravity = ccp(-200,200);

		// angle
		angle = 90;
		angleVar = 360;
		
		// speed of particles
		speed = 15;
		speedVar = 5;
		
		// radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 2;
		lifeVar = 1;
		
		// size, in pixels
		startSize = 60.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.2f;
		startColor.g = 0.4f;
		startColor.b = 0.7f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.2f;
		startColorVar.a = 0.1f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
	
		// duration
		duration = -1;

		// gravity
		self.gravity = ccp(0,0);
		
		// angle
		angle = 90;
		angleVar = 0;
		
		// speed of particles
		speed = 150;
		speedVar = 0;
		
		// radial
		self.radialAccel = -380;
		self.radialAccelVar = 0;
		
		// tagential
		self.tangentialAccel = 45;
		self.tangentialAccelVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 12;
		lifeVar = 0;
		
		// size, in pixels
		startSize = 20.0f;
		startSizeVar = 0.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.5f;
		startColor.g = 0.5f;
		startColor.b = 0.5f;
		startColor.a = 1.0f;
		startColorVar.r = 0.5f;
		startColorVar.g = 0.5f;
		startColorVar.b = 0.5f;
		startColorVar.a = 0.0f;
		endColor.r = 0.5f;
		endColor.g = 0.5f;
		endColor.b = 0.5f;
		endColor.a = 1.0f;
		endColorVar.r = 0.5f;
		endColorVar.g = 0.5f;
		endColorVar.b = 0.5f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int)p
{
	if( (self=[super initWithTotalParticles:p]) ) {
	
		// duration
		duration = 0.1f;
		
		// gravity
		self.gravity = ccp(0,0);
		
		// angle
		angle = 90;
		angleVar = 360;
		
		// speed of particles
		speed = 70;
		speedVar = 40;
		
		// radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 5.0f;
		lifeVar = 2;
		
		// size, in pixels
		startSize = 15.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/duration;
		
		// color of particles
		startColor.r = 0.7f;
		startColor.g = 0.1f;
		startColor.b = 0.2f;
		startColor.a = 1.0f;
		startColorVar.r = 0.5f;
		startColorVar.g = 0.5f;
		startColorVar.b = 0.5f;
		startColorVar.a = 0.0f;
		endColor.r = 0.5f;
		endColor.g = 0.5f;
		endColor.b = 0.5f;
		endColor.a = 0.0f;
		endColorVar.r = 0.5f;
		endColorVar.g = 0.5f;
		endColorVar.b = 0.5f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
	
		// duration
		duration = -1;
		
		// Emitter mode: A
		self.emitterMode = kCCParticleModeA;
		
		// gravity
		self.gravity = ccp(0,0);

		// radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// angle
		angle = 90;
		angleVar = 5;
		
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, 0);
		posVar = ccp(20, 0);
		
		// life of particles
		life = 4;
		lifeVar = 1;
		
		// speed of particles
		speed = 25;
		speedVar = 10;
		
		// size, in pixels
		startSize = 60.0f;
		startSizeVar = 10.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.8f;
		startColor.g = 0.8f;
		startColor.b = 0.8f;
		startColor.a = 1.0f;
		startColorVar.r = 0.02f;
		startColorVar.g = 0.02f;
		startColorVar.b = 0.02f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int)p
{
	if( (self=[super initWithTotalParticles:p]) ) {
	
		// duration
		duration = -1;
		
		self.emitterMode = kCCParticleModeA;

		// gravity
		self.gravity = ccp(0,-1);
		
		// angle
		angle = -90;
		angleVar = 5;
		
		// speed of particles
		speed = 5;
		speedVar = 1;
		
		// radial
		self.radialAccel = 0;
		self.radialAccelVar = 1;
		
		// tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 1;
		
		// emitter position
		self.position = (CGPoint) {
			[[CCDirector sharedDirector] winSize].width / 2,
			[[CCDirector sharedDirector] winSize].height + 10
		};
		posVar = ccp( [[CCDirector sharedDirector] winSize].width / 2, 0 );
		
		// life of particles
		life = 45;
		lifeVar = 15;
		
		// size, in pixels
		startSize = 10.0f;
		startSizeVar = 5.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = 10;
		
		// color of particles
		startColor.r = 1.0f;
		startColor.g = 1.0f;
		startColor.b = 1.0f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 1.0f;
		endColor.g = 1.0f;
		endColor.b = 1.0f;
		endColor.a = 0.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
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

-(id) initWithTotalParticles:(int)p
{
	if( (self=[super initWithTotalParticles:p]) ) {
	
		// duration
		duration = -1;
		
		self.emitterMode = kCCParticleModeA;

		// gravity
		self.gravity = ccp(10,-10);
		
		// radial
		self.radialAccel = 0;
		self.radialAccelVar = 1;
		
		// tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 1;
		
		// angle
		angle = -90;
		angleVar = 5;
		
		// speed of particles
		speed = 130;
		speedVar = 30;
		
		// emitter position
		self.position = (CGPoint) {
			[[CCDirector sharedDirector] winSize].width / 2,
			[[CCDirector sharedDirector] winSize].height
		};
		posVar = ccp( [[CCDirector sharedDirector] winSize].width / 2, 0 );
		
		// life of particles
		life = 4.5f;
		lifeVar = 0;
		
		// size, in pixels
		startSize = 4.0f;
		startSizeVar = 2.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = 20;
		
		// color of particles
		startColor.r = 0.7f;
		startColor.g = 0.8f;
		startColor.b = 1.0f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 0.7f;
		endColor.g = 0.8f;
		endColor.b = 1.0f;
		endColor.a = 0.5f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
		
		// additive
		self.blendAdditive = NO;
	}
	
	return self;
}
@end
