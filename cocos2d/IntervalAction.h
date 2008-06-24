/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import "Action.h"

#include <sys/time.h>

/** An interval action is an action that takes place within a certain period of time.
It has an start time, and a finish time. The finish time is the parameter
duration plus the start time.

These IntervalAction actions have some interesting properties, like:
 - They can run normally (default)
 - They can run reversed with the Reverse action.
 - They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.

For example, you can simulate a Ping Pong effect running the action normally and
then running it again in Reverse mode.

Example:
 
	Action * pingPongAction = [Sequence actions: action, [action reverse], nil];
*/
@interface IntervalAction: Action <NSCopying>
{
	struct timeval lastUpdate;
	double elapsed;
	//! duration in seconds
	double duration;
}

@property (readwrite,assign) double duration;

/** creates the action */
+(id) actionWithDuration: (double) d;
/** initializes the action */
-(id) initWithDuration: (double) d;
-(void) step;
/** called when the action is about to start */
-(void) start;
/** returns YES if the action has finished */
-(BOOL) isDone;
-(double) getDeltaTime;
/** returns a reversed action */
- (IntervalAction*) reverse;
@end

/** Runs actions sequentially, one after another
 */
@interface Sequence : IntervalAction <NSCopying>
{
	NSArray *actions;
	double split;
	int last;
}
/** helper contructor to create an array of sequenceable actions */
+(id) actions: (IntervalAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the action */
+(id) actionOne: (IntervalAction*) one two:(IntervalAction*) two;
/** initializes the action */
-(id) initOne: (IntervalAction*) one two:(IntervalAction*) two;
@end


/** Repeats an action a number of times
 */
@interface Repeat : IntervalAction <NSCopying>
{
	unsigned int times;
	unsigned int total;
	IntervalAction *other;
}
/** creates the action */
+(id) actionWithAction: (IntervalAction*) action times: (unsigned int) t;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action times: (unsigned int) t;
@end

/** Spawn a new action immediately
 */
@interface Spawn : IntervalAction <NSCopying>
{
	IntervalAction *one;
	IntervalAction *two;
}
/** helper constructor to create an array of spawned actions */
+(id) actions: (IntervalAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the action */
+(id) actionOne: (IntervalAction*) one two:(IntervalAction*) two;
/** initializes the action */
-(id) initOne: (IntervalAction*) one two:(IntervalAction*) two;
@end

/**  Rotates a `CocosNode` object to a certain angle by modifying it's
 rotation attribute.
 The direction will be decided by the shortest angle.
*/ 
@interface RotateTo : IntervalAction <NSCopying>
{
	float angle;
	float startAngle;
}
/** creates the action */
+(id) actionWithDuration: (double) t angle:(float) a;
/** initializes the action */
-(id) initWithDuration: (double) t angle:(float) a;
@end

/** Rotates a CocosNode object clockwise a number of degrees by modiying it's rotation attribute.
*/
@interface RotateBy : IntervalAction <NSCopying>
{
	float angle;
	float startAngle;
}
/** creates the action */
+(id) actionWithDuration: (double) t angle:(float) a;
/** initializes the action */
-(id) initWithDuration: (double) t angle:(float) a;
@end

/** Moves a CocosNode object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
*/
@interface MoveTo : IntervalAction <NSCopying>
{
	CGPoint endPosition;
	CGPoint startPosition;
	CGPoint delta;
}
/** creates the action */
+(id) actionWithDuration: (double) t position: (CGPoint) pos;
/** initializes the action */
-(id) initWithDuration: (double) t position: (CGPoint) pos;
@end

/**  Moves a CocosNode object x,y pixels by modifying it's position attribute.
 x and y are relative to the position of the object.
 Duration is is seconds.
*/ 
@interface MoveBy : MoveTo <NSCopying>
{
}
/** creates the action */
+(id) actionWithDuration: (double) t delta: (CGPoint) delta;
/** initializes the action */
-(id) initWithDuration: (double) t delta: (CGPoint) delta;
@end

/** Moves a CocosNode object simulating a jump movement by modifying it's position attribute.
*/
 @interface JumpBy : IntervalAction <NSCopying>
{
	CGPoint startPosition;
	CGPoint delta;
	double height;
	int jumps;
}
/** creates the action */
+(id) actionWithDuration: (double) t position: (CGPoint) pos height: (double) h jumps:(int)j;
/** initializes the action */
-(id) initWithDuration: (double) t position: (CGPoint) pos height: (double) h jumps:(int)j;
@end

/** Moves a `CocosNode` object to a position simulating a jump movement by modifying it's position attribute.
*/ 
 @interface JumpTo : JumpBy <NSCopying>
{
}
@end


/** Scales a CocosNode object to a zoom factor by modifying it's scale attribute.
 */
@interface ScaleTo : IntervalAction <NSCopying>
{
	float scale;
	float startScale;
	float endScale;
	float delta;
}
/** creates the action */
+(id) actionWithDuration: (double) t scale:(float) s;
/** initializes the action */
-(id) initWithDuration: (double) t scale:(float) s;
@end

/** Scales a CocosNode object a zoom factor by modifying it's scale attribute.
*/
@interface ScaleBy : ScaleTo <NSCopying>
{
}
@end

/** Blinks a CocosNode object by modifying it's visible attribute
*/
@interface Blink : IntervalAction <NSCopying>
{
	int times;
}
/** creates the action */
+(id) actionWithDuration: (double) t blinks: (int) blinks;
/** initilizes the action */
-(id) initWithDuration: (double) t blinks: (int) blinks;
@end

/** Fades in a CocosNode, from opacity 0 to 255 */
@interface FadeIn : IntervalAction <NSCopying>
{
}
@end

/** Fades out a CocosNode, from opacity 255 to 0 */
@interface FadeOut : IntervalAction <NSCopying>
{
}
@end

/** Fades a CocosNode from current opacity to a custom one */
@interface FadeTo : IntervalAction <NSCopying>
{
	GLubyte toOpacity;
	GLubyte fromOpacity;
}
/** creates an action with duration and opactiy */
+(id) actionWithDuration: (double) t opacity: (GLubyte) o;
/** initializes the action with duration and opacity */
-(id) initWithDuration: (double) t opacity: (GLubyte) o;
@end



/** Changes the acceleration of an action
 */
@interface Accelerate: IntervalAction <NSCopying>
{
	IntervalAction *other;
	float rate;
}
/** creates the action */
+(id) actionWithAction: (IntervalAction*) action rate: (float) rate;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action rate: (float) rate;
@end

/** Makes an action change the travel speed but retain near normal speed at the beginning and ending.
*/
@interface AccelDeccel: IntervalAction <NSCopying>
{
	IntervalAction *other;
}
/** creates an action */
+(id) actionWithAction: (IntervalAction*) action;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action;
@end

/** Changes the speed of an action, making it take longer (speed>1)
 or less (speed<1)
 */
@interface Speed : IntervalAction <NSCopying>
{
	double speed;
	IntervalAction * other;
}
/** creates the action */
+(id) actionWithAction: (IntervalAction*) action speed:(double)s;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action speed:(double)s;
@end

/** Delays the action a certain amount of seconds
*/
@interface DelayTime : IntervalAction <NSCopying>
{
}
@end

/** Executes an action in reverse order, from time=duration to time=0
 
 WARNING: Use this action carefully. This action is not
 sequenceable. Use it as the default "reversed" method
 of your own actions, but using it outside the "reversed"
 scope is not recommended.
*/
@interface ReverseTime : IntervalAction <NSCopying>
{
	IntervalAction * other;
}
/** creates the action */
+(id) actionWithAction: (IntervalAction*) action;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action;
@end
