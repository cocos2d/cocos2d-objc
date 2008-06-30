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

#import "Particle.h"
#import "OpenGL_Internal.h"

#define RANDOM_FLOAT() (((float)random() / (float)0x3fffffff )-1.0f)


@implementation Particle
@synthesize pos, dir, life;
@end

@implementation Emitter

@synthesize pos, angle, angleVar, speed, speedVar, emitsPerFrame, emitVar, totalParticles, particles;

-(id) init
{
	if( ! [super init] )
		return nil;
	
	particles = [[NSMutableArray arrayWithCapacity:200] retain];
	totalParticles = 100;
	force.x = 0;
	force.y = -0.1;
	angle = 90;
	angleVar = 45;
	pos.x = 160;
	pos.y = 240;
	life = 100;
	lifeVar = 20;
	speed = 3;
	speedVar = 0.3;
	
	return self;
}

-(void) dealloc
{
	[particles release];
	[super dealloc];
}

-(BOOL) addParticle
{
	if( particleCount < totalParticles ) {
		Particle * particle = [[Particle alloc] init];
		
		[self initParticle: particle];
		
		particleCount++;
		
		[particles addObject: particle];
		[particle release];
		
		return YES;
	}
	return NO;
}

-(void) initParticle: (Particle*) particle
{
	particle.pos = cpvzero;
	particle.dir = cpvzero;
	particle.life = life + lifeVar * RANDOM_FLOAT();
	float ar = angle + angleVar * RANDOM_FLOAT();
	float a = DEGREES_TO_RADIANS( ar );
	cpVect v;
	v.y = sinf( a );
	v.x = cosf( a );
	float s = speed + speedVar * RANDOM_FLOAT();
	particle.dir = cpvmult( v, s );
	particle.life = life + lifeVar * RANDOM_FLOAT();
}

-(BOOL) updateParticle: (Particle*) p
{
	if( p.life > 0 ) {
		p.pos = cpvadd( p.pos, p.dir );
		p.dir = cpvadd( p.dir, force );
		p.life--;
		return YES;
	} else {
		[self initParticle:p];
//		particleCount--;
//		[particles removeObject: p];
	}
	return NO;
}
@end

@implementation EmitFireworks
-(id) init
{
	if( ! [super init] )
		return nil;
	
	return self;
}
@end
