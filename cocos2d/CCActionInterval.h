/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 */


#import "CCNode.h"
#import "CCAction.h"
#import "CCProtocols.h"

#include <sys/time.h>

/** An interval action is an action that takes place within a certain period of time.
It has an start time, and a finish time. The finish time is the parameter
duration plus the start time.

These CCActionInterval actions have some interesting properties, like:
 - They can run normally (default)
 - They can run reversed with the reverse method
 - They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.

For example, you can simulate a Ping Pong effect running the action normally and
then running it again in Reverse mode.

Example:

	CCAction * pingPongAction = [CCSequence actions: action, [action reverse], nil];
*/
@interface CCActionInterval: CCActionFiniteTime <NSCopying>
{
	CCTime	_elapsed;
	BOOL	_firstTick;
}

/** how many seconds had elapsed since the actions started to run. */
@property (nonatomic,readonly) CCTime elapsed;

/** creates the action */
+(id) actionWithDuration: (CCTime) d;
/** initializes the action */
-(id) initWithDuration: (CCTime) d;
/** returns YES if the action has finished */
-(BOOL) isDone;
/** returns a reversed action */
- (CCActionInterval*) reverse;
@end

/** Runs actions sequentially, one after another
 */
@interface CCActionSequence : CCActionInterval <NSCopying>
{
	CCActionFiniteTime *_actions[2];
	CCTime _split;
	int _last;
}
/** helper constructor to create an array of sequence-able actions */
+(id) actions: (CCActionFiniteTime*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** helper constructor to create an array of sequence-able actions */
+(id) actions: (CCActionFiniteTime*) action1 vaList:(va_list) args;
/** helper constructor to create an array of sequence-able actions given an array */
+(id) actionWithArray: (NSArray*) arrayOfActions;
/** creates the action */
+(id) actionOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;
/** initializes the action */
-(id) initOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;
@end


/** Repeats an action a number of times.
 * To repeat an action forever use the CCRepeatForever action.
 */
@interface CCActionRepeat : CCActionInterval <NSCopying>
{
	NSUInteger _times;
	NSUInteger _total;
	CCTime _nextDt;
	BOOL _isActionInstant;
	CCActionFiniteTime *_innerAction;
}

/** Inner action */
@property (nonatomic,readwrite,strong) CCActionFiniteTime *innerAction;

/** creates a CCRepeat action. Times is an unsigned integer between 1 and MAX_UINT.
 */
+(id) actionWithAction:(CCActionFiniteTime*)action times: (NSUInteger)times;
/** initializes a CCRepeat action. Times is an unsigned integer between 1 and MAX_UINT */
-(id) initWithAction:(CCActionFiniteTime*)action times: (NSUInteger)times;
@end

/** Spawn a new action immediately
 */
@interface CCActionSpawn : CCActionInterval <NSCopying>
{
	CCActionFiniteTime *_one;
	CCActionFiniteTime *_two;
}
/** helper constructor to create an array of spawned actions */
+(id) actions: (CCActionFiniteTime*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** helper constructor to create an array of spawned actions */
+(id) actions: (CCActionFiniteTime*) action1 vaList:(va_list)args;
/** helper constructor to create an array of spawned actions given an array */
+(id) actionWithArray: (NSArray*) arrayOfActions;
/** creates the Spawn action */
+(id) actionOne: (CCActionFiniteTime*) one two:(CCActionFiniteTime*) two;
/** initializes the Spawn action with the 2 actions to spawn */
-(id) initOne: (CCActionFiniteTime*) one two:(CCActionFiniteTime*) two;
@end

/**  Rotates a CCNode object to a certain angle by modifying it's
 rotation attribute.
 The direction will be decided by the shortest angle.
*/
@interface CCActionRotateTo : CCActionInterval <NSCopying>
{
	float _dstAngleX;
	float _startAngleX;
	float _diffAngleX;
  
	float _dstAngleY;
	float _startAngleY;
	float _diffAngleY;
}
/** creates the action */
+(id) actionWithDuration:(CCTime)duration angle:(float)angle;
/** initializes the action */
-(id) initWithDuration:(CCTime)duration angle:(float)angle;

/** creates the action with separate rotation angles */
+(id) actionWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;
-(id) initWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;
@end

/** Rotates a CCNode object clockwise a number of degrees by modifying its rotation attribute.
*/
@interface CCActionRotateBy : CCActionInterval <NSCopying>
{
	float _angleX;
	float _startAngleX;
	float _angleY;
	float _startAngleY;
}
/** creates the action */
+(id) actionWithDuration:(CCTime)duration angle:(float)deltaAngle;
/** initializes the action */
-(id) initWithDuration:(CCTime)duration angle:(float)deltaAngle;

/** creates the action with separate rotation angles */
+(id) actionWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;
-(id) initWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;
@end

/**  Moves a CCNode object x,y pixels by modifying it's position attribute.
 x and y are relative to the position of the object.
 Several CCMoveBy actions can be concurrently called, and the resulting
 movement will be the sum of individual movements.
 @since v2.1beta2-custom
 */
@interface CCActionMoveBy : CCActionInterval <NSCopying>
{
	CGPoint _positionDelta;
	CGPoint _startPos;
	CGPoint _previousPos;
}
/** creates the action */
+(id) actionWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;
/** initializes the action */
-(id) initWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;
@end

/** Moves a CCNode object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
 Several CCMoveTo actions can be concurrently called, and the resulting
 movement will be the sum of individual movements.
 @since v2.1beta2-custom
 */
@interface CCActionMoveTo : CCActionMoveBy
{
	CGPoint _endPosition;
}
/** creates the action */
+(id) actionWithDuration:(CCTime)duration position:(CGPoint)position;
/** initializes the action */
-(id) initWithDuration:(CCTime)duration position:(CGPoint)position;
@end

/** Skews a CCNode object to given angles by modifying its skewX and skewY attributes
 @since v1.0
 */
@interface CCActionSkewTo : CCActionInterval <NSCopying>
{
	float _skewX;
	float _skewY;
	float _startSkewX;
	float _startSkewY;
	float _endSkewX;
	float _endSkewY;
	float _deltaX;
	float _deltaY;
}
/** creates the action */
+(id) actionWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;
/** initializes the action with duration, skew X and skew Y */
-(id) initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;
@end

/** Skews a CCNode object by skewX and skewY degrees
 @since v1.0
 */
@interface CCActionSkewBy : CCActionSkewTo <NSCopying>
{
}
/** initializes the action with duration, skew X and skew Y */
-(id) initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;
@end

/** Moves a CCNode object simulating a parabolic jump movement by modifying its position attribute.
*/
@interface CCActionJumpBy : CCActionInterval <NSCopying>
{
	CGPoint _startPosition;
	CGPoint _delta;
	CCTime	_height;
	NSUInteger _jumps;
	CGPoint _previousPos;
}
/** creates the action */
+(id) actionWithDuration: (CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;
/** initializes the action */
-(id) initWithDuration: (CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;
@end

/** Moves a CCNode object to a parabolic position simulating a jump movement by modifying its position attribute.
*/
@interface CCActionJumpTo : CCActionJumpBy <NSCopying>
{
}
// XXX: Added to prevent bug on BridgeSupport
-(void) startWithTarget:(CCNode *)aTarget;
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
@interface CCActionBezierBy : CCActionInterval <NSCopying>
{
	ccBezierConfig _config;
	CGPoint _startPosition;
	CGPoint _previousPosition;
}

/** creates the action with a duration and a bezier configuration */
+(id) actionWithDuration: (CCTime) t bezier:(ccBezierConfig) c;

/** initializes the action with a duration and a bezier configuration */
-(id) initWithDuration: (CCTime) t bezier:(ccBezierConfig) c;
@end

/** An action that moves the target with a cubic Bezier curve to a destination point.
 @since v0.8.2
 */
@interface CCActionBezierTo : CCActionBezierBy
{
	ccBezierConfig _toConfig;
}
// XXX: Added to prevent bug on BridgeSupport
-(void) startWithTarget:(CCNode *)aTarget;
@end

/** Scales a CCNode object to a zoom factor by modifying its scale attribute.
 @warning This action doesn't support "reverse"
 */
@interface CCActionScaleTo : CCActionInterval <NSCopying>
{
	float _scaleX;
	float _scaleY;
	float _startScaleX;
	float _startScaleY;
	float _endScaleX;
	float _endScaleY;
	float _deltaX;
	float _deltaY;
}
/** creates the action with the same scale factor for X and Y */
+(id) actionWithDuration: (CCTime)duration scale:(float) s;
/** initializes the action with the same scale factor for X and Y */
-(id) initWithDuration: (CCTime)duration scale:(float) s;
/** creates the action with and X factor and a Y factor */
+(id) actionWithDuration: (CCTime)duration scaleX:(float) sx scaleY:(float)sy;
/** initializes the action with and X factor and a Y factor */
-(id) initWithDuration: (CCTime)duration scaleX:(float) sx scaleY:(float)sy;
@end

/** Scales a CCNode object a zoom factor by modifying its scale attribute.
*/
@interface CCActionScaleBy : CCActionScaleTo <NSCopying>
{
}
// XXX: Added to prevent bug on BridgeSupport
-(void) startWithTarget:(CCNode *)aTarget;
@end

/** Blinks a CCNode object by modifying its visible attribute
*/
@interface CCActionBlink : CCActionInterval <NSCopying>
{
	NSUInteger _times;
	BOOL _originalState;
}
/** creates the action */
+(id) actionWithDuration: (CCTime)duration blinks:(NSUInteger)blinks;
/** initializes the action */
-(id) initWithDuration: (CCTime)duration blinks:(NSUInteger)blinks;
@end

/** Fades In an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 0 to 255.
 The "reverse" of this action is FadeOut
 */
@interface CCActionFadeIn : CCActionInterval <NSCopying>
{
}
// XXX: Added to prevent bug on BridgeSupport
-(void) update:(CCTime)dt;
@end

/** Fades Out an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 255 to 0.
 The "reverse" of this action is FadeIn
*/
@interface CCActionFadeOut : CCActionInterval <NSCopying>
{
}
// XXX: Added to prevent bug on BridgeSupport
-(void) update:(CCTime)dt;
@end

/** Fades an object that implements the CCRGBAProtocol protocol. It modifies the opacity from the current value to a custom one.
 @warning This action doesn't support "reverse"
 */
@interface CCActionFadeTo : CCActionInterval <NSCopying>
{
	GLubyte _toOpacity;
	GLubyte _fromOpacity;
}
/** creates an action with duration and opacity */
+(id) actionWithDuration:(CCTime)duration opacity:(GLubyte)opactiy;
/** initializes the action with duration and opacity */
-(id) initWithDuration:(CCTime)duration opacity:(GLubyte)opacity;
@end

/** Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 @warning This action doesn't support "reverse"
 @since v0.7.2
*/
@interface CCActionTintTo : CCActionInterval <NSCopying>
{
	ccColor3B _to;
	ccColor3B _from;
}
/** creates an action with duration and color */
+(id) actionWithDuration:(CCTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;
/** initializes the action with duration and color */
-(id) initWithDuration:(CCTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;
@end

/** Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 @since v0.7.2
 */
@interface CCActionTintBy : CCActionInterval <NSCopying>
{
	GLshort _deltaR, _deltaG, _deltaB;
	GLshort _fromR, _fromG, _fromB;
}
/** creates an action with duration and color */
+(id) actionWithDuration:(CCTime)duration red:(GLshort)deltaRed green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;
/** initializes the action with duration and color */
-(id) initWithDuration:(CCTime)duration red:(GLshort)deltaRed green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;
@end

/** Delays the action a certain amount of seconds
*/
@interface CCActionDelay : CCActionInterval <NSCopying>
{
}
// XXX: Added to prevent bug on BridgeSupport
-(void) update:(CCTime)dt;
@end

/** Executes an action in reverse order, from time=duration to time=0

 @warning Use this action carefully. This action is not
 sequence-able. Use it as the default "reversed" method
 of your own actions, but using it outside the "reversed"
 scope is not recommended.
*/
@interface CCActionReverse : CCActionInterval <NSCopying>
{
	CCActionFiniteTime * _other;
}
/** creates the action */
+(id) actionWithAction: (CCActionFiniteTime*) action;
/** initializes the action */
-(id) initWithAction: (CCActionFiniteTime*) action;
@end


@class CCAnimation;
@class CCTexture;
/** Animates a sprite given the name of an Animation */
@interface CCActionAnimate : CCActionInterval <NSCopying>
{
	NSMutableArray		*_splitTimes;
	NSInteger			_nextFrame;
	CCAnimation			*_animation;
	id					_origFrame;
	NSUInteger			_executedLoops;
}
/** animation used for the image */
@property (readwrite,nonatomic,strong) CCAnimation * animation;

/** creates the action with an Animation and will restore the original frame when the animation is over */
+(id) actionWithAnimation:(CCAnimation*)animation;
/** initializes the action with an Animation and will restore the original frame when the animation is over */
-(id) initWithAnimation:(CCAnimation*)animation;
@end
