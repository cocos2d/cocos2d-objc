/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008 Radu Gruian
 *
 * Copyright (c) 2011 Vit Valentin
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
 * Orignal code by Radu Gruian: http://www.codeproject.com/Articles/30838/Overhauser-Catmull-Rom-Splines-for-Camera-Animatio.So
 *
 * Adapted to cocos2d-x by Vit Valentin
 *
 * Adapted from cocos2d-x to cocos2d-iphone by Ricardo Quesada
 */


#import "CCActionInterval.h"

/** @CatmullRom configuration class
 */
@interface CCCatmullRomConfig : NSObject <NSCopying>
{
	NSMutableArray *controlPoints_;
}

/** Array that contains the control points */
@property (nonatomic,readwrite,retain) NSMutableArray *controlPoints;

/** creates and initializes a Catmull Rom config with a capacity hint */
+(id) configWithCapacity:(NSUInteger)capacity;

/** initializes a Catmull Rom config with a capacity hint */
-(id) initWithCapacity:(NSUInteger)capacity;

/** appends a control point */
-(void) addControlPoint:(CGPoint)controlPoint;

/** inserts a controlPoint at index */
-(void) insertControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index;

/** replaces an existing controlPoint at index */
-(void) replaceControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index;

/** get the value of a controlPoint at a given index */
-(CGPoint) getControlPointAtIndex:(NSInteger)index;

/** deletes a control point at a given index */
-(void) removeControlPointAtIndex:(NSUInteger)index;

/** returns the number of objects of the control point array */
-(NSUInteger) count;

/** returns a new copy of the array reversed. User is responsible for releasing this copy */
-(CCCatmullRomConfig*) reverse;

/** reverse the current control point array inline, without generating a new one */
-(void) reverseInline;
@end

/** An action that moves the target with a CatmullRom curve to a destination point. */
@interface CCCatmullRomTo : CCActionInterval
{
	CCCatmullRomConfig	*configuration_;
	CGFloat				deltaT_;
}
/** CatmullRom configuration */
@property (nonatomic,readwrite,retain) CCCatmullRomConfig *configuration;

/** creates an action with a CatmullRom configuration */
+(id) actionWithDuration:(ccTime)dt configuration:(CCCatmullRomConfig*)config;

/** initializes the action with a duration and a CatmullRom configuration */
-(id) initWithDuration:(ccTime)dt configuration:(CCCatmullRomConfig*)config;
@end

/** An action that moves the target with a CatmullRom curve by a certain distance. */
@interface CCCatmullRomBy : CCCatmullRomTo
{
	CGPoint				startPosition_;
}
@end

/** Returns the Catmull Rom position for a given set of points and time */
CGPoint ccCatmullRomAt( CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, ccTime t );
