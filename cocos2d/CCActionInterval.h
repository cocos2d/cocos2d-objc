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
 Abstract base class for interval actions. An interval action is an action that performs its task over a certain period of time.
 
 Most CCActionInterval actions can be reversed or have their speed altered via the CCActionSpeed action.
 
 ### Moving, Rotating, Scaling a Node
 
 - Moving a node along a straight line or curve:
    - CCActionMoveBy, CCActionMoveTo
    - CCActionBezierBy, CCActionBezierTo
    - CCActionCardinalSplineTo, CCActionCardinalSplineBy
    - CCActionCatmullRomBy, CCActionCatmullRomTo
 - Rotating a node:
    - CCActionRotateBy, CCActionRotateTo
 - Scaling a node:
    - CCActionScaleTo, CCActionScaleBy

 ### Animating a Node's Visual Properties
 
 - Periodically toggle visible property on/off:
    - CCActionBlink
 - Fading a node in/out/to:
    - CCActionFadeIn, CCActionFadeOut
    - CCActionFadeTo
 - Colorizing a node:
    - CCActionTintBy, CCActionTintTo
 - Skewing a node:
    - CCActionSkewTo, CCActionSkewBy
 - Animate the sprite frames of a CCSprite with CCAnimation:
    - CCActionAnimate
 - Animating a CCProgressNode:
    - CCActionProgressFromTo, CCActionProgressTo
 
 ### Repeating and Reversing Actions
 
 - Repeating an action a specific number of times:
    - CCActionRepeat
 - Reversing an action (if supported by the action):
    - CCActionReverse

 ### Creating Sequences of Actions

 - Creating a linear sequence of actions:
    - CCActionSequence
    - Wait for a given time in a CCActionSequence:
        - CCActionDelay
    - Spawning parallel running actions in a CCActionSequence and continue the sequence when all spawned actions have ended:
        - CCActionSpawn

 ### Easing the Duration of an Action
 
 - Easing duration of a CCActionInterval:
    - CCActionEase
    - CCActionEaseBackIn, CCActionEaseBackInOut, CCActionEaseBackOut
    - CCActionEaseBounce, CCActionEaseBounceIn, CCActionEaseBounceInOut, CCActionEaseBounceOut
    - CCActionEaseElastic, CCActionEaseElasticIn, CCActionEaseElasticInOut, CCActionEaseElasticOut
    - CCActionEaseRate, CCActionEaseIn, CCActionEaseInOut, CCActionEaseOut
    - CCActionEaseSineIn, CCActionEaseSineInOut, CCActionEaseSineOut

 ### Animating custom float/double Properties
 
 - Tweening any node property (of type float or double):
    - CCActionTween
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
/// @name Creating a Interval Action
/// -----------------------------------------------------------------------

/**
 *  Creates and returns an action interval object.
 *
 *  @param d Action interval.
 *
 *  @return The CCActionInterval object.
 */
+ (id)actionWithDuration:(CCTime)d;

/**
 *  Initializes and returns an action interval object.
 *
 *  @param d Action interval.
 *
 *  @return An initialized CCActionInterval Object.
 */
-(id) initWithDuration: (CCTime) d;


/// -----------------------------------------------------------------------
/// @name Reversing an Action
/// -----------------------------------------------------------------------

/**
 *  Returns a reversed action.
 *
 *  @return Created reversed action.
 */
- (CCActionInterval*) reverse;

/// -----------------------------------------------------------------------
/// @name Methods implemented by Subclasses
/// -----------------------------------------------------------------------

/**
 *  Returns YES if the action has finished.
 *
 *  @return Action finished status.
 */
-(BOOL) isDone;

@end


/** 
 This action allows actions to be executed sequentially, meaning *one after another*.
 
 Usage example with action1 through action3 being already declared actions which directly or indirectly inherit from CCActionFiniteTime:
 
    NSArray* actionsArray = @[action1, action2, action3];
    id sequence = [CCActionSequence actionsWithArray:actionsArray];
    [self runAction:sequence];

 The traditional way still works, is less verbose but potentially dangerous, see warning below:
 
    id sequence = [CCActionSequence actions:action1, action2, action3, nil];
    [self runAction:sequence];
 
 @warning Terminating the actions: list with nil is mandatory. Failure to do so will result in a compiler warning: *"Missing sentinal in method dispatch"*.
 If you run the app anyway it will cause a crash (EXC_BAD_ACCESS) when creating the sequence.
 
 @note In order to spawn multiple actions at the same time from within the sequence, use CCActionSpawn.
 */
@interface CCActionSequence : CCActionInterval <NSCopying> {
	CCActionFiniteTime *_actions[2];
	CCTime _split;
	int _last;
}

/** @name Creating a Sequence Action */

/**
 *  Helper constructor to create an array of sequence-able actions. 
 *  @warning List must be nil-terminated. Not doing so results in "Missing sentinal in method dispatch" warning, which will crash the app if ignored.
 *
 *  @param action1 First action to add to sequence.
 *  @param ...     nil-terminated list of actions to sequence.
 *
 *  @return A New action sequence.
 */
+ (id)actions: (CCActionFiniteTime*)action1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Helper constructor to create an array of sequence-able actions. 
 *  @note The usual C/C++ memory management and [va_list usage principles](http://en.wikipedia.org/wiki/Stdarg.h) apply.
 *
 *  @param action1 Action to sequence.
 *  @param args    C/C++ variadic arguments list (va_list) of actions.
 *
 *  @return New action sequence.
 */
+ (id)actions:(CCActionFiniteTime*)action1 vaList:(va_list) args;

/**
 *  Helper constructor to create an array of sequence-able actions given an array. **Recommended, safe initializer.**
 *
 *  @param arrayOfActions Array of actions to sequence.
 *
 *  @return New action sequence.
 */
+ (id)actionWithArray: (NSArray*) arrayOfActions;
- (id)initWithArray:(NSArray*)arrayOfActions;

// purposefully undocumented: no point in having this documented if you can just create a list/array with 2 actions
+ (id)actionOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;

// purposefully undocumented: no point in having this documented if you can just create a list/array with 2 actions
- (id)initOne:(CCActionFiniteTime*)actionOne two:(CCActionFiniteTime*)actionTwo;

@end


/**
 *  This action will repeat the specified action a number of times.
 *  If you wish to repeat an action forever, use CCActionRepeatForever.
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

/** @name Creating a Repeat Action */

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


/** This action can be used in a CCActionSequence to allow the sequence to spawn 2 or more actions that run in parallel to the sequence.

 Usage example with a sequence, assuming actionX and spawnActionX are previously declared, assigned and initialized with a CCActionFiniteTime or subclass:
 
    id spawn = [CCActionSpawn actionsWithArray:@[spawnAction1, spawnAction2]];
 
    NSArray* actionsArray = @[action1, spawn, action2];
    id sequence = [CCActionSequence actionsWithArray:actionsArray];
    [self runAction:sequence];
 
 This will run action1 to completion. Then spawnAction1 and spawnAction2 will run in parallel to completion. Then action4 will run after
 both spawnAction1 and spawnAction2 have run to completion. Note that if spawnAction1 and spawnAction2 have different duration, the duration
 of the longer running action will become the duration of the spawn action.
 
 @note To generally run actions in parallel you can simply call runAction: for each action rather than creating a sequence with a spawn action.
 For example, this suffices to run two actions in parallel:
 
    [self runAction:action1];
    [self runAction:action2];
 
 @note It is not meaningful to use CCActionSpawn with just one action.
 */
@interface CCActionSpawn : CCActionInterval <NSCopying> {
	CCActionFiniteTime *_one;
	CCActionFiniteTime *_two;
}

/** @name Creating a Spawn Action */

/**
 *  Helper constructor to create an array of spawned actions. Usage: `id spawn = [CCActionSpawn actions:spawnAction1, spawnAction2, nil];`
 *
 *  @warning List must be nil-terminated. Not doing so results in "Missing sentinal in method dispatch" warning, which will crash the app if ignored.
 *
 *  @param action1 First action to spawn.
 *  @param ...     Nil terminated list of action to spawn.
 *
 *  @return New action spawn.
 *  @see CCActionSequence
 */
+ (id)actions:(CCActionFiniteTime*)action1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Helper constructor to create an array of spawned actions.
 *  @note The usual C/C++ memory management and [va_list usage principles](http://en.wikipedia.org/wiki/Stdarg.h) apply.
 *
 *  @param action1 Action to spawn.
 *  @param args    C++ style list of actions.
 *
 *  @return New action spawn.
 *  @see CCActionSequence
 */
+ (id)actions:(CCActionFiniteTime*)action1 vaList:(va_list)args;

/**
 *  Helper constructor to create an array of spawned actions given an array. **Recommended, safe initializer.**
 *
 *  @param arrayOfActions Array of actions to spawn.
 *
 *  @return New action spawn.
 *  @see CCActionSequence
 */
+ (id)actionWithArray:(NSArray*)arrayOfActions;
- (id)initWithArray:(NSArray*)arrayOfActions;

// purposefully undocumented: no point in having this documented if you can just create a list/array with 2 actions
+ (id)actionOne:(CCActionFiniteTime*)one two:(CCActionFiniteTime*)two;

// purposefully undocumented: no point in having this documented if you can just create a list/array with 2 actions
- (id)initOne:(CCActionFiniteTime*)one two:(CCActionFiniteTime*)two;

@end

/**  
 This action rotates the target to the specified angle.
 The direction will be decided by the shortest route.
 
 @warning Rotate actions shouldn't be used to rotate nodes with a dynamic CCPhysicsBody unless the body has allowsRotation set to NO.
 Otherwise both the physics body and the action will alter the node's rotation property, overriding each other's changes.
 This leads to unpredictable behavior.
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

/** @name Creating a Rotate Action */

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
 *  @param simple   Simple rotation, no smart checks.
 *
 *  @return New rotate action.
 */
+ (id)actionWithDuration:(CCTime)duration angle:(float)angle simple:(bool)simple;

/**
 *  Initializes the action.
 *
 *  @param duration Action duration.
 *  @param angle    Angle to rotate to (degrees).
 *  @param simple   Simple rotation, no smart checks.
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
 This action rotates the target clockwise by the number of degrees specified. 

 @warning Rotate actions shouldn't be used to rotate nodes with a dynamic CCPhysicsBody unless the body has allowsRotation set to NO. 
 Otherwise both the physics body and the action will alter the node's rotation property, overriding each other's changes.
 This leads to unpredictable behavior.
 */
@interface CCActionRotateBy : CCActionInterval <NSCopying> {
	float _angleX;
	float _startAngleX;
	float _angleY;
	float _startAngleY;
}

/** @name Creating a Rotate Action */

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
 This action moves the target by the x,y values in the specified point value.
 X and Y are relative to the position of the object.
 Several CCMoveBy actions can be concurrently called, and the resulting movement will be the sum of individual movements.
 
 @warning Move actions shouldn't be used to move nodes with a dynamic CCPhysicsBody as both the physics body and the action
 will alter the node's position property, overriding each other's changes. This leads to unpredictable behavior.
 */
@interface CCActionMoveBy : CCActionInterval <NSCopying> {
	CGPoint _positionDelta;
	CGPoint _startPos;
	CGPoint _previousPos;
}

/** @name Creating a Move Action */

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
 This action moves the target to the position specified, these are absolute coordinates.
 Several CCMoveTo actions can be concurrently called, and the resulting movement will be the sum of individual movements.
 
 @warning Move actions shouldn't be used to move nodes with a dynamic CCPhysicsBody as both the physics body and the action
 will alter the node's position property, overriding each other's changes. This leads to unpredictable behavior.
 */
@interface CCActionMoveTo : CCActionMoveBy {
	CGPoint _endPosition;
}

/** @name Creating a Move Action */

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
 *  This action skews the target to the specified angles. Skewing changes the rectangular shape of the node to that of a parallelogram.
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

/** @name Creating a Skew Action */

/**
 *  Creates the action.
 *
 *  @param t  Action duration.
 *  @param sx X skew value in degrees, between -90 and 90.
 *  @param sy Y skew value in degrees, between -90 and 90.
 *
 *  @return New skew action.
 */
+ (id)actionWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

/**
 *  Initializes the action.
 *
 *  @param t  Action duration.
 *  @param sx X skew value in degrees, between -90 and 90.
 *  @param sy Y skew value in degrees, between -90 and 90.
 *
 *  @return New skew action.
 */
- (id)initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

@end

/**
 *  This action skews a target by the specified skewX and skewY degrees values. Skewing changes the rectangular shape of the node to that of a parallelogram.
 */
@interface CCActionSkewBy : CCActionSkewTo <NSCopying> {
}

/** @name Creating a Skew Action */

/**
 *  Initializes the action.
 *
 *  @param t  Action duration.
 *  @param sx X skew delta value in degrees, between -90 and 90.
 *  @param sy Y skew delta value in degrees, between -90 and 90.
 *
 *  @return New skew action.
 */
- (id)initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy;

@end


// purposefully undocumented: jump action is pretty much useless, especially when using it for game logic.
// Rounding errors will not make it come back down to the exact same height as before.
@interface CCActionJumpBy : CCActionInterval <NSCopying> {
	CGPoint _startPosition;
	CGPoint _delta;
	CCTime	_height;
	NSUInteger _jumps;
	CGPoint _previousPos;
}

// purposefully undocumented: see note above @interface
+ (id)actionWithDuration:(CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;

// purposefully undocumented: see note above @interface
- (id)initWithDuration:(CCTime)duration position:(CGPoint)position height:(CCTime)height jumps:(NSUInteger)jumps;

@end


// purposefully undocumented: see note above in CCActionJumpBy interface
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

/** @name Creating a Bezier Path Move Action */

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
 This action moves the target with a cubic Bezier curve to a destination point.

 See CCActionBezierBy for more information.
 */
@interface CCActionBezierTo : CCActionBezierBy {
	ccBezierConfig _toConfig;
}

@end


/**
 *  This action scales the target to the specified factor value.
 *
 *  @note This action is not reversible.
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

/** @name Creating a Scale Action */

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
 This action scales the target by the specified factor value.
 
 @note Unlike CCActionScaleTo, this action can be reversed.
 */
@interface CCActionScaleBy : CCActionScaleTo <NSCopying>

@end


/**
 *  This action performs a blinks effect on the target by altering its `visible` property periodically.
 */
@interface CCActionBlink : CCActionInterval <NSCopying> {
	NSUInteger _times;
	BOOL _originalState;
}

/** @name Creating a Blink Action */

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
 This action fades in the target, it modifies the opacity from 0 to 1.
 
 See CCActionFadeTo for more information.
 */
@interface CCActionFadeIn : CCActionInterval <NSCopying>

@end


/**
 This action fades out the target, it modifies the opacity from 1 to 0.

 See CCActionFadeTo for more information.
*/
@interface CCActionFadeOut : CCActionInterval <NSCopying>

@end


/**
 This action fades the target, it modifies the opacity from the current value to the specified value.

 @note If you want the children to fade too use [CCNode cascadeOpacityEnabled] to enable this behavior in the node.
 */
@interface CCActionFadeTo : CCActionInterval <NSCopying> {
	CGFloat _toOpacity;
	CGFloat _fromOpacity;
}

/** @name Creating a Fade Action */

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
 *  This action tints (colorizes) the target from current color to the specified color.
 *
 *  @note This action is not reversible.
 */
@interface CCActionTintTo : CCActionInterval <NSCopying> {
	CCColor* _to;
	CCColor* _from;
}

/** @name Creating a Colorize Action */

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
 *  This action tints (colorizes) the target from current color to the specified color.
 *  @note Contrary to CCActionTintTo, this action is reversible.
 */
@interface CCActionTintBy : CCActionInterval <NSCopying> {
	CGFloat _deltaR, _deltaG, _deltaB;
	CGFloat _fromR, _fromG, _fromB;
}

/** @name Creating a Colorize Action */

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
 This action waits for the time specified. Used in sequences to delay (pause) the sequence for a given time.
 
 Example, wait for 2 seconds:
 
    id delay = [CCActionDelay actionWithDuration:2.0];
 */
@interface CCActionDelay : CCActionInterval <NSCopying>

@end

/**
 *  This action executes the specified action in reverse order.
 *
 *  @note This action can not be used in a CCActionSequence. Not all actions are reversible.
 *  Use it as the default "reversed" method of your own actions, but using it outside the "reversed" scope is not recommended.
 */
@interface CCActionReverse : CCActionInterval <NSCopying> {
	CCActionFiniteTime * _other;
}

/** @name Creating a Reverse Action */

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

/** Animates a sprite given the name of an Animation.
 
 @note This action can only be run on CCSprite nodes.
 */
@interface CCActionAnimate : CCActionInterval <NSCopying> {
	NSMutableArray		*_splitTimes;
	NSInteger			_nextFrame;
	CCAnimation			*_animation;
	id					_origFrame;
	NSUInteger			_executedLoops;
}

// Animation used for the sprite.
@property (readwrite,nonatomic,strong) CCAnimation * animation;

/** @name Creating a Animation Action */

/**
  Creates the action with an Animation.
  Will restore the original frame when the animation is over

  @param animation Animation to run

  @return New animation action
  @see CCAnimation
*/
+(instancetype) actionWithAnimation:(CCAnimation*)animation;

/**
  Initializes the action with an Animation.
  Will restore the original frame when the animation is over

  @param animation Animation to run

  @return New animation action
  @see CCAnimation
*/
-(id) initWithAnimation:(CCAnimation*)animation;

@end
