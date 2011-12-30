//
//  DebugAudioVis.m
//  DenshionAudioVisualDemo
//
//  Created by Lam Pham on 2/5/10.
//  Copyright 2010 FancyRatStudios Inc.. All rights reserved.
//

#import "DebugAudioVis.h"

@implementation DebugAudioVis
-(id)init{
	if((self = [super init])){
		//	Now let's setup audio visualization of the debug layer
		//	We add a delegate callback for each audio channel, there's 2 generally
		[[AudioVisualization sharedAV] addDelegate:self forChannel:0];
		//	Setting the smoothing filter pertty much smooths out drastic changes in
		//	the audio.
		[[AudioVisualization sharedAV] setFilterSmooth:0.2f];
		avgPower_ = peakPower_ = 0.f;
	}
	return self;
}

///
//	The callback when the avg power level changes it gives you a level amount from 0..1
//	We store the values so we can use it later in the draw routine
///
- (void) avAvgPowerLevelDidChange:(float) level channel:(ushort) aChannel
{
	avgPower_ = level;
}
///
//	The callback when the peak power level changes it gives you a level amount from 0..1
//	We store the values so we can use it later in the draw routine
///
- (void) avPeakPowerLevelDidChange:(float) level channel:(ushort) aChannel
{
	peakPower_ = level;
}

-(void)draw
{

//	glDisable(GL_TEXTURE_2D);
//	glDisableClientState(GL_COLOR_ARRAY);
//	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//	glPushMatrix();

	kmGLPushMatrix();
	{
		glLineWidth(10.f);
		ccDrawColor4B(255, 255, 255, 64);
		ccDrawLine(ccp(20.f, 0.f), ccp(20.f, 460.f*avgPower_));

		ccDrawColor4B(255, 255, 255, 255);
		kmGLPushMatrix();

		kmGLTranslatef(0.f, 460.f*peakPower_, 0.f);
		ccDrawLine(ccp(20.f, 0.f), ccp(20.f, 5.f));
		kmGLPopMatrix();

		glLineWidth(1.f);
	}
	kmGLPopMatrix();
//	glEnable(GL_TEXTURE_2D);
//	glEnableClientState(GL_COLOR_ARRAY);
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}
@end
