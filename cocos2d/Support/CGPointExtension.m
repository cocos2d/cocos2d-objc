/* cocos2d for iPhone
 * http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2007 Scott Lembcke
 *
 * Copyright (c) 2010 Lam Pham
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

#include "stdio.h"
#include "math.h"

#import "../ccMacros.h"		// CC_SWAP
#include "CGPointExtension.h"

#define kCGPointEpsilon FLT_EPSILON

float clampf(float value, float min_inclusive, float max_inclusive)
{
	if (min_inclusive > max_inclusive) {
		CC_SWAP(min_inclusive,max_inclusive);
	}
	return value < min_inclusive ? min_inclusive : value < max_inclusive? value : max_inclusive;
}

CGPoint ccpClamp(CGPoint p, CGPoint min_inclusive, CGPoint max_inclusive)
{
	return ccp(clampf(p.x,min_inclusive.x,max_inclusive.x), clampf(p.y, min_inclusive.y, max_inclusive.y));
}

CGPoint ccpFromSize(CGSize s)
{
	return ccp(s.width, s.height);
}

CGPoint ccpCompOp(CGPoint p, float (*opFunc)(float))
{
	return ccp(opFunc(p.x), opFunc(p.y));
}

BOOL ccpFuzzyEqual(CGPoint a, CGPoint b, float var)
{
	if(a.x - var <= b.x && b.x <= a.x + var)
		if(a.y - var <= b.y && b.y <= a.y + var)
			return true;
	return false;
}

CGPoint ccpCompMult(CGPoint a, CGPoint b)
{
	return ccp(a.x * b.x, a.y * b.y);
}

float ccpAngleSigned(CGPoint a, CGPoint b)
{
	CGPoint a2 = ccpNormalize(a);
	CGPoint b2 = ccpNormalize(b);
	float angle = atan2f(a2.x * b2.y - a2.y * b2.x, ccpDot(a2, b2));
	if( fabs(angle) < kCGPointEpsilon ) return 0.f;
	return angle;
}

CGPoint ccpRotateByAngle(CGPoint v, CGPoint pivot, float angle)
{
	CGPoint r = ccpSub(v, pivot);
	float cosa = cosf(angle), sina = sinf(angle);
	float t = r.x;
	r.x = t*cosa - r.y*sina + pivot.x;
	r.y = t*sina + r.y*cosa + pivot.y;
	return r;
}


BOOL ccpSegmentIntersect(CGPoint A, CGPoint B, CGPoint C, CGPoint D)
{
	float S, T;

	if( ccpLineIntersect(A, B, C, D, &S, &T )
	   && (S >= 0.0f && S <= 1.0f && T >= 0.0f && T <= 1.0f) )
		return YES;

	return NO;
}

CGPoint ccpIntersectPoint(CGPoint A, CGPoint B, CGPoint C, CGPoint D)
{
	float S, T;

	if( ccpLineIntersect(A, B, C, D, &S, &T) ) {
		// Point of intersection
		CGPoint P;
		P.x = A.x + S * (B.x - A.x);
		P.y = A.y + S * (B.y - A.y);
		return P;
	}

	return CGPointZero;
}

BOOL ccpLineIntersect(CGPoint A, CGPoint B,
					  CGPoint C, CGPoint D,
					  float *S, float *T)
{
	// FAIL: Line undefined
	if ( (A.x==B.x && A.y==B.y) || (C.x==D.x && C.y==D.y) ) return NO;

	const float BAx = B.x - A.x;
	const float BAy = B.y - A.y;
	const float DCx = D.x - C.x;
	const float DCy = D.y - C.y;
	const float ACx = A.x - C.x;
	const float ACy = A.y - C.y;

	const float denom = DCy*BAx - DCx*BAy;

	*S = DCx*ACy - DCy*ACx;
	*T = BAx*ACy - BAy*ACx;

	if (denom == 0) {
		if (*S == 0 || *T == 0) {
			// Lines incident
			return YES;
		}
		// Lines parallel and not incident
		return NO;
	}

	*S = *S / denom;
	*T = *T / denom;

	// Point of intersection
	// CGPoint P;
	// P.x = A.x + *S * (B.x - A.x);
	// P.y = A.y + *S * (B.y - A.y);

	return YES;
}

float ccpAngle(CGPoint a, CGPoint b)
{
	float angle = acosf(ccpDot(ccpNormalize(a), ccpNormalize(b)));
	if( fabs(angle) < kCGPointEpsilon ) return 0.f;
	return angle;
}

@implementation NSValue (CCValue)

+ (NSValue *)valueWithCGPoint:(CGPoint)point
{
    return [NSValue value:&point withObjCType:@encode(CGPoint)];
}

+ (NSValue *)valueWithCGRect:(CGRect)rect
{
    return [NSValue value:&rect withObjCType:@encode(CGRect)];
}

+ (NSValue *)valueWithCGSize:(CGSize)size
{
    return [NSValue value:&size withObjCType:@encode(CGSize)];
}

+ (NSValue *)valueWithCGAffineTransform:(CGAffineTransform)transform
{
    return [NSValue value:&transform withObjCType:@encode(CGAffineTransform)];
}

- (CGPoint)CGPointValue
{
	CGPoint pt = CGPointZero;
    [self getValue:&pt];
    return pt;
}

- (CGRect)CGRectValue
{
    CGRect r = CGRectZero;
    [self getValue:&r];
    return r;
}

- (CGSize)CGSizeValue
{
	CGSize sz = CGSizeZero;
    [self getValue:&sz];
    return sz;
}

- (CGAffineTransform)CGAffineTransformValue
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    [self getValue:&transform];
    return transform;
}

@end


