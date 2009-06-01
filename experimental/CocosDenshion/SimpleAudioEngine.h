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

@interface SimpleAudioEngine : NSObject {	
	
}

+ (SimpleAudioEngine*) sharedEngine;

-(void) playBackgroundMusic:(NSString*) filename;
-(void) stopBackgroundMusic;
-(void) pauseBackgroundMusic;
-(void) rewindBackgroundMusic;
-(BOOL) isBackgroundMusicPlaying;

-(ALuint) playEffect:(NSString*) filename;
-(void) preloadEffect:(NSString*) filename;
-(void) unloadEffect:(NSString*) filename;

@end
