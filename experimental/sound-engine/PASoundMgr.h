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
#import "cocos2d.h"

@class PASoundListener, PASoundSource;

@interface PASoundMgr : NSObject {
    NSMutableDictionary *sounds;
    PASoundListener *listener;
    float soundsMasterGain;
}

@property (readwrite, retain) PASoundListener *listener;
@property (readwrite, assign) float soundsMasterGain;

+ (PASoundMgr *)sharedSoundManager;

- (PASoundSource *)addSound:(NSString *)name withExtension:(NSString *)ext position:(CGPoint)pos looped:(BOOL)yn;
- (PASoundSource *)addSound:(NSString *)name withPosition:(CGPoint)pos looped:(BOOL)yn;

- (PASoundSource *)sound:(NSString *)name withExtension:(NSString *)ext;
- (PASoundSource *)sound:(NSString *)name;

- (BOOL)play:(NSString *)name withExtension:(NSString *)ext;
- (BOOL)play:(NSString *)name;
- (BOOL)stop:(NSString *)name withExtension:(NSString *)ext;
- (BOOL)stop:(NSString *)name;

- (void)initOpenAL;
- (void)initListener;

@end
