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

#import <Availability.h>
#import <Foundation/Foundation.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <CoreGraphics/CGGeometry.h>	// for CGPoint
#endif


#ifdef __cplusplus
extern "C" {
#endif	
	
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

/** draws multiple lines in one draw call 
    @since 1.1
 */
void ccDrawLines( CGPoint* points, NSUInteger numberOfPoints );	

/** draws a rectangle given the origin and destination point measured in points. */
void ccDrawRect( CGPoint origin, CGPoint destination );

/** draws a solid rectangle given the origin and destination point measured in points.
    @since 1.1
 */
void ccDrawSolidRect( CGPoint origin, CGPoint destination );

/** draws a poligon given a pointer to CGPoint coordiantes and the number of vertices measured in points.
 The polygon can be closed or open
 */
void ccDrawPoly( const CGPoint *vertices, NSUInteger numOfVertices, BOOL closePolygon );

/** draws a solid poligon given a pointer to CGPoint coordiantes and the number of vertices measured in points.
 The polygon can be closed or open
    @since 1.1
 */
void ccDrawSolidPoly( const CGPoint *vertices, NSUInteger numOfVertices, BOOL closePolygon );

/** draws a circle given the center, radius and number of segments measured in points 
 */
void ccDrawCircle( CGPoint center, float radius, float angle, NSUInteger segments, BOOL drawLineToCenter);

/** draws a quad bezier path measured in points.
 @since v0.8
 */
void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments);

/** draws a cubic bezier path measured in points.
 @since v0.8
 */
void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments);

#ifdef __cplusplus
}
#endif

#endif //  __CC_DRAWING_PRIMITIVES_H
