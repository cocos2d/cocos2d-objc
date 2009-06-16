/* cocos2d for iPhone
 * http://www.cocos2d-iphone.org
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
 * Code based on Chipmunk's cpVect.h file
 */

/**
 @file
 CGPoint extensions based on Chipmunk's cpVect file.
 These extensions work both with CGPoint and cpVect.
 
 The "ccp" prefix means: "CoCos2d Point"
 
 Examples:
  - ccpAdd( ccp(1,1), ccp(2,2) ); // preferred cocos2d way
  - ccpAdd( CGPointMake(1,1), CGPointMake(2,2) ); // also ok but more verbose
  
  - cpvadd( cpv(1,1), cpv(2,2) ); // way of the chipmunk
  - ccpAdd( cpv(1,1), cpv(2,2) ); // mixing chipmunk and cocos2d (avoid)
  - cpvadd( CGPointMake(1,1), CGPointMake(2,2) ); // mixing chipmunk and CG (avoid)
 */


#import <CoreGraphics/CGGeometry.h>
#import <math.h>

#ifdef __cplusplus
extern "C" {
#endif	

/** Helper macro that creates a CGPoint
 @return CGPoint
 @since v0.7.2
 */
#define ccp(__X__,__Y__) CGPointMake(__X__,__Y__)


/** Returns opposite of point.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpNeg(const CGPoint v)
{
	return ccp(-v.x, -v.y);
}

/** Calculates sum of two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpAdd(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x + v2.x, v1.y + v2.y);
}

/** Calculates difference of two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpSub(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x - v2.x, v1.y - v2.y);
}

/** Returns point multiplied by given factor.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpMult(const CGPoint v, const CGFloat s)
{
	return ccp(v.x*s, v.y*s);
}

/** Calculates midpoint between two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpMidpoint(const CGPoint v1, const CGPoint v2)
{
	return ccpMult(ccpAdd(v1, v2), 0.5f);
}

/** Calculates dot product of two points.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
ccpDot(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

/** Calculates cross product of two points.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
ccpCross(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

/** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpPerp(const CGPoint v)
{
	return ccp(-v.y, v.x);
}

/** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpRPerp(const CGPoint v)
{
	return ccp(v.y, -v.x);
}

/** Calculates the projection of v1 over v2.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpProject(const CGPoint v1, const CGPoint v2)
{
	return ccpMult(v2, ccpDot(v1, v2)/ccpDot(v2, v2));
}

/** Rotates two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpRotate(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

/** Unrotates two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpUnrotate(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

/** Calculates the square length of a CGPoint (not calling sqrt() )
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
ccpLengthSQ(const CGPoint v)
{
	return ccpDot(v, v);
}

/** Calculates distance between point an origin
 @return CGFloat
 @since v0.7.2
 */
CGFloat ccpLength(const CGPoint v);

/** Calculates the distance between two points
 @return CGFloat
 @since v0.7.2
 */
CGFloat ccpDistance(const CGPoint v1, const CGPoint v2);

/** Returns point multiplied to a length of 1.
 @return CGPoint
 @since v0.7.2
 */
CGPoint ccpNormalize(const CGPoint v);

/** Converts radians to a normalized vector.
 @return CGPoint
 @since v0.7.2
 */
CGPoint ccpForAngle(const CGFloat a);

/** Converts a vector to radians.
 @return CGFloat
 @since v0.7.2
 */
CGFloat ccpToAngle(const CGPoint v);

#ifdef __cplusplus
}
#endif
