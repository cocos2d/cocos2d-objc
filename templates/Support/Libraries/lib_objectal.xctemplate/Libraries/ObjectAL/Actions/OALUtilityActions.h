//
//  OALUtilityActions.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-10-10.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//

#import "OALAction.h"


#pragma mark OALTargetedAction

/**
 * Ignores whatever target it was invoked upon and applies the specified action
 * on the target specified at creation time.
 */
@interface OALTargetedAction: OALAction
{
	/** The action that will be run on the target. */
	OALAction* action_;
}

/** The target which this action will actually be invoked upon. */
@property(nonatomic,readwrite,assign) id forcedTarget;

/** Create an action.
 *
 * @param target The target to run the action upon.
 * @param action The action to run.
 * @return A new action.
 */
+ (id) actionWithTarget:(id) target action:(OALAction*) action;

/** Initialize an action.
 *
 * @param target The target to run the action upon.
 * @param action The action to run.
 * @return The initialized action.
 */
- (id) initWithTarget:(id) target action:(OALAction*) action;

@end


#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS

#pragma mark -
#pragma mark OALSequentialActions

/**
 * A set of actions that get run in sequence.
 */
@interface OALSequentialActions: OALAction
{
	/** The index of the action currently being processed. */
	NSUInteger actionIndex_;
	
	/** The last completeness proportion value acted upon. */
	float pLastComplete_;

	/** The proportional duration of the current action. */
	float pCurrentActionDuration_;
	
	/** The proportional completeness of the current action. */
	float pCurrentActionComplete_;
}


#pragma mark Properties

/** The actions which will be run. */
@property(nonatomic,readwrite,retain) NSMutableArray* actions;


#pragma mark Object Management

/** Create an action.
 *
 * @param actions The comma separated list of actions.
 * @param NS_REQUIRES_NIL_TERMINATION List of actions must be terminated by a nil.
 * @return A new set of sequential actions.
 */
+ (id) actions:(OALAction*) actions, ... NS_REQUIRES_NIL_TERMINATION;

/** Create an action.
 *
 * @param actions The actions to run.
 * @return A new set of sequential actions.
 */
+ (id) actionsFromArray:(NSArray*) actions;

/** Initialize an action.
 *
 * @param actions The actions to run.
 * @return The initialized set of sequential actions.
 */
- (id) initWithActions:(NSArray*) actions;

@end


#pragma mark -
#pragma mark OALConcurrentActions

/**
 * A set of actions that get run concurrently.
 */
@interface OALConcurrentActions: OALAction


#pragma mark Properties

/** The actions which will be run. */
@property(nonatomic,readwrite,retain) NSMutableArray* actions;


#pragma mark Object Management

/** Create an action.
 *
 * @param actions The comma separated list of actions.
 * @param NS_REQUIRES_NIL_TERMINATION List of actions must be terminated by a nil.
 * @return A new set of concurrent actions.
 */
+ (id) actions:(OALAction*) actions, ... NS_REQUIRES_NIL_TERMINATION;

/** Create an action.
 *
 * @param actions The actions to run.
 * @return A new set of concurrent actions.
 */
+ (id) actionsFromArray:(NSArray*) actions;

/** Initialize an action.
 *
 * @param actions The actions to run.
 * @return The initialized set of concurrent actions.
 */
- (id) initWithActions:(NSArray*) actions;

@end

#else /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */

COCOS2D_SUBCLASS_HEADER(OALSequentialActions,CCSequence);


COCOS2D_SUBCLASS_HEADER(OALConcurrentActions,CCSpawn);

#endif /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */


#pragma mark -
#pragma mark OALCallAction

/**
 * Calls a selector on a target.
 * This action will ignore whatever target it is run against,
 * and will invoke the selector on the target specified at creation
 * time.
 */
@interface OALCallAction: OALAction
{
	/** The target to call the selector on. */
	id callTarget_;
	
	/** The selector to invoke */
	SEL selector_;
	
	/** The number of parameters which will be passed to the selector. */
	int numObjects_;
	
	/** The first object to pass to the selector, if any. */
	id object1_;
	
	/** The second object to pass to the selector, if any. */
	id object2_;
}

/** Create an action.
 *
 * @param callTarget The target to call.
 * @param selector The selector to invoke.
 * @return A new action.
 */
+ (id) actionWithCallTarget:(id) callTarget
				   selector:(SEL) selector;

/** Create an action.
 *
 * @param callTarget The target to call.
 * @param selector The selector to invoke.
 * @param object The object to pass to the selector.
 * @return A new action.
 */
+ (id) actionWithCallTarget:(id) callTarget
				   selector:(SEL) selector
				 withObject:(id) object;

/** Create an action.
 *
 * @param callTarget The target to call.
 * @param selector The selector to invoke.
 * @param firstObject The first object to pass to the selector.
 * @param secondObject The second object to pass to the selector.
 * @return A new action.
 */
+ (id) actionWithCallTarget:(id) callTarget
				   selector:(SEL) selector
				 withObject:(id) firstObject
				 withObject:(id) secondObject;

/** Initialize an action.
 *
 * @param callTarget The target to call.
 * @param selector The selector to invoke.
 * @return The initialized action.
 */
- (id) initWithCallTarget:(id) callTarget
				 selector:(SEL) selector;

/** Initialize an action.
 *
 * @param callTarget The target to call.
 * @param selector The selector to invoke.
 * @param object The object to pass to the selector.
 * @return Initialize an action.
 */
- (id) initWithCallTarget:(id) callTarget
				 selector:(SEL) selector
			   withObject:(id) object;

/** Initialize an action.
 *
 * @param callTarget The target to call.
 * @param selector The selector to invoke.
 * @param firstObject The first object to pass to the selector.
 * @param secondObject The second object to pass to the selector.
 * @return The initialized action.
 */
- (id) initWithCallTarget:(id) callTarget
				 selector:(SEL) selector
			   withObject:(id) firstObject
			   withObject:(id) secondObject;

@end
