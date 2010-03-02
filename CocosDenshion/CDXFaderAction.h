/* CDXFaderAction
 *
 * Copyright (C) 2010 Steve Oldmeadow
 *
 * For independent entities this program is free software; you can redistribute
 * it and/or modify it under the terms of the 'cocos2d for iPhone' license with
 * the additional proviso that 'cocos2D for iPhone' must be credited in a manner
 * that can be be observed by end users, for example, in the credits or during
 * start up. Failure to include such notice is deemed to be acceptance of a 
 * non independent license (see below).
 *
 * For the purpose of this software non independent entities are defined as 
 * those where the annual revenue of the entity employing, partnering, or 
 * affiliated in any way with the Licensee is greater than $250,000 USD annually.
 *
 * Non independent entities may license this software or a derivation of it
 * by a donation of $500 USD per application to the cocos2d for iPhone project. 
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 */

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

typedef enum {
	kFC_LinearFade,		//!Straigh linear interpolation fade
	kFC_SCurveFade,		//!S curved fade
	kFC_ExponentialFade	//!Exponential curve fade
} tFaderCurve;

/** Base class for actions that fade out audio
 */
@interface CDXFaderAction : CCIntervalAction {
	float startVolume;
	float finalVolume;
	tFaderCurve faderCurve;
}
/** creates the action */
+(id) actionWithDuration:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve;
/** initializes the action */
-(id) initWithDuration:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve;
/** Override in base class to work with specific audio targets */
-(float) getInitialTargetVolume;
/** Override in base class to work with specific audio targets */
-(void) setTargetVolume:(float)volume;

/** Convenience method to fade CDAudioManager's sound engine
 Works with CDAudioManager and SimpleAudioEngine*/
+(void) fadeSoundEffects:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve;
/** Convenience method to fade CDAudioManager's background music
 Works with CDAudioManager and SimpleAudioEngine*/
+(void) fadeBackgroundMusic:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve;

@end

/**
 * Class for fading out the sound effects, uses the masterGain setting of CDSoundEngine
 */
@interface CDXFadeSoundEffects : CDXFaderAction
{}
@end

/**
 * Class for fading out CDLongAudioSource objects
 */
@interface CDXFadeLongAudioSource : CDXFaderAction
{}
@end


