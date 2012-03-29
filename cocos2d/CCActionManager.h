/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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


#import "CCAction.h"
#import "ccMacros.h"
#import "Support/ccCArray.h"
#import "Support/uthash.h"

typedef struct _hashElement
{
	struct ccArray	*actions;
	NSUInteger		actionIndex;
	BOOL			currentActionSalvaged;
	BOOL			paused;
	UT_hash_handle	hh;

	CC_ARC_UNSAFE_RETAINED	id				target;
	CC_ARC_UNSAFE_RETAINED	CCAction		*currentAction;
} tHashElement;


/** CCActionManager the object that manages all the actions.
 Normally you won't need to use this API directly. 99% of the cases you will use the CCNode interface, which uses this object.
 But there are some cases where you might need to use this API dirctly:
 Examples:
	- When you want to run an action where the target is different from a CCNode.
	- When you want to pause / resume the actions

 @since v0.8
 */
@interface CCActionManager : NSObject
{
	tHashElement	*targets;
	tHashElement	*currentTarget;
	BOOL			currentTargetSalvaged;
}


// actions

/** Adds an action with a target.
 If the target is already present, then the action will be added to the existing target.
 If the target is not present, a new instance of this target will be created either paused or paused, and the action will be added to the newly created target.
 When the target is paused, the queued actions won't be 'ticked'.
 */
-(void) addAction: (CCAction*) action target:(id)target paused:(BOOL)paused;
/** Removes all actions from all the targers.
 */
-(void) removeAllActions;

/** Removes all actions from a certain target.
 All the actions that belongs to the target will be removed.
 */
-(void) removeAllActionsFromTarget:(id)target;
/** Removes an action given an action reference.
 */
-(void) removeAction: (CCAction*) action;
/** Removes an action given its tag and the target */
-(void) removeActionByTag:(NSInteger)tag target:(id)target;
/** Gets an action given its tag an a target
 @return the Action the with the given tag
 */
-(CCAction*) getActionByTag:(NSInteger) tag target:(id)target;
/** Returns the numbers of actions that are running in a certain target
 * Composable actions are counted as 1 action. Example:
 *    If you are running 1 Sequence of 7 actions, it will return 1.
 *    If you are running 7 Sequences of 2 actions, it will return 7.
 */
-(NSUInteger) numberOfRunningActionsInTarget:(id)target;

/** Pauses the target: all running actions and newly added actions will be paused.
 */
-(void) pauseTarget:(id)target;
/** Resumes the target. All queued actions will be resumed.
 */
-(void) resumeTarget:(id)target;

/** Pauses all running actions, returning a list of targets whose actions were paused.
 */
-(NSSet *) pauseAllRunningActions;

/** Resume a set of targets (convenience function to reverse a pauseAllRunningActions call)
 */
-(void) resumeTargets:(NSSet *)targetsToResume;

@end

