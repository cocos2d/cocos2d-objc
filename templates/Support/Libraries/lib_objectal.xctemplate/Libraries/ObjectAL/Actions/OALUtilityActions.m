//
//  OALUtilityActions.m
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

#import "OALUtilityActions.h"
#import "OALAction+Private.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"


#pragma mark OALTargetedAction

/** \cond */
@interface OALTargetedAction ()

@property(nonatomic,readwrite,retain) OALAction* action;

@end
/** \endcond */

@implementation OALTargetedAction


#pragma mark Object Management

+ (id) actionWithTarget:(id) target action:(OALAction*) action
{
	return as_autorelease([(OALTargetedAction*)[self alloc] initWithTarget:target action:action]);
}

- (id) initWithTarget:(id) target action:(OALAction*) action
{
	if(nil != (self = [super initWithDuration:action.duration]))
	{
		self.forcedTarget = target; // Weak reference
		self.action = action;
		self.duration = action.duration;
	}
	return self;
}

- (void) dealloc
{
	as_release(action_);
    as_superdealloc();
}


#pragma mark Properties

@synthesize action = action_;
@synthesize forcedTarget = forcedTarget_;


#pragma mark Functions

- (void) prepareWithTarget:(id) target
{
	// Have the action use the forced target.
	[action_ prepareWithTarget:forcedTarget_];
	duration_ = action_.duration;

	// Since we may be running in the manager (if duration > 0), we
	// must call [super prepareWithTarget:] using the passed in target.
	[super prepareWithTarget:target];
}

#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS

- (void) startAction
{
	[super startAction];
	[action_ startAction];
}

#endif /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */

- (void) stopAction
{
	[super stopAction];
	[action_ stopAction];
}

- (void) updateCompletion:(float) proportionComplete
{
	[super updateCompletion:proportionComplete];
	[action_ updateCompletion:proportionComplete];
}

@end


#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS

#pragma mark -
#pragma mark OALSequentialActions

/** \cond */
@interface OALSequentialActions ()

/** The durations of the actions. */
@property(nonatomic,readwrite,retain) NSMutableArray* pDurations;

/** The current action being processed. */
@property(nonatomic,readwrite,assign) OALAction* currentAction;

@end
/** \endcond */


@implementation OALSequentialActions

@synthesize actions = actions_;
@synthesize pDurations = pDurations_;
@synthesize currentAction = currentAction_;

#pragma mark Object Management

+ (id) actions:(OALAction*) firstAction, ...
{
	NSMutableArray* actions = [NSMutableArray arrayWithCapacity:10];
	va_list params;

	va_start(params, firstAction);
	for(OALAction* action = firstAction; nil != action; action = va_arg(params,OALAction*))
	{
		[actions addObject:action];
	}
	va_end(params);

	return as_autorelease([[self alloc] initWithActions:actions]);
}

+ (id) actionsFromArray:(NSArray*) actions;
{
	return as_autorelease([[self alloc] initWithActions:actions]);
}

- (id) initWithActions:(NSArray*) actions
{
	if(nil != (self = [super initWithDuration:0]))
	{
		if([actions isKindOfClass:[NSMutableArray class]])
		{
			// Take ownership if it's a mutable array.
			self.actions = (NSMutableArray*)actions;
		}
		else
		{
			// Otherwise copy it into a mutable array.
			self.actions = [NSMutableArray arrayWithArray:actions];
		}

		self.pDurations = [NSMutableArray arrayWithCapacity:[actions count]];
	}
	return self;
}

- (void) dealloc
{
	as_release(actions_);
	as_release(pDurations_);
    as_superdealloc();
}


#pragma mark Functions

- (void) prepareWithTarget:(id) target
{
	// Calculate the total duration in seconds of all children.
	duration_ = 0;
	for(OALAction* action in actions_)
	{
		[action prepareWithTarget:target];
		duration_ += action.duration;
	}

	// Calculate the childrens' duration as proportions of the total.
	[pDurations_ removeAllObjects];
	if(0 == duration_)
	{
		// Easy case: 0 duration.
		for(OALAction* action in actions_)
		{
			[pDurations_ addObject:[NSNumber numberWithFloat:0]];
		}
	}
	else
	{
		// Complex case: > 0 duration.
		for(OALAction* action in actions_)
		{
			[pDurations_ addObject:[NSNumber numberWithFloat:action.duration/duration_]];
		}
	}

	// Start at the first action.
	if([actions_ count] > 0)
	{
		self.currentAction = [actions_ objectAtIndex:0];
		pCurrentActionDuration_ = [[pDurations_ objectAtIndex:0] floatValue];
	}
	else
	{
		// Just in case this is an empty set.
		self.currentAction = nil;
		pCurrentActionDuration_ = 0;
	}

	actionIndex_ = 0;
	pLastComplete_ = 0;
	pCurrentActionComplete_ = 0;

	[super prepareWithTarget:target];
}

- (void) startAction
{
	[currentAction_ startAction];
	[super startAction];
}

- (void) stopAction
{
	[currentAction_ stopAction];
	[super stopAction];
}

- (void) updateCompletion:(float) pComplete
{
	float pDelta = pComplete - pLastComplete_;

	// First, run past all actions that have been completed since the last update.
	while(pCurrentActionComplete_ + pDelta >= pCurrentActionDuration_)
	{
		// Only send a 1.0 update if the action has a duration.
		if(currentAction_.duration > 0)
		{
			[currentAction_ updateCompletion:1.0f];
		}

		[currentAction_ stopAction];

		// Subtract its contribution to the current delta.
		pDelta -= (pCurrentActionDuration_ - pCurrentActionComplete_);

		// Move on to the next action.
		actionIndex_++;
		if(actionIndex_ >= [actions_ count])
		{
			// If there are no more actions, we are done.
			return;
		}

		// Store some info about the new current action and start it running.
		self.currentAction = [actions_ objectAtIndex:actionIndex_];
		pCurrentActionDuration_ = [[pDurations_ objectAtIndex:actionIndex_] floatValue];
		pCurrentActionComplete_ = 0;
		[currentAction_ startAction];
	}

	if(pComplete >= 1.0)
	{
		// Make sure a cumulative rounding error doesn't cause an uncompletable action.
		[currentAction_ updateCompletion:1.0f];
		[currentAction_ stopAction];
	}
	else
	{
		// The action is not yet complete.  Send an update with the current proportion
		// for this action.
		pCurrentActionComplete_ += pDelta;
		[currentAction_ updateCompletion:pCurrentActionComplete_ / pCurrentActionDuration_];
	}

	pLastComplete_ = pComplete;
}

@end

#else /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */

COCOS2D_SUBCLASS(OALSequentialActions)

- (void) prepareWithTarget:(id) target
{
    #pragma unused(target)
}

- (void) updateCompletion:(float) proportionComplete
{
    #pragma unused(proportionComplete)
}

@end

#endif /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */



#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS

#pragma mark -
#pragma mark OALConcurrentActions

/** \cond */
@interface OALConcurrentActions ()

/** The durations of the actions. */
@property(nonatomic,readwrite,retain) NSMutableArray* pDurations;

/** A list of actions that have duration > 0. */
@property(nonatomic,readwrite,assign) NSMutableArray* actionsWithDuration;

@end
/** \endcond */


@implementation OALConcurrentActions

@synthesize actions = actions_;
@synthesize pDurations = pDurations_;
@synthesize actionsWithDuration = actionsWithDuration_;


#pragma mark Object Management

+ (id) actions:(OALAction*) firstAction, ...
{
	NSMutableArray* actions = [NSMutableArray arrayWithCapacity:10];
	va_list params;

	va_start(params, firstAction);
	for(OALAction* action = firstAction; nil != action; action = va_arg(params,OALAction*))
	{
		[actions addObject:action];
	}
	va_end(params);

	return as_autorelease([[self alloc] initWithActions:actions]);
}

+ (id) actionsFromArray:(NSArray*) actions;
{
	return as_autorelease([[self alloc] initWithActions:actions]);
}

- (id) initWithActions:(NSArray*) actions
{
	if(nil != (self = [super initWithDuration:0]))
	{
		if([actions isKindOfClass:[NSMutableArray class]])
		{
			// Take ownership if it's a mutable array.
			self.actions = (NSMutableArray*)actions;
		}
		else
		{
			// Otherwise copy it into a mutable array.
			self.actions = [NSMutableArray arrayWithArray:actions];
		}

		self.pDurations = [NSMutableArray arrayWithCapacity:[actions count]];
		self.actionsWithDuration = [NSMutableArray arrayWithCapacity:[actions count]];
	}
	return self;
}

- (void) dealloc
{
	as_release(actions_);
	as_release(pDurations_);
	as_release(actionsWithDuration_);
	as_superdealloc();
}


#pragma mark Functions

- (void) prepareWithTarget:(id) target
{
	[actionsWithDuration_ removeAllObjects];

	// Calculate the longest duration in seconds of all children.
	duration_ = 0;
	for(OALAction* action in actions_)
	{
		[action prepareWithTarget:target];
		if(action.duration > 0)
		{
			if(action.duration > duration_)
			{
				duration_ = action.duration;
			}

			// Also keep track of actions with durations.
			[actionsWithDuration_ addObject:action];
		}
	}

	// Calculate the childrens' durations as proportions of the total.
	[pDurations_ removeAllObjects];
	for(OALAction* action in actionsWithDuration_)
	{
		[pDurations_ addObject:[NSNumber numberWithFloat:action.duration/duration_]];
	}

	[super prepareWithTarget:target];
}

- (void) startAction
{
	[actions_ makeObjectsPerformSelector:@selector(startAction)];
	[super startAction];
}

- (void) stopAction
{
	[actions_ makeObjectsPerformSelector:@selector(stopAction)];
	[super stopAction];
}

- (void) updateCompletion:(float) proportionComplete
{
	if(0 == proportionComplete)
	{
		// All actions get an update at 0.
		for(OALAction* action in actions_)
		{
			[action updateCompletion:0];
		}
	}
	else
	{
		// Only actions with a duration get an update after 0.
		for(NSUInteger i = 0; i < [actionsWithDuration_ count]; i++)
		{
			OALAction* action = [actionsWithDuration_ objectAtIndex:i];
			float proportion = proportionComplete / [[pDurations_ objectAtIndex:i] floatValue];
			if(proportion > 1.0f)
			{
				proportion = 1.0f;
			}
			[action updateCompletion:proportion];
		}
	}
}

@end

#else /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */

COCOS2D_SUBCLASS(OALConcurrentActions)

- (void) prepareWithTarget:(id) target
{
    #pragma unused(target)
}

- (void) updateCompletion:(float) proportionComplete
{
    #pragma unused(proportionComplete)
}

@end

#endif /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */


#pragma mark -
#pragma mark OALCallAction

@implementation OALCallAction


#pragma mark Object Management

+ (id) actionWithCallTarget:(id) callTarget
				   selector:(SEL) selector
{
	return as_autorelease([[self alloc] initWithCallTarget:callTarget selector:selector]);
}

+ (id) actionWithCallTarget:(id) callTarget
				   selector:(SEL) selector
				 withObject:(id) object
{
	return as_autorelease([[self alloc] initWithCallTarget:callTarget
                                                  selector:selector
                                                withObject:object]);
}

+ (id) actionWithCallTarget:(id) callTarget
				   selector:(SEL) selector
				 withObject:(id) firstObject
				 withObject:(id) secondObject
{
	return as_autorelease([[self alloc] initWithCallTarget:callTarget
                                                  selector:selector
                                                withObject:firstObject
                                                withObject:secondObject]);
}

- (id) initWithCallTarget:(id) callTargetIn selector:(SEL) selectorIn
{
	if(nil != (self = [super init]))
	{
		callTarget_ = callTargetIn;
		selector_ = selectorIn;
	}
	return self;
}

- (id) initWithCallTarget:(id) callTargetIn
				 selector:(SEL) selectorIn
			   withObject:(id) object
{
	if(nil != (self = [super init]))
	{
		callTarget_ = callTargetIn;
		selector_ = selectorIn;
		object1_ = object;
		numObjects_ = 1;
	}
	return self;
}

- (id) initWithCallTarget:(id) callTargetIn
				 selector:(SEL) selectorIn
			   withObject:(id) firstObject
			   withObject:(id) secondObject
{
	if(nil != (self = [super init]))
	{
		callTarget_ = callTargetIn;
		selector_ = selectorIn;
		object1_ = firstObject;
		object2_ = secondObject;
		numObjects_ = 2;
	}
	return self;
}


#pragma mark Functions

- (void) startAction
{
#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS
	[super startAction];
#endif /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	switch(numObjects_)
	{
		case 2:
			[callTarget_ performSelector:selector_ withObject:object1_ withObject:object2_];
			break;
		case 1:
			[callTarget_ performSelector:selector_ withObject:object1_];
			break;
		default:
			[callTarget_ performSelector:selector_];
	}
#pragma clang diagnostic pop
}

#if OBJECTAL_CFG_USE_COCOS2D_ACTIONS

-(void) startWithTarget:(id) targetIn
{
	[super startWithTarget:targetIn];
	[self startAction];
}

#endif /* OBJECTAL_CFG_USE_COCOS2D_ACTIONS */


@end
