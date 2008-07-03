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

#import <UIKit/UIKit.h>

#import "chipmunk.h"
#import "CocosNode.h"
#import "types.h"

#define kLIVE (1 << 0)
typedef struct sParticle
{
	cpVect	pos;
	cpVect	dir;
	float	radialAccel;
	float	tangentialAccel;
	ColorF	color;
	ColorF	deltaColor;
	float	size;
	float	life;
	long	flags;
} Particle;

@class Texture2D;

@interface ParticleSystem : CocosNode
{
	int id;
	long flags;
	
	/// Gravity of the particles
	cpVect gravity;

	/// Position where the particles will be born
	cpVect pos;
	/// Position variance
	cpVect posVar;
	
	/// The angle (direction) of the particles measured in degrees
	float angle;
	/// Angle variance measured in degrees;
	float angleVar;
	
	/// The speed the particles will have.
	float speed;
	/// The speed variance
	float speedVar;
	
	/// Tangential acceleration
	float tangentialAccel;
	/// Tangential acceleration variance
	float tangentialAccelVar;

	/// Radial acceleration
	float radialAccel;
	/// Radial acceleration variance
	float radialAccelVar;
	
	/// Size of the particles
	float size;
	/// Size variance
	float sizeVar;
	
	/// Start color of the particles
	ColorF startColor;
	/// Start color variance
	ColorF startColorVar;
	/// End color of the particles
	ColorF endColor;
	/// End color variance
	ColorF endColorVar;
	
	Particle *particles;
	/// Maximum particles
	int totalParticles;
	/// Count of particles
	int particleCount;
	
	/// How many particles can be emitted per second
	float emissionRate;
	float emitCounter;
	
	/// How many seconds will the particle live
	float life;
	/// Life variance
	float lifeVar;
}
// FLAGS
#define kRESPAWN ( 1 << 0 )

@property (readwrite,assign) cpVect pos;
@property (readwrite,assign) cpVect posVar;
@property (readwrite,assign) float angle;
@property (readwrite,assign) float angleVar;
@property (readwrite,assign) float speed;
@property (readwrite,assign) float speedVar;
@property (readwrite,assign) float tangentialAccel;
@property (readwrite,assign) float tangentialAccelVar;
@property (readwrite,assign) float radialAccel;
@property (readwrite,assign) float radialAccelVar;
@property (readwrite,assign) ColorF startColor;
@property (readwrite,assign) ColorF startColorVar;
@property (readwrite,assign) ColorF endColor;
@property (readwrite,assign) ColorF endColorVar;
@property (readwrite,assign) float emissionRate;
@property (readwrite,assign) int totalParticles;


//! Add a particle to the emitter
-(BOOL) addParticle;
//! Update a particle
-(BOOL) updateParticle: (Particle*) particle delta:(double)dt;
//! Initializes a particle
-(void) initParticle: (Particle*) particle;
//! Draws the particle
-(void) drawParticle: (Particle*) particle;
//! perform actions before all the particles are visited
-(void) preParticles;
//! perform actions after all the particles have been visited, like draw them
-(void) postParticles;
@end

@interface TextureParticleSystem : ParticleSystem
{
	Texture2D *texture;
	
	// VBO related
	VtxPointSprite *vertices;
	ColorF	*colors;
	GLuint	verticesID;
	GLuint	colorsID;
	
	int particleIdx;
}
@end

@interface PixelParticleSystem : ParticleSystem
{
}
@end

@interface ParticleFireworks : PixelParticleSystem
{
}
@end

@interface ParticleFire: TextureParticleSystem
{
}
@end

@interface ParticleFireworks2 : TextureParticleSystem
{
}
@end

@interface ParticleSun : TextureParticleSystem
{
}
@end

@interface ParticleGalaxy : TextureParticleSystem
{
}
@end

