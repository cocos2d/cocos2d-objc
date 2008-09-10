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


// cocos2d
#import "ParticleSystems.h"
#import "TextureMgr.h"

//
// ParticleFireworks
//
@implementation ParticleFireworks
-(id) init
{
	return [self initWithParticles:1500];
}

-(id) initWithParticles:(int)p
{
	if( ! [super initWithParticles:p] )
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
	life = 3.5;
	lifeVar = 1;
		
	// emits per frame
	emissionRate = totalParticles/life;
	
	// color of particles
	startColor.r = 0.5f;
	startColor.g = 0.5f;
	startColor.b = 0.5f;
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
	size = 8.0f;
	sizeVar = 2.0f;

	texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	[texture retain];

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
	return [self initWithParticles:250];
}

-(id) initWithParticles:(int) p
{
	if( ! [super initWithParticles:p] )
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
	lifeVar = 0.25;
	
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
	return [self initWithParticles:350];
}

-(id) initWithParticles:(int) p
{
	if( ! [super initWithParticles:p] )
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
	lifeVar = 0.5;
	
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
	
	return self;
}
@end

//
// ParticleGalaxy
//
@implementation ParticleGalaxy
-(id) init
{
	return [self initWithParticles:200];
}

-(id) initWithParticles:(int)p
{
	if( ! [super initWithParticles:p] )
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
	return [self initWithParticles:250];
}

-(id) initWithParticles:(int) p
{
	if( ! [super initWithParticles:p] )
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
	
	texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	[texture retain];

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
	return [self initWithParticles:150];
}

-(id) initWithParticles:(int) p
{
	if( ! [super initWithParticles:p] )
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
	
	texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	[texture retain];
	
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
	return [self initWithParticles:500];
}

-(id) initWithParticles:(int) p
{
	if( ! [super initWithParticles:p] )
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
	posVar.x = 00;
	posVar.y = 00;
	
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
	
	texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	[texture retain];

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
	return [self initWithParticles:700];
}

-(id) initWithParticles:(int)p
{
	if( ! [super initWithParticles:p] )
		return nil;
	
	// duration
	duration = 0.1;
	
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
	posVar.x = 00;
	posVar.y = 00;
	
	// life of particles
	life = 5.0;
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
	
	texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
	[texture retain];

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
	return [self initWithParticles:200];
}

-(id) initWithParticles:(int) p
{
	if( ! [super initWithParticles:p] )
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
	startColorVar.r = 0.02;
	startColorVar.g = 0.02;
	startColorVar.b = 0.02;
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
	
	// additive
	blendAdditive = NO;
	
	return self;
}
@end
