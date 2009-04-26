/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Leonardo Kasperavičius
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "ParticleSystem.h"

/** QuadParticleSystem is a subclass of ParticleSystem

 It includes all the features of ParticleSystem.
 
 Special features and Limitations:
  - Particle size can be any float number.
  - The system can be scaled
  - The particles can be rotated
  - It is a bit slower that PointParticleSystem
  - It consumes more RAM and more GPU memory than PointParticleSystem
 */
@interface QuadParticleSystem : ParticleSystem
{
	ccTexColorQuad	*quads;	// quads to be rendered
	GLushort	*indices;	// indices
	
	GLuint	quadsID;		// VBO id
}


// initialices the indices for the vertices
-(void) initIndices;
// initilizes the text coords
-(void) initTexCoords;


@end

