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

#import "CDXFaderAction.h"

@implementation CDXFaderAction

+(id) actionWithDuration:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve
{
	return [[[self alloc] initWithDuration:t finalVolume:endVol faderCurve:curve ] autorelease];
}	

/** initializes the action */
-(id) initWithDuration:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve;
{
	if( (self=[super initWithDuration: t]) ) {	
		self->finalVolume = endVol;
		self->faderCurve = curve;
	}
	return self;
	
}	

-(float) getInitialTargetVolume
{
	//This is used for testing purposes only, this method should always be overriden
	if (finalVolume == 0.0f) {
		return 1.0f;
	} else {
		return 0.0f;
	}	
}	

-(void) setTargetVolume: (float) volume
{
	//This is used for testing purposes only, this method should always be overriden
	CDLOG(@"CDXFaderAction::setTargeVolume %0.2f", volume);
}	

-(id) copyWithZone: (NSZone*) zone
{
	CDXFaderAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] finalVolume: finalVolume faderCurve: faderCurve];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	self->startVolume = [self getInitialTargetVolume];
}

-(void) update: (ccTime) t
{
	//t is equal to fraction of time that has elapsed e.g .25 means we are quarter of the way through
	if (t < 1.0f) {
		switch (faderCurve) {
			case kFC_LinearFade:
				//Linear interpolation
				[self setTargetVolume: ((finalVolume - startVolume) * t) + startVolume];
				break;
				
			case kFC_SCurveFade:
				//Cubic s curve t^2 * (3 - 2t)
				[self setTargetVolume: ((float)(t * t * (3.0 - (2.0 * t))) * (finalVolume - startVolume)) + startVolume];
				break;
			
			case kFC_ExponentialFade:	
				//Formulas taken from EaseAction
				if (finalVolume > startVolume) {
					//Fade in
					float logDelta = (t==0) ? 0 : powf(2, 10 * (t/1 - 1)) - 1 * 0.001f;
					[self setTargetVolume: ((finalVolume - startVolume) * logDelta) + startVolume];
				} else {
					//Fade Out
					float logDelta = (-powf(2, -10 * t/1) + 1);
					[self setTargetVolume: ((finalVolume - startVolume) * logDelta) + startVolume];
				}
			
				break;
		}
	} else {	
		[self setTargetVolume: finalVolume];
	} 
}



+(void) fadeBackgroundMusic:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve
{
	CDXFadeLongAudioSource *action = [CDXFadeLongAudioSource actionWithDuration:t finalVolume:endVol faderCurve:curve];
	//Background music is mapped to the left channel long audio source
	[[CCActionManager sharedManager] addAction:action target:[[CDAudioManager sharedManager] audioSourceForChannel:kASC_Left] paused:NO];
}	

+(void) fadeSoundEffects:(ccTime)t finalVolume:(float)endVol faderCurve:(tFaderCurve) curve
{
	CDXFadeSoundEffects *action = [CDXFadeSoundEffects actionWithDuration:t finalVolume:endVol faderCurve:curve];
	//Background music is mapped to the left channel long audio source
	[[CCActionManager sharedManager] addAction:action target:[CDAudioManager sharedManager].soundEngine paused:NO];
}	

@end

@implementation CDXFadeSoundEffects
-(float) getInitialTargetVolume
{
	return ((CDSoundEngine*)target).masterGain;
}	

-(void) setTargetVolume: (float) volume
{
	((CDSoundEngine*)target).masterGain = volume;
}

-(void) startWithTarget:(id)aTarget
{
	NSObject* theTarget = (NSObject*)aTarget;
	NSAssert([theTarget isKindOfClass:[CDSoundEngine class]], @"CDXFadeSoundEffects requires CDSoundEngine as target");
	[super startWithTarget:aTarget];
}

@end

@implementation CDXFadeLongAudioSource
-(float) getInitialTargetVolume
{
	return ((CDLongAudioSource*)target).volume;
}	

-(void) setTargetVolume: (float) volume
{
	((CDLongAudioSource*)target).volume = volume;
}

-(void) startWithTarget:(id)aTarget
{
	NSObject* theTarget = (NSObject*)aTarget;
	NSAssert([theTarget isKindOfClass:[CDLongAudioSource class]], @"CDXFadeLongAudioSource requires CDLongAudioSource as target");
	[super startWithTarget:aTarget];
}

@end

