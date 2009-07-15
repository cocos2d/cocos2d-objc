/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CocosNode.h"
#import "Action.h"

#include <sys/time.h>

/** An interval action is an action that takes place within a certain period of time.
It has an start time, and a finish time. The finish time is the parameter
duration plus the start time.

These IntervalAction actions have some interesting properties, like:
 - They can run normally (default)
 - They can run reversed with the reverse method
 - They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.

For example, you can simulate a Ping Pong effect running the action normally and
then running it again in Reverse mode.

Example:
 
	Action * pingPongAction = [Sequence actions: action, [action reverse], nil];
*/
@interface IntervalAction: FiniteTimeAction <NSCopying>
{
	ccTime elapsed;
	BOOL	firstTick;
}

@property (readonly) ccTime elapsed;

/** creates the action */
+(id) actionWithDuration: (ccTime) d;
/** initializes the action */
-(id) initWithDuration: (ccTime) d;
/** called when the action is about to start */
-(void) start;
/** returns YES if the action has finished */
-(BOOL) isDone;
/** returns a reversed action */
- (IntervalAction*) reverse;
@end

/** Runs actions sequentially, one after another
 */
@interface Sequence : IntervalAction <NSCopying>
{
	NSArray *actions;
	ccTime split;
	int last;
}
/** helper contructor to create an array of sequenceable actions */
+(id) actions: (FiniteTimeAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the action */
+(id) actionOne:(FiniteTimeAction*)actionOne two:(FiniteTimeAction*)actionTwo;
/** initializes the action */
-(id) initOne:(FiniteTimeAction*)actionOne two:(FiniteTimeAction*)actionTwo;
@end


/** Repeats an action a number of times.
 * To repeat an action forever use the RepeatForever action.
 */
@interface Repeat : IntervalAction <NSCopying>
{
	unsigned int times;
	unsigned int total;
	FiniteTimeAction *other;
}
/** creates the Repeat action. Times is an unsigned integer between 1 and pow(2,30) */
+(id) actionWithAction:(FiniteTimeAction*)action times: (unsigned int)times;
/** initializes the action. Times is an unsigned integer between 1 and pow(2,30) */
-(id) initWithAction:(FiniteTimeAction*)action times: (unsigned int)times;
@end

/** Spawn a new action immediately
 */
@interface Spawn : IntervalAction <NSCopying>
{
	FiniteTimeAction *one;
	FiniteTimeAction *two;
}
/** helper constructor to create an array of spawned actions */
+(id) actions: (FiniteTimeAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the Spawn action */
+(id) actionOne: (FiniteTimeAction*) one two:(FiniteTimeAction*) two;
/** initializes the Spawn action with the 2 actions to spawn */
-(id) initOne: (FiniteTimeAction*) one two:(FiniteTimeAction*) two;
@end

/**  Rotates a CocosNode object to a certain angle by modifying it's
 rotation attribute.
 The direction will be decided by the shortest angle.
*/ 
@interface RotateTo : IntervalAction <NSCopying>
{
	float angle;
	float startAngle;
}
/** creates the action */
+(id) actionWithDuration:(ccTime)duration angle:(float)angle;
/** initializes the action */
-(id) initWithDuration:(ccTime)duration angle:(float)angle;
@end

/** Rotates a CocosNode object clockwise a number of degrees by modiying it's rotation attribute.
*/
@interface RotateBy : IntervalAction <NSCopying>
{
	float angle;
	float startAngle;
}
/** creates the action */
+(id) actionWithDuration:(ccTime)duration angle:(float)deltaAngle;
/** initializes the action */
-(id) initWithDuration:(ccTime)duration angle:(float)deltaAngle;
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
+(id) actionWithDuration:(ccTime)duration position:(CGPoint)position;
/** initializes the action */
-(id) initWithDuration:(ccTime)duration position:(CGPoint)position;
@end

/**  Moves a CocosNode object x,y pixels by modifying it's position attribute.
 x and y are relative to the position of the object.
 Duration is is seconds.
*/ 
@interface MoveBy : MoveTo <NSCopying>
{
}
/** creates the action */
+(id) actionWithDuration: (ccTime)duration position:(CGPoint)deltaPosition;
/** initializes the action */
-(id) initWithDuration: (ccTime)duration position:(CGPoint)deltaPosition;
@end

/** Moves a CocosNode object simulating a jump movement by modifying it's position attribute.
*/
 @interface JumpBy : IntervalAction <NSCopying>
{
	CGPoint startPosition;
	CGPoint delta;
	ccTime height;
	int jumps;
}
/** creates the action */
+(id) actionWithDuration: (ccTime)duration position:(CGPoint)position height:(ccTime)height jumps:(int)jumps;
/** initializes the action */
-(id) initWithDuration: (ccTime)duration position:(CGPoint)position height:(ccTime)height jumps:(int)jumps;
@end

/** Moves a CocosNode object to a position simulating a jump movement by modifying it's position attribute.
*/ 
 @interface JumpTo : JumpBy <NSCopying>
{
}
@end

/** bezier configuration structure
 */
typedef struct _ccBezierConfig {
	//! startPosition of the bezier
	CGPoint startPosition;
	//! end position of the bezier
	CGPoint endPosition;
	//! Bezier control point 1
	CGPoint controlPoint_1;
	//! Bezier control point 2
	CGPoint controlPoint_2;
} ccBezierConfig;

/** A action that moves the target with a cubic Bezier curve.
 Since BezierBy moves the target "relative" it will be easier if
 the startPosition of the Bezier configuration is (0,0)
 */
@interface BezierBy : IntervalAction <NSCopying>
{
	ccBezierConfig config;
	CGPoint startPosition;
}

/** creates the action with a duration and a bezier configuration */
+(id) actionWithDuration: (ccTime) t bezier:(ccBezierConfig) c;

/** initializes the action with a duration and a bezier configuration */
-(id) initWithDuration: (ccTime) t bezier:(ccBezierConfig) c;
@end

/** Scales a CocosNode object to a zoom factor by modifying it's scale attribute.
 @warning This action doesn't support "reverse"
 */
@interface ScaleTo : IntervalAction <NSCopying>
{
	float scaleX;
	float scaleY;
	float startScaleX;
	float startScaleY;
	float endScaleX;
	float endScaleY;
	float deltaX;
	float deltaY;
}
/** creates the action with the same scale factor for X and Y */
+(id) actionWithDuration: (ccTime)duration scale:(float) s;
/** initializes the action with the same scale factor for X and Y */
-(id) initWithDuration: (ccTime)duration scale:(float) s;
/** creates the action with and X factor and a Y factor */
+(id) actionWithDuration: (ccTime)duration scaleX:(float) sx scaleY:(float)sy;
/** initializes the action with and X factor and a Y factor */
-(id) initWithDuration: (ccTime)duration scaleX:(float) sx scaleY:(float)sy;
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
+(id) actionWithDuration: (ccTime)duration blinks:(unsigned int)blinks;
/** initilizes the action */
-(id) initWithDuration: (ccTime)duration blinks:(unsigned int)blinks;
@end

/** Fades In an object that implements the CocosNodeRGBA protocol. It modifies the opacity from 0 to 255.
 The "reverse" of this action is FadeOut
 */
@interface FadeIn : IntervalAction <NSCopying>
{
}
@end

/** Fades Out an object that implements the CocosNodeRGBA protocol. It modifies the opacity from 255 to 0.
 The "reverse" of this action is FadeIn
*/
@interface FadeOut : IntervalAction <NSCopying>
{
}
@end

/** Fades an object that implements the CocosNodeRGBA protocol. It modifies the opacity from the current value to a custom one.
 @warning This action doesn't support "reverse"
 */
@interface FadeTo : IntervalAction <NSCopying>
{
	GLubyte toOpacity;
	GLubyte fromOpacity;
}
/** creates an action with duration and opactiy */
+(id) actionWithDuration:(ccTime)duration opacity:(GLubyte)opactiy;
/** initializes the action with duration and opacity */
-(id) initWithDuration:(ccTime)duration opacity:(GLubyte)opacity;
@end

/** Tints a CocosNode that implements the CocosNodeRGB protocol from current tint to a custom one.
 @warning This action doesn't support "reverse"
 @since v0.7.2
*/
@interface TintTo : IntervalAction <NSCopying>
{
	ccColor3B to;
	ccColor3B from;
}
/** creates an action with duration and color */
+(id) actionWithDuration:(ccTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;
/** initializes the action with duration and color */
-(id) initWithDuration:(ccTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;
@end

/** Tints a CocosNode that implements the CocosNodeRGB protocol from current tint to a custom one.
 @since v0.7.2
 */
@interface TintBy : IntervalAction <NSCopying>
{
	GLshort deltaR, deltaG, deltaB;
	GLshort fromR, fromG, fromB;
}
/** creates an action with duration and color */
+(id) actionWithDuration:(ccTime)duration red:(GLshort)deltaRed green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;
/** initializes the action with duration and color */
-(id) initWithDuration:(ccTime)duration red:(GLshort)deltaRed green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;
@end

/** Delays the action a certain amount of seconds
*/
@interface DelayTime : IntervalAction <NSCopying>
{
}
@end

/** Executes an action in reverse order, from time=duration to time=0
 
 @warning Use this action carefully. This action is not
 sequenceable. Use it as the default "reversed" method
 of your own actions, but using it outside the "reversed"
 scope is not recommended.
*/
@interface ReverseTime : IntervalAction <NSCopying>
{
	FiniteTimeAction * other;
}
/** creates the action */
+(id) actionWithAction: (FiniteTimeAction*) action;
/** initializes the action */
-(id) initWithAction: (FiniteTimeAction*) action;
@end


@class Animation;
@class Texture2D;
/** Animates a sprite given the name of an Animation */
@interface Animate : IntervalAction <NSCopying>
{
	Animation *animation;
	id origFrame;
	BOOL restoreOriginalFrame;
}
/** creates the action with an Animation and will restore the original frame when the animation is over */
+(id) actionWithAnimation:(id<CocosAnimation>) a;
/** initializes the action with an Animation and will restore the original frame when the animtion is over */
-(id) initWithAnimation:(id<CocosAnimation>) a;
/** creates the action with an Animation */
+(id) actionWithAnimation:(id<CocosAnimation>) a restoreOriginalFrame:(BOOL)b;
/** initializes the action with an Animation */
-(id) initWithAnimation:(id<CocosAnimation>) a restoreOriginalFrame:(BOOL)b;
@end


