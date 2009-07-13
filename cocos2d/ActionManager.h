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

#import "Action.h"
#import "Support/ccArray.h"
#import "Support/uthash.h"

typedef struct _hashElement
{
	struct ccArray	*actions;
	id				target;
	unsigned int	actionIndex;
	Action			*currentAction;
	BOOL			currentActionSalvaged;
	BOOL			paused;
	UT_hash_handle	hh;
} tHashElement;


/** ActionManager is a singleton that manages all the actions.
 @since v0.8
 */
@interface ActionManager : NSObject {

	tHashElement	* targets;
	tHashElement	* currentTarget;
	BOOL			currentTargetSalvaged;
}

/** returns a shared instance of the ActionManager */
+ (ActionManager *)sharedManager;

// actions

/** Adds an action with a target. The action can be added paused or unpaused.
 */
-(void) addAction: (Action*) action target:(id)target paused:(BOOL)paused;
/** Removes all actions from a certain target */
-(void) removeAllActionsFromTarget:(id)target;
/** Removes an action given the action reference */
-(void) removeAction: (Action*) action;
/** Removes an action from the running action list given its tag and the target */
-(void) removeActionByTag:(int)tag target:(id)target;
/** Gets an action from the running action list given its tag an a target
 @return the Action the with the given tag
 */
-(Action*) getActionByTag:(int) tag target:(id)target;
/** Returns the numbers of actions that are running in a certain target
 * Composable actions are counted as 1 action. Example:
 *    If you are running 1 Sequence of 7 actions, it will return 1.
 *    If you are running 7 Sequences of 2 actions, it will return 7.
 */
-(int) numberOfRunningActionsInTarget:(id)target;
/** Pauses all actions for a certain target */
-(void) pauseAllActionsForTarget:(id)target;
/** Resumes all actions for a certain target */
-(void) resumeAllActionsForTarget:(id)target;

@end

