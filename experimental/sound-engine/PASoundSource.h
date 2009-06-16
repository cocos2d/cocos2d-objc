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

#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>

#import "cocos2d.h"

@interface PASoundSource : NSObject {
    CGPoint position;
    float orientation;
    NSString *file;
    NSString *extension;
    BOOL looped;
    BOOL isPlaying;
    
    ALuint source;
	ALuint buffer;
    
    float gain;
}

@property (readwrite, assign) CGPoint position;
@property (readwrite, assign) float orientation;
@property (readwrite, copy) NSString *file;
@property (readwrite, copy) NSString *extension;
@property (readwrite, assign) BOOL looped;
@property (readwrite, assign) BOOL isPlaying;

- (id)initWithPosition:(CGPoint)pos file:(NSString *)f extension:(NSString *)e looped:(BOOL)yn;
- (id)initWithPosition:(CGPoint)pos file:(NSString *)f looped:(BOOL)yn;
- (id)initWithPosition:(CGPoint)pos file:(NSString *)f;
- (id)initWithFile:(NSString *)f extension:(NSString *)e looped:(BOOL)yn;
- (id)initWithFile:(NSString *)f looped:(BOOL)yn;
- (id)initWithFile:(NSString *)f;

- (void)initSource;
- (void)initBuffer;

- (void)playAtPosition:(CGPoint)p restart:(BOOL)r;
- (void)playAtPosition:(CGPoint)p;
- (void)playWithRestart:(BOOL)r;
- (void)play;
- (void)playAtListenerPositionWithRestart:(BOOL)r;
- (void)playAtListenerPosition;

- (void)stop;

- (void)setGain:(float)g;
- (void)setRolloff:(float)factor;
- (void)setPitch:(float)factor;

@end
