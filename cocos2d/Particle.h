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
} Particle;

@class Texture2D;

//! Particle System base class
@interface ParticleSystem : CocosNode
{
	int id;
	
	/// is the particle system active ?
	BOOL active;
	/// duration in seconds of the system. -1 is infinity
	float duration;
	/// time elapsed since the start of the system (in seconds)
	float elapsed;
	
	/// Gravity of the particles
	cpVect gravity;

	/// position is from "superclass" CocosNode
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
	
	/// How many seconds will the particle live
	float life;
	/// Life variance
	float lifeVar;
	
	/// Start color of the particles
	ColorF startColor;
	/// Start color variance
	ColorF startColorVar;
	/// End color of the particles
	ColorF endColor;
	/// End color variance
	ColorF endColorVar;
	
	/// Array of particles
	Particle *particles;
	/// Maximum particles
	int totalParticles;
	/// Count of particles
	int particleCount;
	
	// additive color or blend
	BOOL blendAdditive;
	// color modulate
	BOOL colorModulate;
	
	/// How many particles can be emitted per second
	float emissionRate;
	float emitCounter;
	
	/// Texture of the particles
	Texture2D *texture;
	
	/// Array of (x,y,size) 
	VtxPointSprite *vertices;
	/// Array of colors
	ColorF	*colors;
	/// vertices buffer id
	GLuint	verticesID;
	/// colors buffer id
	GLuint	colorsID;
	
	///  particle idx
	int particleIdx;
}

@property (readonly)	BOOL active;
@property (readwrite,assign) float duration;
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
//! Update all particles
-(void) step:(double)dt;
//! Initializes a particle
-(void) initParticle: (Particle*) particle;
//! draw all the particles
-(void) draw;
//! stop the running system
-(void) stopSystem;
//! reset the system
-(void) resetSystem;
//! is the system full ?
-(BOOL) isFull;
@end