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

//
// cocos (cc) types
//

//! RGBA color composed of bytes
typedef struct _ccColorB
{
	char r;
	char g;
	char b;
	char a;
} ccColorB;

//! RGBA color composed of floats
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

//!	A 2D Quad. 8 floats.
typedef struct sQuad2 {
	float	lb_x, lb_y;
	float	rb_x, rb_y;
	float	tr_x, tr_y;
	float tl_x, tl_y;
} ccQuad2;

//!	A 3D Quad. 12 floats.
typedef struct sQuad3 {
	float	lb_x, lb_y, lb_z;
	float	rb_x, rb_y, rb_z;
	float	tr_x, tr_y, tr_z;
	float tl_x, tl_y, tl_z;
} ccQuad3;


//! delta time type
typedef float ccTime;
//typedef double ccTime;

