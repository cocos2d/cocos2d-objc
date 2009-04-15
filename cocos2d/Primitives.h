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
 Drawing OpenGL ES primitives.
  - drawPoint
  - drawLine
  - drawPoly
  - drawCircle
 
 You can change the color, width and other property by calling the
 glColor4ub(), glLineWitdh(), etc..
 
 @warning These functions draws the Line, Point, Polygon, immediately. They aren't batched. If you are going to make a game that depends on these primitives, I suggest creating a batch.
 */

#import <CoreGraphics/CGGeometry.h>	// for CGPoint
#import <objc/objc.h>				// for BOOL

/** draws a point given point.
 @deprecated Use drawPoint() instead. Will be removed in v0.8
 */
void drawPointDeprecated( float x, float y ) __attribute__((deprecated));

/** draws a point given x and y coordinate */
void drawPoint( CGPoint point );

/** draws a line given x1,y1 and x2,y2 coordinates
@deprecated Use drawLine() instead. Will be removed in v0.8
*/
void drawLineDeprecated(float x1, float y1, float x2, float y2) __attribute__((deprecated));

/** draws a line given the origin and destination point */
void drawLine( CGPoint origin, CGPoint destination );

/** draws a poligon given a pointer to float coordiantes and the number of vertices
 @deprecated Use drawPoly(vertices, numOfVertices, open) instead
 */
void drawPolyDeprecated( float *poli, int points ) __attribute__((deprecated));

/** draws a poligon given a pointer to CGPoint coordiantes and the number of vertices. The polygon can be closed or open
 */
void drawPoly( CGPoint *vertices, int numOfVertices, BOOL openPolygon );

/** draws a circle given the center, radius and number of segments.
 @deprecated Use drawCircle() instead. Will be removed in v0.8
 */
void drawCircleDeprecated( float x, float y, float radius, float angle, int segs) __attribute__((deprecated));

/** draws a circle given the center, radius and number of segments. */
void drawCircle( CGPoint center, float radius, float angle, int segments, BOOL drawLineToCenter);
