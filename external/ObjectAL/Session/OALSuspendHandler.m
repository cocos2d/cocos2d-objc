//
//  OALSuspendHandler.m
//  ObjectAL
//
//  Created by Karl Stenerud on 10-12-19.
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

#import "OALSuspendHandler.h"
#import "NSMutableArray+WeakReferences.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import <objc/message.h>

/** \cond */
@interface OALSuspendHandler ()
/** \endcond */

/** Slave object that is notified when this object suspends or unsuspends. WEAK reference */
@property(nonatomic,readwrite,assign) id suspendStatusChangeTarget;

@end


@implementation OALSuspendHandler

@synthesize suspendStatusChangeTarget;

+ (OALSuspendHandler*) handlerWithTarget:(id) target selector:(SEL) selector
{
	return as_autorelease([[self alloc] initWithTarget:target selector:selector]);
}

- (id) initWithTarget:(id) target selector:(SEL) selector
{
	if(nil != (self = [super init]))
	{
		listeners = [NSMutableArray newMutableArrayUsingWeakReferencesWithCapacity:10];
		manualSuspendStates = [[NSMutableArray alloc] initWithCapacity:10];
		suspendStatusChangeTarget = target;
		suspendStatusChangeSelector = selector;
	}
	return self;
}

- (void) dealloc
{
	as_release(listeners);
	as_release(manualSuspendStates);
    as_superdealloc();
}

- (void) addSuspendListener:(id<OALSuspendListener>) listener
{
	@synchronized(self)
	{
		[listeners addObject:listener];
		// If this handler is already suspended, make sure we don't unsuspend
		// a newly added listener on the next manual unsuspend.
		bool startingSuspendedValue = manualSuspendLock ? listener.manuallySuspended : NO;
		[manualSuspendStates addObject:[NSNumber numberWithBool:startingSuspendedValue]];
	}
}

- (void) removeSuspendListener:(id<OALSuspendListener>) listener
{
	@synchronized(self)
	{
		NSUInteger index = [listeners indexOfObject:listener];
		if(NSNotFound != index)
		{
			[listeners removeObjectAtIndex:index];
			[manualSuspendStates removeObjectAtIndex:index];
		}
	}
}

- (bool) manuallySuspended
{
	@synchronized(self)
	{
		return manualSuspendLock;
	}
}

- (void) setManuallySuspended:(bool) value
{
	/* This handler propagates all suspend/unsuspend events to all listeners.
	 * An unsuspend will occur in the reverse order to a suspend (meaning, it will
	 * unsuspend listeners in the reverse order that it suspended them).
	 * On suspend, all listeners will be suspended prior to suspending this handler's
	 * slave object. On unsuspend, all listeners will resume after the slave object.
	 *
	 * Since "suspended" is manually triggered, this handler records all listeners'
	 * suspend states so that it can intelligently decide whether to unsuspend or
	 * not.
	 */
	
	@synchronized(self)
	{
		// Setting must occur in the opposite order to clearing.
		if(value)
		{
			NSUInteger numListeners = [listeners count];
			for(NSUInteger index = 0; index < numListeners; index++)
			{
				id<OALSuspendListener> listener = [listeners objectAtIndex:index];
				
				// Record whether they were already suspended or not
				bool alreadySuspended = listener.manuallySuspended;
				if(alreadySuspended != [[manualSuspendStates objectAtIndex:index] boolValue])
				{
					[manualSuspendStates replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:alreadySuspended]];
				}
				
				// Update listener suspend state if necessary
				if(!alreadySuspended)
				{
					listener.manuallySuspended = YES;
				}
			}
		}

		/* If the new value is the same as the old, do nothing.
		 * If the other lock is set, do nothing.
		 * Otherwise, send a suspend/unsuspend event to the slave.
		 */
		if(value != manualSuspendLock)
		{
			manualSuspendLock = value;
			if(!interruptLock)
			{
				if(nil != suspendStatusChangeTarget)
				{
					objc_msgSend(suspendStatusChangeTarget, suspendStatusChangeSelector, manualSuspendLock);
				}
			}
		}
		
		// Ensure clearing occurs in opposing order
		if(!value)
		{
			for(int index = (int)[listeners count] - 1; index >= 0; index--)
			{
				id<OALSuspendListener> listener = [listeners objectAtIndex:(NSUInteger)index];
				
				bool alreadySuspended = [[manualSuspendStates objectAtIndex:(NSUInteger)index] boolValue];
				
				// Update listener suspend state if necessary
				if(!alreadySuspended && listener.manuallySuspended)
				{
					listener.manuallySuspended = NO;
				}
			}
		}
	}
}

- (bool) interrupted
{
	@synchronized(self)
	{
		return interruptLock;
	}
}

- (void) setInterrupted:(bool) value
{
	/* This handler propagates all interrupt/end interrupt events to all listeners.
	 * An end interrupt will occur in the reverse order to an interrupt (meaning, it will
	 * end interrupt on listeners in the reverse order that it interrupted them).
	 * On interrupt, all listeners will be interrupted prior to suspending this handler's
	 * slave object. On end interrupt, all listeners will end interrupt after the slave object.
	 */
	@synchronized(self)
	{
		// Setting must occur in the opposite order to clearing.
		if(value)
		{
			for(id<OALSuspendListener> listener in listeners)
			{
				if(!listener.interrupted)
				{
					listener.interrupted = YES;
				}
			}
		}
		
		/* If the new value is the same as the old, do nothing.
		 * If the other lock is set, do nothing.
		 * Otherwise, send a suspend/unsuspend event to the slave.
		 */
		if(value != interruptLock)
		{
			interruptLock = value;
			if(!manualSuspendLock)
			{
				if(nil != suspendStatusChangeTarget)
				{
					objc_msgSend(suspendStatusChangeTarget, suspendStatusChangeSelector, interruptLock);
				}
			}
		}
		
		// Ensure clearing occurs in opposing order
		if(!value)
		{
			for(id<OALSuspendListener> listener in [listeners reverseObjectEnumerator])
			{
				if(listener.interrupted)
				{
					listener.interrupted = NO;
				}
			}
		}
	}
}

- (bool) suspended
{
	return interruptLock | manualSuspendLock;
}

@end
