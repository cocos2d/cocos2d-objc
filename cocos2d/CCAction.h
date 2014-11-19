/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

#include <sys/time.h>
#import <Foundation/Foundation.h>

#import "ccTypes.h"

enum {
	//! Default tag
	kCCActionTagInvalid = -1,
};

/**
 * CCAction forms the foundation for one the great areas of Cocos2D functionality.
 * The manipulatinon of node properties such as position, rotation, scale and opacity over time, to create fun effects.
 *
 * - Actions can be modified with easing actions to create more realistic animations. 
 * - Actions can be put in sequence to create more complex animation sequences.
 *
 */
@interface CCAction : NSObject <NSCopying> {
	id			__unsafe_unretained _originalTarget;
	id			__unsafe_unretained _target;
	NSInteger	_tag;
}


/// -----------------------------------------------------------------------
/// @name Accessing Action Attributes
/// -----------------------------------------------------------------------

/**
 *  The "target". The action will modify the target properties.
 *  The target will be set with the 'startWithTarget' method.
 *  When the 'stop' method is called, target will be set to nil.
 *  The target is 'assigned', it is not 'retained'.
 */
@property (nonatomic,readonly,unsafe_unretained) id target;

/** The original target, since target can be nil. */
@property (nonatomic,readonly,unsafe_unretained) id originalTarget;

/** The action tag. An identifier of the action. */
@property (nonatomic,readwrite,assign) NSInteger tag;


/// -----------------------------------------------------------------------
/// @name Creating a CCAction Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns an action object.
 *
 *  @return The CCAction Object.
 */
+ (id)action;


/// -----------------------------------------------------------------------
/// @name Initializing a CCAction Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns an action object.
 *
 *  @return An initialized CCAction Object.
 */
- (id)init;

// NSCopying support.
- (id)copyWithZone:(NSZone*) zone;


/// -----------------------------------------------------------------------
/// @name Action Management
/// -----------------------------------------------------------------------

/**
 *  Return YES if the action has finished.
 *
 *  @return Action completion status
 */
- (BOOL)isDone;

/**
 *  Assigns a target to the action
 *  Called before the action is started.
 *
 *  @param target Target to assign to action (weak reference).
 */
- (void)startWithTarget:(id)target;

/**
 *  Stops the action
 *  Called after the action has finished. Will assign the internal target reference to nil.
 *  Note:
 *  You should never call this method directly. 
 *  In stead use: [target stopAction:action]
 */
- (void)stop;

/**
 *  Steps the action.
 *  Called for every frame with step interval.
 *
 *  Note:
 *  Do not override unless you know what you are doing.
 *
 *  @param dt Ellapsed interval since last step.
 */
- (void)step:(CCTime)dt;

/**
 *  Updates the action with normalized value.
 *
 *  For example:
 *  A value of 0.5 indicates that the action is 50% complete.
 *
 *  @param time Normalized action progress.
 */
- (void)update:(CCTime)time;

@end

#pragma mark - CCActionFiniteTime

//
//  Base class for actions that have a finite time duration.
//
//  Possible actions:
//  - An action with a duration of 0 seconds.
//  - An action with a duration of 35.5 seconds.
//
@interface CCActionFiniteTime : CCAction <NSCopying> {
	// Duration in seconds.
	CCTime _duration;
}

// Duration of the action in seconds.
@property (nonatomic,readwrite) CCTime duration;

//
//  Returns a reversed action.
//
//  @return The reversed action object.
//
- (CCActionFiniteTime *)reverse;

@end

#pragma mark - CCActionRepeatForever

@class CCActionInterval;

/**
 *  Repeats an action indefinitely (until stopped).
 *  To repeat the action for a limited number of times use the CCActionRepeat action.
 *
 *  @note This action can not be used within a CCActionSequence because it is not an CCActionInterval action.
 *  However you can use CCActionRepeatForever to repeat a CCActionSequence.
 */
@interface CCActionRepeatForever : CCAction <NSCopying> {
	CCActionInterval *_innerAction;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Repeat Forever Action Attributes
/// -----------------------------------------------------------------------

/** Inner action. */
@property (nonatomic, readwrite, strong) CCActionInterval *innerAction;


/// -----------------------------------------------------------------------
/// @name Creating a CCActionRepeatForever Object
/// -----------------------------------------------------------------------

/**
 *  Creates the repeat forever action.
 *
 *  @param action Action to repeat forever.
 *
 *  @return The repeat action object.
 */
+ (id)actionWithAction:(CCActionInterval *) action;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionRepeatForever Object
/// -----------------------------------------------------------------------

/**
 *  Initalizes the repeat forever action.
 *
 *  @param action Action to repeat forever
 *
 *  @return An initialised repeat action object.
 */
- (id)initWithAction:(CCActionInterval *) action;

@end

#pragma mark - CCActionSpeed

/**
 Allows you to change the speed of an action while the action is running. Useful to simulate slow motion or fast forward effects.
 Can also be used to implement custom easing effects without having to create your own CCActionEase subclass.
 
 You will need to keep a reference to the speed action in order to change its `speed` property. It is best to assign
 the speed action to an ivar or property with the `__weak` (ivar) or `weak` (@property) keyword.
 
 For instance:
 
    @implementation YourClass
    {
        __weak CCActionSpeed* _speed;
    }
 
 Now you can create an action whose speed you want to be able to alter while the action is running:
 
    id move = [CCMoveBy actionWithDuration:60 position:ccp(600, 0)];
    _speed = [CCActionSpeed actionWithAction:move speed:1];
 
 The speed factor of 1 will start running the `move` action at its normal speed. Later when you determined that it's
 time to change the speed of the `move` action, just change the `_speed` action's `speed` property:
 
    -(void) update:(CCTime)deltaTime
    {
        if (slowMotionMode) {
            _speed.speed = 0.2f; // move at one fifth of the regular speed
        } else {
            _speed.speed = 1.0f; // move at regular speed
        }
    }
 
 When the move action has run to completion it will end and thanks to the `__weak` keyword and ARC the `_speed` ivar will
 automatically become `nil`.
 
 @note CCActionSpeed can not be added to a CCActionSequence because it does not inherit from CCActionFiniteTime.
 It can however be used to control the speed of an entire CCActionSequence.
 */
@interface CCActionSpeed : CCAction <NSCopying> {
	CCActionInterval	*_innerAction;
	CGFloat _speed;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Speed Action Attributes
/// -----------------------------------------------------------------------

/** 
 * Alter the speed of the controlled action at runtime.
 *
 * - Speeds below 1.0 will make the action run slower.
 * - Speeds above 1.0 will make the action run faster.
 */
@property (nonatomic,readwrite) CGFloat speed;

// purposefully undocumented: it seems this shouldn't be user-assignable as newly assigned actions
// may be left in an undefined state (they don't get the start message send)
@property (nonatomic, readwrite, strong) CCActionInterval *innerAction;


/// -----------------------------------------------------------------------
/// @name Creating a CCActionSpeed Object
/// -----------------------------------------------------------------------

/**
 *  Creates the speed action.
 *
 *  @param action Action to modify for speed.
 *  @param value  Initial action speed.
 *
 *  @return The CCActionSpeed object.
 */
+ (id)actionWithAction:(CCActionInterval *)action speed:(CGFloat)value;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionSpeed Object
/// -----------------------------------------------------------------------

/**
 *  Initalizes the speed action.
 *
 *  @param action Action to modify for speed.
 *  @param value  Initial action speed.
 *
 *  @return An initialized CCActionSpeed object.
 */
- (id)initWithAction:(CCActionInterval *)action speed:(CGFloat)value;

@end

#pragma mark - CCActionFollow

@class CCNode;

/**
 Creates an action which follows a node. The followed node can be moved by any means available 
 (ie move action, physics velocity, changing position property). The target node will be moved in the opposite direction
 to keep it centered on the followed node.
 
 A boundary can be specified to prevent the target's position to leave a certain area. Note that this area must be smaller
 to account for the fact that the followed node is at the center but you will probably want the following to stop when
 the border of the target node reaches the boundary (ie typicall the screen border).
 
 Smoothly following a node or keeping it off-center is not supported. Look at the CCActionFollow code to create a 
 custom action with those features. There's also an explanation [Centering the Scene on a Node](https://developer.apple.com/library/ios/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Actions/Actions.html#//apple_ref/doc/uid/TP40013043-CH4-SW32)
 in the Sprite Kit documentation - the same principle can be applied to Cocos2D and is used by CCActionFollow.
 
 Usage example:
 
    id follow = [CCFollow actionWithTarget:playerNode];
    [gameLayerNode runAction:follow];

 Whenever `playerNode` changes its position, the position of `gameLayerNode` will be updated (moved in the opposite direction)
 to keep `playerNode` centered.
 */
@interface CCActionFollow : CCAction <NSCopying> {
    
	// Node to follow.
	CCNode	*_followedNode;

	// Whether camera should be limited to certain area.
	BOOL _boundarySet;

	// If screen-size is bigger than the boundary - update not needed.
	BOOL _boundaryFullyCovered;

	// Fast access to the screen dimensions.
	CGPoint _halfScreenSize;
	CGPoint _fullScreenSize;

	// World boundaries.
	float _leftBoundary;
	float _rightBoundary;
	float _topBoundary;
	float _bottomBoundary;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Follow Action Attributes
/// -----------------------------------------------------------------------

/** Turns boundary behaviour on / off.  If set to YES, movement will be clamped to boundaries. */
@property (nonatomic,readwrite) BOOL boundarySet;


/// -----------------------------------------------------------------------
/// @name Creating a CCActionFollow Object
/// -----------------------------------------------------------------------

/**
 *  Creates a follow action with no boundaries.
 *
 *  @param followedNode Node to follow.
 *
 *  @return The follow action object.
 */
+ (id)actionWithTarget:(CCNode *)followedNode;

/**
 *  Creates a follow action with boundaries.
 *
 *  @param followedNode Node to follow.
 *  @param rect         Boundary rect.
 *
 *  @return The follow action object.
 */
+ (id)actionWithTarget:(CCNode *)followedNode worldBoundary:(CGRect)rect;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionFollow Object
/// -----------------------------------------------------------------------

/**
 *  Initalizes a follow action with no boundaries.
 *
 *  @param followedNode Node to follow.
 *
 *  @return An initialized follow action object.
 */
- (id)initWithTarget:(CCNode *)followedNode;

/**
 *  Initalizes a follow action with boundaries.
 *
 *  @param followedNode Node to follow.
 *  @param rect         Boundary rect.
 *
 *  @return The initalized follow action object.
 */
- (id)initWithTarget:(CCNode *)followedNode worldBoundary:(CGRect)rect;

@end

