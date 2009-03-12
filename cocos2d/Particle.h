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

#import <UIKit/UIKit.h>

#import "chipmunk.h"
#import "CocosNode.h"
#import "ccTypes.h"

typedef struct sParticle
{
	cpVect	pos;
	cpVect	dir;
	float	radialAccel;
	float	tangentialAccel;
	ccColorF	color;
	ccColorF	deltaColor;
	float	size;
	float	life;
} Particle;

@class Texture2D;

//! Particle System base class
@interface ParticleSystem : CocosNode
{
	int id;
	
	// is the particle system active ?
	BOOL active;
	// duration in seconds of the system. -1 is infinity
	float duration;
	// time elapsed since the start of the system (in seconds)
	float elapsed;
	
	/// Gravity of the particles
	cpVect gravity;

	// position is from "superclass" CocosNode
	// Emitter source position
	cpVect source;
	// Position variance
	cpVect posVar;
	
	// The angle (direction) of the particles measured in degrees
	float angle;
	// Angle variance measured in degrees;
	float angleVar;
	
	// The speed the particles will have.
	float speed;
	// The speed variance
	float speedVar;
	
	// Tangential acceleration
	float tangentialAccel;
	// Tangential acceleration variance
	float tangentialAccelVar;

	// Radial acceleration
	float radialAccel;
	// Radial acceleration variance
	float radialAccelVar;
	
	// Size of the particles
	float size;
	// Size variance
	float sizeVar;
	
	// How many seconds will the particle live
	float life;
	// Life variance
	float lifeVar;
	
	// Start color of the particles
	ccColorF startColor;
	// Start color variance
	ccColorF startColorVar;
	// End color of the particles
	ccColorF endColor;
	// End color variance
	ccColorF endColorVar;
	
	// Array of particles
	Particle *particles;
	// Maximum particles
	int totalParticles;
	// Count of active particles
	int particleCount;
	
	// additive color or blend
	BOOL blendAdditive;
	// color modulate
	BOOL colorModulate;
	
	// How many particles can be emitted per second
	float emissionRate;
	float emitCounter;
	
	// Texture of the particles
	Texture2D *texture;
	
	// Array of (x,y,size) 
	ccPointSprite *vertices;
	// Array of colors
	ccColorF	*colors;
	// vertices buffer id
	GLuint	verticesID;
	// colors buffer id
	GLuint	colorsID;
	
	//  particle idx
	int particleIdx;
}

/** Is the emitter active */
@property (readonly) BOOL active;
/** Quantity of particles that are being simulated at the moment */
@property (readonly) int	particleCount;
/** Gravity value */
@property (readwrite,assign) cpVect gravity;
/** How many seconds the emitter wil run. -1 means 'forever' */
@property (readwrite,assign) float duration;
/** Source location of particles respective to emitter location */
@property (readwrite,assign) cpVect source;
/** Position variance of the emitter */
@property (readwrite,assign) cpVect posVar;
/** life, and life variation of each particle */
@property (readwrite,assign) float life;
/** life variance of each particle */
@property (readwrite,assign) float lifeVar;
/** angle and angle variation of each particle */
@property (readwrite,assign) float angle;
/** angle variance of each particle */
@property (readwrite,assign) float angleVar;
/** speed of each particle */
@property (readwrite,assign) float speed;
/** speed variance of each particle */
@property (readwrite,assign) float speedVar;
/** tangential acceleration of each particle */
@property (readwrite,assign) float tangentialAccel;
/** tangential acceleration variance of each particle */
@property (readwrite,assign) float tangentialAccelVar;
/** radial acceleration of each particle */
@property (readwrite,assign) float radialAccel;
/** radial acceleration variance of each particle */
@property (readwrite,assign) float radialAccelVar;
/** size in pixels of each particle */
@property (readwrite,assign) float size;
/** size variance in pixels of each particle */
@property (readwrite,assign) float sizeVar;
/** start color of each particle */
@property (readwrite,assign) ccColorF startColor;
/** start color variance of each particle */
@property (readwrite,assign) ccColorF startColorVar;
/** end color and end color variation of each particle */
@property (readwrite,assign) ccColorF endColor;
/** end color variance of each particle */
@property (readwrite,assign) ccColorF endColorVar;
/** emission rate of the particles */
@property (readwrite,assign) float emissionRate;
/** maximum particles of the system */
@property (readwrite,assign) int totalParticles;

//! Initializes a system with a fixed number of particles
-(id) initWithTotalParticles:(int) numberOfParticles;
//! Add a particle to the emitter
-(BOOL) addParticle;
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
