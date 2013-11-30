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

// -----------------------------------------------------------------
/** @name CCActionInterval */

/**
 *  An interval action is an action that takes place within a certain period of time.
 *  It has an start time, and a finish time. The finish time is the parameter
 *  duration plus the start time.
 *
 *  These CCActionInterval actions have some interesting properties, like:
 *  - They can run normally (default)
 *  - They can run reversed with the reverse method
 *  - They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.
 *
 *  For example, you can simulate a Ping Pong effect running the action normally and
 *  then running it again in Reverse mode.
 *
 *  Example:
 *  CCAction * pingPongAction = [CCSequence actions: action, [action reverse], nil];
 */
@interface CCActionInterval: CCActionFiniteTime <NSCopying>
{
	CCTime	_elapsed;
	BOOL	_firstTick;
}

/** 
 *  How many seconds had elapsed since the actions started to run. 
 */
@property (nonatomic,readonly) CCTime elapsed;

/**
 *  Creates a new action.
 *
 *  @param d Action interval
 *
 *  @return Created action
 */
+(id) actionWithDuration: (CCTime) d;

/**
 *  Initializes the action.
 *
 *  @param d Action interval
 *
 *  @return Initialzed action
 */
-(id) initWithDuration: (CCTime) d;

/**
 *  Returns YES if the action has finished
 *
 *  @return Action finishded status
 */
-(BOOL) isDone;

/** returns a reversed action */
/**
 *  Returns a reversed action
 *
 *  @return Created reverse action
 */
- (CCActionInterval*) reverse;

@end

// -----------------------------------------------------------------
/** @name CCActionSequence */

/** 
 *  Runs actions sequentially, one after another
 */
@interface CCActionSequence : CCActionInterval <NSCopying>
{
	CCActionFiniteTime *_actions[2];
	CCTime _split;
	int _last;
}

/**
 *  Helper constructor to create an array of sequence-able actions.
 *
 *  @param action1 First action to add to sequence.
 *  @param ...     Nil terminated list of actions to sequence.
 *
 *  @return A New action sequence.
 */
+(id) actions: (CCActionFiniteTime*) action1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Helper constructor to create an array of sequence-able actions.
 *
 *  @param action1 Action to sequence.
 *  @param args    C++ style list of actions.
 *
 *  @return New action sequence
 */
+(id) actions: (CCActionFiniteTime*) action1 vaList:(va_list) args;

/**
 *  Helper constructor to create an array of sequence-able actions given an array.
 *
 *  @param arrayOfActions Array of actions to sequence
 *
 *  @return New action sequence
 */
+(id) actionWithArray: (NSArray*) arrayOfActions;

/**
 *  Creates an action sequence from two actions
 *
 *  @param actionOne Action one
 *  @param actionTwo Action two
 *
 *  @return New action sequence
 */
+(id) actionOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;

/**
 *  Initializes an action sequence with two actions
 *
 *  @param actionOne Action one
 *  @param actionTwo Action two
 *
 *  @return New action sequence
 */
-(id) initOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;

@end

// -----------------------------------------------------------------
/** @name CCActionRepeat */

/**
 *  Repeats an action a number of times.
 *  To repeat an action forever use the CCRepeatForever action. 
 */
@interface CCActionRepeat : CCActionInterval <NSCopying>
{
	NSUInteger _times;
	NSUInteger _total;
	CCTime _nextDt;
	BOOL _isActionInstant;
	CCActionFiniteTime *_innerAction;
}

/** 
 *  Inner action 
 */
@property (nonatomic,readwrite,strong) CCActionFiniteTime *innerAction;

/**
 *  Creates a CCRepeat action.
 *  Times is an unsigned integer between 1 and MAX_UINT.
 *
 *  @param action Action to repeat
 *  @param times  Number of times to repeat action
 *
 *  @return New action repeat
 */
+(id) actionWithAction:(CCActionFiniteTime*)action times: (NSUInteger)times;

/**
 *  Initializes a CCRepeat action.
 *  Times is an unsigned integer between 1 and MAX_UINT.
 *
 *  @param action Action to repeat
 *  @param times  Number of times to repeat action
 *
 *  @return New action repeat
 */
-(id) initWithAction:(CCActionFiniteTime*)action times: (NSUInteger)times;
@end

// -----------------------------------------------------------------
/** @name CCActionSpawn */

/** Spawn a new action immediately
 */
@interface CCActionSpawn : CCActionInterval <NSCopying>
{
	CCActionFiniteTime *_one;
	CCActionFiniteTime *_two;
}

/**
 *  Helper constructor to create an array of spawned actions.
 *
 *  @param action1 First action to spawn.
 *  @param ...     Nil terminated list of action to spawn.
 *
 *  @return New action spawn
 */
+(id) actions: (CCActionFiniteTime*) action1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Helper constructor to create an array of spawned actions.
 *
 *  @param action1 Action to spawn
 *  @param args    C++ style list of actions.
 *
 *  @return New action spawn
 */
+(id) actions: (CCActionFiniteTime*) action1 vaList:(va_list)args;

/**
 *  Helper constructor to create an array of spawned actions given an array.
 *
 *  @param arrayOfActions Array of actions to spawn
 *
 *  @return New action spawn
 */
+(id) actionWithArray: (NSArray*) arrayOfActions;

/**
 *  Creates the Spawn action from two actions
 *
 *  @param one Action one
 *  @param two Action two
 *
 *  @return New action spawn
 */
+(id) actionOne: (CCActionFiniteTime*) one two:(CCActionFiniteTime*) two;

/**
 *  Initializes the Spawn action with the 2 actions to spawn.
 *
 *  @param one Action one
 *  @param two Action two
 *
 *  @return New action spawn
 */
-(id) initOne: (CCActionFiniteTime*) one two:(CCActionFiniteTime*) two;

@end

// -----------------------------------------------------------------
/** @name CCActionRotateTo */

/**  
 *  Rotates a CCNode object to a certain angle by modifying it's rotation attribute.
 *  The direction will be decided by the shortest angle.
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

/**
 *  Creates the action.
 *
 *  @param duration Action duration
 *  @param angle    Angle to rotate to (degrees)
 *
 *  @return New rotate action
 */
+(id) actionWithDuration:(CCTime)duration angle:(float)angle;

/**
 *  Initializes the action.
 *
 *  @param duration Action duration
 *  @param angle    Angle to rotate to (degrees)
 *
 *  @return New rotate action
 */
-(id) initWithDuration:(CCTime)duration angle:(float)angle;

/**
 *  Creates the action with separate rotation angles.
 *
 *  @param t  Action duration
 *  @param aX X rotation in degrees
 *  @param aY Y rotation in degrees
 *
 *  @return New rotate action
 */
+(id) actionWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;

/**
 *  Initializes the action with separate rotation angles.
 *
 *  @param t  Action duration
 *  @param aX X rotation in degrees
 *  @param aY Y rotation in degrees
 *
 *  @return New rotate action
 */
-(id) initWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;

@end

// -----------------------------------------------------------------
/** @name CCActionRotateBy */

/** 
 *  Rotates a CCNode object clockwise a number of degrees by modifying its rotation attribute.
*/
@interface CCActionRotateBy : CCActionInterval <NSCopying>
{
	float _angleX;
	float _startAngleX;
	float _angleY;
	float _startAngleY;
}

/**
 *  Creates the action.
 *
 *  @param duration   Action duration
 *  @param deltaAngle Delta angle in degrees
 *
 *  @return New rotate action
 */
+(id) actionWithDuration:(CCTime)duration angle:(float)deltaAngle;

/**
 *  Initializes the action.
 *
 *  @param duration   Action duration
 *  @param deltaAngle Delta angle in degrees
 *
 *  @return New rotate action
 */
-(id) initWithDuration:(CCTime)duration angle:(float)deltaAngle;

/**
 *  Creates the action with separate rotation angles.
 *
 *  @param t  Action duration
 *  @param aX X rotation in degrees
 *  @param aY Y rotation in degrees
 *
 *  @return New rotate action
 */
+(id) actionWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;

/**
 *  Initializes the action with separate rotation angles.
 *
 *  @param t  Action duration
 *  @param aX X rotation in degrees
 *  @param aY Y rotation in degrees
 *
 *  @return New rotate action
 */
-(id) initWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY;

@end

// -----------------------------------------------------------------
/** @name CCActionMoveBy */

/**  
 *  Moves a CCNode object x,y pixels by modifying it's position attribute.
 *  X and y are relative to the position of the object.
 *  Several CCMoveBy actions can be concurrently called, and the resulting movement will be the sum of individual movements.
 */
@interface CCActionMoveBy : CCActionInterval <NSCopying>
{
	CGPoint _positionDelta;
	CGPoint _startPos;
	CGPoint _previousPos;
}

/**
 *  Creates the action.
 *
 *  @param duration      Action interval
 *  @param deltaPosition Delta position
 *
 *  @return New moveby action
 */
+(id) actionWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;

/**
 *  Initializes the action.
 *
 *  @param duration      Action interval
 *  @param deltaPosition Delta position
 *
 *  @return New moveby action
 */
-(id) initWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;

@end

// -----------------------------------------------------------------
/** @name CCActionMoveTo */

/** 
 *  Moves a CCNode object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
 *  Several CCMoveTo actions can be concurrently called, and the resulting movement will be the sum of individual movements.
 */
@interface CCActionMoveTo : CCActionMoveBy
{
	CGPoint _endPosition;
}

/**
 *  Creates the action.
 *
 *  @param duration Action interval
 *  @param position Absolute position to move to
 *
 *  @return New moveto action
 */
+(id) actionWithDuration:(CCTime)duration position:(CGPoint)position;

/**
 *  Initializes the action.
 *
 *  @param duration Action interval
 *  @param position Absolute position to move to
 *
 *  @return New moveto action
 */
-(id) initWithDuration:(CCTime)duration position:(CGPoint)position;

@end

// -----------------------------------------------------------------
/** @name CCActionSkewTo */

/**
 *  Skews a CCNode object to given angles by modifying its skewX and skewY attributes.
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

/**
 *  Creates the action.
 *
 *  @param t  Action duration
 *  @param sx X skew value
 *  @param sy Y skew value
 *
 *  @return New skew action
 */
+(id) actionWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

/**
 *  Initializes the action.
 *
 *  @param t  Action duration
 *  @param sx X skew value in degrees
 *  @param sy Y skew value in degrees
 *
 *  @return New skew action
 */
-(id) initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;
@end

// -----------------------------------------------------------------
/** @name CCActionSkewBy */

/**
 *  Skews a CCNode object by skewX and skewY degrees
 */
@interface CCActionSkewBy : CCActionSkewTo <NSCopying>
{
}

/**
 *  Initializes the action.
 *
 *  @param t  Action duration
 *  @param sx X skew delta value in degrees
 *  @param sy Y skew delta value in degrees
 *
 *  @return New skew action
 */
-(id) initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

@end

// -----------------------------------------------------------------
/** @name CCActionJumpBy */

/**
 *  Moves a CCNode object simulating a parabolic jump movement by modifying its position attribute.
 */
@interface CCActionJumpBy : CCActionInterval <NSCopying>
{
	CGPoint _startPosition;
	CGPoint _delta;
	CCTime	_height;
	NSUInteger _jumps;
	CGPoint _previousPos;
}

/**
 *  Creates the action.
 *
 *  @param duration Action duration
 *  @param position Delta position
 *  @param height   Height of jump
 *  @param jumps    Number of jumps to perform
 *
 *  @return New jump action
 */
+(id) actionWithDuration: (CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;

/**
 *  Initializes the action.
 *
 *  @param duration Action duration
 *  @param position Delta position
 *  @param height   Height of jump
 *  @param jumps    Number of jumps to perform
 *
 *  @return New jump action
 */
-(id) initWithDuration: (CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;
@end

// -----------------------------------------------------------------
/** @name CCActionJumpTo */

/**
 *  Moves a CCNode object simulating a parabolic jump movement by modifying its position attribute.
 */
@interface CCActionJumpTo : CCActionJumpBy <NSCopying>
{
}

// XXX: Added to prevent bug on BridgeSupport
-(void) startWithTarget:(CCNode *)aTarget;

@end

// -----------------------------------------------------------------
/** @name CCActionBezierBy */

/** 
 *  Bezier configuration structure.
 */
typedef struct _ccBezierConfig {
	//! end position of the bezier
	CGPoint endPosition;
	//! Bezier control point 1
	CGPoint controlPoint_1;
	//! Bezier control point 2
	CGPoint controlPoint_2;
} ccBezierConfig;

/**
 *  An action that moves the target with a cubic Bezier curve by a certain distance.
 */
@interface CCActionBezierBy : CCActionInterval <NSCopying>
{
	ccBezierConfig _config;
	CGPoint _startPosition;
	CGPoint _previousPosition;
}

/**
 *  Creates the action with a duration and a bezier configuration.
 *
 *  @param t Action duration
 *  @param c Bezier configuration
 *
 *  @return New bezier action
 */
+(id) actionWithDuration: (CCTime) t bezier:(ccBezierConfig) c;

/**
 *  Initializes the action with a duration and a bezier configuration.
 *
 *  @param t Action duration
 *  @param c Bezier configuration
 *
 *  @return New bezier action
 */
-(id) initWithDuration: (CCTime) t bezier:(ccBezierConfig) c;

@end

// -----------------------------------------------------------------
/** @name CCActionBezierTo */

/**
 *  An action that moves the target with a cubic Bezier curve to a destination point.
 */
@interface CCActionBezierTo : CCActionBezierBy
{
	ccBezierConfig _toConfig;
}

// XXX: Added to prevent bug on BridgeSupport
-(void) startWithTarget:(CCNode *)aTarget;

@end

// -----------------------------------------------------------------
/** @name CCActionScaleTo */

/**
 *  Scales a CCNode object to a zoom factor by modifying its scale attribute.
 *  Note:
 *  This action doesn't support "reverse"
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

/**
 *  Creates the action with the same scale factor for X and Y.
 *
 *  @param duration Action duration
 *  @param s        Scale to scale to
 *
 *  @return New scale action
 */
+(id) actionWithDuration: (CCTime)duration scale:(float) s;

/**
 *  Initializes the action with the same scale factor for X and Y.
 *
 *  @param duration Action duration
 *  @param s        Scale to scale to
 *
 *  @return New scale action
 */
-(id) initWithDuration: (CCTime)duration scale:(float) s;

/**
 *  Creates the action with individual scale factor for X and Y.
 *
 *  @param duration Action duration
 *  @param sx       X scale to scale to
 *  @param sy       Y scale to scale to
 *
 *  @return New scale action
 */
+(id) actionWithDuration: (CCTime)duration scaleX:(float) sx scaleY:(float)sy;

/**
 *  Initializes the action with individual scale factor for X and Y.
 *
 *  @param duration Action duration
 *  @param sx       X scale to scale to
 *  @param sy       Y scale to scale to
 *
 *  @return New scale action
 */
-(id) initWithDuration: (CCTime)duration scaleX:(float) sx scaleY:(float)sy;

@end

// -----------------------------------------------------------------
/** @name CCActionScaleBy */

/**
 *  Scales a CCNode object a zoom factor by modifying its scale attribute.
 */
@interface CCActionScaleBy : CCActionScaleTo <NSCopying>
{
}

// XXX: Added to prevent bug on BridgeSupport
-(void) startWithTarget:(CCNode *)aTarget;

@end

// -----------------------------------------------------------------
/** @name CCActionBlink */

/**
 *  Blinks a CCNode object by modifying its visible attribute.
 */
@interface CCActionBlink : CCActionInterval <NSCopying>
{
	NSUInteger _times;
	BOOL _originalState;
}

/**
 *  Creates the blink action
 *
 *  @param duration Action duration
 *  @param blinks   Number of times to blink
 *
 *  @return New blink action
 */
+(id) actionWithDuration: (CCTime)duration blinks:(NSUInteger)blinks;

/**
 *  Initializes the blink action
 *
 *  @param duration Action duration
 *  @param blinks   Number of times to blink
 *
 *  @return New blink action
 */
-(id) initWithDuration: (CCTime)duration blinks:(NSUInteger)blinks;

@end

// -----------------------------------------------------------------
/** @name CCActionFadeIn */

/**
 *  Fades In an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 0 to 255.
 *  The "reverse" of this action is FadeOut
 */
@interface CCActionFadeIn : CCActionInterval <NSCopying>
{
}

// XXX: Added to prevent bug on BridgeSupport
-(void) update:(CCTime)dt;

@end

// -----------------------------------------------------------------
/** @name CCActionFadeOut */

/**
 *  Fades Out an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 255 to 0.
 *  The "reverse" of this action is FadeIn
 */
@interface CCActionFadeOut : CCActionInterval <NSCopying>
{
}

// XXX: Added to prevent bug on BridgeSupport
-(void) update:(CCTime)dt;

@end

// -----------------------------------------------------------------
/** @name CCActionFadeTo */

/**
 *  Fades an object that implements the CCRGBAProtocol protocol. It modifies the opacity from the current value to a custom one.
 *  Note:
 *  This action doesn't support "reverse"
 */
@interface CCActionFadeTo : CCActionInterval <NSCopying>
{
	GLubyte _toOpacity;
	GLubyte _fromOpacity;
}

/**
 *  Creates a fade action.
 *
 *  @param duration Action duration
 *  @param opactiy  Opacity to fade to
 *
 *  @return New fade action
 */
+(id) actionWithDuration:(CCTime)duration opacity:(GLubyte)opactiy;

/**
 *  Initalizes a fade action.
 *
 *  @param duration Action duration
 *  @param opacity  Opacity to fade to
 *
 *  @return New fade action
 */
-(id) initWithDuration:(CCTime)duration opacity:(GLubyte)opacity;

@end

// -----------------------------------------------------------------
/** @name CCActionTintTo */

/**
 *  Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 *  Note:
 *  This action doesn't support "reverse"
 */
@interface CCActionTintTo : CCActionInterval <NSCopying>
{
	ccColor3B _to;
	ccColor3B _from;
}

/**
 *  Creates a tint to action
 *
 *  @param duration Action duration
 *  @param red      Red color to tint to
 *  @param green    Green color to tint to
 *  @param blue     Blue color to tint to
 *
 *  @return New tint to action
 */
+(id) actionWithDuration:(CCTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;

/**
 *  Initalizes a tint to action
 *
 *  @param duration Action duration
 *  @param red      Red color to tint to
 *  @param green    Green color to tint to
 *  @param blue     Blue color to tint to
 *
 *  @return New tint to action
 */
-(id) initWithDuration:(CCTime)duration red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue;

@end

// -----------------------------------------------------------------
/** @name CCActionTintBy */

/**
 *  Tints a CCNode that implements the CCNodeRGB protocol from current tint to a custom one.
 */
@interface CCActionTintBy : CCActionInterval <NSCopying>
{
	GLshort _deltaR, _deltaG, _deltaB;
	GLshort _fromR, _fromG, _fromB;
}

/**
 *  Creates a tint to action
 *
 *  @param duration   Action duration
 *  @param deltaRed   Red delta color to tint
 *  @param deltaGreen Green delta color to tint
 *  @param deltaBlue  Blue delta color to tint
 *
 *  @return New tint by action
 */
+(id) actionWithDuration:(CCTime)duration red:(GLshort)deltaRed green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;

/**
 *  Initalizes a tint to action
 *
 *  @param duration   Action duration
 *  @param deltaRed   Red delta color to tint
 *  @param deltaGreen Green delta color to tint
 *  @param deltaBlue  Blue delta color to tint
 *
 *  @return New tint by action
 */
-(id) initWithDuration:(CCTime)duration red:(GLshort)deltaRed green:(GLshort)deltaGreen blue:(GLshort)deltaBlue;

@end

// -----------------------------------------------------------------
/** @name CCActionDelay */

/**
 *  Delays the action a certain amount of seconds.
 */
@interface CCActionDelay : CCActionInterval <NSCopying>
{
}

// XXX: Added to prevent bug on BridgeSupport
-(void) update:(CCTime)dt;

@end

// -----------------------------------------------------------------
/** @name CCActionReverse */

/**
 *  Executes an action in reverse order, from time=duration to time=0
 *  Note:
 *  Use this action carefully. This action is not sequence-able. 
 *  Use it as the default "reversed" method of your own actions, but using it outside the "reversed" scope is not recommended.
 */
@interface CCActionReverse : CCActionInterval <NSCopying>
{
	CCActionFiniteTime * _other;
}

/**
 *  Creates a reverse action.
 *
 *  @param action Action to reverse
 *
 *  @return New reverse action
 */
+(id) actionWithAction: (CCActionFiniteTime*) action;

/**
 *  Initalizes a reverse action.
 *
 *  @param action Action to reverse
 *
 *  @return New reverse action
 */
-(id) initWithAction: (CCActionFiniteTime*) action;

@end

// -----------------------------------------------------------------
/** @name CCActionAnimate */

@class CCAnimation;
@class CCTexture;

/**
 *  Animates a sprite given the name of an Animation.
 */
@interface CCActionAnimate : CCActionInterval <NSCopying>
{
	NSMutableArray		*_splitTimes;
	NSInteger			_nextFrame;
	CCAnimation			*_animation;
	id					_origFrame;
	NSUInteger			_executedLoops;
}

/**
 *  Animation used for the sprite
 */
@property (readwrite,nonatomic,strong) CCAnimation * animation;

/**
 *  Creates the action with an Animation.
 *  Will restore the original frame when the animation is over
 *
 *  @param animation Animation to run
 *
 *  @return New animation action
 */
+(id) actionWithAnimation:(CCAnimation*)animation;

/**
 *  Initializes the action with an Animation.
 *  Will restore the original frame when the animation is over
 *
 *  @param animation Animation to run
 *
 *  @return New animation action
 */
-(id) initWithAnimation:(CCAnimation*)animation;

@end
