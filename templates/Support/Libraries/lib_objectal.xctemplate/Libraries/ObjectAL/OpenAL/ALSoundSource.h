//
//  SoundSource.h
//  ObjectAL
//
//  Created by Karl Stenerud on 15/12/09.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//

#import <Foundation/Foundation.h>
#import "ALBuffer.h"
#import "ALTypes.h"


#pragma mark ALSoundSource

/**
 * Manages all properties relating to an OpenAL sound source.
 * There are currently two classes that adhere to this protocol: ALSource
 * and ChannelSource (which collectively manipulates a set of ALSource objects).
 * A full description of the properties themselves is available in the
 * OpenAL 1.1 Specification and Reference:
 * http://connect.creativelabs.com/openal/Documentation
 */
@protocol ALSoundSource <NSObject>


#pragma mark Properties

/** Cone inner angle (OpenAL property). */
@property(nonatomic,readwrite,assign) float coneInnerAngle;

/** Cone outer angle (OpenAL property). */
@property(nonatomic,readwrite,assign) float coneOuterAngle;

/** Cone outer gain (OpenAL property). */
@property(nonatomic,readwrite,assign) float coneOuterGain;

/** Direction (OpenAL property). */
@property(nonatomic,readwrite,assign) ALVector direction;

/** Gain (volume) (OpenAL property). */
@property(nonatomic,readwrite,assign) float gain;

/** Volume (alias to gain). */
@property(nonatomic,readwrite,assign) float volume;

/** If true, this source may be interrupted when resources are low. */
@property(nonatomic,readwrite,assign) bool interruptible;

/** Looping (OpenAL property). */
@property(nonatomic,readwrite,assign) bool looping;

/** Max distance (OpenAL property). */
@property(nonatomic,readwrite,assign) float maxDistance;

/** Max gain (OpenAL property). */
@property(nonatomic,readwrite,assign) float maxGain;

/** Min gain (OpenAL property). */
@property(nonatomic,readwrite,assign) float minGain;

/** If true, this source is muted. */
@property(nonatomic,readwrite,assign) bool muted;

/** If true, this source is currently paused. */
@property(nonatomic,readwrite,assign) bool paused;

/** Pitch (OpenAL property). */
@property(nonatomic,readwrite,assign) float pitch;

/** If true, this source is currently playing audio. */
@property(nonatomic,readonly,assign) bool playing;

/** Position (OpenAL property). */
@property(nonatomic,readwrite,assign) ALPoint position;

/** Reference distance (OpenAL property). */
@property(nonatomic,readwrite,assign) float referenceDistance;

/** Rolloff factor (OpenAL property). */
@property(nonatomic,readwrite,assign) float rolloffFactor;

/** Source relative (OpenAL property). */
@property(nonatomic,readwrite,assign) int sourceRelative;

/** Source type (OpenAL property). */
@property(nonatomic,readonly,assign) int sourceType;

/** Velocity (OpenAL property). */
@property(nonatomic,readwrite,assign) ALVector velocity;

/** Pan value (-1.0 = far left, 1.0 = far right).
 * Note: This effect is simulated by changing the source's X position.
 * Do not use this property if you are modifying the position property as well.
 */
@property(nonatomic,readwrite,assign) float pan;

/** Reverb send level (how much reverb affects this source). (iOS 5.0+)
 * 0.0 = fully dry, 1.0 = fully wet.
 * Default 0.
 */
@property(nonatomic,readwrite,assign) float reverbSendLevel;

/** Reverb occlusion (wall/door between listener and source). (iOS 5.0+)
 * -100.0db (most occlusion) to 0.0 (no occlusion).
 * Default 0.
 */
@property(nonatomic,readwrite,assign) float reverbOcclusion;

/** Reverb obstruction (object between listener and source). (iOS 5.0+)
 * -100.0db (most obstruction) to 0.0 (no obstruction).
 * Default 0.
 */
@property(nonatomic,readwrite,assign) float reverbObstruction;


#pragma mark Object Management


#pragma mark Playback

/** Play a sound.
 *
 * @param buffer the buffer to play.
 * @return the source playing the sound, or nil if the sound could not be played.
 */
- (id<ALSoundSource>) play:(ALBuffer*) buffer;

/** Play a sound, optionally looping.
 *
 * @param buffer the buffer to play.
 * @param loop If TRUE, the sound will loop until you call "stop" on the returned sound source.
 * @return the source playing the sound, or nil if the sound could not be played.
 */
- (id<ALSoundSource>) play:(ALBuffer*) buffer loop:(bool) loop;

/** Play a sound, setting gain, pitch, pan, and looping.
 *
 * @param buffer the buffer to play.
 * @param gain The gain (volume) to play at (0.0 - 1.0).
 * @param pitch The pitch to play at (1.0 = normal pitch).
 * @param pan Left-right panning (-1.0 = far left, 1.0 = far right).
 * @param loop If TRUE, the sound will loop until you call "stop" on the returned sound source.
 * @return the source playing the sound, or nil if the sound could not be played.
 */
- (id<ALSoundSource>) play:(ALBuffer*) buffer
					gain:(float) gain
				   pitch:(float) pitch
					 pan:(float) pan
					loop:(bool) loop;

/** Stop playing the current sound.
 */
- (void) stop;

/** Stop playing the current sound and set its state to AL_INITIAL.
 */
- (void) rewind;

/** Fade to the specified gain value.
 *
 * @param gain The gain to fade to.
 * @param duration The duration of the fade operation in seconds.
 * @param target The target to notify when the fade completes (can be nil).
 * @param selector The selector to call when the fade completes. The selector must accept
 * a single parameter, which will be the object that performed the fade.
 */
- (void) fadeTo:(float) gain
	   duration:(float) duration
		 target:(id) target
	   selector:(SEL) selector;

/** Stop the currently running fade operation, if any.
 */
- (void) stopFade;

/** pan to the specified value.
 *
 * @param pan The value to pan to.
 * @param duration The duration of the pan operation in seconds.
 * @param target The target to notify when the pan completes (can be nil).
 * @param selector The selector to call when the pan completes. The selector must accept
 * a single parameter, which will be the object that performed the pan.
 */
- (void) panTo:(float) pan
	   duration:(float) duration
		 target:(id) target
	   selector:(SEL) selector;

/** Stop the currently running pan operation, if any.
 */
- (void) stopPan;

/** Gradually change pitch to the specified value.
 *
 * @param pitch The value to change pitch to.
 * @param duration The duration of the pitch operation in seconds.
 * @param target The target to notify when the pitch change completes (can be nil).
 * @param selector The selector to call when the pitch change completes. The selector
 * must accept a single parameter, which will be the object that performed the pitch change.
 */
- (void) pitchTo:(float) pitch
	   duration:(float) duration
		 target:(id) target
	   selector:(SEL) selector;

/** Stop the currently running pitch operation, if any.
 */
- (void) stopPitch;

/** Stop any currently running fade, pan, or pitch operations.
 */
- (void) stopActions;


#pragma mark Utility

/** Clear any buffers this source is currently using.
 */
- (void) clear;

@end
