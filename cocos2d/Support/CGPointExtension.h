/* cocos2d for iPhone
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (c) 2007 Scott Lembcke
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Code based on Chipmunk's CGPoint.h file
 */

/**
 @file
 CGPoint extentions based on Chipmunk's cpVect file.
 These extensions work both with CGPoint and cpVect.
 
 Examples:
  - CGPointAdd( CGPointMake(1,1), CGPointMake(2,2) );  // CG way (prefered way)
  - cpvadd( cpv(1,1), cpv(2,2) ); // chipmunk's way
  - CGPointAdd( cpv(1,1), cpv(2,2) );  // mixing chipmunk and CG (avoid)
  - cpvadd( CGPointMake(1,1), CGPointMake(2,2) );  // mixing chipmunk and CG (avoid)
 */


#import <CoreGraphics/CGGeometry.h>
#import <math.h>

/** Adds two CGPoint structures.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint CGPointAdd(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x + v2.x, v1.y + v2.y);
}

/** Negates a CGPoint structures.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointNeg(const CGPoint v)
{
	return CGPointMake(-v.x, -v.y);
}

/** Subtracts two CGPoint structures.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointSub(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x - v2.x, v1.y - v2.y);
}

/** Multiplies a CGPoint structure with an scalar.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointMult(const CGPoint v, const CGFloat s)
{
	return CGPointMake(v.x*s, v.y*s);
}

/** Calculates midpoint between two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointMidpoint(const CGPoint v1, const CGPoint v2)
{
	return CGPointMult(CGPointAdd(v1, v2), 0.5f);
}

/** Performs a dot product between two CGPoint structures.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
CGPointDot(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

/** Performs a cross product between two CGPoint structures.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
CGPointCross(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

/** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointPerp(const CGPoint v)
{
	return CGPointMake(-v.y, v.x);
}

/** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointRPerp(const CGPoint v)
{
	return CGPointMake(v.y, -v.x);
}

/** Calculates the projection of v1 over v2
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointProject(const CGPoint v1, const CGPoint v2)
{
	return CGPointMult(v2, CGPointDot(v1, v2)/CGPointDot(v2, v2));
}

/** Rotates two CGPoint structures.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointRotate(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

/** Unrotates tow CGPoint structures.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointUnrotate(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

/** Calculates the square length of a CGPoint (not calling sqrt() )
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
CGPointLengthSQ(const CGPoint v)
{
	return CGPointDot(v, v);
}

/** Calculates the length of a CGPoint
 @return CGFloat
 @since v0.7.2
 */
CGFloat CGPointLength(const CGPoint v);

/** Calculates the distance between 2 CGPoints
 @return CGFloat
 @since v0.7.2
 */
CGFloat CGPointDistance(const CGPoint v1, const CGPoint v2);

/** Normalizes a CGPoint
 @return CGPoint
 @since v0.7.2
 */
CGPoint CGPointNormalize(const CGPoint v);

/** Converts radians to a normalized vector
 @return CGPoint
 @since v0.7.2
 */
CGPoint CGPointForAngle(const CGFloat a);

/** Converts a vector to radians
 @return CGFloat
 @since v0.7.2
 */
CGFloat CGPointToAngle(const CGPoint v);

/** Gets a string representation of a vector
 @return char
 @since v0.7.2
 */
const char *CGPointToCString(const CGPoint v);
