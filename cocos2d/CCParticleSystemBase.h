/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "CCProtocols.h"
#import "CCNode.h"
#import "ccTypes.h"
#import "ccConfig.h"

@class CCParticleBatchNode;
@class CCTexture;

/** The Particle emitter lives forever. */
#define CCParticleSystemDurationInfinity -1

/** The starting size of the particle is equal to the ending size. */
#define CCParticleSystemStartSizeEqualToEndSize -1

/** The starting radius of the particle is equal to the ending radius.  */
#define CCParticleSystemStartRadiusEqualToEndRadius -1

/** Particle system mode. */
typedef NS_ENUM(NSUInteger, CCParticleSystemMode) {
    
	/** Gravity mode (A mode). */
	CCParticleSystemModeGravity,

	/** Radius mode (B mode). */
	CCParticleSystemModeRadius,
};

/** Particle system position type. */
typedef NS_ENUM(NSUInteger, CCParticleSystemPositionType) {
    
	/** Living particles are attached to the world and are unaffected by emitter repositioning. */
	CCParticleSystemPositionTypeFree,

	/** Living particles are attached to the world but will follow the emitter repositioning.
	 Use case: Attach an emitter to an sprite, and you want that the emitter follows the sprite.
	 */
	CCParticleSystemPositionTypeRelative,

	/** Living particles are attached to the emitter and are translated along with it. */
	CCParticleSystemPositionTypeGrouped,
};

/** Contains the values of each individual particle. */
typedef struct _sCCParticle {
    
	GLKVector2		pos;
	GLKVector2		startPos;
    
	GLKVector4	color;
	GLKVector4	deltaColor;
    
	float		size;
	float		deltaSize;
    
	float		rotation;
	float		deltaRotation;
    
	float		timeToLive;
    
	NSUInteger	atlasIndex;
    
	union {
		// Mode A
		struct {
			GLKVector2		dir;
			float		radialAccel;
			float		tangentialAccel;
		} A;
        
		// Mode B
		struct {
			float		angle;
			float		degreesPerSecond;
			float		radius;
			float		deltaRadius;
		} B;
	} mode;
    
}_CCParticle;

typedef void (*_CC_UPDATE_PARTICLE_IMP)(id, SEL, _CCParticle*, CGPoint);

/** 
 Felxbile particle system.
 
 ### Attribute overview of a particle system
 
 - Gravity Mode (Mode A)
    - Gravity
    - Direction
    - Speed +-  variance
    - Tangential acceleration +- variance
    - Radial acceleration +- variance
 
 - Radius Mode (Mode B)
    - Start Radius +- variance
    - End Radius +- variance
    - Rotate +- variance
 
 - Properties common to all modes
    - Life +- variance
    - Start spin +- variance
    - End spin +- variance
    - Start size +- variance
    - End size +- variance
    - Start color +- variance
    - End color +- variance
    - Life +- variance
    - Blending function
 
 - Texture

 ### Supported editors
 
 - Particle Designer http://particledesigner.71squared.com/
 
 ### Notes
 
 cocos2d supports all the variables used by Particle Designer plus a bit more:
 
 - Spinning particles (supported when using CCParticleSystemQuad)
 - Tangential acceleration (Gravity mode)
 - Radial acceleration (Gravity mode)
 - Radius direction (Radius mode) (Particle Designer supports outwards to inwards direction only)

 */
@interface CCParticleSystemBase : CCNode <CCTextureProtocol, CCShaderProtocol, CCBlendProtocol>
{
	// True if the the particle system is active.
	BOOL _active;
    
	// Duration in seconds of the system. -1 is infinity.
	float _duration;
    
	// Time elapsed since the start of the system (in seconds).
	float _elapsed;

	// Position is from "superclass" CCNode.
	CGPoint _sourcePosition;
    
	// Position variance.
	CGPoint _posVar;

	// The angle (direction) of the particles measured in degrees.
	float _angle;
    
	// Angle variance measured in degrees.
	float _angleVar;

	// Different modes (Gravity or Radius)

	CCParticleSystemMode _emitterMode;
	union {
		// Mode A:Gravity + Tangential Accel + Radial Accel.
        
		struct {
			// Gravity of the particles.
			GLKVector2 gravity;

			// The speed the particles will have.
			float speed;
            
			// The speed variance.
			float speedVar;

			// Tangential acceleration.
			float tangentialAccel;
            
			// Tangential acceleration variance.
			float tangentialAccelVar;

			// Radial acceleration.
			float radialAccel;
            
			// Radial acceleration variance.
			float radialAccelVar;
            
			} A;

		// Mode B: circular movement (gravity, radial accel and tangential accel don't are not used in this mode).
		struct {

			// The starting radius of the particles.
			float startRadius;
            
			// The starting radius variance of the particles.
			float startRadiusVar;
            
			// The ending radius of the particles.
			float endRadius;
            
			// The ending radius variance of the particles.
			float endRadiusVar;
            
			// Number of degress to rotate a particle around the source pos per second.
			float rotatePerSecond;
            
			// Variance in degrees for rotatePerSecond.
			float rotatePerSecondVar;
            
		} B;
	} _mode;

	// Start ize of the particles.
	float _startSize;
    
	// Start Size variance.
	float _startSizeVar;
    
	// End size of the particle.
	float _endSize;
    
	// End size of variance.
	float _endSizeVar;

	// How many seconds will the particle live.
	float _life;
    
	// Life variance.
	float _lifeVar;

	// Start color of the particles.
	ccColor4F _startColor;
    
	// Start color variance.
	ccColor4F _startColorVar;
    
	// End color of the particles.
	ccColor4F _endColor;
    
	// End color variance.
	ccColor4F _endColorVar;

	// Start angle of the particles.
	float _startSpin;
    
	// Start angle variance.
	float _startSpinVar;
    
	// End angle of the particle.
	float _endSpin;
    
	// End angle ariance.
	float _endSpinVar;

	// Array of particles.
	_CCParticle *_particles;
    
	// Maximum particles.
	NSUInteger _totalParticles;
    
	// Count of active particles.
	NSUInteger _particleCount;
    
    // Number of allocated particles.
    NSUInteger _allocatedParticles;

	// How many particles can be emitted per second.
	float _emissionRate;
    
    // Particle emission counter.
	float _emitCounter;

	// Movment type: free or grouped.
	CCParticleSystemPositionType	_particlePositionType;

	// Whether or not the node will be auto-removed when there are not particles.
	BOOL	_autoRemoveOnFinish;

    // The particly system resetd upon visibility toggling to True.
    BOOL    _resetOnVisibilityToggle;
    
	// YES if scaled or rotated.
	BOOL _transformSystemDirty;
}


/// -----------------------------------------------------------------------
/// @name Accessing Particle Attributes
/// -----------------------------------------------------------------------

/** True if particle system active. */
@property (nonatomic,readonly) BOOL active;

/** Quantity of particles that are being simulated at the moment. */
@property (nonatomic,readonly) NSUInteger particleCount;

/** How many seconds the emitter wil run. -1 means 'forever'. */
@property (nonatomic,readwrite,assign) float duration;

/** The source position of the emitter. */
@property (nonatomic,readwrite,assign) CGPoint sourcePosition;

/** The Position variance of the emitter. */
@property (nonatomic,readwrite,assign) CGPoint posVar;

/** Life time of each particle. */
@property (nonatomic,readwrite,assign) float life;

/** Life variance of each particle. */
@property (nonatomic,readwrite,assign) float lifeVar;

/** Angle of each particle. */
@property (nonatomic,readwrite,assign) float angle;

/** Angle variance of each particle. */
@property (nonatomic,readwrite,assign) float angleVar;

/** Start size in pixels of each particle. */
@property (nonatomic,readwrite,assign) float startSize;

/** Size variance in pixels of each particle. */
@property (nonatomic,readwrite,assign) float startSizeVar;

/** End size in pixels of each particle. */
@property (nonatomic,readwrite,assign) float endSize;

/** End size variance in pixels of each particle. */
@property (nonatomic,readwrite,assign) float endSizeVar;

/** Start color of each particle. */
@property (nonatomic,readwrite,strong) CCColor* startColor;

/** Start color variance of each particle. */
@property (nonatomic,readwrite,strong) CCColor* startColorVar;

/** End color and end color variation of each particle. */
@property (nonatomic,readwrite,strong) CCColor* endColor;

/** End color variance of each particle. */
@property (nonatomic,readwrite,strong) CCColor* endColorVar;

/** Start spin of each particle. */
@property (nonatomic,readwrite,assign) float startSpin;

/** Start spin variance of each particle. */
@property (nonatomic,readwrite,assign) float startSpinVar;

/** End spin of each particle. */
@property (nonatomic,readwrite,assign) float endSpin;

/** End spin variance of each particle. */
@property (nonatomic,readwrite,assign) float endSpinVar;

/** Emission rate of the particles. */
@property (nonatomic,readwrite,assign) float emissionRate;

/** Maxmium particles of the system. */
@property (nonatomic,readwrite,assign) NSUInteger totalParticles;

/** True to enable blend additive mode. (GL_SRC_ALPHA, GL_ONE). */
@property (nonatomic,readwrite) BOOL blendAdditive;

/** Particles movement type: Free or Grouped. */
@property (nonatomic,readwrite) CCParticleSystemPositionType particlePositionType;

/** True will remove particle system on completition. */
@property (nonatomic,readwrite) BOOL autoRemoveOnFinish;

/** True particle system will reset upon visibility  toggling to True. */
@property (nonatomic,readwrite) BOOL resetOnVisibilityToggle;

/** Set emitter mode mechanism. */
@property (nonatomic,readwrite) CCParticleSystemMode emitterMode;


/// -----------------------------------------------------------------------
/// @name Accessing Gravity Mode Specific Attributes
/// -----------------------------------------------------------------------

/** Gravity value. Only available in 'Gravity' mode. */
@property (nonatomic,readwrite,assign) CGPoint gravity;

/** Speed of each particle. Only available in 'Gravity' mode.  */
@property (nonatomic,readwrite,assign) float speed;

/** Speed variance of each particle. Only available in 'Gravity' mode. */
@property (nonatomic,readwrite,assign) float speedVar;

/** Tangential acceleration of each particle. Only available in 'Gravity' mode. */
@property (nonatomic,readwrite,assign) float tangentialAccel;

/** Tangential acceleration variance of each particle. Only available in 'Gravity' mode. */
@property (nonatomic,readwrite,assign) float tangentialAccelVar;

/** Radial acceleration of each particle. Only available in 'Gravity' mode. */
@property (nonatomic,readwrite,assign) float radialAccel;

/** Radial acceleration variance of each particle. Only available in 'Gravity' mode. */
@property (nonatomic,readwrite,assign) float radialAccelVar;


/// -----------------------------------------------------------------------
/// @name Accessing Radius Mode Specific Attributes
/// -----------------------------------------------------------------------

/** The starting radius of the particles. Only available in 'Radius' mode. */
@property (nonatomic,readwrite,assign) float startRadius;

/** The starting radius variance of the particles. Only available in 'Radius' mode. */
@property (nonatomic,readwrite,assign) float startRadiusVar;

/** The ending radius of the particles. Only available in 'Radius' mode. */
@property (nonatomic,readwrite,assign) float endRadius;

/** The ending radius variance of the particles. Only available in 'Radius' mode. */
@property (nonatomic,readwrite,assign) float endRadiusVar;

/** Number of degress to rotate a particle around the source pos per second. Only available in 'Radius' mode. */
@property (nonatomic,readwrite,assign) float rotatePerSecond;

/** Variance in degrees for rotatePerSecond. Only available in 'Radius' mode. */
@property (nonatomic,readwrite,assign) float rotatePerSecondVar;


/// -----------------------------------------------------------------------
/// @name Creating a CCParticleSystem Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a particle system object from the specified plist source file.
 *
 *  @param plistFile Particle configuration file.
 *
 *  @return The CCParticleSystem Object.
 */
+(id) particleWithFile:(NSString*)plistFile;

/**
 *  Creates and returns an empty particle system object with the specified maxmium number of particles.
 *
 *  @param numberOfParticles Maximum particles.
 *
 *  @return The CCParticleSystem Object.
 */
+(id) particleWithTotalParticles:(NSUInteger) numberOfParticles;


/// -----------------------------------------------------------------------
/// @name Initializing a CCParticleSystem Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a particle system object from the specified plist source file.
 *
 *  @param plistFile Particle configuration file.
 *
 *  @return An initialized CCParticleSystem Object.
 */
-(id) initWithFile:(NSString*) plistFile;

/**
 *  Initializes and returns a particle system object from the specified dictionary.
 *
 *  @param dictionary Particle dictionary object.
 *
 *  @return An initialized CCParticleSystem Object.
 */
-(id) initWithDictionary:(NSDictionary*)dictionary;

/**
 *  Initializes and returns a particle system object from the specified dictionary and texture directory path values.
 *
 *  @param dictionary Particle dictionary object.
 *  @param dirname    Path to dictionary
 *
 *  @return An initialized CCParticleSystem Object.
 */
-(id) initWithDictionary:(NSDictionary *)dictionary path:(NSString*)dirname;

/**
 *  Initializes and returns an empty particle system object with the specified maxmium number of particles.
 *
 *  @param numberOfParticles Maximum particles.
 *
 *  @return An initialized CCParticleSystem Object.
 */
-(id) initWithTotalParticles:(NSUInteger) numberOfParticles;


/// -----------------------------------------------------------------------
/// @name Particle System Management
/// -----------------------------------------------------------------------

/** Stop emitting new particles, existing particles will die off. */
-(void) stopSystem;

/** Destroy all particles. */
-(void) resetSystem;

@end
