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

/** Big Particle System class
 Attributes of a Particle System:
 * All the attributes of Particle System
 
 Features and Limitations:
 * Size can be any float number.
 * The system can be scaled
 * It is a little bit slower than Particle System since it renders each particle using 4 quads instead of 1
 */
@interface BigParticleSystem : ParticleSystem
{
	ccVertex3D *faces;		// the vertex coordinates
	ccTexCoord *texcoords;	// the texcoords values
	ccColorF	*colors;	// Array of colors
	GLushort	*indices;	// indices
	
	GLuint	facesID;		// the face's id
	GLuint	texCoordsID;	// the texcoord's id
	GLuint	colorsID;		// colors buffer id
}

// initialices the indices for the vertices
-(void) initIndices;
// initilizes the text coords
-(void) initTexCoords;
@end

