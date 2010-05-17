/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008-2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCProtocols.h"
#import "CCNode.h"
#import "ccTypes.h"
#import "ccConfig.h"

#if CC_ENABLE_PROFILERS
@class CCProfilingTimer;
#endif

enum {
	kCCParticleStartSizeEqualToEndSize = -1,
	kCCParticleDurationInfinity = -1,

	// backward compatible
	kParticleStartSizeEqualToEndSize = kCCParticleStartSizeEqualToEndSize,
	kParticleDurationInfinity = kCCParticleDurationInfinity,
};

enum {
	kCCParticleModeA,
	kCCParticleModeB,	
};


/** possible types of particle positions */
typedef enum {
	/** If the emitter is repositioned, the living particles won't be repositioned */
	kCCPositionTypeFree,
	/** If the emitter is repositioned, the living particles will be repositioned too */
	kCCPositionTypeGrouped,
}tCCPositionType;

// backward compatible
enum {
	kPositionTypeFree = kCCPositionTypeFree,
	kPositionTypeGrouped = kCCPositionTypeGrouped,
}; 

/** Structure that contains the values of each particle
 */
typedef struct sCCParticle
{
	CGPoint		pos;
	CGPoint		startPos;

	ccColor4F	color;
	ccColor4F	deltaColor;

	float		size;
	float		deltaSize;

	float		rotation;
	float		deltaRotation;

	float		timeToLive;

	union {
		// Mode A: dir, radial accel, tangential accel
		struct {
			CGPoint		dir;
			float		radialAccel;
			float		tangentialAccel;
		} A;
	
		// Mode B: radius movement
		struct {
			float		angle;
			float		degreesPerSecond;
			float		radius;
			float		deltaRadius;
		} B;
	} mode;

} tCCParticle;

@class CCTexture2D;

/** Particle System base class
 Attributes of a Particle System:
  * duration
  * emmision rate
  * total max particles
  * speed +-  variance
  * start spin +- variance
  * end spin +- variance
  * Mode A:
  *   gravity
  *   tangential acceleration +- variance
  *   radial acceleration +- variance
  * Mode B:
  *    maxRadius +- variance
  *    minRadius
  *	   rotate +- variance
  * start size +- variance
  * end size +- variance
  * start color +- variance
  * end color +- variance
  * life +- variance
  * blend additive or not
  * one texture
 
 Limitations:
  * size can't be bigger than 64
  * the system can't be scaled since the particles are rendered using GL_POINT_SPRITE
 */
@interface CCParticleSystem : CCNode <CCTextureProtocol>
{
	int id;
	
	// is the particle system active ?
	BOOL active;
	// duration in seconds of the system. -1 is infinity
	float duration;
	// time elapsed since the start of the system (in seconds)
	float elapsed;
	
	// position is from "superclass" CocosNode
	// Emitter centerOfGravity position
	CGPoint centerOfGravity;
	// Position variance
	CGPoint posVar;
	
	// The angle (direction) of the particles measured in degrees
	float angle;
	// Angle variance measured in degrees;
	float angleVar;
	
	// Different modes
	
	int emitterMode_;
	union {
		// Mode A:Gravity + Tangential Accel + Radial Accel
		struct {
			// gravity of the particles
			CGPoint gravity;

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
			} A;

		// Mode B: circular movement (gravity, radial accel and tangential accel don't are not used in this mode)
		struct {
	
			// Max radius at which particles are drawn when rotating
			float maxRadius;
			// Variance of the maxRadius
			float maxRadiusVar;
			// Radius from source below which a particle dies
			float minRadius;
			// Numeber of degress to rotate a particle around the source pos per second
			float rotatePerSecond;
			// Variance in degrees for rotatePerSecond
			float rotatePerSecondVar;
		} B;
	} mode;
	
	// start ize of the particles
	float startSize;
	// start Size variance
	float startSizeVar;
	// End size of the particle
	float endSize;
	// end size of variance
	float endSizeVar;
	
	// How many seconds will the particle live
	float life;
	// Life variance
	float lifeVar;
	
	// Start color of the particles
	ccColor4F startColor;
	// Start color variance
	ccColor4F startColorVar;
	// End color of the particles
	ccColor4F endColor;
	// End color variance
	ccColor4F endColorVar;
	
	// start angle of the particles
	float startSpin;
	// start angle variance
	float startSpinVar;
	// End angle of the particle
	float endSpin;
	// end angle ariance
	float endSpinVar;
	
	
	// Array of particles
	tCCParticle *particles;
	// Maximum particles
	int totalParticles;
	// Count of active particles
	int particleCount;
	
	// color modulate
	BOOL colorModulate;
	
	// How many particles can be emitted per second
	float emissionRate;
	float emitCounter;
	
	// Texture of the particles
	CCTexture2D *texture_;
	// blend function
	ccBlendFunc	blendFunc_;

	// movment type: free or grouped
	tCCPositionType	positionType_;

	// Whether or not the node will be auto-removed when there are not particles
	BOOL	autoRemoveOnFinish_;

	//  particle idx
	int particleIdx;
	
// profiling
#if CC_ENABLE_PROFILERS
	CCProfilingTimer* _profilingTimer;
#endif
}

/** Is the emitter active */
@property (nonatomic,readonly) BOOL active;
/** Quantity of particles that are being simulated at the moment */
@property (nonatomic,readonly) int	particleCount;
/** Gravity value */
@property (nonatomic,readwrite,assign) CGPoint gravity;
/** How many seconds the emitter wil run. -1 means 'forever' */
@property (nonatomic,readwrite,assign) float duration;
/** centerOfGravity of the emitter */
@property (nonatomic,readwrite,assign) CGPoint centerOfGravity;
/** Position variance of the emitter */
@property (nonatomic,readwrite,assign) CGPoint posVar;
/** life, and life variation of each particle */
@property (nonatomic,readwrite,assign) float life;
/** life variance of each particle */
@property (nonatomic,readwrite,assign) float lifeVar;
/** angle and angle variation of each particle */
@property (nonatomic,readwrite,assign) float angle;
/** angle variance of each particle */
@property (nonatomic,readwrite,assign) float angleVar;
/** speed of each particle */
@property (nonatomic,readwrite,assign) float speed;
/** speed variance of each particle */
@property (nonatomic,readwrite,assign) float speedVar;
/** tangential acceleration of each particle */
@property (nonatomic,readwrite,assign) float tangentialAccel;
/** tangential acceleration variance of each particle */
@property (nonatomic,readwrite,assign) float tangentialAccelVar;
/** radial acceleration of each particle */
@property (nonatomic,readwrite,assign) float radialAccel;
/** radial acceleration variance of each particle */
@property (nonatomic,readwrite,assign) float radialAccelVar;
/** start size in pixels of each particle */
@property (nonatomic,readwrite,assign) float startSize;
/** size variance in pixels of each particle */
@property (nonatomic,readwrite,assign) float startSizeVar;
/** end size in pixels of each particle */
@property (nonatomic,readwrite,assign) float endSize;
/** end size variance in pixels of each particle */
@property (nonatomic,readwrite,assign) float endSizeVar;
/** start color of each particle */
@property (nonatomic,readwrite,assign) ccColor4F startColor;
/** start color variance of each particle */
@property (nonatomic,readwrite,assign) ccColor4F startColorVar;
/** end color and end color variation of each particle */
@property (nonatomic,readwrite,assign) ccColor4F endColor;
/** end color variance of each particle */
@property (nonatomic,readwrite,assign) ccColor4F endColorVar;
//* initial angle of each particle
@property (nonatomic,readwrite,assign) float startSpin;
//* initial angle of each particle
@property (nonatomic,readwrite,assign) float startSpinVar;
//* initial angle of each particle
@property (nonatomic,readwrite,assign) float endSpin;
//* initial angle of each particle
@property (nonatomic,readwrite,assign) float endSpinVar;
/** emission rate of the particles */
@property (nonatomic,readwrite,assign) float emissionRate;
/** maximum particles of the system */
@property (nonatomic,readwrite,assign) int totalParticles;
/** conforms to CocosNodeTexture protocol */
@property (nonatomic,readwrite, retain) CCTexture2D * texture;
/** conforms to CocosNodeTexture protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;
/** whether or not the particles are using blend additive */
@property (nonatomic,readwrite) BOOL blendAdditive;
/** particles movement type: Free or Grouped
 @since v0.8
 */
@property (nonatomic,readwrite) tCCPositionType positionType;
/** whether or not the node will be auto-removed when it has no particles left.
 By default it is NO.
 @since v0.8
 */
@property (nonatomic,readwrite) BOOL autoRemoveOnFinish;
/** Switch between different kind of emitter modes:
  A: uses gravity, radial and tangential acceleration
  B: uses radial movement
 */
@property (nonatomic,readwrite) int emitterMode;

/** creates an initializes a CCQuadParticleSystem from a plist file.
 This plist files can be creted manually or with Particle Designer:
	http://www.71squared.com/
 @since v0.99.3
 */
+(id) particleWithFile:(NSString*)plistFile;

/** initializes a CCQuadParticleSystem from a plist file.
 This plist files can be creted manually or with Particle Designer:
	http://www.71squared.com/
 @since v0.99.3
 */
-(id) initWithFile:(NSString*) plistFile;

/** initializes a CCQuadParticleSystem from a NSDictionary.
 @since v0.99.3
 */
-(id) initWithDictionary:(NSDictionary*)dictionary;

//! Initializes a system with a fixed number of particles
-(id) initWithTotalParticles:(int) numberOfParticles;
//! Add a particle to the emitter
-(BOOL) addParticle;
//! Initializes a particle
-(void) initParticle: (tCCParticle*) particle;
//! stop emitting particles. Running particles will continue to run until they die
-(void) stopSystem;
//! Kill all living particles.
-(void) resetSystem;
//! whether or not the system is full
-(BOOL) isFull;

//! should be overriden by subclasses
-(void) updateQuadWithParticle:(tCCParticle*)particle position:(CGPoint)position;
//! should be overriden by subclasses
-(void) postStep;

@end

