/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 by Florin Dumitrescu.
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
		if (!sharedSoundManager){
			sharedSoundManager = [[PASoundMgr alloc] init];            
        }
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
    if ((self = [super init])) {
        sounds = [[NSMutableDictionary alloc] initWithCapacity:3];
        soundsMasterGain = 1.0f;
        // setup our audio session
		OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, self);
		if (result) printf("Error initializing audio session! %d\n", (int)result);
		else {
			UInt32 category = kAudioSessionCategory_AmbientSound;
			result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
			if (result) printf("Error setting audio session category! %d\n", (int)result);
			else {
				result = AudioSessionSetActive(true);
				if (result) printf("Error setting audio session active! %d\n", (int)result);
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

- (PASoundSource *)addSound:(NSString *)name withExtension:(NSString *)ext position:(CGPoint)pos looped:(BOOL)yn {
    PASoundSource *sound = [[PASoundSource alloc] initWithPosition:pos file:name extension:ext looped:yn];
    if (sound) {
        [sounds setObject:sound forKey:[NSString stringWithFormat:@"%@.%@",name,ext]];
        [sound release];
    }
    return sound;
}
- (PASoundSource *)addSound:(NSString *)name withPosition:(CGPoint)pos looped:(BOOL)yn {
    return [self addSound:name withExtension:@"wav" position:pos looped:yn];
}

- (PASoundSource *)sound:(NSString *)name withExtension:(NSString *)ext {
    NSString *key = [NSString stringWithFormat:@"%@.%@",name,ext];
    if ([[sounds allKeys] containsObject:key]) {
        return [sounds objectForKey:key];
    }
    return nil;
}
- (PASoundSource *)sound:(NSString *)name {
    return [self sound:name withExtension:@"wav"];
}

- (BOOL)play:(NSString *)name withExtension:(NSString *)ext {
    PASoundSource *sound = [self sound:name withExtension:ext];
    if (sound) {
        [sound playAtListenerPosition];
        return YES;
    }
    return NO;
}
- (BOOL)play:(NSString *)name {
    return [self play:name withExtension:@"wav"];
}

- (BOOL)stop:(NSString *)name withExtension:(NSString *)ext {
    PASoundSource *sound = [self sound:name withExtension:ext];
    if (sound) {
        [sound stop];
        return YES;
    }
    return NO;
}
- (BOOL)stop:(NSString *)name {
    return [self stop:name withExtension:@"wav"];
}

- (void)dealloc {
    [sounds release];
    [listener release];
    
	[super dealloc];
}

@end
