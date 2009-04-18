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

@interface BigParticleSystem : ParticleSystem
{
	ccVertex3D *faces;		// the vertex coordinates
	ccTexCoord *texcoords;	// the texcoords values
	ccColorF	*colors;	// Array of colors
	
	GLuint	facesID;		// the face's id
	GLuint	texCoordsID;	// the texcoord's id
	GLuint	colorsID;		// colors buffer id
}

@end

