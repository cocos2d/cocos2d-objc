//
//  ALSource.m
//  ObjectAL
//
//  Created by Karl Stenerud on 15/12/09.
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

#import "ALSource.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "ALWrapper.h"
#import "OpenALManager.h"
#import "OALAudioActions.h"
#import "OALUtilityActions.h"
#import "NSMutableDictionary+WeakReferences.h"


#pragma mark -
#pragma mark Private Methods

/** \cond */
/**
 * (INTERNAL USE) Private methods for ALSource.
 */
@interface ALSource ()

/** (INTERNAL USE) Called by SuspendHandler.
 */
- (void) setSuspended:(bool) value;

/** (INTERNAL USE) Callback for resuming playback after delay to
 * get around OpenAL bug.
 */
- (void) delayedResumePlayback;
/** \endcond */

- (void) receiveNotification:(ALuint) notificationID userData:(void*) userData;

@property(nonatomic, readwrite, retain) NSMutableDictionary* notificationCallbacks;

@end


@implementation ALSource

static NSMutableDictionary* g_allSourcesByID;

static ALvoid alSourceNotification(ALuint sid, ALuint notificationID, ALvoid* userData)
{
    ALSource* source = [g_allSourcesByID objectForKey:[NSNumber numberWithUnsignedInt:sid]];
    [source receiveNotification:notificationID userData:userData];
}


@synthesize notificationCallbacks = _notificationCallbacks;

+ (void) initialize
{
    if(g_allSourcesByID == nil)
    {
        g_allSourcesByID = [NSMutableDictionary newMutableDictionaryUsingWeakReferencesWithCapacity:32];
    }
}

#pragma mark Object Management

+ (id) source
{
	return as_autorelease([[self alloc] init]);
}

+ (id) sourceOnContext:(ALContext*) context
{
	return as_autorelease([[self alloc] initOnContext:context]);
}

- (id) init
{
	return [self initOnContext:[OpenALManager sharedInstance].currentContext];
}

- (id) initOnContext:(ALContext*) contextIn
{
	if(nil != (self = [super init]))
	{
		OAL_LOG_DEBUG(@"%@: Init on context %@", self, contextIn);

		if(nil == contextIn)
		{
			OAL_LOG_ERROR(@"%@: Failed to init because context was nil. Returning nil", self);
			as_release(self);
			return nil;
		}
		
		suspendHandler = [[OALSuspendHandler alloc] initWithTarget:self selector:@selector(setSuspended:)];

        self.notificationCallbacks = [NSMutableDictionary dictionary];
		context = as_retain(contextIn);
		@synchronized([OpenALManager sharedInstance])
		{
			ALContext* realContext = [OpenALManager sharedInstance].currentContext;
			[OpenALManager sharedInstance].currentContext = context;
			sourceId = [ALWrapper genSource];
			[OpenALManager sharedInstance].currentContext = realContext;
		}
		OAL_LOG_DEBUG(@"%@: Created source %08x", self, sourceId);

		[context notifySourceInitializing:self];
		gain = [ALWrapper getSourcef:sourceId parameter:AL_GAIN];
		shadowState = AL_INITIAL;
		
		[context addSuspendListener:self];
        [[self class] notifySourceAllocated:self];
	}
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc, sourceId = %08x", self, sourceId);

    [[self class] notifySourceDeallocated:self];
    [self unregisterAllNotifications];
	[context removeSuspendListener:self];
	[context notifySourceDeallocating:self];

	[gainAction stopAction];
	as_release(gainAction);
	[panAction stopAction];
	as_release(panAction);
	[pitchAction stopAction];
	as_release(pitchAction);
	as_release(suspendHandler);
    as_release(_notificationCallbacks);

    if((ALuint)AL_INVALID != sourceId)
    {
        [ALWrapper sourceStop:sourceId];
        [ALWrapper sourcei:sourceId parameter:AL_BUFFER value:AL_NONE];
        
        @synchronized([OpenALManager sharedInstance])
        {
            ALContext* currentContext = [OpenALManager sharedInstance].currentContext;
            if(currentContext != context)
            {
                // Make this source's context the current one if it isn't already.
                [OpenALManager sharedInstance].currentContext = context;
            }
            
            [ALWrapper deleteSource:sourceId];
            
            [OpenALManager sharedInstance].currentContext = currentContext;
        }
    }

	as_release(context);
    as_release(buffer);

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	as_superdealloc();
}


#pragma mark Properties

- (ALBuffer*) buffer
{
    return buffer;
}

- (void) setBuffer:(ALBuffer *) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
			
		[self stop];

        as_release(buffer);
		buffer = as_retain(value);
		[ALWrapper sourcei:sourceId parameter:AL_BUFFER value:(ALint)buffer.bufferId];
	}
}

- (int) buffersQueued
{
	return [ALWrapper getSourcei:sourceId parameter:AL_BUFFERS_QUEUED];
}

- (int) buffersProcessed
{
	return [ALWrapper getSourcei:sourceId parameter:AL_BUFFERS_PROCESSED];
}

- (float) coneInnerAngle
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_CONE_INNER_ANGLE];
	}
}

- (void) setConeInnerAngle:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_CONE_INNER_ANGLE value:value];
	}
}

- (float) coneOuterAngle
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_CONE_OUTER_ANGLE];
	}
}

- (void) setConeOuterAngle:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_CONE_OUTER_ANGLE value:value];
	}
}

- (float) coneOuterGain
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_CONE_OUTER_GAIN];
	}
}

- (void) setConeOuterGain:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_CONE_OUTER_GAIN value:value];
	}
}

@synthesize context;

- (ALVector) direction
{
	ALVector result;
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[ALWrapper getSource3f:sourceId parameter:AL_DIRECTION v1:&result.x v2:&result.y v3:&result.z];
	}
	return result;
}

- (void) setDirection:(ALVector) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper source3f:sourceId parameter:AL_DIRECTION v1:value.x v2:value.y v3:value.z];
	}
}

- (float) volume
{
	return self.gain;
}

- (void) setVolume:(float) value
{
	self.gain = value;
}

- (float) gain
{
    return gain;
}

- (void) setGain:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		gain = value;
		if(muted)
		{
			value = 0;
		}
		[ALWrapper sourcef:sourceId parameter:AL_GAIN value:value];
	}
}

@synthesize interruptible;

- (bool) looping
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcei:sourceId parameter:AL_LOOPING];
	}
}

- (void) setLooping:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcei:sourceId parameter:AL_LOOPING value:value];
	}
}

- (float) maxDistance
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_MAX_DISTANCE];
	}
}

- (void) setMaxDistance:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_MAX_DISTANCE value:value];
	}
}

- (float) maxGain
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_MAX_GAIN];
	}
}

- (void) setMaxGain:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_MAX_GAIN value:value];
	}
}

- (float) minGain
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_MIN_GAIN];
	}
}

- (void) setMinGain:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_MIN_GAIN value:value];
	}
}

- (bool) muted
{
    return muted;
}

- (void) setMuted:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		muted = value;
		if(muted)
		{
			[self stopActions];
		}
		// Force a re-evaluation of gain.
		[self setGain:gain];
	}
}

- (float) offsetInBytes
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_BYTE_OFFSET];
	}
}

- (void) setOffsetInBytes:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_BYTE_OFFSET value:value];
	}
}

- (float) offsetInSamples
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_SAMPLE_OFFSET];
	}
}

- (void) setOffsetInSamples:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_SAMPLE_OFFSET value:value];
	}
}

- (float) offsetInSeconds
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_SEC_OFFSET];
	}
}

- (void) setOffsetInSeconds:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_SEC_OFFSET value:value];
	}
}

- (bool) paused
{
	if(self.suspended)
	{
		return AL_PAUSED == shadowState;
	}

	return AL_PAUSED == self.state;
}

- (void) setPaused:(bool) shouldPause
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		if(shouldPause)
		{
			if(AL_PLAYING == self.state)
			{
                abortPlaybackResume = YES;
				if([ALWrapper sourcePause:sourceId])
				{
					shadowState = AL_PAUSED;
				}
			}
		}
		else
		{
			if(AL_PAUSED == self.state)
			{
				if([ALWrapper sourcePlay:sourceId])
                {
                    shadowState = AL_PLAYING;
                }
                else
				{
					shadowState = AL_STOPPED;
				}
			}
		}
	}
}

- (float) pitch
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_PITCH];
	}
}

- (void) setPitch:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_PITCH value:value];
	}
}

- (bool) playing
{
	if(self.suspended)
	{
		return AL_PLAYING == shadowState || AL_PAUSED == shadowState;
	}
	return AL_PLAYING == self.state || AL_PAUSED == self.state;
}

- (ALPoint) position
{
	ALPoint result;
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[ALWrapper getSource3f:sourceId parameter:AL_POSITION v1:&result.x v2:&result.y v3:&result.z];
	}
	return result;
}

- (void) setPosition:(ALPoint) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper source3f:sourceId parameter:AL_POSITION v1:value.x v2:value.y v3:value.z];
	}
}

- (float) pan
{
	return self.position.x;
}

- (void) setPan:(float) value
{
	if(self.suspended)
	{
		OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
		return;
	}
	
	self.position = alpoint(value, 0, 0);
}

- (float) referenceDistance
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_REFERENCE_DISTANCE];
	}
}

- (void) setReferenceDistance:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_REFERENCE_DISTANCE value:value];
	}
}

- (float) rolloffFactor
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcef:sourceId parameter:AL_ROLLOFF_FACTOR];
	}
}

- (void) setRolloffFactor:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcef:sourceId parameter:AL_ROLLOFF_FACTOR value:value];
	}
}

@synthesize sourceId;

- (int) sourceRelative
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcei:sourceId parameter:AL_SOURCE_RELATIVE];
	}
}

- (void) setSourceRelative:(int) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcei:sourceId parameter:AL_SOURCE_RELATIVE value:value];
	}
}

- (int) sourceType
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getSourcei:sourceId parameter:AL_SOURCE_TYPE];
	}
}

- (void) setSourceType:(int) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcei:sourceId parameter:AL_SOURCE_TYPE value:value];
	}
}

- (int) state
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		// Bug: Apple's OpenAL implementation is broken.
		//return [ALWrapper getSourcei:sourceId parameter:AL_SOURCE_STATE];
		
		if(AL_INITIAL == shadowState || AL_STOPPED == shadowState)
		{
			return shadowState;
		}
		if(AL_STOPPED == [ALWrapper getSourcei:sourceId parameter:AL_SOURCE_STATE])
		{
			return AL_STOPPED;
		}
		return shadowState;
	}
}

- (void) setState:(int) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper sourcei:sourceId parameter:AL_SOURCE_STATE value:value];
		shadowState = value;
	}
}

- (ALVector) velocity
{
	ALVector result;
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[ALWrapper getSource3f:sourceId parameter:AL_VELOCITY v1:&result.x v2:&result.y v3:&result.z];
	}
	return result;
}

- (void) setVelocity:(ALVector) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper source3f:sourceId parameter:AL_VELOCITY v1:value.x v2:value.y v3:value.z];
	}
}

- (float) reverbSendLevel
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper asaGetSourcef:sourceId property:ALC_ASA_REVERB_SEND_LEVEL];
	}
}

- (void) setReverbSendLevel:(float) reverbSendLevel
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper asaSourcef:sourceId property:ALC_ASA_REVERB_SEND_LEVEL value:reverbSendLevel];
	}
}

- (float) reverbOcclusion
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper asaGetSourcef:sourceId property:ALC_ASA_OCCLUSION];
	}
}

- (void) setReverbOcclusion:(float) reverbOcclusion
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper asaSourcef:sourceId property:ALC_ASA_OCCLUSION value:reverbOcclusion];
	}
}

- (float) reverbObstruction
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper asaGetSourcef:sourceId property:ALC_ASA_OBSTRUCTION];
	}
}

- (void) setReverbObstruction:(float) reverbObstruction
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper asaSourcef:sourceId property:ALC_ASA_OBSTRUCTION value:reverbObstruction];
	}
}



#pragma mark Suspend Handler

- (void) addSuspendListener:(id<OALSuspendListener>) listenerIn
{
	[suspendHandler addSuspendListener:listenerIn];
}

- (void) removeSuspendListener:(id<OALSuspendListener>) listenerIn
{
	[suspendHandler removeSuspendListener:listenerIn];
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
	return NO;
}

- (void) setInterrupted:(bool) value
{
#pragma unused(value)
    // Bug: Suspending on interrupt fails in iOS 6+ and doesn't seem to be needed anyway
}

- (bool) suspended
{
	return suspendHandler.suspended;
}

- (void) setSuspended:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
        if(value)
        {
            shadowState = self.state;
            if(AL_PLAYING == shadowState)
            {
                [ALWrapper sourcePause:sourceId];
            }
        }
        else
        {
            // The shadow state holds the state we had when suspending.
            if(AL_PLAYING == shadowState)
            {
                // Because Apple's OpenAL implementation can't stack commands (it defers processing
                // to a later sequence point), we have to delay resuming playback.
                abortPlaybackResume = NO;
                [self performSelector:@selector(delayedResumePlayback) withObject:nil afterDelay:0.03];
            }
        }
    }
}

- (void) delayedResumePlayback
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
        if(!abortPlaybackResume)
        {
            [ALWrapper sourcePlay:sourceId];
        }
    }
}


#pragma mark Playback

- (void) preload:(ALBuffer*) bufferIn
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[self stopActions];

		if(self.playing || self.paused)
		{
			[self stop];
		}
	
		self.buffer = bufferIn;
	}
}

- (id<ALSoundSource>) play
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return nil;
		}
		
		[self stopActions];

		if(self.playing)
		{
			if(!interruptible)
			{
				return nil;
			}
			[self stop];
		}
		
		if(self.paused)
		{
			[self stop];
		}
		
		if([ALWrapper sourcePlay:sourceId])
		{
			shadowState = AL_PLAYING;
		}
		else
		{
			shadowState = AL_STOPPED;
		}
	}
	return self;
}

- (id<ALSoundSource>) play:(ALBuffer*) bufferIn
{
	return [self play:bufferIn loop:NO];
}

- (id<ALSoundSource>) play:(ALBuffer*) bufferIn loop:(bool) loop
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return nil;
		}
		
		[self stopActions];

		if(self.playing)
		{
			if(!interruptible)
			{
				return nil;
			}
			[self stop];
		}
		
		self.buffer = bufferIn;
		self.looping = loop;
		
		if([ALWrapper sourcePlay:sourceId])
		{
			shadowState = AL_PLAYING;
		}
		else
		{
			shadowState = AL_STOPPED;
		}
	}
	return self;
}

- (id<ALSoundSource>) play:(ALBuffer*) bufferIn gain:(float) gainIn pitch:(float) pitchIn pan:(float) panIn loop:(bool) loopIn
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return nil;
		}
		
		[self stopActions];

		if(self.playing)
		{
			if(!interruptible)
			{
				return nil;
			}
			[self stop];
		}
		
		self.buffer = bufferIn;
		
		// Set gain, pitch, and pan
		self.gain = gainIn;
		self.pitch = pitchIn;
		self.pan = panIn;
		self.looping = loopIn;
		
		if([ALWrapper sourcePlay:sourceId])
		{
			shadowState = AL_PLAYING;
		}
		else
		{
			shadowState = AL_STOPPED;
		}
	}		
	return self;
}

- (void) stop
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		abortPlaybackResume = YES;
		[self stopActions];
		[ALWrapper sourceStop:sourceId];
		shadowState = AL_STOPPED;
	}
}

- (void) rewind
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		abortPlaybackResume = YES;
		[self stopActions];
		[ALWrapper sourceRewind:sourceId];
		shadowState = AL_INITIAL;
	}
}

- (void) fadeTo:(float) value
	   duration:(float) duration
		 target:(id) target
	   selector:(SEL) selector
{
	// Must always be synchronized
	@synchronized(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[self stopFade];
		gainAction = [OALSequentialActions actions:
                      [OALPropertyAction gainActionWithDuration:duration endValue:value],
                      [OALCallAction actionWithCallTarget:target selector:selector withObject:self],
                      nil];
        gainAction = as_retain(gainAction);
		[gainAction runWithTarget:self];
	}
}

- (void) stopFade
{
	// Must always be synchronized
	@synchronized(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[gainAction stopAction];
		as_release(gainAction);
		gainAction = nil;
	}
}

- (void) panTo:(float) value
	   duration:(float) duration
		 target:(id) target
	   selector:(SEL) selector
{
	// Must always be synchronized
	@synchronized(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[self stopPan];
		panAction = [OALSequentialActions actions:
                     [OALPropertyAction panActionWithDuration:duration endValue:value],
                     [OALCallAction actionWithCallTarget:target selector:selector withObject:self],
                     nil];
        panAction = as_retain(panAction);
		[panAction runWithTarget:self];
	}
}

- (void) stopPan
{
	// Must always be synchronized
	@synchronized(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[panAction stopAction];
		as_release(panAction);
		panAction = nil;
	}
}

- (void) pitchTo:(float) value
	  duration:(float) duration
		target:(id) target
	  selector:(SEL) selector
{
	// Must always be synchronized
	@synchronized(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[self stopPitch];
		pitchAction = [OALSequentialActions actions:
                       [OALPropertyAction pitchActionWithDuration:duration endValue:value],
					   [OALCallAction actionWithCallTarget:target selector:selector withObject:self],
					   nil];
        pitchAction = as_retain(pitchAction);
		[pitchAction runWithTarget:self];
	}
}

- (void) stopPitch
{
	// Must always be synchronized
	@synchronized(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[pitchAction stopAction];
		as_release(pitchAction);
		pitchAction = nil;
	}
}

- (void) stopActions
{
	[self stopFade];
	[self stopPan];
	[self stopPitch];
}

- (void) clear
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		self.manuallySuspended = NO;
		[self stop];
		self.buffer = nil;
	}
}


#pragma mark Queued Playback

- (bool) queueBuffer:(ALBuffer*) bufferIn
{
    return [self queueBuffer:bufferIn repeats:0];
}

- (bool) queueBuffer:(ALBuffer*) bufferIn repeats:(NSUInteger) repeats
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return NO;
		}
		
		if(AL_STATIC == self.state)
		{
			self.buffer = nil;
		}
        
        NSUInteger totalTimes = repeats + 1;
		ALuint* bufferIds = (ALuint*)malloc(sizeof(ALuint) * totalTimes);
		ALuint bufferId = bufferIn.bufferId;
		for(NSUInteger i = 0; i < totalTimes; i++)
		{
			bufferIds[i] = bufferId;
		}
		bool result = [ALWrapper sourceQueueBuffers:sourceId numBuffers:(ALsizei)totalTimes bufferIds:bufferIds];
		free(bufferIds);
		return result;
	}
}

- (bool) queueBuffers:(NSArray*) buffers
{
    return [self queueBuffers:buffers repeats:0];
}

- (bool) queueBuffers:(NSArray*) buffers repeats:(NSUInteger) repeats
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return NO;
		}
		
		if(AL_STATIC == self.state)
		{
			self.buffer = nil;
		}

        NSUInteger numBuffers = [buffers count];
        NSUInteger totalTimes = repeats + 1;
		ALuint* bufferIds = (ALuint*)malloc(sizeof(ALuint) * totalTimes * numBuffers);
        NSUInteger bufferNum;
        
		for(NSUInteger i = 0; i < totalTimes; i++)
		{
            bufferNum = 0;
            for(ALBuffer* buf in buffers)
            {
                bufferIds[(i * numBuffers) + bufferNum] = buf.bufferId;
                bufferNum++;
            }
		}
		bool result = [ALWrapper sourceQueueBuffers:sourceId numBuffers:(ALsizei)(totalTimes*numBuffers) bufferIds:bufferIds];
		free(bufferIds);
		return result;
	}
}

- (bool) unqueueBuffer:(ALBuffer*) bufferIn
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return NO;
		}
		
		ALuint bufferId = bufferIn.bufferId;
		return [ALWrapper sourceUnqueueBuffers:sourceId numBuffers:1 bufferIds:&bufferId];
	}
}

- (bool) unqueueBuffers:(NSArray*) buffers
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return NO;
		}
		
		if(AL_STATIC == self.state)
		{
			self.buffer = nil;
		}
		NSUInteger numBuffers = [buffers count];
		ALuint* bufferIds = malloc(sizeof(ALuint) * numBuffers);
		int i = 0;
		for(ALBuffer* buf in buffers)
		{
			bufferIds[i] = buf.bufferId;
		}
		bool result = [ALWrapper sourceUnqueueBuffers:sourceId numBuffers:(ALsizei)numBuffers bufferIds:bufferIds];
		free(bufferIds);
		return result;
	}
}


#pragma mark Notifications

+ (void) notifySourceAllocated:(ALSource*) source
{
    @synchronized(g_allSourcesByID)
    {
        [g_allSourcesByID setObject:source forKey:[NSNumber numberWithUnsignedInt:source.sourceId]];
    }
}

+ (void) notifySourceDeallocated:(ALSource*) source
{
    @synchronized(g_allSourcesByID)
    {
        [g_allSourcesByID removeObjectForKey:[NSNumber numberWithUnsignedInt:source.sourceId]];
    }
}

- (void) registerNotification:(ALuint) notificationID
                     callback:(OALSourceNotificationCallback) callback
                     userData:(void*) userData
{
    NSNumber* key = [NSNumber numberWithUnsignedInt:notificationID];
    OPTIONALLY_SYNCHRONIZED(self)
    {
        [self unregisterNotification:notificationID];
        [self.notificationCallbacks setObject:as_autorelease([callback copy])
                                       forKey:key];
        [ALWrapper addNotification:notificationID
                          onSource:self.sourceId
                          callback:alSourceNotification
                          userData:userData];
    }
}

- (void) unregisterNotification:(ALuint) notificationID
{
    NSNumber* key = [NSNumber numberWithUnsignedInt:notificationID];
    OPTIONALLY_SYNCHRONIZED(self)
    {
        if([self.notificationCallbacks objectForKey:key] != nil)
        {
            [self.notificationCallbacks removeObjectForKey:key];
            [ALWrapper removeNotification:notificationID
                                 onSource:self.sourceId
                                 callback:alSourceNotification
                                 userData:NULL];
        }
    }
}

- (void) unregisterAllNotifications
{
    OPTIONALLY_SYNCHRONIZED(self)
    {
        for(NSNumber* key in [self.notificationCallbacks allKeys])
        {
            [ALWrapper removeNotification:[key unsignedIntValue]
                                 onSource:self.sourceId
                                 callback:alSourceNotification
                                 userData:NULL];
        }
        [self.notificationCallbacks removeAllObjects];
    }
}

- (void) receiveNotification:(ALuint) notificationID userData:(void*) userData
{
    NSNumber* key = [NSNumber numberWithUnsignedInt:notificationID];
    OPTIONALLY_SYNCHRONIZED(self)
    {
        OALSourceNotificationCallback callback = [self.notificationCallbacks objectForKey:key];
        if(callback != nil)
        {
            callback(self, notificationID, userData);
        }
    }
}


#pragma mark Internal Use

- (bool) requestUnreserve:(bool) interrupt
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.playing)
		{
			if(!self.interruptible || !interrupt)
			{
				return NO;
			}
			[self stop];
		}
		self.buffer = nil;
	}
	return YES;
}


@end
