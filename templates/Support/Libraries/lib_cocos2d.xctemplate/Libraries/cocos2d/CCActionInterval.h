/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 *  CCAction *pingPongAction = [CCActionSequence actions: action, [action reverse], nil];
 */
@interface CCActionInterval: CCActionFiniteTime <NSCopying> {
	CCTime	_elapsed;
	BOOL	_firstTick;
}

/** 
 *  How many seconds had elapsed since the actions started to run. 
 */
@property (nonatomic,readonly) CCTime elapsed;


/// -----------------------------------------------------------------------
/// @name Creating a CCActionInterval Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns an action interval object.
 *
 *  @param d Action interval.
 *
 *  @return The CCActionInterval object.
 */
+ (id)actionWithDuration:(CCTime)d;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionInterval Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns an action interval object.
 *
 *  @param d Action interval.
 *
 *  @return An initialized CCActionInterval Object.
 */
-(id) initWithDuration: (CCTime) d;


/// -----------------------------------------------------------------------
/// @name CCActionInterval Management
/// -----------------------------------------------------------------------

/**
 *  Returns YES if the action has finished.
 *
 *  @return Action finished status.
 */
-(BOOL) isDone;

/**
 *  Returns a reversed action.
 *
 *  @return Created reversed action.
 */
- (CCActionInterval*) reverse;

@end


/** 
 *  This action allows actions to be executed sequentially e.g. one after another.
 */
@interface CCActionSequence : CCActionInterval <NSCopying> {
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
+ (id)actions: (CCActionFiniteTime*)action1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Helper constructor to create an array of sequence-able actions.
 *
 *  @param action1 Action to sequence.
 *  @param args    C++ style list of actions.
 *
 *  @return New action sequence.
 */
+ (id)actions:(CCActionFiniteTime*)action1 vaList:(va_list) args;

/**
 *  Helper constructor to create an array of sequence-able actions given an array.
 *
 *  @param arrayOfActions Array of actions to sequence.
 *
 *  @return New action sequence.
 */
+ (id)actionWithArray: (NSArray*) arrayOfActions;

/**
 *  Creates an action sequence from two actions.
 *
 *  @param actionOne Action one.
 *  @param actionTwo Action two.
 *
 *  @return New action sequence.
 */
+ (id)actionOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;

/**
 *  Initializes an action sequence with two actions.
 *
 *  @param actionOne Action one.
 *  @param actionTwo Action two.
 *
 *  @return New action sequence.
 */
- (id)initOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;

@end


/**
 *  This action will repeat the specified action a number of times.
 *  If you wish to repeat an action forever, please use the CCRepeatForever action.
 */
@interface CCActionRepeat : CCActionInterval <NSCopying> {
	NSUInteger _times;
	NSUInteger _total;
	CCTime _nextDt;
	BOOL _isActionInstant;
	CCActionFiniteTime *_innerAction;
}

// Inner action
@property (nonatomic,readwrite,strong) CCActionFiniteTime *innerAction;

/**
 *  Creates a repeat action.
 *  Times is an unsigned integer between 1 and MAX_UINT.
 *
 *  @param action Action to repeat.
 *  @param times  Number of times to repeat action.
 *
 *  @return New action repeat
 */
+ (id) actionWithAction:(CCActionFiniteTime*)action times:(NSUInteger)times;

/**
 *  Initializes a CCRepeat action.
 *  Times is an unsigned integer between 1 and MAX_UINT.
 *
 *  @param action Action to repeat.
 *  @param times  Number of times to repeat action.
 *
 *  @return New action repeat.
 */
- (id)initWithAction:(CCActionFiniteTime*)action times:(NSUInteger)times;

@end


/** 
 * This action can be used to execute two to actions in parallel.
 */
@interface CCActionSpawn : CCActionInterval <NSCopying> {
	CCActionFiniteTime *_one;
	CCActionFiniteTime *_two;
}

/**
 *  Helper constructor to create an array of spawned actions.
 *
 *  @param action1 First action to spawn.
 *  @param ...     Nil terminated list of action to spawn.
 *
 *  @return New action spawn.
 */
+ (id)actions:(CCActionFiniteTime*)action1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Helper constructor to create an array of spawned actions.
 *
 *  @param action1 Action to spawn.
 *  @param args    C++ style list of actions.
 *
 *  @return New action spawn.
 */
+ (id)actions:(CCActionFiniteTime*)action1 vaList:(va_list)args;

/**
 *  Helper constructor to create an array of spawned actions given an array.
 *
 *  @param arrayOfActions Array of actions to spawn.
 *
 *  @return New action spawn.
 */
+ (id)actionWithArray:(NSArray*)arrayOfActions;

/**
 *  Creates the Spawn action from two actions
 *
 *  @param one Action one.
 *  @param two Action two.
 *
 *  @return New action spawn.
 */
+ (id)actionOne:(CCActionFiniteTime*)one two:(CCActionFiniteTime*)two;

/**
 *  Initializes the Spawn action with the 2 actions to spawn.
 *
 *  @param one Action one.
 *  @param two Action two.
 *
 *  @return New action spawn.
 */
- (id)initOne:(CCActionFiniteTime*)one two:(CCActionFiniteTime*)two;

@end

/**  
 *  This action rotates the target to the specified angle.
 *  The direction will be decided by the shortest route.
 */
@interface CCActionRotateTo : CCActionInterval <NSCopying> {
	float _dstAngleX;
	float _startAngleX;
	float _diffAngleX;
  
	float _dstAngleY;
	float _startAngleY;
	float _diffAngleY;
    
    bool _rotateX;
    bool _rotateY;
    
    bool _simple;
}

/**
 *  Creates the action.
 *
 *  @param duration Action duration.
 *  @param angle    Angle to rotate to (degrees).
 *
 *  @return New rotate action.
 */
+ (id)actionWithDuration:(CCTime)duration angle:(float)angle;

/**
 *  Creates the action.
 *
 *  @param duration Action duration.
 *  @param angle    Angle to rotate to (degrees).
 *  @param direct   Simple rotation, no smart checks.
 *
 *  @return New rotate action.
 */
+ (id)actionWithDuration:(CCTime)duration angle:(float)angle simple:(bool)simple;

/**
 *  Initializes the action.
 *
 *  @param duration Action duration.
 *  @param angle    Angle to rotate to (degrees).
 *  @param direct   Simple rotation, no smart checks.
 *
 *  @return New rotate action
 */
- (id)initWithDuration:(CCTime)duration angle:(float)angle simple:(bool)simple;

/**
 *  Initializes the action.
 *
 *  @param duration Action duration.
 *  @param angle    Angle to rotate to (degrees).
 *
 *  @return New rotate action
 */
- (id)initWithDuration:(CCTime)duration angle:(float)angle;

/**
 *  Creates the action with angleX rotation angle.
 *
 *  @param t  Action duration.
 *  @param aX X rotation in degrees.
 *
 *  @return New rotate action.
 */
+ (id)actionWithDuration:(CCTime)t angleX:(float)aX;

/**
 *  Initializes the action with angleX rotation angle.
 *
 *  @param t  Action duration.
 *  @param aX X rotation in degrees.
 *
 *  @return New rotate action.
 */
- (id)initWithDuration:(CCTime)t angleX:(float)aX;

/**
 *  Creates the action with angleY rotation angle.
 *
 *  @param t  Action duration.
 *  @param aY Y rotation in degrees.
 *
 *  @return New rotate action.
 */
+ (id)actionWithDuration:(CCTime)t angleY:(float)aY;

/**
 *  Initializes the action with angleY rotation angle.
 *
 *  @param t  Action duration.
 *  @param aY Y rotation in degrees.
 *
 *  @return New rotate action.
 */
- (id)initWithDuration:(CCTime)t angleY:(float)aY;

@end


/** 
 *  This action rotates the target clockwise by the number of degrees specified. 
 */
@interface CCActionRotateBy : CCActionInterval <NSCopying> {
	float _angleX;
	float _startAngleX;
	float _angleY;
	float _startAngleY;
}

/**
 *  Creates the action.
 *
 *  @param duration   Action duration.
 *  @param deltaAngle Delta angle in degrees.
 *
 *  @return New rotate action.
 */
+ (id)actionWithDuration:(CCTime)duration angle:(float)deltaAngle;

/**
 *  Initializes the action.
 *
 *  @param duration   Action duration.
 *  @param deltaAngle Delta angle in degrees.
 *
 *  @return New rotate action.
 */
- (id)initWithDuration:(CCTime)duration angle:(float)deltaAngle;

/**
 *  Creates the action with separate rotation angles.
 *
 *  @param t  Action duration.
 *  @param aX X rotation in degrees.
 *  @param aY Y rotation in degrees.
 *
 *  @return New rotate action.
 */
+ (id)actionWithDuration:(CCTime)t angleX:(float)aX angleY:(float)aY;

/**
 *  Initializes the action with separate rotation angles.
 *
 *  @param t  Action duration.
 *  @param aX X rotation in degrees.
 *  @param aY Y rotation in degrees.
 *
 *  @return New rotate action.
 */
- (id)initWithDuration:(CCTime)t angleX:(float)aX angleY:(float)aY;

@end


/**  
 *  This action moves the target by the x,y values in the specified point value.
 *  X and Y are relative to the position of the object.
 *  Several CCMoveBy actions can be concurrently called, and the resulting movement will be the sum of individual movements.
 */
@interface CCActionMoveBy : CCActionInterval <NSCopying> {
	CGPoint _positionDelta;
	CGPoint _startPos;
	CGPoint _previousPos;
}

/**
 *  Creates the action.
 *
 *  @param duration      Action interval.
 *  @param deltaPosition Delta position.
 *
 *  @return New moveby action.
 */
+ (id)actionWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;

/**
 *  Initializes the action.
 *
 *  @param duration      Action interval.
 *  @param deltaPosition Delta position.
 *
 *  @return New moveby action.
 */
- (id)initWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;

@end


/** 
 *  This action moves the target to the position specified, these are absolute coordinates. 
 *  Several CCMoveTo actions can be concurrently called, and the resulting movement will be the sum of individual movements.
 */
@interface CCActionMoveTo : CCActionMoveBy {
	CGPoint _endPosition;
}

/**
 *  Creates the action.
 *
 *  @param duration Action interval.
 *  @param position Absolute position to move to.
 *
 *  @return New moveto action.
 */
+ (id)actionWithDuration:(CCTime)duration position:(CGPoint)position;

/**
 *  Initializes the action.
 *
 *  @param duration Action interval.
 *  @param position Absolute position to move to.
 *
 *  @return New moveto action.
 */
- (id)initWithDuration:(CCTime)duration position:(CGPoint)position;

@end


/**
 *  This action skews the target to the specified angles.
 */
@interface CCActionSkewTo : CCActionInterval <NSCopying> {
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
 *  @param t  Action duration.
 *  @param sx X skew value.
 *  @param sy Y skew value.
 *
 *  @return New skew action.
 */
+ (id)actionWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

/**
 *  Initializes the action.
 *
 *  @param t  Action duration.
 *  @param sx X skew value in degrees.
 *  @param sy Y skew value in degrees.
 *
 *  @return New skew action.
 */
- (id)initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

@end

/**
 *  This action skews a target by the specified skewX and skewY degrees values.
 */
@interface CCActionSkewBy : CCActionSkewTo <NSCopying> {
}

/**
 *  Initializes the action.
 *
 *  @param t  Action duration.
 *  @param sx X skew delta value in degrees.
 *  @param sy Y skew delta value in degrees.
 *
 *  @return New skew action.
 */
- (id)initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

@end


/**
 *  This action moves the target simulating a parabolic jump movement by modifying its position attribute.
 */
@interface CCActionJumpBy : CCActionInterval <NSCopying> {
	CGPoint _startPosition;
	CGPoint _delta;
	CCTime	_height;
	NSUInteger _jumps;
	CGPoint _previousPos;
}

/**
 *  Creates the action.
 *
 *  @param duration Action duration.
 *  @param position Delta position.
 *  @param height   Height of jump.
 *  @param jumps    Number of jumps to perform.
 *
 *  @return New jump action.
 */
+ (id)actionWithDuration:(CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;

/**
 *  Initializes the action.
 *
 *  @param duration Action duration.
 *  @param position Delta position.
 *  @param height   Height of jump.
 *  @param jumps    Number of jumps to perform.
 *
 *  @return New jump action
 */
- (id)initWithDuration:(CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;

@end


/**
 * This action moves the target to the specified position simulating a parabolic jump movement.
 */
@interface CCActionJumpTo : CCActionJumpBy <NSCopying>

@end


// Bezier configuration structure.
typedef struct _ccBezierConfig {
	// End position of the bezier.
	CGPoint endPosition;
	// Bezier control point 1.
	CGPoint controlPoint_1;
	// Bezier control point 2.
	CGPoint controlPoint_2;
} ccBezierConfig;

/**
 *  This action that moves the target with a cubic Bezier curve by a certain distance.
 */
@interface CCActionBezierBy : CCActionInterval <NSCopying> {
	ccBezierConfig _config;
	CGPoint _startPosition;
	CGPoint _previousPosition;
}

/**
 *  Creates the action with a duration and a bezier configuration.
 *
 *  @param t Action duration.
 *  @param c Bezier configuration.
 *
 *  @return New bezier action.
 */
+ (id)actionWithDuration:(CCTime)t bezier:(ccBezierConfig)c;

/**
 *  Initializes the action with a duration and a bezier configuration.
 *
 *  @param t Action duration.
 *  @param c Bezier configuration.
 *
 *  @return New bezier action.
 */
- (id)initWithDuration:(CCTime)t bezier:(ccBezierConfig)c;

@end


/**
 *  This action moves the target with a cubic Bezier curve to a destination point.
 */
@interface CCActionBezierTo : CCActionBezierBy {
	ccBezierConfig _toConfig;
}

@end


/**
 *  This action scales the target to the specified factor value.
 *
 *  Note:
 *  This action doesn't support "reverse"
 */
@interface CCActionScaleTo : CCActionInterval <NSCopying> {
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
 *  @param duration Action duration.
 *  @param s        Scale to scale to.
 *
 *  @return New scale action.
 */
+ (id)actionWithDuration:(CCTime)duration scale:(float)s;

/**
 *  Initializes the action with the same scale factor for X and Y.
 *
 *  @param duration Action duration.
 *  @param s        Scale to scale to.
 *
 *  @return New scale action.
 */
- (id)initWithDuration:(CCTime)duration scale:(float)s;

/**
 *  Creates the action with individual scale factor for X and Y.
 *
 *  @param duration Action duration.
 *  @param sx       X scale to scale to.
 *  @param sy       Y scale to scale to.
 *
 *  @return New scale action.
 */
+ (id)actionWithDuration:(CCTime)duration scaleX:(float)sx scaleY:(float)sy;

/**
 *  Initializes the action with individual scale factor for X and Y.
 *
 *  @param duration Action duration.
 *  @param sx       X scale to scale to.
 *  @param sy       Y scale to scale to.
 *
 *  @return New scale action.
 */
- (id)initWithDuration:(CCTime)duration scaleX:(float)sx scaleY:(float)sy;

@end


/**
 *  This action scales the target by the specified factor value.
 */
@interface CCActionScaleBy : CCActionScaleTo <NSCopying>

@end


/**
 *  This action performs a blinks effect on the target.
 */
@interface CCActionBlink : CCActionInterval <NSCopying> {
	NSUInteger _times;
	BOOL _originalState;
}

/**
 *  Creates the blink action.
 *
 *  @param duration Action duration.
 *  @param blinks   Number of times to blink.
 *
 *  @return New blink action.
 */
+ (id)actionWithDuration:(CCTime)duration blinks:(NSUInteger)blinks;

/**
 *  Initializes the blink action
 *
 *  @param duration Action duration
 *  @param blinks   Number of times to blink
 *
 *  @return New blink action
 */
-(id) initWithDuration:(CCTime)duration blinks:(NSUInteger)blinks;

@end


/**
 *  This action fades in the target, it modifies the opacity from 0 to 1. 
 *  Notes:
 *  Works with cascadeOpacity, if you want children to fade too.
 */
@interface CCActionFadeIn : CCActionInterval <NSCopying>

@end


/**
 *  This action fades out the target, it modifies the opacity from 1 to 0.
 *  Notes:
 *  Works with cascadeOpacity, if you want children to fade too.
 */
@interface CCActionFadeOut : CCActionInterval <NSCopying>

@end


/**
 *  This action fades the target, it modifies the opacity from the current value to the specified value.
 *  Notes:
 *  Works with cascadeOpacity, if you want children to fade too.
 */
@interface CCActionFadeTo : CCActionInterval <NSCopying> {
	CGFloat _toOpacity;
	CGFloat _fromOpacity;
}

/**
 *  Creates a fade action.
 *
 *  @param duration Action duration.
 *  @param opactiy  Opacity to fade to.
 *
 *  @return New fade action.
 */
+ (id)actionWithDuration:(CCTime)duration opacity:(CGFloat)opactiy;

/**
 *  Initalizes a fade action.
 *
 *  @param duration Action duration.
 *  @param opacity  Opacity to fade to.
 *
 *  @return New fade action.
 */
- (id)initWithDuration:(CCTime)duration opacity:(CGFloat)opacity;

@end


/**
 *  This action tints the target from current tint to the specified value.
 *
 *  Note:
 *  This action doesn't support "reverse"
 */
@interface CCActionTintTo : CCActionInterval <NSCopying> {
	CCColor* _to;
	CCColor* _from;
}

/**
 *  Creates a tint to action.
 *
 *  @param duration     Action duration.
 *  @param color		Destination color tint to.
 *
 *  @return New tint to action.
 */
+ (id)actionWithDuration:(CCTime)duration color:(CCColor*)color;

/**
 *  Initalizes a tint to action.
 *
 *  @param duration     Action duration.
 *  @param color		Destination color tint to.
 *
 *  @return New tint to action.
 */
- (id)initWithDuration:(CCTime)duration color:(CCColor*)color;

@end


/**
 *  This action tints the target from current tint by the value specified.
 */
@interface CCActionTintBy : CCActionInterval <NSCopying> {
	CGFloat _deltaR, _deltaG, _deltaB;
	CGFloat _fromR, _fromG, _fromB;
}

/**
 *  Creates a tint by action.
 *
 *  @param duration   Action duration.
 *  @param deltaRed   Red delta color to tint.
 *  @param deltaGreen Green delta color to tint.
 *  @param deltaBlue  Blue delta color to tint.
 *
 *  @return New tint by action.
 */
+ (id)actionWithDuration:(CCTime)duration red:(CGFloat)deltaRed green:(CGFloat)deltaGreen blue:(CGFloat)deltaBlue;

/**
 *  Initalizes a tint by action.
 *
 *  @param duration   Action duration.
 *  @param deltaRed   Red delta color to tint.
 *  @param deltaGreen Green delta color to tint.
 *  @param deltaBlue  Blue delta color to tint.
 *
 *  @return New tint by action.
 */
- (id)initWithDuration:(CCTime)duration red:(CGFloat)deltaRed green:(CGFloat)deltaGreen blue:(CGFloat)deltaBlue;

@end

/**
 *  This action creates a delay by the time specified, useful in sequences.
 */
@interface CCActionDelay : CCActionInterval <NSCopying>

@end

/**
 *  This action executes the specified action in reverse order.
 *
 *  Note:
 *  Use this action carefully. This action is not sequence-able. 
 *  Use it as the default "reversed" method of your own actions, but using it outside the "reversed" scope is not recommended.
 */
@interface CCActionReverse : CCActionInterval <NSCopying> {
	CCActionFiniteTime * _other;
}

/**
 *  Creates a reverse action.
 *
 *  @param action Action to reverse.
 *
 *  @return New reverse action.
 */
+ (id)actionWithAction: (CCActionFiniteTime*)action;

/**
 *  Initalizes a reverse action.
 *
 *  @param action Action to reverse.
 *
 *  @return New reverse action.
 */
- (id)initWithAction:(CCActionFiniteTime*)action;

@end


@class CCAnimation;
@class CCTexture;

// Animates a sprite given the name of an Animation.
@interface CCActionAnimate : CCActionInterval <NSCopying> {
	NSMutableArray		*_splitTimes;
	NSInteger			_nextFrame;
	CCAnimation			*_animation;
	id					_origFrame;
	NSUInteger			_executedLoops;
}

// Animation used for the sprite.
@property (readwrite,nonatomic,strong) CCAnimation * animation;

//
//  Creates the action with an Animation.
//  Will restore the original frame when the animation is over
//
//  @param animation Animation to run
//
//  @return New animation action
//
+(id) actionWithAnimation:(CCAnimation*)animation;

//
//  Initializes the action with an Animation.
//  Will restore the original frame when the animation is over
//
//  @param animation Animation to run
//
//  @return New animation action
//
-(id) initWithAnimation:(CCAnimation*)animation;

@end
