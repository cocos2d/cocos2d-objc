/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * Created by Florin Dumitrescu.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "PASoundMgr.h"
#import "MyOpenALSupport.h"
#import "PASoundListener.h"
#import "PASoundSource.h"

@implementation PASoundMgr

@synthesize listener, soundsMasterGain;

static PASoundMgr *sharedSoundManager = nil;

+ (PASoundMgr *)sharedSoundManager {
	@synchronized(self)	{
		if (!sharedSoundManager)
			[[PASoundMgr alloc] init];
		
		return sharedSoundManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc {
	@synchronized(self)
	{
		NSAssert(sharedSoundManager == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedSoundManager = [super alloc];
		return sharedSoundManager;
	}
	// to avoid compiler warning
	return nil;
}

- (id)init {
    if (self = [super init]) {
        sounds = [[NSMutableDictionary alloc] initWithCapacity:3];
        soundsMasterGain = 1.0f;
        // setup our audio session
		OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, self);
		if (result) printf("Error initializing audio session! %d\n", result);
		else {
			UInt32 category = kAudioSessionCategory_AmbientSound;
			result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
			if (result) printf("Error setting audio session category! %d\n", result);
			else {
				result = AudioSessionSetActive(true);
				if (result) printf("Error setting audio session active! %d\n", result);
			}
		}
		
		// Initialize our OpenAL environment
		[self initOpenAL];
    }
	return self;
}

- (void)initOpenAL {
	ALCcontext		*newContext = NULL;
	ALCdevice		*newDevice = NULL;
	
	// Create a new OpenAL Device
	// Pass NULL to specify the system’s default output device
	newDevice = alcOpenDevice(NULL);
	if (newDevice != NULL) {
		// Create a new OpenAL Context
		// The new context will render to the OpenAL Device just created 
		newContext = alcCreateContext(newDevice, 0);
		if (newContext != NULL) {
			// Make the new context the Current OpenAL Context
			alcMakeContextCurrent(newContext);
        }
	}
	
	atexit(TeardownOpenAL);
	alGetError();
    [self initListener];
}

- (void)initListener {
    listener = [[PASoundListener alloc] init];
}

- (void)addSound:(NSString *)name withPosition:(cpVect)pos looped:(BOOL)yn {
    PASoundSource *sound = [[PASoundSource alloc] initWithPosition:pos file:name looped:yn];
    if (sound) {
        [sounds setObject:sound forKey:name];
        [sound release];
    }
}
- (PASoundSource *)sound:(NSString *)name {
    if ([[sounds allKeys] containsObject:name]) {
        return [sounds objectForKey:name];
    }
    return nil;    
}

- (BOOL)play:(NSString *)name {
    if ([[sounds allKeys] containsObject:name]) {
        [[sounds objectForKey:name] play];
        return YES;
    }
    return NO;
}
- (BOOL)stop:(NSString *)name {
    if ([[sounds allKeys] containsObject:name]) {
        [[sounds objectForKey:name] stop];
        return YES;
    }
    return NO;
}

- (void)dealloc {
    [sounds release];
    [listener release];
    
	[super dealloc];
}

@end