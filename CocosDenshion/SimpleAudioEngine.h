/*
 *  SimpleAudioEngine.h
 *  SweetDreams
 *
 *  Created by João Caxaria on 5/24/09.
 *  Copyright 2009 Cocos2d-iPhone - If you find this useful, please give something back.
 *  Original by skeeet.
 *  http://groups.google.com/group/cocos2d-iphone-discuss/browse_thread/thread/166c5c488b55a858/98c606d518033637?lnk=gst&q=AVAudioPlayer&pli=1
 */
#import "CocosDenshion.h"
#import "CDAudioManager.h"

/**
 * A wrapper to the CDAudioManager object.
 * This class, as it's name suggests it, simplifies the interface to CDAudioManager
 * @since v0.8
 */
@interface SimpleAudioEngine : NSObject {
	
	BOOL	muted_;
	
}

/** whether or not the engine is muted */
@property (readwrite) BOOL muted;

/** returns the shared instance of the SimpleAudioEngine object */
+ (SimpleAudioEngine*) sharedEngine;

/** plays background music */
-(void) playBackgroundMusic:(NSString*) filePath;
/** stops playing background music */
-(void) stopBackgroundMusic;
/** pauses the background music */
-(void) pauseBackgroundMusic;
/** rewind the background music */
-(void) rewindBackgroundMusic;
/** returns whether or not the background music is playing */
-(BOOL) isBackgroundMusicPlaying;

/** plays an audio effect */
-(ALuint) playEffect:(NSString*) filePath;
/** preloads an audio effect */
-(void) preloadEffect:(NSString*) filePath;
/** unloads an audio effect from memory */
-(void) unloadEffect:(NSString*) filePath;

@end
