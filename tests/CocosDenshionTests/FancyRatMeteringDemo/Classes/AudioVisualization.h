//
//  AudioVisualization.h
//  Silhouette
//
//  Created by Lam Pham on 1/21/10.
//  Copyright 2010 FancyRatStudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol AudioVisualizationProtocol
@optional
-(void)avAvgPowerLevelDidChange:(float)level channel:(ushort)aChannel;
-(void)avPeakPowerLevelDidChange:(float)level channel:(ushort)aChannel;
@end

#define AudioVisualization_FilterSmoothing 0.2f
@class AVAudioPlayer;
@interface AudioVisualization : NSObject {
	//	weak reference
	AVAudioPlayer	*audioPlayer_;

	double			filterSmooth_;
	double			*filteredPeak_;
	double			*filteredAverage_;
	NSMutableArray	*delegates_;
	SEL				avAvgPowerLevelSel_;
	SEL				avPeakPowerLevelSel_;
}
///
//	Smoothing factor from [0..1]
///
@property double filterSmooth;

///
//	returns the shared instance
///
+(AudioVisualization*)sharedAV;

///
//	@params seconds is the interval delay
///
-(void)setMeteringInterval:(float) seconds;

-(void)addDelegate:(id<AudioVisualizationProtocol>)delegate forChannel:(ushort)channel;
@end
