// @see header
#import "AudioVisualization.h"
#import "SimpleAudioEngine.h"

@implementation AudioVisualization
static AudioVisualization *sharedAV = nil;
@synthesize filterSmooth = filterSmooth_;

+(AudioVisualization *)sharedAV
{
	@synchronized(self)     {
		if (!sharedAV)
			sharedAV = [[AudioVisualization alloc] init];
	}
	return sharedAV;
}

+(id)alloc
{
	@synchronized(self)     {
		NSAssert(sharedAV == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

-(id)init {
	if((self = [super init])){
		filterSmooth_ = AudioVisualization_FilterSmoothing;
		filteredPeak_ = 0;
		filteredAverage_ = 0;
		delegates_ = [[NSMutableArray alloc]initWithCapacity:2];
		
		avAvgPowerLevelSel_ = @selector(avAvgPowerLevelDidChange:channel:);
		avPeakPowerLevelSel_ = @selector(avPeakPowerLevelDidChange:channel:);

		[[CCScheduler sharedScheduler] scheduleSelector:@selector(tick:) forTarget:self interval:0 paused:NO repeat:kCCRepeatForever delay:0.0f];

		[SimpleAudioEngine sharedEngine];
		if([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]){
			
			audioPlayer_ = [CDAudioManager sharedManager].backgroundMusic.audioSourcePlayer;
			audioPlayer_.meteringEnabled = YES;
			filteredPeak_ = malloc(audioPlayer_.numberOfChannels * sizeof(double));
			filteredAverage_ = malloc(audioPlayer_.numberOfChannels * sizeof(double));
		}
	}
	return self;
}
-(void)dealloc
{
	if(filteredPeak_)
		free(filteredPeak_);
	if(filteredAverage_)
		free(filteredAverage_);
	[delegates_ release];
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(tick:) forTarget:self];
	[super dealloc];
}

-(void)setMeteringInterval:(float) seconds
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(tick:) forTarget:self];
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(tick:) forTarget:self interval:seconds paused:NO repeat:kCCRepeatForever delay:0.0f];
}

-(void)tick:(ccTime) dt
{
	if (!audioPlayer_) return;
	if(filteredPeak_ && filteredAverage_){
		[audioPlayer_ updateMeters];
		double peakPowerForChannel = 0.f,avgPowerForChannel = 0.f;
		for(ushort i = 0; i < audioPlayer_.numberOfChannels; ++i){
			//	convert the -160 to 0 dB to [0..1] range
			peakPowerForChannel = pow(10, (0.05 * [audioPlayer_ peakPowerForChannel:i]));
			avgPowerForChannel = pow(10, (0.05 * [audioPlayer_ averagePowerForChannel:i]));
			
			filteredPeak_[i] = filterSmooth_ * peakPowerForChannel + (1.0f - filterSmooth_) * filteredPeak_[i];
			filteredAverage_[i] = filterSmooth_ * avgPowerForChannel + (1.0f - filterSmooth_) * filteredAverage_[i];
		}
		
		for(NSDictionary *delegate in delegates_){
			if ([[delegate objectForKey:@"delegate"]respondsToSelector:avPeakPowerLevelSel_]) {
				[[delegate objectForKey:@"delegate"]avPeakPowerLevelDidChange:(float)filteredPeak_[[[delegate objectForKey:@"channel"] shortValue]] channel:[[delegate objectForKey:@"channel"] shortValue]];
			}
			if ([[delegate objectForKey:@"delegate"]respondsToSelector:avAvgPowerLevelSel_]) {
				[[delegate objectForKey:@"delegate"]avAvgPowerLevelDidChange:(float)filteredAverage_[[[delegate objectForKey:@"channel"] shortValue]] channel:[[delegate objectForKey:@"channel"] shortValue]];
			}
		}
	}
}
-(void)addDelegate:(id<AudioVisualizationProtocol>)delegate forChannel:(ushort) channel
{
	if(!audioPlayer_) return;
	if(channel < audioPlayer_.numberOfChannels){
		[delegates_ addObject:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", [NSNumber numberWithShort:channel], @"channel", nil]];
	}
}
@end
