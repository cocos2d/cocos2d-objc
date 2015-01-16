/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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

#import "CCAction.h"
#import "ccMacros.h"
#import "uthash.h"
#import "CCScheduler.h"

typedef struct _hashElement {
    __unsafe_unretained NSMutableArray	*actions;
	NSUInteger		actionIndex;
	BOOL			currentActionSalvaged;
	BOOL			paused;
	UT_hash_handle	hh;

	__unsafe_unretained	id				target;
	__unsafe_unretained	CCAction		*currentAction;
} tHashElement;


/** 
 *  CCActionManager the object that manages all the actions.
 *  Normally you won't need to use this API directly. 99% of the cases you will use the CCNode interface, which uses this object.
 *  But there are some cases where you might need to use this API directly:
 *  Examples:
 *	- When you want to run an action where the target is different from a CCNode.
 *	- When you want to pause / resume the actions.
 *
 *  CCActionManager can be run in fixed mode- in this mode, updates occur on a fixed timestep, rather than the normal update loop.
 *  Fixed timesteps are useful when running actions that applied to nodes with physics bodies attached.
 *  All animations that possess physics nodes will utilize the fixed action manager.
 */
@interface CCActionManager : NSObject<CCSchedulableTarget> {
    tHashElement	*targets;
    tHashElement	*currentTarget;
	BOOL			currentTargetSalvaged;
}

/**
 When in fixed mode, actions occur on the fixedUpdate loop instead of the regular update loop.
 Currently, all actions must occur on one loop or the other. Your actions may be automatically
 transitioned to fixedMode if you add actions to physics objects.
 
 @since v4.0
 */
@property(nonatomic,readwrite) BOOL fixedMode;

@end
