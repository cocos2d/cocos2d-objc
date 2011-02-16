/*
 Copyright (c) 2011 Steve Oldmeadow
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 $Id$
 */
#import "CDAudioManager.h"
#import "SoundConfig.h"

/** Possible states of the engine */
typedef enum {
	kCDCAStateUninitialised, //!Audio manager has not been initialised - do not use
	kCDCAStateInitialising,  //!Audio manager is in the process of initialising - do not use
	kCDCAStateInitialised,	 //!Audio manager is initialised - safe to use
	kCDCAStateFailed         //!Audio manager has failed
} tCDCAState;

/**
 * A Facade for CocosDenshion. This is the recommended entry point for developing with CocosDenshion.
 *
 * For those about rock (and code audio), we salute you!
 *
 * @since v99.6
 */
@interface CDCA : NSObject <CDAudioInterruptProtocol> {
	
	BOOL	mute_;
	BOOL	enabled_;
	tCDCAState state_;
	CDSoundEngine* _soundEngine;
	CDAudioManager* _am;
	
}

-(CDSoundEngine*) soundEngine;
-(CDAudioManager*) audioManager;
/** Convenience property, while this returns NO either the audio manager is initialising or the preload sounds are loading asynchronously.*/
@property (readonly) BOOL ready;
@property (readonly) tCDCAState state;
/** This is the id of the first buffer that is available for use with sounds not defined in the SoundConfig.h file. For example,
 * you may generate a sound at runtime (such as a recording via the microphone) that you want to load into a buffer. Such as sound 
 * should be loaded using this value or greater */
@property (readonly) int firstFreeBufferId;

#pragma mark CDCA - Buffers
-(BOOL) bufferLoad:(int) soundId filePath:(NSString*) filePath;
-(BOOL) bufferUnload:(int) soundId;
-(void) buffersLoadAsynchronously:(NSArray *) loadRequests;
/** Returns the duration of the buffer in seconds or a negative value if the buffer id is invalid */
-(float) bufferDurationInSeconds:(int) soundId;
/** Returns the size of the buffer in bytes or a negative value if the buffer id is invalid */
-(ALsizei) bufferSizeInBytes:(int) soundId;
/** Returns the sampling frequency of the buffer in hertz or a negative value if the buffer id is invalid */
-(ALsizei) bufferFrequencyInHertz:(int) soundId;

#pragma mark CDCA - Background Music
/** Background music volume. Range is 0.0f to 1.0f. This will only have an effect if willPlayBackgroundMusic returns YES */
@property (readwrite) float backgroundMusicVolume;
/** If NO it indicates background music will not be played either because no background music is loaded or the audio session does not permit it.*/
@property (readonly) BOOL backgroundMusicWillPlay;
/** Preloads a music file so it will be ready to play as background music */
-(void) backgroundMusicPreload:(NSString*) filePath;
/** plays background music in a loop*/
-(void) backgroundMusicPlay:(NSString*) filePath;
/** plays background music, if loop is true the music will repeat otherwise it will be played once */
-(void) backgroundMusicPlay:(NSString*) filePath loop:(BOOL) loop;
/** stops playing background music */
-(void) backgroundMusicStop;
/** pauses the background music */
-(void) backgroundMusicPause;
/** resume background music that has been paused */
-(void) backgroundMusicResume;
/** rewind the background music */
-(void) backgroundMusicRewind;
/** returns whether or not the background music is playing */
-(BOOL) backgroundMusicIsPlaying;
-(void) backgroundMusicSetMute:(BOOL) mute;
-(void) backgroundMusicSetEnabled:(BOOL) enabled;
-(BOOL) backgroundMusicIsMute;
-(BOOL) backgroundMusicIsEnabled;

#pragma mark CDCA - Effects
/** plays an audio effect, effect may be truncated by another play reques */
-(void) effectPlay:(NSUInteger) soundId;
/** plays an audio effect, effect will play to completion but may not play if other effects are playing  */
-(void) effectPlayCompletely:(NSUInteger) soundId;
/** plays an audio effect with pitch, pan and gain */
-(void) effectPlay:(NSUInteger) soundId pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain;
/** plays an audio effect with pitch, pan and gain */
-(void) effectPlayCompletely:(NSUInteger) soundId pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain;
-(BOOL) effectsAreMute;
-(void) effectsSetMute:(BOOL) mute;
-(BOOL) effectsAreEnabled;
-(void) effectsSetEnabled:(BOOL) enabled;
/** Effects volume. Range is 0.0f to 1.0f */
@property (readwrite) float effectsVolume;

#pragma mark CDCA - Sound Sources
/** Gets a CDSoundSource object set up to play the specified file. */
-(CDSoundSource *) soundSourceForSound:(NSUInteger) soundId;

#pragma mark CDCA - Overrides for subclasses
/** Override this method to provide a different initial mode. Default initial mode is kAMM_FxPlusMusicIfNoOtherAudio*/
-(tAudioManagerMode) initialAudioManagerMode;
/** Override this method to provide a different total for the sound source pool. Default is 16. */
-(int) totalSoundSources;
/** Overrid this method to provide a different total for the uninterruptible effects pool. Default is 4 */
-(int) totalUninterruptibleEffects;
/** Override this method to set a different resign handler. Default is StopPlay with auto handling. */
-(void)	setResignBehavior;
/** Method will be called when initialisation is complete */
-(void) cdcaDidFinishInitialising;

@end

/**
 * We don't like Singletons, oh no, we love them.
 * Seriously, you do not need to use a Singleton to work with CDCA but for those that want one here it is.
 */
@interface CDCAManager : NSObject {
	
}	
+(CDCA*) sharedInstance;	
@end