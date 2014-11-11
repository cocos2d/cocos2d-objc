//
//  ChannelSource.m
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

#import "ALChannelSource.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "OpenALManager.h"



#define SYNTHESIZE_DELEGATE_PROPERTY(NAME, CAPSNAME, TYPE) \
- (TYPE) NAME \
{ \
	OPTIONALLY_SYNCHRONIZED(sourcePool) \
	{ \
		return NAME; \
	} \
} \
 \
- (void) set##CAPSNAME:(TYPE) value \
{ \
	OPTIONALLY_SYNCHRONIZED(sourcePool) \
	{ \
		NAME = value; \
		for(id<ALSoundSource> source in sourcePool.sources) \
		{ \
			source.NAME = value; \
		} \
	} \
}



#pragma mark -
#pragma mark Private Methods

/** \cond */
/**
 * (INTERNAL USE) Private methods for ALChannelSource.
 */
@interface ALChannelSource (Private)

/** (INTERNAL USE) Called by the action system when a fade completes.
 */
- (void) onFadeComplete:(id<ALSoundSource>) source;

/** (INTERNAL USE) Called by the action system when a pan completes.
 */
- (void) onPanComplete:(id<ALSoundSource>) source;

/** (INTERNAL USE) Called by the action system when a pitch change completes.
 */
- (void) onPitchComplete:(id<ALSoundSource>) source;

/** (INTERNAL USE) Set defaults from another channel.
 */
- (void) setDefaultsFromChannel:(ALChannelSource*) channel;

@end
/** \endcond */


@implementation ALChannelSource

#pragma mark Object Management

+ (id) channelWithSources:(int) reservedSources
{
	return as_autorelease([[self alloc] initWithSources:reservedSources]);
}

- (id) initWithSources:(int) reservedSources
{
	if(nil != (self = [super init]))
	{
		OAL_LOG_DEBUG(@"%@: Init with %d sources", self, reservedSources);

		context = as_retain([OpenALManager sharedInstance].currentContext);

		sourcePool = [[ALSoundSourcePool alloc] init];

        for(int i = 0; i < reservedSources; i++)
        {
            [self addSource:[ALSource source]];
        }            
	}
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc", self);
	
	as_release(sourcePool);
	as_release(context);

    as_superdealloc();
}

- (int) reservedSources
{
	return (int)[sourcePool.sources count];
}

- (void) setReservedSources:(int) reservedSources
{
    while(self.reservedSources < reservedSources)
    {
        [self addSource:nil];
    }

    while(self.reservedSources > reservedSources)
    {
        [self removeSource:nil];
    }
}


#pragma mark Properties

@synthesize context;

@synthesize sourcePool;

- (float) volume
{
	return self.gain;
}

- (void) setVolume:(float) value
{
	self.gain = value;
}

- (float) pan
{
	return position.x;
}

- (void) setPan:(float) value
{
	[self setPosition:alpoint(value, 0, 0)];
}

- (int) sourceType
{
    return sourceType;
}

- (bool) playing
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
		for(id<ALSoundSource> source in sourcePool.sources)
		{
			if(source.playing)
			{
				return YES;
			}
		}
	}
	return NO;
}

SYNTHESIZE_DELEGATE_PROPERTY(coneInnerAngle, ConeInnerAngle, float);

SYNTHESIZE_DELEGATE_PROPERTY(coneOuterAngle, ConeOuterAngle, float);

SYNTHESIZE_DELEGATE_PROPERTY(coneOuterGain, ConeOuterGain, float);

SYNTHESIZE_DELEGATE_PROPERTY(direction, Direction, ALVector);

SYNTHESIZE_DELEGATE_PROPERTY(gain, Gain, float);

SYNTHESIZE_DELEGATE_PROPERTY(interruptible, Interruptible, bool);

SYNTHESIZE_DELEGATE_PROPERTY(looping, Looping, bool);

SYNTHESIZE_DELEGATE_PROPERTY(maxDistance, MaxDistance, float);

SYNTHESIZE_DELEGATE_PROPERTY(maxGain, MaxGain, float);

SYNTHESIZE_DELEGATE_PROPERTY(minGain, MinGain, float);

SYNTHESIZE_DELEGATE_PROPERTY(muted, Muted, bool);

SYNTHESIZE_DELEGATE_PROPERTY(paused, Paused, bool);

SYNTHESIZE_DELEGATE_PROPERTY(pitch, Pitch, float);

SYNTHESIZE_DELEGATE_PROPERTY(position, Position, ALPoint);

SYNTHESIZE_DELEGATE_PROPERTY(referenceDistance, ReferenceDistance, float);

SYNTHESIZE_DELEGATE_PROPERTY(rolloffFactor, RolloffFactor, float);

SYNTHESIZE_DELEGATE_PROPERTY(sourceRelative, SourceRelative, int);

SYNTHESIZE_DELEGATE_PROPERTY(velocity, Velocity, ALVector);

SYNTHESIZE_DELEGATE_PROPERTY(reverbSendLevel, ReverbSendLevel, float);

SYNTHESIZE_DELEGATE_PROPERTY(reverbOcclusion, ReverbOcclusion, float);

SYNTHESIZE_DELEGATE_PROPERTY(reverbObstruction, ReverbObstruction, float);

#pragma mark Playback

- (id<ALSoundSource>) play
{
	// Do nothing.
	OAL_LOG_WARNING(@"%@: \"play\" does nothing in ChannelSource.  Use \"play:(ALBuffer*) buffer loop:(bool) loop\" instead.", self);
	return nil;
}

- (id<ALSoundSource>) play:(ALBuffer*) buffer
{
	return [self play:buffer loop:NO];
}

- (id<ALSoundSource>) play:(ALBuffer*) buffer loop:(bool) loop
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
		// Try to find a free source for playback.
		// If this channel is not interruptible, it will not attempt to interrupt its contained sources.
		id<ALSoundSource> soundSource = [sourcePool getFreeSource:interruptible];
		return [soundSource play:buffer loop:loop];
	}
}

- (id<ALSoundSource>) play:(ALBuffer*) buffer gain:(float) gainIn pitch:(float) pitchIn pan:(float) panIn loop:(bool) loop
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
		// Try to find a free source for playback.
		// If this channel is not interruptible, it will not attempt to interrupt its contained sources.
		id<ALSoundSource> soundSource = [sourcePool getFreeSource:interruptible];
		return [soundSource play:buffer gain:gainIn pitch:pitchIn pan:panIn loop:loop];
	}
}

- (void) stop
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        [sourcePool.sources makeObjectsPerformSelector:@selector(stop)];
	}
}

- (void) rewind
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        [sourcePool.sources makeObjectsPerformSelector:@selector(rewind)];
	}
}

- (void) fadeTo:(float) value duration:(float) duration target:(id) target selector:(SEL) selector
{
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		[self stopFade];
		fadeCompleteTarget = target;
		fadeCompleteSelector = selector;

		currentFadeCallbackCount = 0;
		expectedFadeCallbackCount = (int)[sourcePool.sources count];
		for(id<ALSoundSource> source in sourcePool.sources)
		{
			[source fadeTo:value duration:duration target:self selector:@selector(onFadeComplete:)];
		}
	}
}

- (void) onFadeComplete:(id<ALSoundSource>) source
{
    #pragma unused(source)
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		currentFadeCallbackCount++;
		if(currentFadeCallbackCount == expectedFadeCallbackCount)
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[fadeCompleteTarget performSelector:fadeCompleteSelector withObject:self];
#pragma clang diagnostic pop
		}
	}
}

- (void) stopFade
{
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		[sourcePool.sources makeObjectsPerformSelector:@selector(stopFade)];
	}
}

- (void) panTo:(float) value duration:(float) duration target:(id) target selector:(SEL) selector
{
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		[self stopPan];
		panCompleteTarget = target;
		panCompleteSelector = selector;
		
		currentPanCallbackCount = 0;
		expectedPanCallbackCount = (int)[sourcePool.sources count];
		for(id<ALSoundSource> source in sourcePool.sources)
		{
			[source panTo:value duration:duration target:self selector:@selector(onPanComplete:)];
		}
	}
}

- (void) onPanComplete:(id<ALSoundSource>) source
{
    #pragma unused(source)
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		currentPanCallbackCount++;
		if(currentPanCallbackCount == expectedPanCallbackCount)
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[panCompleteTarget performSelector:panCompleteSelector withObject:self];
		}
#pragma clang diagnostic pop
	}
}

- (void) stopPan
{
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		[sourcePool.sources makeObjectsPerformSelector:@selector(stopPan)];
	}
}

- (void) pitchTo:(float) value duration:(float) duration target:(id) target selector:(SEL) selector
{
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		[self stopPitch];
		pitchCompleteTarget = target;
		pitchCompleteSelector = selector;
		
		currentPitchCallbackCount = 0;
		expectedPitchCallbackCount = (int)[sourcePool.sources count];
		for(id<ALSoundSource> source in sourcePool.sources)
		{
			[source pitchTo:value duration:duration target:self selector:@selector(onPitchComplete:)];
		}
	}
}

- (void) onPitchComplete:(id<ALSoundSource>) source
{
    #pragma unused(source)
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		currentPitchCallbackCount++;
		if(currentPitchCallbackCount == expectedPitchCallbackCount)
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[pitchCompleteTarget performSelector:pitchCompleteSelector withObject:self];
#pragma clang diagnostic pop
		}
	}
}

- (void) stopPitch
{
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		[sourcePool.sources makeObjectsPerformSelector:@selector(stopPitch)];
	}
}

- (void) stopActions
{
	// Must always be synchronized
	@synchronized(sourcePool)
	{
		[sourcePool.sources makeObjectsPerformSelector:@selector(stopActions)];
	}
}


- (void) clear
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        [sourcePool.sources makeObjectsPerformSelector:@selector(clear)];
	}
}

- (void) setDefaultsFromSource:(id<ALSoundSource>) source
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        defaultPitch = source.pitch;
        defaultGain = source.gain;
        defaultMaxDistance = source.maxDistance;
        defaultRolloffFactor = source.rolloffFactor;
        defaultReferenceDistance = source.referenceDistance;
        defaultMinGain = source.minGain;
        defaultMaxGain = source.maxGain;
        defaultConeOuterGain = source.coneOuterGain;
        defaultConeInnerAngle = source.coneInnerAngle;
        defaultConeOuterAngle = source.coneOuterAngle;
        defaultPosition = source.position;
        defaultVelocity = source.velocity;
        defaultDirection = source.direction;
        defaultSourceRelative = source.sourceRelative;
        defaultSourceType = source.sourceType;
        defaultLooping = source.looping;
        
        defaultsInitialized = YES;
    }
}

- (void) setDefaultsFromChannel:(ALChannelSource*) channel
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        defaultPitch = channel->defaultPitch;
        defaultGain = channel->defaultGain;
        defaultMaxDistance = channel->defaultMaxDistance;
        defaultRolloffFactor = channel->defaultRolloffFactor;
        defaultReferenceDistance = channel->defaultReferenceDistance;
        defaultMinGain = channel->defaultMinGain;
        defaultMaxGain = channel->defaultMaxGain;
        defaultConeOuterGain = channel->defaultConeOuterGain;
        defaultConeInnerAngle = channel->defaultConeInnerAngle;
        defaultConeOuterAngle = channel->defaultConeOuterAngle;
        defaultPosition = channel->defaultPosition;
        defaultVelocity = channel->defaultVelocity;
        defaultDirection = channel->defaultDirection;
        defaultSourceRelative = channel->defaultSourceRelative;
        defaultSourceType = channel->defaultSourceType;
        defaultLooping = channel->defaultLooping;
        
        defaultsInitialized = YES;
    }
}



- (void) resetToDefault
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        self.pitch = defaultPitch;
        self.gain = defaultGain;
        self.maxDistance = defaultMaxDistance;
        self.rolloffFactor = defaultRolloffFactor;
        self.referenceDistance = defaultReferenceDistance;
        self.minGain = defaultMinGain;
        self.maxGain = defaultMaxGain;
        // Bug: Disabled due to OpenAL default ConeOuterGain value issue
        // self.coneOuterGain = defaultConeOuterGain;
        self.coneInnerAngle = defaultConeInnerAngle;
        self.coneOuterAngle = defaultConeOuterAngle;
        self.position = defaultPosition;
        self.velocity = defaultVelocity;
        self.direction = defaultDirection;
        self.sourceRelative = defaultSourceRelative;
        sourceType = defaultSourceType;
        self.looping = defaultLooping;
    }
}



- (void) addSource:(id<ALSoundSource>) source
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        if(nil == source)
        {
            source = [ALSource source];
        }
        if(defaultsInitialized)
        {
            source.pitch = pitch;
            source.gain = gain;
            source.maxDistance = maxDistance;
            source.rolloffFactor = rolloffFactor;
            source.referenceDistance = referenceDistance;
            source.minGain = minGain;
            source.maxGain = maxGain;
            // Bug: Disabled due to OpenAL default ConeOuterGain value issue
            // source.coneOuterGain = coneOuterGain;
            source.coneInnerAngle = coneInnerAngle;
            source.coneOuterAngle = coneOuterAngle;
            source.position = position;
            source.velocity = velocity;
            source.direction = direction;
            source.sourceRelative = sourceRelative;
            source.looping = looping;
        }
        else
        {
            [self setDefaultsFromSource:source];
            [self resetToDefault];
        }
        [sourcePool addSource:source];
    }
}

- (id<ALSoundSource>) removeSource:(id<ALSoundSource>) source
{
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        if(nil == source)
        {
            source = [sourcePool getFreeSource:YES];
            if(nil == source)
            {
                return nil;
            }
        }
        as_autorelease_noref(as_retain(source));
        [sourcePool removeSource:source];
    }
    
    return source;
}

- (ALChannelSource*) splitChannelWithSources:(int) numSources
{
    ALChannelSource* newChannel;

	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        newChannel = [ALChannelSource channelWithSources:0];
        [newChannel setDefaultsFromChannel:self];
        [newChannel resetToDefault];
        for(int i = 0; i < numSources; i++)
        {
            id<ALSoundSource> source = [self removeSource:nil];
            if(nil == source)
            {
                break;
            }
            [newChannel addSource:source];
        }
    }

    return newChannel;
}

- (void) addChannel:(ALChannelSource*) channel
{
    id<ALSoundSource> source;
    
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        while (nil != (source = [channel removeSource:nil]))
        {
            [self addSource:source];
        }
    }
}

- (NSArray*) clearUnusedBuffers
{
    NSMutableArray* removed = [NSMutableArray arrayWithCapacity:[sourcePool.sources count]];
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        for(ALSource* source in sourcePool.sources)
        {
            if([source isKindOfClass:[ALSource class]] &&
               !source.playing &&
               source.buffer != nil)
            {
                [removed addObject:source.buffer];
                source.buffer = nil;
            }
        }
    }
    return removed;
}

- (BOOL) removeBuffersNamed:(NSString*) name
{
    BOOL playing = NO;
	OPTIONALLY_SYNCHRONIZED(sourcePool)
	{
        for(ALSource* source in sourcePool.sources)
        {
            if([source isKindOfClass:[ALSource class]] &&
               [source.buffer.name isEqualToString:name])
            {
                if(source.playing)
                {
                    playing = YES;
                }
                else
                {
                    source.buffer = nil;
                }
            }
        }
    }
    return !playing;
}

@end
