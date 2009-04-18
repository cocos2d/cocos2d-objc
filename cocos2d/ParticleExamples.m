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


// cocos2d
#import "ParticleExamples.h"
#import "TextureMgr.h"
#import "Director.h"

//
// ParticleFireworks
//
@implementation ParticleFireworks
-(id) init
{
	return [self initWithTotalParticles:1500];
}

-(id) initWithTotalParticles:(int)p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = -1;

	// gravity
	gravity.x = 0;
	gravity.y = -90;
	
	// angle
	angle = 90;
	angleVar = 20;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 0;

	// speed of particles
	speed = 180;
	speedVar = 50;
	
	// emitter position
	position.x = 160;
	position.y = 160;
	
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
	size = 8.0f;
	sizeVar = 2.0f;

	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];

	// additive
	blendAdditive = NO;
	
	return self;
}
@end

//
// ParticleFire
//
@implementation ParticleFire
-(id) init
{
	return [self initWithTotalParticles:250];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;

	// duration
	duration = -1;

	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 10;

	// radial acceleration
	radialAccel = 0;
	radialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 60;
	posVar.x = 40;
	posVar.y = 20;
	
	// life of particles
	life = 3;
	lifeVar = 0.25f;
	
	// speed of particles
	speed = 60;
	speedVar = 20;
		
	// size, in pixels
	size = 100.0f;
	sizeVar = 10.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	
	// additive
	blendAdditive = YES;
		
	return self;
}
@end

//
// ParticleSun
//
@implementation ParticleSun
-(id) init
{
	return [self initWithTotalParticles:350];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;

	// additive
	blendAdditive = YES;
		
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// radial acceleration
	radialAccel = 0;
	radialAccelVar = 0;	
	
	// emitter position
	position.x = 160;
	position.y = 240;
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 1;
	lifeVar = 0.5f;
	
	// speed of particles
	speed = 20;
	speedVar = 5;
	
	// size, in pixels
	size = 30.0f;
	sizeVar = 10.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	
	return self;
}
@end

//
// ParticleGalaxy
//
@implementation ParticleGalaxy
-(id) init
{
	return [self initWithTotalParticles:200];
}

-(id) initWithTotalParticles:(int)p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;

	// duration
	duration = -1;

	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// speed of particles
	speed = 60;
	speedVar = 10;
		
	// radial
	radialAccel = -80;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 80;
	tangentialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 240;
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 4;
	lifeVar = 1;
	
	// size, in pixels
	size = 37.0f;
	sizeVar = 10.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];

	// additive
	blendAdditive = YES;
	
	return self;
}
@end

//
// ParticleFlower
//
@implementation ParticleFlower
-(id) init
{
	return [self initWithTotalParticles:250];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = -1;

	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// speed of particles
	speed = 80;
	speedVar = 10;
	
	// radial
	radialAccel = -60;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 15;
	tangentialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 240;
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 4;
	lifeVar = 1;
	
	// size, in pixels
	size = 30.0f;
	sizeVar = 10.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];

	// additive
	blendAdditive = YES;
		
	return self;
}
@end

//
// ParticleMeteor
//
@implementation ParticleMeteor
-(id) init
{
	return [self initWithTotalParticles:150];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;

	// duration
	duration = -1;
	
	// gravity
	gravity.x = -200;
	gravity.y = 200;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// speed of particles
	speed = 15;
	speedVar = 5;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 240;
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 2;
	lifeVar = 1;
	
	// size, in pixels
	size = 60.0f;
	sizeVar = 10.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	
	// additive
	blendAdditive = YES;
	
	return self;
}
@end

//
// ParticleSpiral
//
@implementation ParticleSpiral
-(id) init
{
	return [self initWithTotalParticles:500];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = -1;

	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 0;
	
	// speed of particles
	speed = 150;
	speedVar = 0;
	
	// radial
	radialAccel = -380;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 45;
	tangentialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 240;
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 12;
	lifeVar = 0;
	
	// size, in pixels
	size = 20.0f;
	sizeVar = 0.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];

	// additive
	blendAdditive = NO;
	
	return self;
}
@end

//
// ParticleExplosion
//
@implementation ParticleExplosion
-(id) init
{
	return [self initWithTotalParticles:700];
}

-(id) initWithTotalParticles:(int)p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = 0.1f;
	
	// gravity
	gravity.x = 0;
	gravity.y = -100;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// speed of particles
	speed = 70;
	speedVar = 40;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 240;
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 5.0f;
	lifeVar = 2;
	
	// size, in pixels
	size = 15.0f;
	sizeVar = 10.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];

	// additive
	blendAdditive = NO;
	
	return self;
}
@end

//
// ParticleSmoke
//
@implementation ParticleSmoke
-(id) init
{
	return [self initWithTotalParticles:200];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 5;
	
	// radial acceleration
	radialAccel = 0;
	radialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 0;
	posVar.x = 20;
	posVar.y = 0;
	
	// life of particles
	life = 4;
	lifeVar = 1;
	
	// speed of particles
	speed = 25;
	speedVar = 10;
	
	// size, in pixels
	size = 60.0f;
	sizeVar = 10.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	
	// additive
	blendAdditive = NO;
	
	return self;
}
@end

@implementation ParticleSnow
-(id) init
{
	return [self initWithTotalParticles:700];
}

-(id) initWithTotalParticles:(int)p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = -1;
	
	// angle
	angle = -90;
	angleVar = 5;
	
	// speed of particles
	speed = 5;
	speedVar = 1;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 1;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 1;
	
	// emitter position
	position.x = [[Director sharedDirector] winSize].width / 2;
	position.y = [[Director sharedDirector] winSize].height + 10;
	posVar.x = [[Director sharedDirector] winSize].width / 2;
	posVar.y = 0;
	
	// life of particles
	life = 45;
	lifeVar = 15;
	
	// size, in pixels
	size = 10.0f;
	sizeVar = 5.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	
	// additive
	blendAdditive = NO;
	
	return self;
}
@end

@implementation ParticleRain
-(id) init
{
	return [self initWithTotalParticles:1000];
}

-(id) initWithTotalParticles:(int)p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 10;
	gravity.y = -10;
	
	// angle
	angle = -90;
	angleVar = 5;
	
	// speed of particles
	speed = 130;
	speedVar = 30;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 1;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 1;
	
	// emitter position
	position.x = [[Director sharedDirector] winSize].width / 2;
	position.y = [[Director sharedDirector] winSize].height;
	posVar.x = [[Director sharedDirector] winSize].width / 2;
	posVar.y = 0;
	
	// life of particles
	life = 4.5f;
	lifeVar = 0;
	
	// size, in pixels
	size = 4.0f;
	sizeVar = 2.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	
	// additive
	blendAdditive = NO;
	
	return self;
}
@end

//
// ParticleFlower
//
@implementation BigParticleFlower
-(id) init
{
	return [self initWithTotalParticles:50];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// speed of particles
	speed = 160;
	speedVar = 20;
	
	// radial
	radialAccel = -120;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 30;
	tangentialAccelVar = 0;
	
	// emitter position
	position.x = 160;
	position.y = 240;
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 4;
	lifeVar = 1;
	
	// size, in pixels
	size = 150.0f;
	sizeVar = 50.0f;
	
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
	
	self.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	
	// additive
	blendAdditive = YES;
	
	return self;
}
@end
