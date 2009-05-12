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

/**
 @file
 cocos2d (cc) types
*/

/** RGB color composed of bytes 3 bytes
@since v0.8
 */
typedef struct _ccColor3B
{
	unsigned char	r;
	unsigned char	g;
	unsigned char	b;
} ccColor3B;

/** RGBA color composed of 4 bytes
@since v0.8
*/
typedef struct _ccColor4B
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} ccColor4B;

/** RGBA color composed of 4 floats
@since v0.8
*/
typedef struct _ccColor4F {
	float r;
	float g;
	float b;
	float a;
} ccColor4F;

/** A vertex composed of 2 floats: x, y
 @since v0.8
 */
#define ccVertex2F CGPoint

/** A vertex composed of 2 floats: x, y
 @since v0.8
 */
typedef struct _ccVertex3F
{
		float x;
		float y;
		float z;
} ccVertex3F;
		
/** A texcoord composed of 2 floats: u, y
 @since v0.8
 */
typedef struct _ccTex2F {
	 float u;
	 float v;
} ccTex2F;

 
//! Point Sprite attributes
typedef struct _ccPointSprite
{
	ccVertex2F	pos;
	float		size;
	ccColor4F	colors;
} ccPointSprite;

//!	A 2D Quad. 4 * 2 floats
typedef struct _ccQuad2 {
	ccVertex2F		tl;
	ccVertex2F		tr;
	ccVertex2F		bl;
	ccVertex2F		br;
} ccQuad2;


//!	A 3D Quad. 4 * 3 floats
typedef struct _ccQuad3 {
	ccVertex3F		bl;
	ccVertex3F		br;
	ccVertex3F		tl;
	ccVertex3F		tr;
} ccQuad3;

//! A 2D grid size
typedef struct _ccGridSize
{
	int	x;
	int	y;
} ccGridSize;

//! helper function to create a ccGridSize
static inline ccGridSize
ccg(const int x, const int y)
{
	ccGridSize v = {x, y};
	return v;
}

//! a Point with a vertex point, a tex coord point and a color
typedef struct _ccTexColorPoint
{
	ccVertex2F		vertices;
	ccTex2F			texCoords;
	ccColor4F		colors;
} ccTexColorPoint;

//! 4 ccTexColorPoint.
typedef struct _ccTexColorQuad
{
	ccTexColorPoint	point[4];
} ccTexColorQuad;

//! delta time type
//! if you want more resolution redefine it as a double
typedef float ccTime;
//typedef double ccTime;

