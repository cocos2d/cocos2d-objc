/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Nader Eloshaiker
 * Copyright (c) 2013-2014 Cocos2D Authors
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


/*
 *
 * IMPORTANT       IMPORTANT        IMPORTANT        IMPORTANT 
 *
 *
 * LEGACY FUNCTIONS
 *
 * USE CCDrawNode instead
 *
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

#import "CCColor.h"
@class CCPointArray;
	
/**
 @file
 Drawing OpenGL ES primitives.
  - ccDrawPoint, ccDrawPoints
  - ccDrawLine
  - ccDrawRect, ccDrawSolidRect
  - ccDrawPoly, ccDrawSolidPoly
  - ccDrawCircle, ccDrawSolidCircle 
  - ccDrawArc, ccDrawSolidArc
  - ccDrawQuadBezier
  - ccDrawCubicBezier
  - ccDrawCatmullRom
  - ccDrawCardinalSpline

 You can change the color, point size, width by calling:
  - ccDrawColor4B(), ccDrawColor4F()
  - ccPointSize()
  - glLineWidth()

 @warning These functions draws the Line, Point, Polygon, immediately. They aren't batched. If you are going to make a game that depends on these primitives, I suggest creating a batch. Instead you should use CCDrawNode
 
 */


/** Initializes the drawing primitives */
void ccDrawInit(void);

/** Frees allocated resources by the drawing primitives */
void ccDrawFree(void);

/** draws a point given x and y coordinate measured in points. */
void ccDrawPoint( CGPoint point );

/** draws an array of points.
 */
void ccDrawPoints( const CGPoint *points, NSUInteger numberOfPoints );

/** draws a line given the origin and destination point measured in points. */
void ccDrawLine( CGPoint origin, CGPoint destination );

/** draws a rectangle given the origin and destination point measured in points. */
void ccDrawRect( CGPoint origin, CGPoint destination );

/** draws a solid rectangle given the origin and destination point measured in points.
 */
void ccDrawSolidRect( CGPoint origin, CGPoint destination, CCColor* color );

/** draws a polygon given a pointer to CGPoint coordinates and the number of vertices measured in points.
 The polygon can be closed or open
 */
void ccDrawPoly( const CGPoint *vertices, NSUInteger numOfVertices, BOOL closePolygon );

/** draws a solid polygon given a pointer to CGPoint coordinates, the number of vertices measured in points, and a color.
 */
void ccDrawSolidPoly( const CGPoint *poli, NSUInteger numberOfPoints, CCColor* color );
    
/** draws a circle given the center, radius and number of segments measured in points */
void ccDrawCircle( CGPoint center, float radius, float angle, NSUInteger segments, BOOL drawLineToCenter);

/** draws a solid circle given the center, radius and number of segments measured in points */
void ccDrawSolidCircle( CGPoint center, float radius, NSUInteger segments);
    
/** draws a arc given the center, radius, arc length and number of segments measured in points */
void ccDrawArc(CGPoint center, CGFloat r, CGFloat a, CGFloat arcLength, NSUInteger segs, BOOL drawLineToCenter);

/** draws a solid arc given the center, radius, arc length and number of segments measured in points */
void ccDrawSolidArc(CGPoint center, CGFloat r, CGFloat a, CGFloat arcLength, NSUInteger segs);

/** draws a quad bezier path measured in points.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 */
void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments);

/** draws a cubic bezier path measured in points.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 */
void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments);

/** draws a Catmull Rom path.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 */
void ccDrawCatmullRom( CCPointArray *arrayOfControlPoints, NSUInteger segments );

/** draws a Cardinal Spline path.
 @warning This function could be pretty slow. Use it only for debugging purposes.
 */
void ccDrawCardinalSpline( CCPointArray *config, CGFloat tension,  NSUInteger segments );

/** set the drawing color with 4 unsigned bytes
 */
void ccDrawColor4B( GLubyte r, GLubyte g, GLubyte b, GLubyte a );

/** set the drawing color with 4 floats
 */
void ccDrawColor4F( GLfloat r, GLfloat g, GLfloat b, GLfloat a );

/** set the point size in points. Default 1.
 */
void ccPointSize( GLfloat pointSize );


#ifdef __cplusplus
}
#endif

#endif //  __CC_DRAWING_PRIMITIVES_H
