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

#import "types.h"

#define kLIVE (1 << 0)
typedef struct sParticle
{
	cpVect	pos;
	cpVect	dir;
	ColorF	color;
	ColorF	deltaColor;
	float	size;
	int		life;
	long	flags;
} Particle;

@class Texture2D;

@interface Emitter : NSObject
{
	int id;
	long flags;
	
	cpVect force;

	cpVect pos, posVar;
	float angle, angleVar;
	float speed, speedVar;
	float size, sizeVar;
	ColorF startColor, startColorVar;
	ColorF endColor, endColorVar;
	
	Particle *particles;
	int totalParticles;
	int particleCount;
	int emitsPerFrame, emitVar;
	int life, lifeVar;
}
// FLAGS
#define kRESPAWN ( 1 << 0 )

@property (readwrite,assign) cpVect pos;
@property (readwrite,assign) float angle;
@property (readwrite,assign) float angleVar;
@property (readwrite,assign) float speed;
@property (readwrite,assign) float speedVar;
@property (readwrite,assign) int emitsPerFrame;
@property (readwrite,assign) int emitVar;
@property (readwrite,assign) int totalParticles;


//! update the emitter
-(void) update;
//! Add a particle to the emitter
-(BOOL) addParticle;
//! Update a particle
-(BOOL) updateParticle: (Particle*) particle;
//! Initializes a particle
-(void) initParticle: (Particle*) particle;
//! Draws the particle
-(void) drawParticle: (Particle*) particle;
//! perform actions before all the particles are visited
-(void) preParticles;
//! perform actions after all the particles have been visited, like draw them
-(void) postParticles;
@end

@interface TextureEmitter : Emitter
{
	Texture2D *texture;
}
@end

@interface PixelEmitter : Emitter
{
}
@end

@interface EmitFireworks : PixelEmitter
{
}
@end

@interface EmitFire: TextureEmitter
{
}
@end


