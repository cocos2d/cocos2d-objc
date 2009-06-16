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

#import <UIKit/UIKit.h>
#include <sys/time.h>

#import "ccTypes.h"

enum {
	//! Default tag
	kActionTagInvalid = -1,
};

@class CocosNode;
/** Base class for actions
 */
@interface Action : NSObject <NSCopying> {
	CocosNode *target;
	int tag;
}

/** The "target". The action will modify the target properties */
@property (readwrite,assign) CocosNode *target;
/** The action tag. An identifier of the action */
@property (readwrite,assign) int tag;

+(id) action;
-(id) init;

-(id) copyWithZone: (NSZone*) zone;

//! called before the action start
-(void) start;
//! return YES if the action has finished
-(BOOL) isDone;
//! called after the action has finished
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
@interface FiniteTimeAction : Action <NSCopying>
{
	//! duration in seconds
	ccTime duration;
}
//! duration in seconds of the action
@property (readwrite) ccTime duration;

/** returns a reversed action */
- (FiniteTimeAction*) reverse;
@end


@class IntervalAction;
/** Repeats an action for ever.
 To repeat the an action for a limited number of times use the Repeat action.
 @warning This action can't be Sequenceable because it is not an IntervalAction
 */
@interface RepeatForever : Action <NSCopying>
{
	IntervalAction *other;
}
/** creates the action */
+(id) actionWithAction: (IntervalAction*) action;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action;
@end

/** Changes the speed of an action, making it take longer (speed>1)
 or less (speed<1) time.
 Useful to simulate 'slow motion' or 'fast forward' effect.
 @warning This action can't be Sequenceable because it is not an IntervalAction
 */
@interface Speed : Action <NSCopying>
{
	IntervalAction	*other;
	float speed;
}
/** alter the speed of the inner function in runtime */
@property (readwrite) float speed;
/** creates the action */
+(id) actionWithAction: (IntervalAction*) action speed:(float)rate;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action speed:(float)rate;
@end
