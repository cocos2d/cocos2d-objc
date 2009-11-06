/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

#import "CCParticleSystem.h"

/** CCPointParticleSystem is a subclass of CCParticleSystem
 Attributes of a Particle System:
 * All the attributes of Particle System

 Features:
  * consumes small memory: uses 1 vertex (x,y) per particle, no need to assign tex coordinates
  * size can't be bigger than 64
  * the system can't be scaled since the particles are rendered using GL_POINT_SPRITE
 */
@interface CCPointParticleSystem : CCParticleSystem
{	
	// Array of (x,y,size) 
	ccPointSprite *vertices;
	// vertices buffer id
	GLuint	verticesID;	
}
@end

