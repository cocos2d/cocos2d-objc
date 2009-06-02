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

static SimpleAudioEngine *sharedEngine;
static CDSoundEngine* soundEngine;
static NSMutableDictionary* loadedEffects;
static bool usedBuffers[CD_MAX_BUFFERS];
static CDAudioManager *am;

// Init
+ (SimpleAudioEngine *) sharedEngine
{
	@synchronized(self)     {
		if (!sharedEngine)
			[[SimpleAudioEngine alloc] init];
		return sharedEngine;
	}
	return nil;
}

+ (id) alloc
{
	@synchronized(self)     {
		NSAssert(sharedEngine == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedEngine = [super alloc];
		return sharedEngine;
	}
	return nil;
}

-(id) init
{
	if(![super init]) return nil;
	
	int channelGroups[1];
	channelGroups[0] = CD_MAX_SOURCES - 1;
	//Setting up the audio manager with this mode means that if the user is playing music when the app starts then 
	//background music will not be played.
	am = [[CDAudioManager alloc] init:kAudioManagerFxPlusMusicIfNoOtherAudio channelGroupDefinitions:channelGroups channelGroupTotal:1];
	soundEngine = am.soundEngine;
	loadedEffects = [[NSMutableDictionary alloc] initWithCapacity:CD_MAX_BUFFERS];
	return self;
}

// Memory
- (void) dealloc
{
	[loadedEffects autorelease];
	sharedEngine = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark AudioEngine

-(void) playBackgroundMusic:(NSString*) filename
{
	[am playBackgroundMusic:filename loop:TRUE];
}

-(void) stopBackgroundMusic
{
	[am stopBackgroundMusic];
}

-(void) pauseBackgroundMusic {
	[am pauseBackgroundMusic];
}	

-(void) rewindBackgroundMusic {
	[am rewindBackgroundMusic];
}

-(BOOL) isBackgroundMusicPlaying {
	return [am isBackgroundMusicPlaying];
}	

-(ALuint) playEffect:(NSString*) filename
{
	NSNumber* soundId = (NSNumber*)[loadedEffects objectForKey:filename];

	if(soundId == nil)
	{
		#ifdef ASSERT_DEBUG
		@throw [[[NSException alloc] initWithName:@"SimpleAudioEngine::playEffect" reason:filename userInfo:nil] autorelease];
		#else
		[self preloadEffect:filename];
		#endif
	}

	return [soundEngine playSound:[soundId intValue] channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:false];
}

-(void) preloadEffect:(NSString*) filename
{
	NSNumber* soundId = (NSNumber*)[loadedEffects objectForKey:filename];

	if(soundId != nil)
	{
		#ifdef ASSERT_DEBUG
		@throw [[[NSException alloc] initWithName:@"SimpleAudioEngine::preloadEffect" reason:filename userInfo:nil] autorelease];
		#else
		return;
		#endif
	}

	NSNumber* position = [self getNextAvailableBuffer];
	[loadedEffects setObject:position forKey:filename];
	[soundEngine loadBuffer:[position intValue] fileName:filename fileType:nil];
}

-(void) unloadEffect:(NSString*) filename
{
	NSNumber* soundId = [loadedEffects objectForKey:filename];
	if(soundId == nil)
	{
		#ifdef ASSERT_DEBUG
		@throw [[[NSException alloc] initWithName:@"SimpleAudioEngine::unloadEffect" reason:filename userInfo:nil] autorelease];
		#else
		return;
		#endif
	}
	[self freeBuffer:soundId];
	[loadedEffects removeObjectForKey:filename];
	[soundEngine unloadBuffer:[soundId intValue]];
}


@end 

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
