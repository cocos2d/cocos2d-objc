/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008 Radu Gruian
 * Copyright (c) 2011 Vit Valentin
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
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
 *
 *
 * Orignal code by Radu Gruian
 *
 * Adapted to cocos2d-x by Vit Valentin
 *
 * Adapted from cocos2d-x to cocos2d-iphone by Ricardo Quesada
 *
 */

#import "CCActionInterval.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     *  Returns the Cardinal Spline position for a given set of control points, tension and time.
     *
     *
     *  @param p0      Control point 0.
     *  @param p1      Control point 1.
     *  @param p2      Control point 2.
     *  @param p3      Control point 3.
     *  @param tension Tension.
     *  @param t       Normalized time.
     *
     *  @return A calculated cardinal spline point.
     */
    CGPoint CCCardinalSplineAt( CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, CGFloat tension, CCTime t );
    
#ifdef __cplusplus
}
#endif


#pragma mark - CCPointArray
/**
 A simple array containing CGPoint values wrapped in NSValue objects so they can be stored in an NSMutableArray.
 This class is only documented for reference.
 
 CCPointArray is used internally by the following spline movement actions:
 
 - CCActionCardinalSplineTo
 - CCActionCardinalSplineBy
 - CCActionCatmullRomTo
 - CCActionCatmullRomBy
 
 @note The documentation of this class is provided as reference only since the above actions expose it,
 and require a CCPointArray object as input. Except for those actions you should refrain from using this class.
 [It may be refactored](https://github.com/cocos2d/cocos2d-swift/issues/1089).
 */
@interface CCPointArray : NSObject <NSCopying> {
	NSMutableArray	*_controlPoints;
}

/*+ Array that contains the control points. */
@property (nonatomic,readwrite,strong) NSMutableArray *controlPoints;

/// -----------------------------------------------------------------------
/// @name Creating a Point Array
/// -----------------------------------------------------------------------

/**
 *  Creates and initializes a Points array with capacity.
 *
 *  @param capacity Capacity of the array.
 *
 *  @return New point array.
 *  @see initWithCapacity:
 */
+ (id)arrayWithCapacity:(NSUInteger)capacity;

/**
 *  Initializes a Points array with capacity.
 *
 *  @param capacity Capacity of the array.
 *
 *  @return New point array.
 *  @see arrayWithCapacity:
 */
- (id)initWithCapacity:(NSUInteger)capacity;


/// -----------------------------------------------------------------------
/// @name Adding and Removing Points
/// -----------------------------------------------------------------------

/**
 *  Appends a control point.
 *
 *  @param controlPoint Control point to append.
 */
- (void)addControlPoint:(CGPoint)controlPoint;

/**
 *  Inserts a controlPoint.
 *
 *  @param controlPoint Control point to insert.
 *  @param index        Index of point.
 */
- (void)insertControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index;

/**
 *  Replaces an existing control point.
 *
 *  @param controlPoint New control point.
 *  @param index        Index of point to replace.
 */
- (void)replaceControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index;

/**
 *  Deletes a control point.
 *
 *  @param index Index of control point to delete.
 */
- (void)removeControlPointAtIndex:(NSUInteger)index;

/// -----------------------------------------------------------------------
/// @name Accessing Points
/// -----------------------------------------------------------------------

/**
 *  Retrieves a control point.
 *
 *  @param index Index of control point to retrieve.
 *
 *  @return A control point.
 */
- (CGPoint)getControlPointAtIndex:(NSInteger)index;

/**
 *  Returns the number of control points in the array.
 *
 *  @return Number of control points.
 */
- (NSUInteger)count;

/// -----------------------------------------------------------------------
/// @name Reversing the Order of Points
/// -----------------------------------------------------------------------

/**
 *  Creates a new copy of the array, in reversed order. 
 *  User is responsible for releasing this array.
 *
 *  @return New point array.
 */
- (CCPointArray*)reverse;

/** Reverses the current control point array. */
- (void)reverseInline;

@end


#pragma mark - CCActionCardinalSplineTo
/** 
 *  Creates an action, based on a cardinal sline path.
 *  @see http://www.codeproject.com/Articles/30838/Overhauser-Catmull-Rom-Splines-for-Camera-Animatio.So
 *
 *  The spline calculates a 2D cardinal spline vector, based on the control points and applied tension.
 *  All cocos2d splines are based on tension. Splines based on tension, are guaranteed to pass through all control points.
 *
 * @note CCPointArray stores a series of CGPoint objects encoded as NSValue in a NSMutableArray.
 */
@interface CCActionCardinalSplineTo : CCActionInterval {
	CCPointArray	*_points;
	CGFloat			_deltaT;
	CGFloat			_tension;
	CGPoint			_previousPosition;
	CGPoint			_accumulatedDiff;
}

// Purposefully undocumented: Code doesn't handle a changing points array after the action was initially created.
/* The array of control points associated with the cardinal spline. */
@property (nonatomic,readwrite,strong) CCPointArray *points;

/** @name Creating a Spline Action */

/**
 *  Creates a cardinal spline action, based on control points and tension.
 *  A tension of 0, will return a curve following the straight lines in the point array.
 *  Increase value of tension to smooth out the curve.
 *
 *  @param duration Action duration.
 *  @param points   Points to use for spline.
 *  @param tension  The tension of the spline curve.
 *
 *  @return New spline action.
 *  @see CCPointArray
 */
+ (id)actionWithDuration:(CCTime)duration points:(CCPointArray*)points tension:(CGFloat)tension;

/**
 *  Initializes a cardinal spline action, based on control points and tension.
 *  A tension of 0, will return a curve following the straight lines in the point array.
 *  Increase value of tension to smooth out the curve.
 *
 *  @param duration Action duration.
 *  @param points   Points to use for spline.
 *  @param tension  The tension of the spline curve.
 *
 *  @return New spline action.
 *  @see CCPointArray
 */
- (id)initWithDuration:(CCTime)duration points:(CCPointArray*)points tension:(CGFloat)tension;

@end


#pragma mark - CCActionCardinalSplineBy
/** 
 *  Creates an action, based on a cardinal spline path.
 *
 *  Adds a start position to the spline.
 *  @note See CCActionCardinalSplineTo for further information.
 */
@interface CCActionCardinalSplineBy : CCActionCardinalSplineTo {
	CGPoint		_startPosition;
}

@end


#pragma mark - CCActionCatmullRomTo
/** 
 *  Creates an action, based on a catmull-rom spline path.
 *
 *  A Catmull Rom is a Cardinal Spline with a tension of 0.5.
 *  @note See CCActionCardinalSplineTo for further information.
 */
@interface CCActionCatmullRomTo : CCActionCardinalSplineTo

/** @name Creating a Spline Action */

/**
 *  Creates an action, performing a catmull-rom spline.
 *  This is similar to creating a cardinal spline, with a tension of 0.5.
 *
 *  @param dt     Action duration.
 *  @param points Points to use for spline.
 *
 *  @return New catmull-rom action.
 *  @see CCPointArray
 */
+ (id)actionWithDuration:(CCTime)dt points:(CCPointArray*)points;

/**
 *  Initializes an action, performing a catmull-rom spline.
 *  This is similar to creating a cardinal spline, with a tension of 0.5.
 *
 *  @param dt     Action duration.
 *  @param points Points to use for spline.
 *
 *  @return New catmull-rom action.
 *  @see CCPointArray
 */
- (id)initWithDuration:(CCTime)dt points:(CCPointArray*)points;

@end


#pragma mark - CCActionCatmullRomBy
/**
 *  Creates an action, based on a catmull-rom spline path.
 *
 *  A Catmull Rom is a Cardinal Spline with a tension of 0.5.
 *  @note See CCActionCardinalSplineTo for further information.
 */
@interface CCActionCatmullRomBy : CCActionCardinalSplineBy

/** @name Creating a Spline Action */

/**
 *  Creates an action, performing a catmull-rom spline.
 *  This is similar to creating a cardinal spline, with a tension of 0.5.
 *
 *  @param dt     Action duration.
 *  @param points Points to use for spline.
 *
 *  @return New catmull-rom action.
 *  @see CCPointArray
 */
+ (id)actionWithDuration:(CCTime)dt points:(CCPointArray*)points;

/**
 *  Initializes an action, performing a catmull-rom spline.
 *  This is similar to creating a cardinal spline, with a tension of 0.5.
 *
 *  @param dt     Action duration.
 *  @param points Points to use for spline.
 *
 *  @return New catmull-rom action.
 *  @see CCPointArray
 */
- (id)initWithDuration:(CCTime)dt points:(CCPointArray*)points;

@end
