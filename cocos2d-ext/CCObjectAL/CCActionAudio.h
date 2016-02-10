//
//  CCActionAudio.h
//  cocos2d-tests
//
//  Created by Andrey Volodin on 10.02.16.
//  Copyright © 2016 Cocos2d. All rights reserved.
//

#import "CCActionInstant.h"

/**
 This actions plays a sound effect through OALSimpleAudio. To play back music use a CCActionCallBlock or CCActionCallFunc
 so that you can use the playBg method of OALSimpleAudio.
 
 @note The action ends immediately, it does not wait for the sound to stop playing. */
@interface CCActionSoundEffect : CCActionInstant
{
    NSString* _soundFile;
    float _pitch;
    float _pan;
    float _gain;
}

/** @name Creating a Sound Effect Action */

/**
 Creates a sound effect action.
 
 @param file The audio file to play.
 @param pitch The playback pitch. 1.0 equals *normal* pitch.
 @param pan Stereo panning, values from -1.0 (far left) to 1.0 (far right).
 @param gain Gain (loudness), default 1.0 equals *normal* volume.
 
 @see OALSimpleAudio
 @see [OALSimpleAudio playEffect:volume:pitch:pan:loop:]
 */
+(instancetype) actionWithSoundFile:(NSString*)file pitch:(float)pitch pan:(float) pan gain:(float)gain;

/**
 Creates a sound effect action.
 
 @param file The audio file to play.
 @param pitch The playback pitch. 1.0 equals *normal* pitch.
 @param pan Stereo panning, values from -1.0 (far left) to 1.0 (far right).
 @param gain Gain (loudness), default 1.0 equals *normal* volume.
 
 @see OALSimpleAudio
 @see [OALSimpleAudio playEffect:volume:pitch:pan:loop:]
 */
-(id) initWithSoundFile:(NSString*)file pitch:(float)pitch pan:(float) pan gain:(float)gain;

@end
