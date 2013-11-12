//
//  OALAudioActions.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-10-10.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//

#import "OALAction.h"
#import "ALTypes.h"


#pragma mark -
#pragma mark Audio Property Actions

@interface OALPropertyAction (Audio)

+ (OALPropertyAction*) pitchActionWithDuration:(float) duration
                                      endValue:(float) endValue;

+ (OALPropertyAction*) pitchActionWithDuration:(float) duration
                                    startValue:(float) startValue
                                      endValue:(float) endValue;

+ (OALPropertyAction*) panActionWithDuration:(float) duration
                                    endValue:(float) endValue;

+ (OALPropertyAction*) panActionWithDuration:(float) duration
                                  startValue:(float) startValue
                                    endValue:(float) endValue;

+ (OALPropertyAction*) gainActionWithDuration:(float) duration
                                     endValue:(float) endValue;

+ (OALPropertyAction*) gainActionWithDuration:(float) duration
                                   startValue:(float) startValue
                                     endValue:(float) endValue;

@end

#pragma mark -
#pragma mark OALPlaceAction

/**
 * Places the target at the specified position.
 */
@interface OALPlaceAction : OALAction
{
	ALPoint position;
}


#pragma mark Properties

/** The position where the target will be placed. */
@property(nonatomic,readwrite,assign) ALPoint position;


#pragma mark Object Management

/** Create an action with the specified position.
 *
 * @param position The position to place the target at.
 * @return A new action.
 */
+ (id) actionWithPosition:(ALPoint) position;

/** Initialize an action with the specified position.
 *
 * @param position The position to place the target at.
 * @return The initialized action.
 */
- (id) initWithPosition:(ALPoint) position;

@end


#pragma mark -
#pragma mark OALMoveToAction

/**
 * Moves the target from its current position to the specified
 * position over time in 3D space.
 */
@interface OALMoveToAction : OALAction
{
	float unitsPerSecond;
	
	/** The point this move is starting at. */
	ALPoint startPoint;
	ALPoint position;
	
	/** The distance being moved. */
	ALPoint delta;
}

#pragma mark Properties

/** The position to move the target to. */
@property(nonatomic,readwrite,assign) ALPoint position;

/** The speed at which to move the target.
 * If this is 0, the target will be moved at the speed determined by duration.
 */
@property(nonatomic,readwrite,assign) float unitsPerSecond;


#pragma mark Object Management

/** Create a new action.
 *
 * @param duration The duration of the move.
 * @param position The position to move to.
 * @return A new action.
 */
+ (id) actionWithDuration:(float) duration position:(ALPoint) position;

/** Create a new action.
 *
 * @param unitsPerSecond The rate of movement.
 * @param position The position to move to.
 * @return A new action.
 */
+ (id) actionWithUnitsPerSecond:(float) unitsPerSecond position:(ALPoint) position;

/** Initialize an action.
 *
 * @param duration The duration of the move.
 * @param position The position to move to.
 * @return The initialized action.
 */
- (id) initWithDuration:(float) duration position:(ALPoint) position;

/** Initialize an action.
 *
 * @param unitsPerSecond The rate of movement.
 * @param position The position to move to.
 * @return The initialized action.
 */
- (id) initWithUnitsPerSecond:(float) unitsPerSecond position:(ALPoint) position;

@end


#pragma mark -
#pragma mark OALMoveByAction

/**
 * Moves the target from its current position by the specified
 * delta over time in 3D space.
 */
@interface OALMoveByAction : OALAction
{
	float unitsPerSecond;
	
	/** The point this move is starting at. */
	ALPoint startPoint;
	ALPoint delta;
}

#pragma mark Properties

/** The amount to move the target by. */
@property(nonatomic,readwrite,assign) ALPoint delta;

/** The speed at which to move the target.
 * If this is 0, the target will be moved at the speed determined by duration.
 */
@property(nonatomic,readwrite,assign) float unitsPerSecond;

/** Create a new action.
 *
 * @param duration The duration of the move.
 * @param delta The amount to move by.
 * @return A new action.
 */
+ (id) actionWithDuration:(float) duration delta:(ALPoint) delta;

/** Create a new action.
 *
 * @param unitsPerSecond The rate of movement.
 * @param delta The amount to move by.
 * @return A new action.
 */
+ (id) actionWithUnitsPerSecond:(float) unitsPerSecond delta:(ALPoint) delta;

/** Initialize an action.
 *
 * @param duration The duration of the move.
 * @param delta The amount to move by.
 * @return The initialized action.
 */
- (id) initWithDuration:(float) duration delta:(ALPoint) delta;

/** Initialize an action.
 *
 * @param unitsPerSecond The rate of movement.
 * @param delta The amount to move by.
 * @return The initialized action.
 */
- (id) initWithUnitsPerSecond:(float) unitsPerSecond delta:(ALPoint) delta;

@end
