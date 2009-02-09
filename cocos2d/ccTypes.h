/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

//
// cocos (cc) types
//

//! RGB color composed of bytes. 3 chars
typedef struct _ccRGBB
{
	unsigned char	r;
	unsigned char	g;
	unsigned char	b;
} ccRGBB;

//! RGBA color composed of bytes. 4 chars
typedef struct _ccColorB
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} ccColorB;

//! RGBA color composed of floats. 4 floats
typedef struct _ccColorF {
	float r;
	float g;
	float b;
	float a;
} ccColorF;

//! Point Sprite attributes
typedef struct _ccPointSprite
{
	float x;
	float y;
	float size;
} ccPointSprite;

//!	A 2D Quad. 8 floats
typedef struct _ccQuad2 {
	float	tl_x, tl_y;
	float	tr_x, tr_y;
	float	bl_x, bl_y;
	float	br_x, br_y;
} ccQuad2;

//!	A 3D Quad. 12 floats
typedef struct _ccQuad3 {
	float	bl_x, bl_y, bl_z;
	float	br_x, br_y, br_z;
	float	tl_x, tl_y, tl_z;
	float	tr_x, tr_y, tr_z;
} ccQuad3;

//! A 3D vertex
typedef struct _ccVertex3D
{
	float x;
	float y;
	float z;
} ccVertex3D;

//! A 2D grid
typedef struct _ccGrid
{
	int	x;
	int	y;
} ccGrid;

static inline ccGrid
ccg(const int x, const int y)
{
	ccGrid v = {x, y};
	return v;
}


//! delta time type
//! if you want more resolution redefine it as a double
typedef float ccTime;
//typedef double ccTime;

