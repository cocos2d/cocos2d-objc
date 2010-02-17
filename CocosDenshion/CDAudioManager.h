/* CocosDenshion Audio Manager
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

#import "CocosDenshion.h"
#import <AVFoundation/AVFoundation.h>

/** Different modes of the engine */
typedef enum {
	kAMM_FxOnly,					//!Other apps will be able to play audio
	kAMM_FxPlusMusic,				//!Only this app will play audio
	kAMM_FxPlusMusicIfNoOtherAudio,	//!If another app is playing audio at start up then allow it to continue and don't play music
	kAMM_MediaPlayback,				//!This app takes over audio e.g music player app
	kAMM_PlayAndRecord				//!App takes over audio and has input and output
} tAudioManagerMode;

/** Possible states of the engine */
typedef enum {
	kAMStateUninitialised, //!Audio manager has not been initialised - do not use
	kAMStateInitialising,  //!Audio manager is in the process of initialising - do not use
	kAMStateInitialised	   //!Audio manager is initialised - safe to use
} tAudioManagerState;

typedef enum {
	kAMRBDoNothing,			    //Audio manager will not do anything on resign or becoming active
	kAMRBStopPlay,    			//Background music is stopped on resign and resumed on become active
	kAMRBStop					//Background music is stopped on resign but not resumed - maybe because you want to do this from within your game
} tAudioManagerResignBehavior;


@interface CDAsynchInitialiser : NSOperation {}	
@end

/** CDAudioManager supports two long audio source channels called left and right*/
typedef enum {
	kASC_Left = 0,
	kASC_Right = 1
} tAudioSourceChannel;	

typedef enum {
	kLAS_Init,
	kLAS_Loaded,
	kLAS_Playing,
	kLAS_Paused,
	kLAS_Stopped,
} tLongAudioSourceState;

@class CDLongAudioSource;
@protocol CDLongAudioSourceDelegate <NSObject>
@optional
/** The audio source completed playing */
- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource;
/** The file used to load the audio source has changed */
- (void) cdAudioSourceFileDidChange:(CDLongAudioSource *) audioSource;
@end

/**
 CDLongAudioSource represents an audio source that has a long duration which makes
 it costly to load into memory for playback as an effect using CDSoundEngine. Examples
 include background music and narration tracks. The audio file may or may not be compressed.
 Bear in mind that current iDevices can only use hardware to decode a single compressed
 audio file at a time and playing multiple compressed files will result in a performance drop
 as software decompression will take place.
 @since v0.99
 */
@interface CDLongAudioSource : NSObject <AVAudioPlayerDelegate>{
	AVAudioPlayer	*audioSourcePlayer;
	NSString		*audioSourceFilePath;
	NSInteger		numberOfLoops;
	float			volume;
	id<CDLongAudioSourceDelegate> delegate; 
	BOOL			mute;
@public	
	BOOL			systemPaused;//Used for auto resign handling
	NSTimeInterval	systemPauseLocation;//Used for auto resign handling
@protected
	tLongAudioSourceState state;
}	
@property (readonly) AVAudioPlayer *audioSourcePlayer;
@property (readonly) NSString *audioSourceFilePath;
@property (readwrite, nonatomic) NSInteger numberOfLoops;
@property (readwrite, nonatomic) float volume;
/** If mute is NO then no audio is output, however, audio will continue to advance.
 If you do not want that to happen then pause or stop the audio.
 */
@property (readwrite, nonatomic) BOOL mute;
@property(assign) id<CDLongAudioSourceDelegate> delegate; 

/** Loads the file into the audio source */
-(void) load:(NSString*) filePath;
/** Plays the audio source */
-(void) play;
/** Stops playing the audio soruce */
-(void) stop;
/** Pauses the audio source */
-(void) pause;
/** Rewinds the audio source */
-(void) rewind;
/** Resumes playing the audio source if it was paused */
-(void) resume;
/** Returns whether or not the audio source is playing */
-(BOOL) isPlaying;

@end

/** 
 CDAudioManager manages audio requirements for a game.  It provides access to a CDSoundEngine object
 for playing sound effects.  It provides access to two CDLongAudioSource object (left and right channel)
 for playing long duration audio such as background music and narration tracks.  Additionally it manages
 the audio session to take care of things like audio session interruption and interacting with the audio
 of other apps that are running on the device.
 
 Requirements:
 - Firmware: OS 2.2 or greater 
 - Files: CDAudioManager.*, CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox, AVFoundation
 @since v0.8
 */
@interface CDAudioManager : NSObject <CDLongAudioSourceDelegate> {
	CDSoundEngine		*soundEngine;
	CDLongAudioSource	*backgroundMusic;
	NSMutableArray		*audioSourceChannels;
	UInt32				_audioSessionCategory;
	BOOL				_audioWasPlayingAtStartup;
	tAudioManagerMode	_mode;
	SEL backgroundMusicCompletionSelector;
	id backgroundMusicCompletionListener;
	BOOL willPlayBackgroundMusic;
	BOOL _mute;
	BOOL _muteStoppedMusic;
	
	//For handling resign/become active
	BOOL _isObservingAppEvents;
	tAudioManagerResignBehavior _resignBehavior;
}

@property (readonly) CDSoundEngine *soundEngine;
@property (readonly) CDLongAudioSource *backgroundMusic;
@property (readonly) BOOL willPlayBackgroundMusic;
@property (readwrite) BOOL mute; 

/** Returns the shared singleton */
+ (CDAudioManager *) sharedManager;
+ (tAudioManagerState) sharedManagerState;
/** Configures the shared singleton with a mode, a channel definition and a total number of channels */
+ (void) configure: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;
/** Initializes the engine asynchronously with a mode, channel definition and a total number of channels */
+ (void) initAsynchronously: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;
/** Initializes the engine synchronously with a mode, channel definition and a total number of channels */
- (id) init: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;
-(void) audioSessionInterrupted;
-(void) audioSessionResumed;
-(void) setResignBehavior:(tAudioManagerResignBehavior) resignBehavior autoHandle:(BOOL) autoHandle;
/** Returns true is audio is muted at a hardware level e.g user has ringer switch set to off */
-(BOOL) isDeviceMuted;
/** Returns true if another app is playing audio such as the iPod music player */
-(BOOL) isOtherAudioPlaying;
/** Sets the way the audio manager interacts with the operating system such as whether it shares output with other apps or obeys the mute switch */
-(void) setMode:(tAudioManagerMode) mode;
/** Shuts down the shared audio manager instance so that it can be reinitialised */
+(void) end;

//New AVAudioPlayer API
/** Loads the data from the specified file path to the channel's audio source */
-(CDLongAudioSource*) audioSourceLoad:(NSString*) filePath channel:(tAudioSourceChannel) channel;
/** Retrieves the audio source for the specified channel */
-(CDLongAudioSource*) audioSourceForChannel:(tAudioSourceChannel) channel;

//Legacy AVAudioPlayer API
/** Plays music in background. The music can be looped or not
 It is recommended to use .mp3 files as background music since they are decoded by the device (hardware).
 */
-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop;
/** Preloads a background music */
-(void) preloadBackgroundMusic:(NSString*) filePath;
/** Stops playing the background music */
-(void) stopBackgroundMusic;
/** Pauses the background music */
-(void) pauseBackgroundMusic;
/** Rewinds the background music */
-(void) rewindBackgroundMusic;
/** Resumes playing the background music */
-(void) resumeBackgroundMusic;
/** Returns whether or not the background music is playing */
-(BOOL) isBackgroundMusicPlaying;

-(void) setBackgroundMusicCompletionListener:(id) listener selector:(SEL) selector;

@end
