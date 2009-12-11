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
	kAudioManagerFxOnly,					//!Other apps will be able to play audio
	kAudioManagerFxPlusMusic,				//!Only this app will play audio
	kAudioManagerFxPlusMusicIfNoOtherAudio	//!If another app is playing audio at start up then allow it to continue and don't play music
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

/** CDAudioManager is a wrapper around AVAudioPlayer.
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
 @since v0.8
 */
@interface CDAudioManager : NSObject <AVAudioPlayerDelegate> {
	CDSoundEngine		*soundEngine;
	AVAudioPlayer		*backgroundMusic;
	NSString			*lastBackgroundMusicFilePath;
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
	BOOL _systemPausedMusic;
	tAudioManagerResignBehavior _resignBehavior;
	NSTimeInterval _bookmark;
	
	
}

@property (readonly) CDSoundEngine *soundEngine;
@property (readonly) AVAudioPlayer *backgroundMusic;
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
/** Plays music in background. The music can be looped or not
 It is recommended to use .mp3 files as background since they are decoded by the device (hardware).
 */
-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop;
/** Preloads a background music */
-(void) preloadBackgroundMusic:(NSString*) filePath;
/** Stops playing the background music */
-(void) stopBackgroundMusic;
/** Stops the background music. The music can also be released from the cache */
-(void) stopBackgroundMusic:(BOOL) release;
/** Pauses the background music */
-(void) pauseBackgroundMusic;
/** Rewinds the background music */
-(void) rewindBackgroundMusic;
/** Resumes playing the background music */
-(void) resumeBackgroundMusic;
/** Returns whether or not the background music is playing */
-(BOOL) isBackgroundMusicPlaying;

-(void) setBackgroundMusicCompletionListener:(id) listener selector:(SEL) selector;
-(void) audioSessionInterrupted;
-(void) audioSessionResumed;
-(void) setResignBehavior:(tAudioManagerResignBehavior) resignBehavior autoHandle:(BOOL) autoHandle;
/** Returns true is audio is muted at a hardware level e.g user has ringer switch set to off */
-(BOOL) isDeviceMuted;

@end
