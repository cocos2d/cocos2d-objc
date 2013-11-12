//
//  OALAudioTracks.m
//  ObjectAL
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

#import "OALAudioTracks.h"
#import "NSMutableArray+WeakReferences.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "OALAudioSession.h"


SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(OALAudioTracks);


/** \cond */
/**
 * (INTERNAL USE) Private methods for OALAudioTracks.
 */
@interface OALAudioTracks (Private)

/** (INTERNAL USE) Read deviceCurrentTime from an audio player
 * as a workaround for a bug in iOS devices that causes the value
 * to reset to 0 in certain circumstances.
 */
- (void) pollDeviceTime;

@end
/** \endcond */


#pragma mark OALAudioTracks

@implementation OALAudioTracks

#pragma mark Object Management

SYNTHESIZE_SINGLETON_FOR_CLASS(OALAudioTracks);

- (id) init
{
	if(nil != (self = [super init]))
	{
		OAL_LOG_DEBUG(@"%@: Init", self);

		suspendHandler = [[OALSuspendHandler alloc] initWithTarget:nil selector:nil];

		tracks = [NSMutableArray newMutableArrayUsingWeakReferencesWithCapacity:10];
		
		[[OALAudioSession sharedInstance] addSuspendListener:self];

        // Bug: Need to constantly poll deviceCurrentTime or else it resets to 0
        // on devices (doesn't happen in simulator).
        deviceTimePoller = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(pollDeviceTime)
                                                          userInfo:nil
                                                           repeats:YES];
    }
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc", self);
	[[OALAudioSession sharedInstance] removeSuspendListener:self];
    [deviceTimePoller invalidate];

	as_release(tracks);
	as_release(suspendHandler);
	as_superdealloc();
}


#pragma mark Properties

@synthesize tracks;

- (bool) paused
{
    return paused;
}

- (void) setPaused:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(tracks)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		paused = value;
		for(OALAudioTrack* track in tracks)
		{
			track.paused = paused;
		}
	}
}

- (bool) muted
{
    return muted;
}

- (void) setMuted:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(tracks)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		muted = value;
		for(OALAudioTrack* track in tracks)
		{
			track.muted = muted;
		}
	}
}


#pragma mark Playback

- (void) stopAllTracks
{
    [self.tracks makeObjectsPerformSelector:@selector(stop)];
}


#pragma mark Suspend Handler

- (void) addSuspendListener:(id<OALSuspendListener>) listener
{
	[suspendHandler addSuspendListener:listener];
}

- (void) removeSuspendListener:(id<OALSuspendListener>) listener
{
	[suspendHandler removeSuspendListener:listener];
}

- (bool) manuallySuspended
{
	return suspendHandler.manuallySuspended;
}

- (void) setManuallySuspended:(bool) value
{
	suspendHandler.manuallySuspended = value;
}

- (bool) interrupted
{
	return suspendHandler.interrupted;
}

- (void) setInterrupted:(bool) value
{
	suspendHandler.interrupted = value;
}

- (bool) suspended
{
	return suspendHandler.suspended;
}


#pragma mark Internal Use

- (void) notifyTrackInitializing:(OALAudioTrack*) track
{
	@synchronized(tracks)
	{
        track.muted = self.muted;
		[tracks addObject:track];
	}
}

- (void) notifyTrackDeallocating:(OALAudioTrack*) track
{
	@synchronized(tracks)
	{
		[tracks removeObject:track];
	}
}

- (void) pollDeviceTime
{
	@synchronized(tracks)
	{
        // Only actually have to poll a single track's value to avoid the bug.
        if([tracks count] > 0)
        {
            [[tracks objectAtIndex:0] deviceCurrentTime];
        }
    }
}

@end
