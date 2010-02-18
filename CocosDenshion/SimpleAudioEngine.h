/*
 *  SimpleAudioEngine.h
 *  SweetDreams
 *
 *  Created by João Caxaria on 5/24/09.
 *  Copyright 2009 Cocos2d-iPhone - If you find this useful, please give something back.
 *  Original by skeeet.
 *  http://groups.google.com/group/cocos2d-iphone-discuss/browse_thread/thread/166c5c488b55a858/98c606d518033637?lnk=gst&q=AVAudioPlayer&pli=1
 */
#import "CDAudioManager.h"

/**
 A wrapper to the CDAudioManager object.
 This is recommended for basic audio requirements. If you just want to play some sound fx
 and some background music and have no interest in learning the lower level workings then
 this is the interface to use.
 
 Requirements:
 - Firmware: OS 2.2 or greater 
 - Files: SimpleAudioEngine.*, CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox, AVFoundation
 @since v0.8
 */
@interface SimpleAudioEngine : NSObject {
	
	BOOL	muted_;
	
}

/** whether or not the engine is muted */
@property (readwrite) BOOL muted;
/** Background music volume. Range is 0.0f to 1.0f. This will only have an effect if willPlayBackgroundMusic returns YES */
@property (readwrite) float backgroundMusicVolume;
/** Effects volume. Range is 0.0f to 1.0f */
@property (readwrite) float effectsVolume;
/** If NO it indicates background music will not be played either because no background music is loaded or the audio session does not permit it.*/
@property (readonly) BOOL willPlayBackgroundMusic;

/** returns the shared instance of the SimpleAudioEngine object */
+ (SimpleAudioEngine*) sharedEngine;

/** Preloads a music file so it will be ready to play as background music */
-(void) preloadBackgroundMusic:(NSString*) filePath;

/** plays background music in a loop*/
-(void) playBackgroundMusic:(NSString*) filePath;
/** plays background music, if loop is true the music will repeat otherwise it will be played once */
-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop;
/** stops playing background music */
-(void) stopBackgroundMusic;
/** pauses the background music */
-(void) pauseBackgroundMusic;
/** resume background music that has been paused */
-(void) resumeBackgroundMusic;
/** rewind the background music */
-(void) rewindBackgroundMusic;
/** returns whether or not the background music is playing */
-(BOOL) isBackgroundMusicPlaying;

/** plays an audio effect with a file path*/
-(ALuint) playEffect:(NSString*) filePath;
/** stop a sound that is playing, note you must pass in the soundId that is returned when you started playing the sound with playEffect */
-(void) stopEffect:(ALuint) soundId;
/** plays an audio effect with a file path, pitch, pan and gain */
-(ALuint) playEffect:(NSString*) filePath pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain;
/** preloads an audio effect */
-(void) preloadEffect:(NSString*) filePath;
/** unloads an audio effect from memory */
-(void) unloadEffect:(NSString*) filePath;

/** Shuts down the shared audio engine instance so that it can be reinitialised */
+(void) end;

@end
