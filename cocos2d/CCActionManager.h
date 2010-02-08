/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCAction.h"
#import "Support/ccArray.h"
#import "Support/ccHashSet.h"

typedef struct _hashElement
{
	struct ccArray	*actions;
	id				target;
	unsigned int	actionIndex;
	CCAction		*currentAction;
	BOOL			currentActionSalvaged;
	BOOL			paused;	
} tHashElement;


/** CCActionManager is a singleton that manages all the actions.
 Normally you won't need to use this singleton directly. 99% of the cases you will use the CCNode interface,
 which uses this singleton.
 But there are some cases where you might need to use this singleton.
 Examples:
	- When you want to run an action where the target is different from a CCNode. 
	- When you want to pause / resume the actions
 
 @since v0.8
 */
@interface CCActionManager : NSObject {

	ccHashSet		* targets;
	tHashElement	* currentTarget;
	BOOL			currentTargetSalvaged;
}

/** returns a shared instance of the CCActionManager */
+ (CCActionManager *)sharedManager;

/** purges the shared action manager. It releases the retained instance.
 @since v0.99.0
 */
+(void)purgeSharedManager;

// actions

/** Adds an action with a target. The action can be added paused or unpaused.
 The action will be run "against" the target.
 If the action is added paused, then it will be queued, but it won't be "ticked" until it is resumed.
 If the action is added unpaused, then it will be queued, and it will be "ticked" in every frame.
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
-(void) removeActionByTag:(int)tag target:(id)target;
/** Gets an action given its tag an a target
 @return the Action the with the given tag
 */
-(CCAction*) getActionByTag:(int) tag target:(id)target;
/** Returns the numbers of actions that are running in a certain target
 * Composable actions are counted as 1 action. Example:
 *    If you are running 1 Sequence of 7 actions, it will return 1.
 *    If you are running 7 Sequences of 2 actions, it will return 7.
 */
-(int) numberOfRunningActionsInTarget:(id)target;
/** Pauses all actions for a certain target.
 When the actions are paused, they won't be "ticked".
 */
-(void) pauseAllActionsForTarget:(id)target;
/** Resumes all actions for a certain target.
 Once the actions are resumed, they will be "ticked" in every frame.
 */
-(void) resumeAllActionsForTarget:(id)target;

@end

