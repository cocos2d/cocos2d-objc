/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#ifndef __CC_DRAWING_PRIMITIVES_H
#define __CC_DRAWING_PRIMITIVES_H

#import <Foundation/Foundation.h>

#import "ccTypes.h"
#import "ccMacros.h"

#ifdef __CC_PLATFORM_IOS
#import <CoreGraphics/CGGeometry.h>	// for CGPoint
#endif


#ifdef __cplusplus
extern "C" {
#endif

@class CCPointArray;

	
/**
 @file
 Drawing OpenGL ES primitives.
  - ccDrawPoint
  - ccDrawLine
  - ccDrawPoly
  - ccDrawCircle
  - ccDrawQuadBezier
  - ccDrawCubicBezier

 You can change the color, width and other property by calling the
   glColor4ub(), glLineWidth(), glPointSize().

 @warning These functions draws the Line, Point, Polygon, immediately. They aren't batched. If you are going to make a game that depends on these primitives, I suggest creating a batch.
 */


/** draws a point given x and y coordinate measured in points. */
void ccDrawPoint( CGPoint point );

/** draws an array of points.
 @since v0.7.2
 */
void ccDrawPoints( const CGPoint *points, NSUInteger numberOfPoints );

/** draws a line given the origin and destination point measured in points. */
void ccDrawLine( CGPoint origin, CGPoint destination );

/** draws a rectangle given the origin and destination point measured in points. */
void ccDrawRect( CGPoint origin, CGPoint destination );

/** draws a solid rectangle given the origin and destination point measured in points.
    @since 1.1
 */
void ccDrawSolidRect( CGPoint origin, CGPoint destination, ccColor4F color );

/** draws a poligon given a pointer to CGPoint coordiantes and the number of vertices measured in points.
 The polygon can be closed or open
 */
void ccDrawPoly( const CGPoint *vertices, NSUInteger numOfVertices, BOOL closePolygon );

/** draws a solid polygon given a pointer to CGPoint coordiantes, the number of vertices measured in points, and a color.
 */
void ccDrawSolidPoly( const CGPoint *poli, NSUInteger numberOfPoints, ccColor4F color );
    
/** draws a circle given the center, radius and number of segments measured in points */
void ccDrawCircle( CGPoint center, float radius, float angle, NSUInteger segments, BOOL drawLineToCenter);

/** draws a quad bezier path measured in points.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 @since v0.8
 */
void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments);

/** draws a cubic bezier path measured in points.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 @since v0.8
 */
void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments);

/** draws a Catmull Rom path.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 @since v2.0
 */
void ccDrawCatmullRom( CCPointArray *arrayOfControlPoints, NSUInteger segments );

/** draws a Cardinal Spline path.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 @since v2.0
 */
void ccDrawCardinalSpline( CCPointArray *config, CGFloat tension,  NSUInteger segments );

/** set the drawing color with 4 unsigned bytes
 @since v2.0
 */
void ccDrawColor4B( GLubyte r, GLubyte g, GLubyte b, GLubyte a );

/** set the drawing color with 4 floats
 @since v2.0
 */
void ccDrawColor4F( GLfloat r, GLfloat g, GLfloat b, GLfloat a );

/** set the point size in points. Default 1.
 @since v2.0
 */
void ccPointSize( GLfloat pointSize );


#ifdef __cplusplus
}
#endif

#endif //  __CC_DRAWING_PRIMITIVES_H
