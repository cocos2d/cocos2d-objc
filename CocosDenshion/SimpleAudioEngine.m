/*
 *  SimpleAudioEngine.mm
 *  SweetDreams
 *
 *  Created by João Caxaria on 5/24/09.
 *  Copyright 2009 Cocos2d-iPhone - If you find this useful, please give something back.
 *
 */

#import "SimpleAudioEngine.h"
#import <AVFoundation/AVFoundation.h>


@interface SimpleAudioEngine (Buffers)

-(NSNumber*) getNextAvailableBuffer;
-(void) freeBuffer:(NSNumber*) buffer;

@end


@implementation SimpleAudioEngine

static SimpleAudioEngine *sharedEngine = nil;
static CDSoundEngine* soundEngine = nil;
static NSMutableDictionary* loadedEffects = nil;
static bool usedBuffers[CD_MAX_BUFFERS];
static CDAudioManager *am = nil;

// Init
+ (SimpleAudioEngine *) sharedEngine
{
	@synchronized(self)     {
		if (!sharedEngine)
			sharedEngine = [[SimpleAudioEngine alloc] init];
	}
	return sharedEngine;
}

+ (id) alloc
{
	@synchronized(self)     {
		NSAssert(sharedEngine == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

-(id) init
{
	if((self=[super init])) {
	
		int channelGroups[1];
		channelGroups[0] = CD_MAX_SOURCES - 1;
		//Setting up the audio manager with this mode means that if the user is playing music when the app starts then 
		//background music will not be played.
		[CDAudioManager configure:kAMM_FxPlusMusicIfNoOtherAudio channelGroupDefinitions:channelGroups channelGroupTotal:1];
		am = [CDAudioManager sharedManager];//Issue #748
		soundEngine = am.soundEngine;
		loadedEffects = [[NSMutableDictionary alloc] initWithCapacity:CD_MAX_BUFFERS];
		
		muted_ = NO;
	}
	return self;
}

// Memory
- (void) dealloc
{
	am = nil;
	soundEngine = nil;
	[loadedEffects autorelease];
	loadedEffects = nil;
	[super dealloc];
}

+(void) end 
{
	am = nil;
	[CDAudioManager end];
	[sharedEngine release];
}	

#pragma mark SimpleAudioEngine - background music

-(void) preloadBackgroundMusic:(NSString*) filePath {
	[am preloadBackgroundMusic:filePath];
}

-(void) playBackgroundMusic:(NSString*) filePath
{
	[am playBackgroundMusic:filePath loop:TRUE];
}

-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop
{
	[am playBackgroundMusic:filePath loop:loop];
}

-(void) stopBackgroundMusic
{
	[am stopBackgroundMusic];
}

-(void) pauseBackgroundMusic {
	[am pauseBackgroundMusic];
}	

-(void) resumeBackgroundMusic {
	[am resumeBackgroundMusic];
}	

-(void) rewindBackgroundMusic {
	[am rewindBackgroundMusic];
}

-(BOOL) isBackgroundMusicPlaying {
	return [am isBackgroundMusicPlaying];
}	

-(BOOL) willPlayBackgroundMusic {
	return [am willPlayBackgroundMusic];
}

#pragma mark SimpleAudioEngine - sound effects

-(ALuint) playEffect:(NSString*) filePath
{
	return [self playEffect:filePath pitch:1.0f pan:0.0f gain:1.0f];
}

-(ALuint) playEffect:(NSString*) filePath pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain
{
	NSNumber* soundId = (NSNumber*)[loadedEffects objectForKey:filePath];
	
	if(soundId == nil)
	{
#ifdef ASSERT_DEBUG
		@throw [[[NSException alloc] initWithName:@"SimpleAudioEngine::playEffect" 
										   reason:filePath userInfo:nil] autorelease];
#else
		[self preloadEffect:filePath];
		soundId = (NSNumber*)[loadedEffects objectForKey:filePath];//Issue 465 - thanks myBuddyCJ
#endif
	}
	
	return [soundEngine playSound:[soundId intValue] channelGroupId:0 pitch:pitch pan:pan gain:gain loop:false];
}

-(void) stopEffect:(ALuint) soundId {
	[soundEngine stopSound:soundId];
}	

-(void) preloadEffect:(NSString*) filePath
{
	NSNumber* soundId = (NSNumber*)[loadedEffects objectForKey:filePath];

	if(soundId != nil)
	{
		#ifdef ASSERT_DEBUG
		@throw [[[NSException alloc] initWithName:@"SimpleAudioEngine::preloadEffect" reason:filePath userInfo:nil] autorelease];
		#else
		return;
		#endif
	}

	NSNumber* position = [self getNextAvailableBuffer];
	[loadedEffects setObject:position forKey:filePath];
	[soundEngine loadBuffer:[position intValue] filePath:filePath];
}

-(void) unloadEffect:(NSString*) filePath
{
	NSNumber* soundId = [loadedEffects objectForKey:filePath];
	if(soundId == nil)
	{
		#ifdef ASSERT_DEBUG
		@throw [[[NSException alloc] initWithName:@"SimpleAudioEngine::unloadEffect" reason:filePath userInfo:nil] autorelease];
		#else
		return;
		#endif
	}
	[self freeBuffer:soundId];
	[loadedEffects removeObjectForKey:filePath];
	[soundEngine unloadBuffer:[soundId intValue]];
}

#pragma mark SimpleAudioEngine - Muted
-(BOOL) muted
{
	return muted_;
}

-(void) setMuted:(BOOL)muted
{
	muted_ = muted;
	am.mute = muted;
}

#pragma mark SimpleAudioEngine - BackgroundMusicVolume
-(float) backgroundMusicVolume
{
	return am.backgroundMusic.volume;
}	

-(void) setBackgroundMusicVolume:(float) volume
{
	am.backgroundMusic.volume = volume;
}	

#pragma mark SimpleAudioEngine - EffectsVolume
-(float) effectsVolume
{
	return am.soundEngine.masterGain;
}	

-(void) setEffectsVolume:(float) volume
{
	am.soundEngine.masterGain = volume;
}	


@end 

#pragma mark SimpleAudioEngine - Buffers

@implementation SimpleAudioEngine (Buffers)

-(NSNumber*) getNextAvailableBuffer
{
	for(int i = 0; i < CD_MAX_BUFFERS ; i++)
	{
		if(!usedBuffers[i])
		{
			usedBuffers[i] = true;
			return [[[NSNumber alloc] initWithInt:i] autorelease];
		}
	}
#ifdef ASSERT_DEBUG
	@throw [[[NSException alloc] initWithName:@"AudioEngine::getNextAvailableBuffer" reason:@"Full buffers" userInfo:nil] autorelease];
#endif
	return nil;//Added to get rid of compiler warning
}

-(void) freeBuffer:(NSNumber*) buffer
{
	usedBuffers[[buffer intValue]] = false;
}

@end
