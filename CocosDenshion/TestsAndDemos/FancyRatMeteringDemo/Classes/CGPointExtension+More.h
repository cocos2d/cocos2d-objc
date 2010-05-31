///
//  CGPointExtension+More.h
//
//  Created by Lam Pham on 20/10/09.
///

#import <Foundation/Foundation.h>
#import "CGPointExtension.h"

#ifdef __cplusplus
extern "C" {
#endif	
	
#define kCGPointEpsilon		0.0001f
#define kInvalidFloat		FLT_MIN
	
	extern const CGPoint ccpX;
	extern const CGPoint ccpY;
	extern const CGPoint ccpOne;
	extern const CGPoint ccpInvalid;
	
	///
	//	Clamp a point between from and to.
	///
	CGPoint ccpClamp(CGPoint p, CGPoint from, CGPoint to);
	
	///
	//	Linear Interpolation between two points a and b
	//	@returns
	//		alpha == 0 ? a
	//		alpha == 1 ? b
	//		otherwise a value between a..b
	///
	CGPoint ccpLerp(CGPoint a, CGPoint b, float alpha);
	
	///
	//	Quickly convert CGSize to a CGPoint
	///
	CGPoint ccpFromSize(CGSize s);
	///
	//	Quickly convert CGPoint to a CGSize
	///
	CGSize ccSizeFromCCP(CGPoint s);
	
	///
	//	Point is valid
	///
	bool ccpIsValid(CGPoint p);
	
	///
	//	@returns if points have fuzzy equality which means equal with some degree
	//	of variance.
	///
	bool ccpFuzzyEqual(CGPoint a, CGPoint b, float variance);
	
	///
	//	Multiplies a nd b components, a.x*b.x, a.y*b.y
	//	@returns a component-wise multiplication
	///
	CGPoint ccpCompMult(CGPoint a, CGPoint b);
	
	///
	//	@returns the signed angle in radians between two points
	///
	float ccpAngleSigned(CGPoint a, CGPoint b);
	
	///
	//	@returns the angle in radians between two points
	///
	float ccpAngle(CGPoint a, CGPoint b);
	
	///
	//	Rotates a point counter clockwise by the angle around a pivot
	//	@param v is the point to rotate
	//	@param pivot is the pivot, naturally
	//	@param angle is the angle of rotation ccw in radians
	//	@returns the rotated point
	///
	CGPoint ccpRotateByAngle(CGPoint v, CGPoint pivot, float angle);
		
	///
	// A general line-line intersection test
	// @params p1 
	//		is the startpoint for the first line P1 = (p1 - p2)
	// @params p2 
	//		is the endpoint for the first line P1 = (p1 - p2)
	// @params p3 
	//		is the startpoint for the second line P2 = (p3 - p4)
	// @params p4 
	//		is the endpoint for the second line P2 = (p3 - p4)
	// @params s 
	//		is the range for a hitpoint in P1 (pa = p1 + s*(p2 - p1))
	// @params t
	//		is the range for a hitpoint in P3 (pa = p2 + t*(p4 - p3))
	// @return bool 
	//		indicating successful intersection of a line
	//		note that to truly test intersection for segments we have to make 
	//		sure that s & t lie within [0..1] and for rays, make sure s & t > 0
	//		the hit point is		p3 + t * (p4 - p3);
	//		the hit point also is	p1 + s * (p2 - p1);
	///
	bool ccpLineIntersect(CGPoint p1, CGPoint p2, 
									 CGPoint p3, CGPoint p4,
									 float *s, float *t);
#ifdef __cplusplus
}
#endif