/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Leonardo Kasperavičius
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCParticleSystem.h"

/** CCQuadParticleSystem is a subclass of CCParticleSystem

 It includes all the features of ParticleSystem.
 
 Special features and Limitations:
  - Particle size can be any float number.
  - The system can be scaled
  - The particles can be rotated
  - It is a bit slower that PointParticleSystem
  - It consumes more RAM and more GPU memory than PointParticleSystem
 @since v0.8
 */
@interface CCQuadParticleSystem : CCParticleSystem
{
	ccV2F_C4F_T2F_Quad	*quads;		// quads to be rendered
	GLushort			*indices;	// indices
	GLuint				quadsID;	// VBO id
}


// initialices the indices for the vertices
-(void) initIndices;
// initilizes the text coords
-(void) initTexCoords;


@end

