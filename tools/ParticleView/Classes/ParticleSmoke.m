//
//  ParticleSmoke.m
//  EnchantedCavern
//
//  Created by Stanislav Skuratov on 6/23/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import "ParticleSmoke.h"


@implementation ParticleSmoke2

-(id) init
{
	return [self initWithTotalParticles:100];
}

-(id) initWithTotalParticles:(int) p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = 0.5f;
	
	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = -90;
	angleVar = 10;
	
	// radial acceleration
	radialAccel = 0;
	radialAccelVar = 0;
	
	// emitter position
	self.position = CGPointMake(160, 60);
	posVar.x = 40;
	posVar.y = 30;
	
	// life of particles
	life = 1;
	lifeVar = 0.25f;
	
	// speed of particles
	speed = 60;
	speedVar = 20;
	
	// size, in pixels
	startSize = 50.0f;
	startSizeVar = 10.0f;
	endSize = kParticleStartSizeEqualToEndSize;
	
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
	[self.texture retain];
	
	// additive
	blendAdditive = YES;
	
	return self;
}

@end
