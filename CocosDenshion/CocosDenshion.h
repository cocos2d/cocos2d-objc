/* CocosDenshion Sound Engine
 *
 * Copyright (C) 2009 Steve Oldmeadow
 *
 * For independent entities this program is free software; you can redistribute
 * it and/or modify it under the terms of the 'cocos2d for iPhone' license with
 * the additional proviso that 'cocos2D for iPhone' must be credited in a manner
 * that can be be observed by end users, for example, in the credits or during
 * start up. Failure to include such notice is deemed to be acceptance of a 
 * non independent license (see below).
 *
 * For the purpose of this software non independent entities are defined as 
 * those where the annual revenue of the entity employing, partnering, or 
 * affiliated in any way with the Licensee is greater than $250,000 USD annually.
 *
 * Non independent entities may license this software or a derivation of it
 * by a donation of $500 USD per application to the cocos2d for iPhone project. 
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 */

/** 
@file
@b IMPORTANT
There are 3 different ways of using CocosDenshion. Depending on which you choose you 
will need to include different files and frameworks.

@par SimpleAudioEngine
This is recommended for basic audio requirements. If you just want to play some sound fx
and some background music and have no interest in learning the lower level workings then
this is the interface to use.

Requirements:
 - Firmware: OS 2.2 or greater 
 - Files: SimpleAudioEngine.*, CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox, AVFoundation
 
@par CDAudioManager
CDAudioManager is basically a thin wrapper around an AVAudioPlayer object used for playing
background music and a CDSoundEngine object used for playing sound effects. It manages the
audio session for you deals with audio session interruption. It is fairly low level and it
is expected you have some understanding of the underlying technologies. For example, for 
many use cases regarding background music it is expected you will work directly with the
backgroundMusic AVAudioPlayer which is exposed as a property.
 
Requirements:
  - Firmware: OS 2.2 or greater 
  - Files: CDAudioManager.*, CocosDenshion.*
  - Frameworks: OpenAL, AudioToolbox, AVFoundation

@par CDSoundEngine
CDSoundEngine is a sound engine built upon OpenAL and derived from Apple's oalTouch 
example. It can playback up to 32 sounds simultaneously with control over pitch, pan
and gain.  It can be set up to handle audio session interruption automatically.  You 
may decide to use CDSoundEngine directly instead of CDAudioManager or SimpleAudioEngine
because you require OS 2.0 compatibility.
 
Requirements:
  - Firmware: OS 2.0 or greater 
  - Files: CocosDenshion.*
  - Frameworks: OpenAL, AudioToolbox
 
*/ 

#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CDConfig.h"

#if CD_DEBUG
#define CDLOG(...) NSLog(__VA_ARGS__)
#else
#define CDLOG(...) do {} while (0)
#endif


#define CD_MAX_SOURCES 32 //Total number of playback channels that can be created (32 is the limit)
#define CD_NO_SOURCE 0xFEEDFAC //Return value indicating playback failed i.e. no source
#define CD_IGNORE_AUDIO_SESSION 0xBEEFBEE //Used internally to indicate audio session will not be handled
#define CD_CHANNEL_GROUP_NON_INTERRUPTIBLE 0xFEDEEFF //User internally to indicate channel group is not interruptible
#define CD_MUTE      0xFEEDBAB //Return value indicating sound engine is muted or non functioning

#define CD_SAMPLE_RATE_HIGH 44100
#define CD_SAMPLE_RATE_MID  22050
#define CD_SAMPLE_RATE_LOW  16000
#define CD_SAMPLE_RATE_BASIC 8000
#define CD_SAMPLE_RATE_DEFAULT 44100

enum bufferState {
	CD_BS_EMPTY = 0,
	CD_BS_LOADED = 1,
	CD_BS_FAILED = 2
};

typedef struct _channelGroup {
	int startIndex;
	int endIndex;
	int currentIndex;
	bool mute;
} channelGroup;

/**
 Collectin of utilities required by CocosDenshion
 */
@interface CDUtilities : NSObject
{
}	

/** Fundamentally the same as the corresponding method is CCFileUtils but added to break binding to cocos2d */
+(NSString*) fullPathFromRelativePath:(NSString*) relPath;

@end


////////////////////////////////////////////////////////////////////////////

/** CDSoundEngine is built upon OpenAL and works with SDK 2.0.
 CDSoundEngine is a sound engine built upon OpenAL and derived from Apple's oalTouch 
 example. It can playback up to 32 sounds simultaneously with control over pitch, pan
 and gain.  It can be set up to handle audio session interruption automatically.  You 
 may decide to use CDSoundEngine directly instead of CDAudioManager or SimpleAudioEngine
 because you require OS 2.0 compatibility.
 
 Requirements:
 - Firmware: OS 2.0 or greater 
 - Files: CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox
 
 @since v0.8
 */
@interface CDSoundEngine : NSObject {
	
	ALuint			*_sources;
	ALuint			*_buffers;
	int				*_bufferStates;
	ALuint			*_sourceBufferAttachments;
#ifdef CD_USE_STATIC_BUFFERS	
	ALvoid          **_bufferData;
#endif	
	channelGroup	*_channelGroups;
	ALCcontext		*context;
	int				_channelGroupTotal;
	int				_channelTotal;
	UInt32			_audioSessionCategory;
	BOOL			_handleAudioSession;
	BOOL			_mute;
	ALfloat			_preMuteGain;

	ALenum			lastErrorCode;
	BOOL			functioning;
	float			asynchLoadProgress;
		
}

@property (readwrite, nonatomic) ALfloat masterGain;
@property (readwrite, nonatomic) BOOL mute;
@property (readonly)  ALenum lastErrorCode;//Last OpenAL error code that was generated
@property (readonly)  BOOL functioning;//Is the sound engine functioning
@property (readwrite) float asynchLoadProgress;

/** Sets the sample rate for the audio mixer. For best performance this should match the sample rate of your audio content */
+ (void) setMixerSampleRate:(Float32) sampleRate;

/** Initializes the engine with a group definition and a total number of groups */
- (id)init:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;
/** Initializes the engine with a group definition, a total number of groups and an audio session category */
- (id)init:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal audioSessionCategory:(UInt32) audioSessionCategory;

/** Plays a sound in a channel group with a pitch, pan and gain. The sound could played looped or not */
- (ALuint) playSound:(int) soundId channelGroupId:(int)channelGroupId pitch:(float) pitch pan:(float) pan gain:(float) gain loop:(BOOL) loop;

/** Stops playing a sound */
- (void) stopSound:(ALuint) sourceId;
/** Stops playing a channel group */
- (void) stopChannelGroup:(int) channelGroupId;
/** Stops all playing sounds */
-(void) stopAllSounds;
- (void) setChannelGroupNonInterruptible:(int) channelGroupId isNonInterruptible:(BOOL) isNonInterruptible;
- (void) setChannelGroupMute:(int) channelGroupId mute:(BOOL) mute;
- (BOOL) channelGroupMute:(int) channelGroupId;
- (BOOL) loadBuffer:(int) soundId filePath:(NSString*) filePath;
- (void) loadBuffersAsynchronously:(NSArray *) loadRequests;
- (BOOL) unloadBuffer:(int) soundId;
- (ALCcontext *) openALContext;
- (void) audioSessionInterrupted;
- (void) audioSessionResumed;

@end

////////////////////////////////////////////////////////////////////////////
@interface CDSourceWrapper : NSObject {
	ALuint sourceId;
	float lastPitch;
	float lastPan;
	float lastGain;
	BOOL lastLooping;
}
@property (readwrite, nonatomic) ALuint sourceId;
@property (readwrite, nonatomic) float pitch;
@property (readwrite, nonatomic) float gain;
@property (readwrite, nonatomic) float pan;
@property (readwrite, nonatomic) BOOL looping;
@property (readonly)  BOOL isPlaying;

@end

////////////////////////////////////////////////////////////////////////////
@interface CDAsynchBufferLoader : NSOperation {
	NSArray *_loadRequests;
	CDSoundEngine *_soundEngine;
}	

-(id) init:(NSArray *)loadRequests soundEngine:(CDSoundEngine *) theSoundEngine;

@end

////////////////////////////////////////////////////////////////////////////

@interface CDBufferLoadRequest: NSObject
{
	NSString *filePath;
	int		 soundId;
	//id       loader;
}

@property (readonly) NSString *filePath;
@property (readonly) int soundId;

- (id)init:(int) theSoundId filePath:(NSString *) theFilePath;

@end
