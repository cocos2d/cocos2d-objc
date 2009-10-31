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

#ifndef __CC_DRAWING_PRIMITIVES_H
#define __CC_DRAWING_PRIMITIVES_H

#ifdef __cplusplus
extern "C" {
#endif	
	
/**
 @file
 Drawing OpenGL ES primitives.
  - drawPoint
  - drawLine
  - drawPoly
  - drawCircle
 
 You can change the color, width and other property by calling the
 glColor4ub(), glLineWitdh(), glPointSize().
 
 @warning These functions draws the Line, Point, Polygon, immediately. They aren't batched. If you are going to make a game that depends on these primitives, I suggest creating a batch.
 */

#import <CoreGraphics/CGGeometry.h>	// for CGPoint
#import <objc/objc.h>				// for BOOL

/** draws a point given x and y coordinate */
void ccDrawPoint( CGPoint point );

/** draws an array of points.
 @since v0.7.2
 */
void ccDrawPoints( CGPoint *points, unsigned int numberOfPoints );

/** draws a line given the origin and destination point */
void ccDrawLine( CGPoint origin, CGPoint destination );

/** draws a poligon given a pointer to CGPoint coordiantes and the number of vertices. The polygon can be closed or open
 */
void ccDrawPoly( CGPoint *vertices, int numOfVertices, BOOL closePolygon );

/** draws a circle given the center, radius and number of segments. */
void ccDrawCircle( CGPoint center, float radius, float angle, int segments, BOOL drawLineToCenter);

/** draws a quad bezier path
 @since v0.8
 */
void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, int segments);

/** draws a cubic bezier path
 @since v0.8
 */
void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, int segments);

#ifdef __cplusplus
}
#endif

#endif //  __CC_DRAWING_PRIMITIVES_H
