//
//  OALActionManager.m
//  ObjectAL
//
//  Created by Karl Stenerud on 10-09-18.
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

#import "OALActionManager.h"
#import "mach_timing.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "NSMutableArray+WeakReferences.h"
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#endif

#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(OALActionManager);

/** \cond */
/**
 * (INTERNAL USE) Private methods for OALActionManager.
 */
@interface OALActionManager (Private)

/** Resets the time delta in cases where proper time delta calculations become impossible.
 */
- (void) doResetTimeDelta:(NSNotification*) notification;
/** \endcond */

@end

#pragma mark OALActionManager

@implementation OALActionManager


#pragma mark Object Management

SYNTHESIZE_SINGLETON_FOR_CLASS(OALActionManager);

- (id) init
{
	if(nil != (self = [super init]))
	{
		targets = [NSMutableArray newMutableArrayUsingWeakReferencesWithCapacity:50];
		targetActions = [[NSMutableArray alloc] initWithCapacity:50];
		actionsToAdd = [[NSMutableArray alloc] initWithCapacity:100];
		actionsToRemove = [[NSMutableArray alloc] initWithCapacity:100];

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(doResetTimeDelta:)
													 name:UIApplicationSignificantTimeChangeNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(doResetTimeDelta:)
													 name:UIApplicationDidBecomeActiveNotification
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doResetTimeDelta:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
#endif
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	as_release(targets);
	as_release(targetActions);
	as_release(actionsToAdd);
	as_release(actionsToRemove);
	as_superdealloc();
}

- (void) doResetTimeDelta:(NSNotification*) notification
{
    #pragma unused(notification)
	lastTimestamp = 0;
}


#pragma mark Action Management

- (void) stopAllActions
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		for(NSMutableArray* actions in targetActions)
		{
			[actions makeObjectsPerformSelector:@selector(stopAction)];
		}
		
		[actionsToAdd makeObjectsPerformSelector:@selector(stopAction)];
	}
}


#pragma mark Timer Interface

- (void) step:(NSTimer*) timer
{
    #pragma unused(timer)
	OPTIONALLY_SYNCHRONIZED(self)
	{
		// Add new actions
		for(OALAction* action in actionsToAdd)
		{
			// But only if they haven't been stopped already
			if(action.running)
			{
				NSUInteger index = [targets indexOfObject:action.target];
				if(NSNotFound == index)
				{
					// Since this target has no running actions yet, add the support
					// structure to keep track of it.
					index = [targets count];
					[targets addObject:action.target];
					[targetActions addObject:[NSMutableArray arrayWithCapacity:5]];
				}

				// Get the list of actions operating on this target and add the new action.
				NSMutableArray* actions = [targetActions objectAtIndex:index];
				[actions addObject:action];
			}
		}
		// All actions have been added.  Clear the "add" list.
		[actionsToAdd removeAllObjects];
		

		// Remove stopped actions
		for(OALAction* action in actionsToRemove)
		{
			NSUInteger index = [targets indexOfObject:action.target];
			if(NSNotFound != index)
			{
				// Remove the action.
				NSMutableArray* actions = [targetActions objectAtIndex:index];
				[actions removeObject:action];
				if([actions count] == 0)
				{
					// If there are no more actions for this target, stop tracking it.
					[targets removeObjectAtIndex:index];
					[targetActions removeObjectAtIndex:index];
					
					// If there are no more actions running, stop the master timer.
					if([targets count] == 0)
					{
						[stepTimer invalidate];
						stepTimer = nil;
						break;
					}
				}
			}
		}
		[actionsToRemove removeAllObjects];
		
		// Get the time elapsed and update timestamp.
		// If there was a break in timing (lastTimestamp == 0), assume 0 time has elapsed.
		uint64_t currentTime = mach_absolute_time();
		float elapsedTime = 0;
		if(lastTimestamp > 0)
		{
			elapsedTime = (float)mach_absolute_difference_seconds(currentTime, lastTimestamp);
		}
		lastTimestamp = currentTime;

		// Update all remaining actions, if any
		for(NSMutableArray* actions in targetActions)
		{
			for(OALAction* action in actions)
			{
				action.elapsed += elapsedTime;
				float proportionComplete = action.elapsed / action.duration;
				if(proportionComplete < 1.0f)
				{
					[action updateCompletion:proportionComplete];
				}
				else
				{
					[action updateCompletion:1.0f];
					[action stopAction];
				}
			}
		}
	}
}


#pragma mark Internal Use

- (void) notifyActionStarted:(OALAction*) action
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[actionsToAdd addObject:action];
		
		// Start the timer if it hasn't been started yet and there are actions to perform.
		if([targets count] == 0 && [actionsToAdd count] == 1)
		{
			stepTimer = [NSTimer scheduledTimerWithTimeInterval:kActionStepInterval
														 target:self
													   selector:@selector(step:)
													   userInfo:nil
														repeats:YES];

			// Reset timestamp since we have been off for awhile.
			lastTimestamp = 0;
		}
	}
}

- (void) notifyActionStopped:(OALAction*) action
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[actionsToRemove addObject:action];
	}
}

@end

#endif /* OBJECTAL_CFG_USE_COCOS2D_ACTIONS */
