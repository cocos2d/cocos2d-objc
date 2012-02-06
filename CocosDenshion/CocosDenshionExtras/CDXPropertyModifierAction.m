/*
 Copyright (c) 2010 Steve Oldmeadow

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 $Id$
 */

#import "CDXPropertyModifierAction.h"

@implementation CDXPropertyModifierAction

+(id) actionWithDuration:(ccTime)t modifier:(CDPropertyModifier*) aModifier;
{
	return [[[self alloc] initWithDuration:t modifier:aModifier] autorelease];
}

-(id) initWithDuration:(ccTime)t modifier:(CDPropertyModifier*) aModifier;
{
	if( (self=[super initWithDuration: t]) ) {
		//Release the previous modifier
		if (modifier) {
			[modifier release];
		}
		modifier = aModifier;
		[modifier retain];
		//lastSetValue = [modifier _getTargetProperty];//Issue 1304
	}
	return self;
}



-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	lastSetValue = [modifier _getTargetProperty];
}

-(void) dealloc {
	CDLOG(@"Denshon::CDXPropertyModifierAction deallocated %@",self);
	[modifier release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CDXPropertyModifierAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] modifier: modifier];
	return copy;
}

-(void) update: (ccTime) t
{
	//Check if modified property has been externally modified and if so bail out
	if ([modifier _getTargetProperty] != lastSetValue) {
		CCDirector *director = [CCDirector sharedDirector];
		[[director actionManager] removeAction:self];
		return;
	}
	[modifier modify:t];
	lastSetValue = [modifier _getTargetProperty];
}

+(void) fadeSoundEffects:(ccTime)t finalVolume:(float)endVol curveType:(tCDInterpolationType)curve shouldStop:(BOOL) stop {
	CDSoundEngine* se = [CDAudioManager sharedManager].soundEngine;
	//Create a fader object
	CDSoundEngineFader* fader = [[CDSoundEngineFader alloc] init:se interpolationType:curve startVal:se.masterGain endVal:endVol];
	[fader setStopTargetWhenComplete:stop];
	//Create a property modifier action to wrap the fader
	CDXPropertyModifierAction* action = [CDXPropertyModifierAction actionWithDuration:t modifier:fader];
	[fader release];//Action will retain

	CCDirector *director = [CCDirector sharedDirector];
	[[director actionManager] addAction:action target:se paused:NO];
}

+(void) fadeSoundEffect:(ccTime)t finalVolume:(float)endVol curveType:(tCDInterpolationType)curve shouldStop:(BOOL) stop effect:(CDSoundSource*) effect{
	//Create a fader object
	CDSoundSourceFader* fader = [[CDSoundSourceFader alloc] init:effect interpolationType:curve startVal:effect.gain endVal:endVol];
	[fader setStopTargetWhenComplete:stop];
	//Create a property modifier action to wrap the fader
	CDXPropertyModifierAction* action = [CDXPropertyModifierAction actionWithDuration:t modifier:fader];
	[fader release];//Action will retain

	CCDirector *director = [CCDirector sharedDirector];
	[[director actionManager] addAction:action target:effect paused:NO];
}


+(void) fadeBackgroundMusic:(ccTime)t finalVolume:(float)endVol curveType:(tCDInterpolationType) curve shouldStop:(BOOL) stop
{
	//Background music is mapped to the left "channel"
	CDLongAudioSource *player = [[CDAudioManager sharedManager] audioSourceForChannel:kASC_Left];
	CDLongAudioSourceFader* fader = [[CDLongAudioSourceFader alloc] init:player interpolationType:curve startVal:player.volume endVal:endVol];
	[fader setStopTargetWhenComplete:stop];
	//Create a property modifier action to wrap the fader
	CDXPropertyModifierAction* action = [CDXPropertyModifierAction actionWithDuration:t modifier:fader];
	[fader release];//Action will retain

	CCDirector *director = [CCDirector sharedDirector];
	[[director actionManager] addAction:action target:player paused:NO];
}

@end



