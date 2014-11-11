//
//  OALSimpleAudio.m
//  ObjectAL
//
//  Created by Karl Stenerud on 10-01-14.
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

#import "OALSimpleAudio.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "OALAudioSession.h"
#import "OpenALManager.h"

// By default, reserve all 32 sources.
#define kDefaultReservedSources 32

#pragma mark -
#pragma mark Private Methods

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(OALSimpleAudio);

/** \cond */
/**
 * (INTERNAL USE) Private interface to OALSimpleAudio.
 */
@interface OALSimpleAudio (Private)

/** (INTERNAL USE) Preload a sound effect and return the preloaded buffer.
 *
 * @param filePath The path containing the sound data.
 * @param reduceToMono If true, reduce the sample to mono
 *        (stereo samples don't support panning or positional audio).
 * @return The preloaded buffer.
 */
- (ALBuffer*) internalPreloadEffect:(NSString*) filePath reduceToMono:(bool) reduceToMono;

@end
/** \endcond */

#pragma mark -
#pragma mark OALSimpleAudio

@implementation OALSimpleAudio

#pragma mark Object Management

SYNTHESIZE_SINGLETON_FOR_CLASS(OALSimpleAudio);

@synthesize device;
@synthesize context;

+ (OALSimpleAudio*) sharedInstanceWithSources:(int) sources
{
	return as_autorelease([[self alloc] initWithSources:sources]);
}

+ (OALSimpleAudio*) sharedInstanceWithReservedSources:(int) reservedSources
                                          monoSources:(int) monoSources
                                        stereoSources:(int) stereoSources
{
    return as_autorelease([[self alloc] initWithReservedSources:reservedSources
                                                    monoSources:monoSources
                                                  stereoSources:stereoSources]);
}

- (id) init
{
	return [self initWithSources:kDefaultReservedSources];
}

- (void) initCommon:(int) reservedSources
{
    [OpenALManager sharedInstance].currentContext = context;
    channel = [[ALChannelSource alloc] initWithSources:reservedSources];

    backgroundTrack = [[OALAudioTrack alloc] init];

#if NS_BLOCKS_AVAILABLE && OBJECTAL_CFG_USE_BLOCKS
    oal_dispatch_queue	= dispatch_queue_create("objectal.simpleaudio.queue", NULL);
#endif
    pendingLoadCount	= 0;

    self.preloadCacheEnabled = YES;
    self.bgVolume = 1.0f;
    self.effectsVolume = 1.0f;
}

- (id) initWithReservedSources:(int) reservedSources
                   monoSources:(int) monoSources
                 stereoSources:(int) stereoSources
{
	if(nil != (self = [super init]))
	{
		OAL_LOG_DEBUG(@"%@: Init with %d reserved sources, %d mono, %d stereo",
                      self, reservedSources, monoSources, stereoSources);
		device = [[ALDevice alloc] initWithDeviceSpecifier:nil];
        context = [[ALContext alloc] initOnDevice:device
                                  outputFrequency:44100
                                 refreshIntervals:10
                               synchronousContext:FALSE
                                      monoSources:monoSources
                                    stereoSources:stereoSources];
        [self initCommon:reservedSources];
	}
	return self;
}

- (id) initWithSources:(int) reservedSources
{
	if(nil != (self = [super init]))
	{
		OAL_LOG_DEBUG(@"%@: Init with %d reserved sources", self, reservedSources);
		device = [[ALDevice alloc] initWithDeviceSpecifier:nil];
        context = [[ALContext alloc] initOnDevice:device attributes:nil];
        [self initCommon:reservedSources];
	}
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc", self);
#if NS_BLOCKS_AVAILABLE && OBJECTAL_CFG_USE_BLOCKS && !__has_feature(objc_arc)
	dispatch_release(oal_dispatch_queue);
#endif

	as_release(backgroundTrack);
	[channel stop];
	as_release(channel);
	as_release(context);
	as_release(device);
	as_release(preloadCache);
	as_superdealloc();
}

#pragma mark Properties

- (NSUInteger) preloadCacheCount
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [preloadCache count];
	}
}

- (bool) preloadCacheEnabled
{
    return nil != preloadCache;
}

- (void) setPreloadCacheEnabled:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(value != self.preloadCacheEnabled)
		{
			if(value)
			{
				preloadCache = [[NSMutableDictionary alloc] initWithCapacity:64];
			}
			else
			{
				if(pendingLoadCount > 0)
				{
					OAL_LOG_WARNING(@"Attempted to turn off preload cache while pending loads are queued.");
					return;
				}
				else
				{
					as_release(preloadCache);
					preloadCache = nil;
				}
			}
		}
	}
}

- (bool) allowIpod
{
	return [OALAudioSession sharedInstance].allowIpod;
}

- (void) setAllowIpod:(bool) value
{
	[OALAudioSession sharedInstance].allowIpod = value;
}

- (bool) useHardwareIfAvailable
{
	return [OALAudioSession sharedInstance].useHardwareIfAvailable;
}

- (void) setUseHardwareIfAvailable:(bool) value
{
	[OALAudioSession sharedInstance].useHardwareIfAvailable = value;
}


- (int) reservedSources
{
	return channel.reservedSources;
}

- (void) setReservedSources:(int) value
{
	channel.reservedSources = value;
}

@synthesize channel;

@synthesize backgroundTrack;

- (bool) bgPaused
{
	return backgroundTrack.paused;
}

- (void) setBgPaused:(bool) value
{
	backgroundTrack.paused = value;
}

- (bool) bgPlaying
{
	return backgroundTrack.playing;
}

- (float) bgVolume
{
	return backgroundTrack.gain;
}

- (void) setBgVolume:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		backgroundTrack.gain = value;
	}
}

- (bool) effectsPaused
{
	return channel.paused;
}

- (void) setEffectsPaused:(bool) value
{
	channel.paused = value;
}

- (float) effectsVolume
{
	return [OpenALManager sharedInstance].currentContext.listener.gain;
}

- (void) setEffectsVolume:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[OpenALManager sharedInstance].currentContext.listener.gain = value;
	}
}

- (bool) paused
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return self.effectsPaused && self.bgPaused;
	}
}

- (void) setPaused:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		self.effectsPaused = self.bgPaused = value;
	}
}

- (bool) honorSilentSwitch
{
	return [OALAudioSession sharedInstance].honorSilentSwitch;
}

- (void) setHonorSilentSwitch:(bool) value
{
	[OALAudioSession sharedInstance].honorSilentSwitch = value;
}

- (bool) bgMuted
{
    return bgMuted;
}

- (void) setBgMuted:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		bgMuted = value;
		backgroundTrack.muted = bgMuted | muted;
	}
}

- (bool) effectsMuted
{
    return effectsMuted;
}

- (void) setEffectsMuted:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		effectsMuted = value;
		[OpenALManager sharedInstance].currentContext.listener.muted = effectsMuted | muted;
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
		muted = value;
		backgroundTrack.muted = bgMuted | muted;
		[OpenALManager sharedInstance].currentContext.listener.muted = effectsMuted | muted;
	}
}

#pragma mark Background Music

- (NSURL *) backgroundTrackURL
{
	return [backgroundTrack currentlyLoadedUrl];
}

- (bool) preloadBg:(NSString*) filePath
{
	return [self preloadBg:filePath seekTime:0];
}

- (bool) preloadBg:(NSString*) filePath seekTime:(NSTimeInterval)seekTime
{
	if(nil == filePath)
	{
		OAL_LOG_ERROR(@"filePath was NULL");
		return NO;
	}
	BOOL result = [backgroundTrack preloadFile:filePath seekTime:seekTime];
	if(result){
		backgroundTrack.numberOfLoops = 0;
	}
	return result;
}

- (bool) playBg:(NSString*) filePath
{
	return [self playBg:filePath loop:NO];
}

- (bool) playBg:(NSString*) filePath loop:(bool) loop
{
	if(nil == filePath)
	{
		OAL_LOG_ERROR(@"filePath was NULL");
		return NO;
	}
	return [backgroundTrack playFile:filePath loops:loop ? -1 : 0];
}

- (bool) playBg:(NSString*) filePath
		 volume:(float) volume
			pan:(float) pan
		   loop:(bool) loop
{
	OAL_LOG_DEBUG(@"Play bg with vol %f, pan %f, loop %d, file %@", volume, pan, loop, filePath);
	OPTIONALLY_SYNCHRONIZED(self)
	{
		backgroundTrack.gain = volume;
		backgroundTrack.pan = pan;
		return [backgroundTrack playFile:filePath loops:loop ? -1 : 0];
	}
}

- (bool) playBg
{
	return [self playBgWithLoop:NO];
}

- (bool) playBgWithLoop:(bool) loop
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		OAL_LOG_DEBUG(@"Play bg, loop %d", loop);
		backgroundTrack.numberOfLoops = loop ? -1 : 0;
		return [backgroundTrack play];
	}
}

- (void) stopBg
{
	OAL_LOG_DEBUG(@"Stop bg");
	[backgroundTrack stop];
}


#pragma mark Sound Effects

- (NSString*) cacheKeyForBuffer:(ALBuffer*) buffer
{
    return buffer.name;
}

- (NSString*) cacheKeyForEffectPath:(NSString*) filePath
{
    return [[OALTools urlForPath:filePath] description];
}

- (ALBuffer*) internalPreloadEffect:(NSString*) filePath reduceToMono:(bool) reduceToMono
{
	ALBuffer* buffer;
    NSString* cacheKey = [self cacheKeyForEffectPath:filePath];
	OPTIONALLY_SYNCHRONIZED(self)
	{
		buffer = [preloadCache objectForKey:cacheKey];
	}
	if(nil == buffer)
	{
		OAL_LOG_DEBUG(@"Effect not in cache. Loading %@", filePath);
		buffer = [[OpenALManager sharedInstance] bufferFromFile:filePath reduceToMono:reduceToMono];
		if(nil == buffer)
		{
			OAL_LOG_ERROR(@"Could not load effect %@", filePath);
			return nil;
		}

        buffer.name = cacheKey;
		OPTIONALLY_SYNCHRONIZED(self)
		{
			[preloadCache setObject:buffer forKey:cacheKey];
		}
	}

	return buffer;
}

- (ALBuffer*) preloadEffect:(NSString*) filePath
{
	return [self preloadEffect:filePath reduceToMono:NO];
}

- (ALBuffer*) preloadEffect:(NSString*) filePath reduceToMono:(bool) reduceToMono
{
	if(nil == filePath)
	{
		OAL_LOG_ERROR(@"filePath was NULL");
		return nil;
	}

    if(pendingLoadCount > 0)
    {
        OAL_LOG_WARNING(@"You are loading an effect synchronously, but have pending async loads that have not completed. Your load will happen after those finish. Your thread is now stuck waiting. Next time just load everything async please.");
    }

#if NS_BLOCKS_AVAILABLE && OBJECTAL_CFG_USE_BLOCKS
	//Using blocks with the same queue used to asynch load removes the need for locking
	//BUT be warned that if you had called preloadEffects and then called this method, your app will stall until all of the loading is done.
	//It is advised you just always use async loading
	__block ALBuffer* retBuffer = nil;
	pendingLoadCount++;
	dispatch_sync(oal_dispatch_queue,
                  ^{
                      retBuffer = [self internalPreloadEffect:filePath reduceToMono:reduceToMono];
                  });
	pendingLoadCount--;
	return retBuffer;
#else
	return [self internalPreloadEffect:filePath reduceToMono:reduceToMono];
#endif
}

#if NS_BLOCKS_AVAILABLE && OBJECTAL_CFG_USE_BLOCKS

- (BOOL) preloadEffect:(NSString*) filePath
          reduceToMono:(bool) reduceToMono
       completionBlock:(void(^)(ALBuffer *)) completionBlock
{
	if(nil == filePath)
	{
		OAL_LOG_ERROR(@"filePath was NULL");
		completionBlock(nil);
		return NO;
	}

	pendingLoadCount++;
	dispatch_async(oal_dispatch_queue,
                   ^{
                       OAL_LOG_INFO(@"Preloading effect: %@", filePath);

                       ALBuffer *retBuffer = [self internalPreloadEffect:filePath reduceToMono:reduceToMono];
                       if(!retBuffer)
                       {
                           OAL_LOG_WARNING(@"%@ failed to preload.", filePath);
                       }
                       dispatch_async(dispatch_get_main_queue(),
                                      ^{
                                          completionBlock(retBuffer);
                                          pendingLoadCount--;
                                      });
                   });
	return YES;
}

- (void) preloadEffects:(NSArray*) filePaths
           reduceToMono:(bool) reduceToMono
		  progressBlock:(void (^)(NSUInteger progress, NSUInteger successCount, NSUInteger total)) progressBlock
{
	NSUInteger total = [filePaths count];
	if(total < 1)
	{
		OAL_LOG_ERROR(@"Preload effects: No files to process");
		progressBlock(0,0,0);
		return;
	}

	__block NSUInteger successCount = 0;

	pendingLoadCount += total;
	dispatch_async(oal_dispatch_queue,
                   ^{
                       [filePaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                        {
                            #pragma unused(stop)
                            OAL_LOG_INFO(@"Preloading effect: %@", obj);
                            ALBuffer *result = [self internalPreloadEffect:(NSString *)obj reduceToMono:reduceToMono];
                            if(!result)
                            {
                                OAL_LOG_WARNING(@"%@ failed to preload.", obj);
                            }
                            else
                            {
                                successCount++;
                            }
                            NSUInteger cnt = idx+1;
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               if(cnt == total)
                                               {
                                                   pendingLoadCount		-= total;
                                               }
                                               progressBlock(cnt, successCount, total);
                                           });
                        }];
                   });
}
#endif

- (bool) unloadEffect:(NSString*) filePath
{
	if(nil == filePath)
	{
		OAL_LOG_ERROR(@"filePath was NULL");
		return NO;
	}
    NSString* cacheKey = [self cacheKeyForEffectPath:filePath];
	OAL_LOG_DEBUG(@"Remove effect from cache: %@", filePath);
    bool isSuccess = YES;
	OPTIONALLY_SYNCHRONIZED(self)
	{
        isSuccess = [channel removeBuffersNamed:cacheKey];
        if(isSuccess)
        {
            [preloadCache removeObjectForKey:cacheKey];
        }
	}
    if(!isSuccess)
    {
        OAL_LOG_DEBUG(@"Could not remove effect from cache because it is still playing: %@", filePath);
    }
    return isSuccess;
}

- (void) unloadAllEffects
{
    OAL_LOG_DEBUG(@"Remove all effects from cache");
	OPTIONALLY_SYNCHRONIZED(self)
	{
        for(ALBuffer* buffer in [channel clearUnusedBuffers])
        {
            [preloadCache removeObjectForKey:[self cacheKeyForBuffer:buffer]];
        }
	}
}

- (id<ALSoundSource>) playEffect:(NSString*) filePath
{
	return [self playEffect:filePath volume:1.0f pitch:1.0f pan:0.0f loop:NO];
}

- (id<ALSoundSource>) playEffect:(NSString*) filePath loop:(bool) loop
{
	return [self playEffect:filePath volume:1.0f pitch:1.0f pan:0.0f loop:loop];
}

- (id<ALSoundSource>) playEffect:(NSString*) filePath
						  volume:(float) volume
						   pitch:(float) pitch
							 pan:(float) pan
							loop:(bool) loop
{
	if(nil == filePath)
	{
		OAL_LOG_ERROR(@"filePath was NULL");
		return nil;
	}
	ALBuffer* buffer = [self internalPreloadEffect:filePath reduceToMono:NO];
	if(nil != buffer)
	{
		return [channel play:buffer gain:volume pitch:pitch pan:pan loop:loop];
	}
	return nil;
}

- (id<ALSoundSource>) playBuffer:(ALBuffer*) buffer
						  volume:(float) volume
						   pitch:(float) pitch
							 pan:(float) pan
							loop:(bool) loop
{
	if(nil == buffer)
	{
		OAL_LOG_ERROR(@"buffer was NULL");
		return nil;
	}
	return [channel play:buffer gain:volume pitch:pitch pan:pan loop:loop];
}

- (void) stopAllEffects
{
	OAL_LOG_DEBUG(@"Stop all effects");
	[channel stop];
    [channel clearUnusedBuffers];
}


#pragma mark Utility

- (void) stopEverything
{
	[self stopAllEffects];
	[self stopBg];
}

- (void) resetToDefault
{
	OAL_LOG_DEBUG(@"Reset to default");
	[self stopEverything];
	[channel resetToDefault];
	self.reservedSources = kDefaultReservedSources;
	self.bgMuted = NO;
	self.bgVolume = 1.0f;
}

- (bool) manuallySuspended
{
	return [OALAudioSession sharedInstance].manuallySuspended;
}

- (void) setManuallySuspended:(bool) value
{
	[OALAudioSession sharedInstance].manuallySuspended = value;
}

- (bool) interrupted
{
	return [OALAudioSession sharedInstance].interrupted;
}

- (bool) suspended
{
	return [OALAudioSession sharedInstance].suspended;
}


@end
