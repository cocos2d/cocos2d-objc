/* Copyright (c) 2007 Scott Lembcke
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

#import <CoreGraphics/CGGeometry.h>

static inline CGPoint
CGPointAdd(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x + v2.x, v1.y + v2.y);
}

static inline CGPoint
CGPointNeg(const CGPoint v)
{
	return CGPointMake(-v.x, -v.y);
}

static inline CGPoint
CGPointSub(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x - v2.x, v1.y - v2.y);
}

static inline CGPoint
CGPointMult(const CGPoint v, const CGFloat s)
{
	return CGPointMake(v.x*s, v.y*s);
}

static inline CGFloat
CGPointDot(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

static inline CGFloat
CGPointCross(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

static inline CGPoint
CGPointPerp(const CGPoint v)
{
	return CGPointMake(-v.y, v.x);
}

static inline CGPoint
CGPointRPerp(const CGPoint v)
{
	return CGPointMake(v.y, -v.x);
}

static inline CGPoint
CGPointProject(const CGPoint v1, const CGPoint v2)
{
	return CGPointMult(v2, CGPointDot(v1, v2)/CGPointDot(v2, v2));
}

static inline CGPoint
CGPointRotate(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

static inline CGPoint
CGPointUnrotate(const CGPoint v1, const CGPoint v2)
{
	return CGPointMake(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

CGFloat CGPointLength(const CGPoint v);
CGFloat CGPointLengthSQ(const CGPoint v); // no sqrt() call
CGPoint CGPointNormalize(const CGPoint v);
CGPoint CGPointForAngle(const CGFloat a); // convert radians to a normalized vector
CGFloat CGPointToAngle(const CGPoint v); // convert a vector to radians
char *CGPointChar(const CGPoint v); // get a string representation of a vector
