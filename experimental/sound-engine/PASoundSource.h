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

#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>

#import "cocos2d.h"

@interface PASoundSource : NSObject {
    cpVect position;
    float orientation;
    NSString *file;
    BOOL looped;
    BOOL isPlaying;
    
    ALuint source;
	ALuint buffer;
    
    float gain;
}

@property (readwrite, assign) cpVect position;
@property (readwrite, assign) float orientation;
@property (readwrite, copy) NSString *file;
@property (readwrite, assign) BOOL looped;
@property (readwrite, assign) BOOL isPlaying;

- (id)initWithPosition:(cpVect)pos file:(NSString *)f looped:(BOOL)yn;
- (id)initWithPosition:(cpVect)pos file:(NSString *)f;
- (void)initSource;
- (void)initBuffer;

- (void)play;
- (void)stop;

- (void)setGain:(float)g;
- (void)setRolloff:(float)factor;
- (void)setPitch:(float)factor;

@end
