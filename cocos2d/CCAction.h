/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <UIKit/UIKit.h>
#include <sys/time.h>

#import "ccTypes.h"

enum {
	//! Default tag
	kActionTagInvalid = -1,
};

/** Base class for CCAction objects.
 */
@interface CCAction : NSObject <NSCopying> {
	id	originalTarget;
	id	target;
	int	tag;
}

/** The "target". The action will modify the target properties.
 The target will be set with the 'startWithTarget' method.
 When the 'stop' method is called, target will be set to nil.
 The target is 'assigned', it is not 'retained'.
 */
@property (nonatomic,readonly,assign) id target;

/** The original target, since target can be nil.
 Is the target that were used to run the action. Unless you are doing something complex, like ActionManager, you should NOT call this method.
 @since v0.8.2
*/
@property (nonatomic,readonly,assign) id originalTarget;


/** The action tag. An identifier of the action */
@property (nonatomic,readwrite,assign) int tag;

/** Allocates and initializes the action */
+(id) action;

/** Initializes the action */
-(id) init;

-(id) copyWithZone: (NSZone*) zone;

//! return YES if the action has finished
-(BOOL) isDone;
//! called before the action start. It will also set the target.
-(void) startWithTarget:(id)target;
//! called after the action has finished. It will set the 'target' to nil.
//! IMPORTANT: You should never call "[action stop]" manually. Instead, use: "[target stopAction:action];"
-(void) stop;
//! called every frame with it's delta time. DON'T override unless you know what you are doing.
-(void) step: (ccTime) dt;
//! called once per frame. time a value between 0 and 1
//! For example: 
//! * 0 means that the action just started
//! * 0.5 means that the action is in the middle
//! * 1 means that the action is over
-(void) update: (ccTime) time;

@end

/** Base class actions that do have a finite time duration.
 Possible actions:
   - An action with a duration of 0 seconds
   - An action with a duration of 35.5 seconds
 Infitite time actions are valid
 */
@interface CCFiniteTimeAction : CCAction <NSCopying>
{
	//! duration in seconds
	ccTime duration;
}
//! duration in seconds of the action
@property (nonatomic,readwrite) ccTime duration;

/** returns a reversed action */
- (CCFiniteTimeAction*) reverse;
@end


@class CCIntervalAction;
/** Repeats an action for ever.
 To repeat the an action for a limited number of times use the Repeat action.
 @warning This action can't be Sequenceable because it is not an IntervalAction
 */
@interface CCRepeatForever : CCAction <NSCopying>
{
	CCIntervalAction *other;
}
/** creates the action */
+(id) actionWithAction: (CCIntervalAction*) action;
/** initializes the action */
-(id) initWithAction: (CCIntervalAction*) action;
@end

/** Changes the speed of an action, making it take longer (speed>1)
 or less (speed<1) time.
 Useful to simulate 'slow motion' or 'fast forward' effect.
 @warning This action can't be Sequenceable because it is not an IntervalAction
 */
@interface CCSpeed : CCAction <NSCopying>
{
	CCIntervalAction	*other;
	float speed;
}
/** alter the speed of the inner function in runtime */
@property (nonatomic,readwrite) float speed;
/** creates the action */
+(id) actionWithAction: (CCIntervalAction*) action speed:(float)rate;
/** initializes the action */
-(id) initWithAction: (CCIntervalAction*) action speed:(float)rate;
@end
