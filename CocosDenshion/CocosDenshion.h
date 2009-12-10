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

/* Changelog
2.0 (2009.07.09) * Change all file names to file paths to support loading sounds from locations other than root.
                   (Thanks to Jason Cecil)
                 * Take out C++ dependencies to make it easy to include CocosDenshion in static libraries. 
1.6 (2009.07.02) * Added looping property to CDSourceWrapper so that looping flag can be toggled during playback
                   (Thanks to Pablo Ruiz)
                 * Added fix to ensure mp3 files are not decoded in software on 3.0 (Thanks to Bryan Accleroto) 
                 * Added mute to CDAudioManager
                 * Added handlers for resign active and become active to CDAudioManager (Thanks to Dominique Bongard)
			     * Added stopBackgroundMusic method with flag to indicate whether resources should be released
				   (Thanks to Dominique Bongard) 
				 * Added functionality to mute channel groups
1.5 (2009.06.13) * Added preLoadBackgroundMusic method to CDAudioManager to allow background music to be preloaded
                 * Fixed bug with sound engine locking up when trying to load non existent file asynchronously 
                   (Thanks to Edison's Labs for reporting)
1.4 (2009.06.10) * Implemented asynchronous initialisation of audio manager
                 * Implemented asynchronous loading of sound buffers
                 * Fixed problem with mute button being ignored if game played background music (Thanks to Sebastien Flory for reporting)
1.3 (2009.06.02) * Added non interruptible option for channel group
                 * Added loop parameter for playing background music
                 * Added isPlaying property to CDSourceWrapper
                 * Modified CDSourceWrapper to return last set values of pitch, pan and gain
                 * Added option of specifying callback selector for background music completion to CDAudioManager
                 * Workaround for issue in 2.2 & 2.2.1 simulator whereby OpenAL playback would be killed after 
                   an AVAudioPlayer (backgroundMusic) stops.
1.2 (2009.05.27) * Changes for integration with cocos2d svn repository.
				 * Renamed myOpenALSupport.h to CDOpenALSupport.h to distinguish it from the
				   version included with the Aeterius sound engine.
				 * Added unloadBuffer method.
				 * Updated myOpenALSupport.h to latest version with support for IMA4 compressed files
1.1 (2009.05.26) * Added code for handling audio session interruption. Thanks to Andy Fitter and
                   Ben Britten for the code.
1.0 (2009.05.01) * Initial release
*/

#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CCFileUtils.h"

//You may want to edit these. Devices won't support any more than 32 sources though.
#define CD_MAX_BUFFERS 32 //Total number of sounds that can be loaded
#define CD_MAX_SOURCES 32 //Total number of playback channels that can be created (32 is the limit)

#define CD_NO_SOURCE 0xFEEDFAC //Return value indicating playback failed i.e. no source
#define CD_IGNORE_AUDIO_SESSION 0xBEEFBEE //Used internally to indicate audio session will not be handled
#define CD_CHANNEL_GROUP_NON_INTERRUPTIBLE 0xFEDEEFF //User internally to indicate channel group is not interruptible
#define CD_MUTE      0xFEEDBAB //Return value indicating sound engine is muted or non functioning

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
	channelGroup	*_channelGroups;
	ALCcontext		*context;
	int				_channelGroupTotal;
	int				_channelTotal;
	UInt32			_audioSessionCategory;
	BOOL			_handleAudioSession;
	BOOL			_mute;
	
	ALenum			lastErrorCode;
	BOOL			functioning;
	float			asynchLoadProgress;
	
}

@property (readwrite, nonatomic) ALfloat masterGain;
@property (readwrite, nonatomic) BOOL mute;
@property (readonly)  ALenum lastErrorCode;//Last OpenAL error code that was generated
@property (readonly)  BOOL functioning;//Is the sound engine functioning
@property (readwrite) float asynchLoadProgress;

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
- (void) setChannelGroupNonInterruptible:(int) channelGroupId isNonInterruptible:(BOOL) isNonInterruptible;
- (void) setChannelGroupMute:(int) channelGroupId mute:(BOOL) mute;
- (BOOL) channelGroupMute:(int) channelGroupId;
- (BOOL) loadBuffer:(int) soundId filePath:(NSString*) filePath;
- (void) loadBuffersAsynchronously:(NSArray *) loadRequests;
- (BOOL) unloadBuffer:(int) soundId;
- (ALCcontext *) openALContext;
- (void) audioSessionInterrupted;
- (void) audioSessionResumed;

- (BOOL) _initOpenAL;
- (ALuint) _startSound:(int) soundId channelId:(int) channelId pitchVal:(float) pitchVal panVal:(float) panVal gainVal:(float) gainVal looping:(BOOL) looping checkState:(BOOL) checkState
;

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
