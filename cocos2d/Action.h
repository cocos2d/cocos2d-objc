/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
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
#import "chipmunk.h"

@class CocosNode;
/** Base class for actions
 */
@interface Action : NSObject <NSCopying> {
	CocosNode *target;	
}

@property (readwrite,retain) CocosNode *target;

+(id) action;
-(id) init;

-(id) copyWithZone: (NSZone*) zone;

//! called before the action start
-(void) start;
//! return YES if the action has finished
-(BOOL) isDone;
//! called after the action has finished
-(void) stop;
-(void) step: (ccTime) dt;
//! called once per frame. time a value between 0 and 1
//! For example: 
//! * 0 means that the action just started
//! * 0.5 means that the action is in the middle
//! * 1 means that the action is over
-(void) update: (ccTime) time;

@end


@class IntervalAction;
/** Repeats an action for ever.
 * To repeat the an action for a limited number of times use the Repeat action.
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
