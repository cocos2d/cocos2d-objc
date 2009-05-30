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

/* Changelog
1.2 (2009.05.27) * Changes for integration with cocos2d svn repository.
				 * Renamed myOpenALSupport.h to CDOpenALSupport.h to distinguish it from the
				   version included with the Aeterius sound engine.
				 * Added unloadBuffer method.
				 * Updated myOpenALSupport.h to latest version with support for IMA4
1.1 (2009.05.26) * Added code for handling audio session interruption. Thanks to Andy Fitter and
                 Ben Britten for the code.
1.0 (2009.05.01) * Initial release
*/

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>


//You may want to edit these. Devices won't support any more than 32 sources though.
#define CD_MAX_BUFFERS 32 //Total number of sounds that can be loaded
#define CD_MAX_SOURCES 32 //Total number of playback channels that can be created

#define CD_NO_SOURCE 0xFEEDFACE //Return value indicating playback failed i.e. no source
#define CD_MUTE      0xFEEDBABE //Return value indicating sound engine is muted or non functioning
#define CD_IGNORE_AUDIO_SESSION 0xFEEDBABE

enum bufferState {
	CD_BS_EMPTY = 0,
	CD_BS_LOADED = 1,
	CD_BS_FAILED = 2
};

typedef struct _channelGroup {
	int startIndex;
	int endIndex;
	int currentIndex;
} channelGroup;


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
	
}

@property (readwrite) ALfloat masterGain;
@property (readwrite) BOOL mute;
@property (readonly)  ALenum lastErrorCode;//Last OpenAL error code that was generated
@property (readonly)  BOOL functioning;//Is the sound engine functioning

- (id)init:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;
- (id)init:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal audioSessionCategory:(UInt32) audioSessionCategory;

- (ALuint) playSound:(int) soundId channelGroupId:(int)channelGroupId pitch:(float) pitch pan:(float) pan gain:(float) gain loop:(BOOL) loop;

- (void) stopSound:(ALuint) sourceId;
- (void) stopChannelGroup:(int) channelGroupId;
- (BOOL) loadBuffer:(int) soundId fileName:(NSString*) fileName fileType:(NSString*) fileType;
- (BOOL) unloadBuffer:(int) soundId;
- (ALCcontext *) openALContext;
- (void) audioSessionInterrupted;
- (void) audioSessionResumed;

- (BOOL) _initOpenAL;
- (ALuint) _startSound:(int) soundId channelId:(int) channelId pitchVal:(float) pitchVal panVal:(float) panVal gainVal:(float) gainVal looping:(BOOL) looping;

@end

////////////////////////////////////////////////////////////////////////////
@interface CDSourceWrapper : NSObject {
	ALuint sourceId;
}
@property (readwrite) ALuint sourceId;
@property (readwrite) float pitch;
@property (readwrite) float gain;
@property (readwrite) float pan;

@end
