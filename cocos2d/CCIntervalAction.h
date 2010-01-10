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

#import "CCNode.h"
#import "CCAction.h"
#import "CCProtocols.h"

#include <sys/time.h>

/** An interval action is an action that takes place within a certain period of time.
It has an start time, and a finish time. The finish time is the parameter
duration plus the start time.

These CCIntervalAction actions have some interesting properties, like:
 - They can run normally (default)
 - They can run reversed with the reverse method
 - They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.

For example, you can simulate a Ping Pong effect running the action normally and
then running it again in Reverse mode.

Example:
 
	CCAction * pingPongAction = [CCSequence actions: action, [action reverse], nil];
*/
@interface CCIntervalAction: CCFiniteTimeAction <NSCopying>
{
	ccTime elapsed;
	BOOL	firstTick;
}

/** how many seconds had elapsed since the actions started to run. */
@property (nonatomic,readonly) ccTime elapsed;

/** creates the action */
+(id) actionWithDuration: (ccTime) d;
/** initializes the action */
-(id) initWithDuration: (ccTime) d;
/** returns YES if the action has finished */
-(BOOL) isDone;
/** returns a reversed action */
- (CCIntervalAction*) reverse;
@end

/** Runs actions sequentially, one after another
 */
@interface CCSequence : CCIntervalAction <NSCopying>
{
	NSArray *actions;
	ccTime split;
	int last;
}
/** helper contructor to create an array of sequenceable actions */
+(id) actions: (CCFiniteTimeAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the action */
+(id) actionOne:(CCFiniteTimeAction*)actionOne two:(CCFiniteTimeAction*)actionTwo;
/** initializes the action */
-(id) initOne:(CCFiniteTimeAction*)actionOne two:(CCFiniteTimeAction*)actionTwo;
@end


/** Repeats an action a number of times.
 * To repeat an action forever use the CCRepeatForever action.
 */
@interface CCRepeat : CCIntervalAction <NSCopying>
{
	unsigned int times;
	unsigned int total;
	CCFiniteTimeAction *other;
}
/** creates a CCRepeat action. Times is an unsigned integer between 1 and pow(2,30) */
+(id) actionWithAction:(CCFiniteTimeAction*)action times: (unsigned int)times;
/** initializes a CCRepeat action. Times is an unsigned integer between 1 and pow(2,30) */
-(id) initWithAction:(CCFiniteTimeAction*)action times: (unsigned int)times;
@end

/** Spawn a new action immediately
 */
@interface CCSpawn : CCIntervalAction <NSCopying>
{
	CCFiniteTimeAction *one;
	CCFiniteTimeAction *two;
}
/** helper constructor to create an array of spawned actions */
+(id) actions: (CCFiniteTimeAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the Spawn action */
+(id) actionOne: (CCFiniteTimeAction*) one two:(CCFiniteTimeAction*) two;
/** initializes the Spawn action with the 2 actions to spawn */
-(id) initOne: (CCFiniteTimeAction*) one two:(CCFiniteTimeAction*) two;
@end

/**  Rotates a CCNode object to a certain angle by modifying it's
 rotation attribute.
 The direction will be decided by the shortest angle.
*/ 
@interface CCRotateTo : CCIntervalAction <NSCopying>
{
	float dstAngle;
	float startAngle;
	float diffAngle;
}
/** creates the action */
+(id) actionWithDuration:(ccTime)duration angle:(float)angle;
/** initializes the action */
-(id) initWithDuration:(ccTime)duration angle:(float)angle;
@end

/** Rotates a CCNode object clockwise a number of degrees by modiying it's rotation attribute.
*/
@interface CCRotateBy : CCIntervalAction <NSCopying>
{
	float angle;
	float startAngle;
}
/** creates the action */
+(id) actionWithDuration:(ccTime)duration angle:(float)deltaAngle;
/** initializes the action */
-(id) initWithDuration:(ccTime)duration angle:(float)deltaAngle;
@end

/** Moves a CCNode object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
*/
@interface CCMoveTo : CCIntervalAction <NSCopying>
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

/**  Moves a CCNode object x,y pixels by modifying it's position attribute.
 x and y are relative to the position of the object.
 Duration is is seconds.
*/ 
@interface CCMoveBy : CCMoveTo <NSCopying>
{
}
/** creates the action */
+(id) actionWithDuration: (ccTime)duration position:(CGPoint)deltaPosition;
/** initializes the action */
-(id) initWithDuration: (ccTime)duration position:(CGPoint)deltaPosition;
@end

/** Moves a CCNode object simulating a parabolic jump movement by modifying it's position attribute.
*/
 @interface CCJumpBy : CCIntervalAction <NSCopying>
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

/** Moves a CCNode object to a parabolic position simulating a jump movement by modifying it's position attribute.
*/ 
 @interface CCJumpTo : CCJumpBy <NSCopying>
{
}
@end

/** bezier configuration structure
 */
typedef struct _ccBezierConfig {
	//! end position of the bezier
	CGPoint endPosition;
	//! Bezier control point 1
	CGPoint controlPoint_1;
	//! Bezier control point 2
	CGPoint controlPoint_2;
} ccBezierConfig;

/** An action that moves the target with a cubic Bezier curve by a certain distance.
 */
@interface CCBezierBy : CCIntervalAction <NSCopying>
{
	ccBezierConfig config;
	CGPoint startPosition;
}

/** creates the action with a duration and a bezier configuration */
+(id) actionWithDuration: (ccTime) t bezier:(ccBezierConfig) c;

/** initializes the action with a duration and a bezier configuration */
-(id) initWithDuration: (ccTime) t bezier:(ccBezierConfig) c;
@end

/** An action that moves the target with a cubic Bezier curve to a destination point.
 @since v0.8.2
 */
@interface CCBezierTo : CCBezierBy
{
}
@end

/** Scales a CCNode object to a zoom factor by modifying it's scale attribute.
 @warning This action doesn't support "reverse"
 */
@interface CCScaleTo : CCIntervalAction <NSCopying>
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

/** Scales a CCNode object a zoom factor by modifying it's scale attribute.
*/
@interface CCScaleBy : CCScaleTo <NSCopying>
{
}
@end

/** Blinks a CCNode object by modifying it's visible attribute
*/
@interface CCBlink : CCIntervalAction <NSCopying>
{
	int times;
}
/** creates the action */
+(id) actionWithDuration: (ccTime)duration blinks:(unsigned int)blinks;
/** initilizes the action */
-(id) initWithDuration: (ccTime)duration blinks:(unsigned int)blinks;
@end

/** Fades In an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 0 to 255.
 The "reverse" of this action is FadeOut
 */
@interface CCFadeIn : CCIntervalAction <NSCopying>
{
}
@end

/** Fades Out an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 255 to 0.
 The "reverse" of this action is FadeIn
*/
@interface CCFadeOut : CCIntervalAction <NSCopying>
{
}
@end

/** Fades an object that implements the CCRGBAProtocol protocol. It modifies the opacity from the current value to a custom one.
 @warning This action doesn't support "reverse"
 */
@interface CCFadeTo : CCIntervalAction <NSCopying>
{
	GLubyte toOpacity;
	GLubyte fromOpacity;
}
/** creates an action with duration and opactiy */
+(id) actionWithDuration:(ccTime)duration opacity:(GLubyte)opactiy;
/** initializes the action with duration and opacity */
-(id) initWithDuration:(ccTime)duration opacity:(GLubyte)opacity;
@end

/** Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 @warning This action doesn't support "reverse"
 @since v0.7.2
*/
@interface CCTintTo : CCIntervalAction <NSCopying>
{
	ccColor3B to;
	ccColor3B from;
}
/** creates an action with duration and color */
+(id) actionWithDuration:(ccTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;
/** initializes the action with duration and color */
-(id) initWithDuration:(ccTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;
@end

/** Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 @since v0.7.2
 */
@interface CCTintBy : CCIntervalAction <NSCopying>
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
@interface CCDelayTime : CCIntervalAction <NSCopying>
{
}
@end

/** Executes an action in reverse order, from time=duration to time=0
 
 @warning Use this action carefully. This action is not
 sequenceable. Use it as the default "reversed" method
 of your own actions, but using it outside the "reversed"
 scope is not recommended.
*/
@interface CCReverseTime : CCIntervalAction <NSCopying>
{
	CCFiniteTimeAction * other;
}
/** creates the action */
+(id) actionWithAction: (CCFiniteTimeAction*) action;
/** initializes the action */
-(id) initWithAction: (CCFiniteTimeAction*) action;
@end


@class CCAnimation;
@class CCTexture2D;
/** Animates a sprite given the name of an Animation */
@interface CCAnimate : CCIntervalAction <NSCopying>
{
	CCAnimation *animation_;
	id origFrame;
	BOOL restoreOriginalFrame;
}
/** animation used for the animage */
@property (readwrite,nonatomic,retain) CCAnimation * animation;

/** creates the action with an Animation and will restore the original frame when the animation is over */
+(id) actionWithAnimation:(id<CCAnimationProtocol>) a;
/** initializes the action with an Animation and will restore the original frame when the animtion is over */
-(id) initWithAnimation:(id<CCAnimationProtocol>) a;
/** creates the action with an Animation */
+(id) actionWithAnimation:(id<CCAnimationProtocol>) a restoreOriginalFrame:(BOOL)b;
/** initializes the action with an Animation */
-(id) initWithAnimation:(id<CCAnimationProtocol>) a restoreOriginalFrame:(BOOL)b;
/** creates an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
 The 'delay' parameter of the animation will be overrided by the duration parameter.
 @since v0.9.0
 */
+(id) actionWithDuration:(ccTime)duration animation:(id<CCAnimationProtocol>)animation restoreOriginalFrame:(BOOL)b;
/** initializes an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
 The 'delay' parameter of the animation will be overrided by the duration parameter.
 @since v0.9.0
 */
-(id) initWithDuration:(ccTime)duration animation:(id<CCAnimationProtocol>)animation restoreOriginalFrame:(BOOL)b;
@end


