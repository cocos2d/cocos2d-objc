//
//  DebugAudioVis.h
//  DenshionAudioVisualDemo
//
//  Created by Lam Pham on 2/5/10.
//  Copyright 2010 FancyRatStudios Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AudioVisualization.h"

///
//	A Class to just debug the audio visualization
//	It pretty much draws two bars for each channel
//	The average power is represented by the large bar
//	The peak power is represented by the top line above the bar
///
@interface DebugAudioVis : CCNode<AudioVisualizationProtocol> {
	float avgPower_, peakPower_;
}

@end
