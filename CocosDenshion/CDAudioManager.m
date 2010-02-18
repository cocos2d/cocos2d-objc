/* CocosDenshion Audio Manager
 *
 * Copyright (C) 2009 Steve Oldmeadow
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

#import "CDAudioManager.h"

//Audio session interruption callback - used if sound engine is 
//handling audio session interruption automatically
extern void managerInterruptionCallback (void *inUserData, UInt32 interruptionState ) { 
	CDAudioManager *controller = (CDAudioManager *) inUserData; 
    if (interruptionState == kAudioSessionBeginInterruption) { 
        [controller audioSessionInterrupted]; 
    } else if (interruptionState == kAudioSessionEndInterruption) { 
        [controller audioSessionResumed]; 
    } 
} 

//NSOperation object used to asynchronously initialise 
@implementation CDAsynchInitialiser

-(void) main {
	[super main];
	[CDAudioManager sharedManager];
}	

@end

@implementation CDLongAudioSource

@synthesize audioSourcePlayer, audioSourceFilePath, delegate;

-(id) init {
	if ((self = [super init])) {
		state = kLAS_Init;
		volume = 1.0f;
		mute = NO;
	}
	return self;
}

-(void) dealloc {
	[audioSourcePlayer release];
	[audioSourceFilePath release];
	[super dealloc];
}	

-(void) load:(NSString*) filePath {
	//We have alread loaded a file previously,  check if we are being asked to load the same file
	if (state == kLAS_Init || ![filePath isEqualToString:audioSourceFilePath]) {
		CDLOG(@"Denshion::CDLongAudioSource - Loading new audio source %@",filePath);
		//New file
		if (state != kLAS_Init) {
			[audioSourceFilePath release];//Release old file path
			[audioSourcePlayer release];//Release old AVAudioPlayer, they can't be reused
		}
		audioSourceFilePath = [filePath copy];
		NSError *error;
		NSString *path = [CDUtilities fullPathFromRelativePath:audioSourceFilePath];
		audioSourcePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
		if (error == nil) {
			[audioSourcePlayer prepareToPlay];
			audioSourcePlayer.delegate = self;
			if (delegate && [delegate respondsToSelector:@selector(cdAudioSourceFileDidChange:)]) {
				//Tell our delegate the file has changed
				[delegate cdAudioSourceFileDidChange:self];
			}	
		} else {
			CDLOG(@"Denshion::CDLongAudioSource - Error initialising audio player: %@",error);
		}	
	} else {
		//Same file - just return it to a consistent state
		[self stop];
		[self rewind];
	}
	audioSourcePlayer.volume = volume;
	audioSourcePlayer.numberOfLoops = numberOfLoops;
	state = kLAS_Loaded;
}	

-(void) play {
	self->systemPaused = NO;
	[audioSourcePlayer play];
}	

-(void) stop {
	[audioSourcePlayer stop];
}	

-(void) pause {
	[audioSourcePlayer pause];
}	

-(void) rewind {
	[audioSourcePlayer setCurrentTime:0];
}

-(void) resume {
	[audioSourcePlayer play];
}	

-(BOOL) isPlaying {
	if (state != kLAS_Init) {
		return [audioSourcePlayer isPlaying];
	} else {
		return NO;
	}
}

-(void) setVolume:(float) newVolume
{
	volume = newVolume;
	if (state != kLAS_Init) {
		audioSourcePlayer.volume = newVolume;
	}	
}

-(float) volume 
{
	return volume;
}

-(BOOL) mute
{
	return mute;
}	

-(void) setMute:(BOOL) muteValue 
{
	if (mute != muteValue) {
		if (mute) {
			//Turn sound back on
			audioSourcePlayer.volume = volume;
		} else {
			audioSourcePlayer.volume = 0.0f;
		}
		mute = muteValue;
	}	
}	

-(NSInteger) numberOfLoops {
	return numberOfLoops;
}	

-(void) setNumberOfLoops:(NSInteger) loopCount
{
	audioSourcePlayer.numberOfLoops = loopCount;
	numberOfLoops = loopCount;
}	

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	CDLOG(@"Denshion::CDLongAudioSource - audio player finished");
#if TARGET_IPHONE_SIMULATOR	
	CDLOG(@"Denshion::CDLongAudioSource - workaround for OpenAL clobbered audio issue");
	//This is a workaround for an issue in all simulators (tested to 3.1.2).  Problem is 
	//that OpenAL audio playback is clobbered when an AVAudioPlayer stops.  Workaround
	//is to keep the player playing on an endless loop with 0 volume and then when
	//it is played again reset the volume and set loop count appropriately.
	//NB: this workaround is not foolproof but it is good enough for most situations.
	player.numberOfLoops = -1;
	player.volume = 0;
	[player play];
#endif	
	if (delegate && [delegate respondsToSelector:@selector(cdAudioSourceDidFinishPlaying:)]) {
		[delegate cdAudioSourceDidFinishPlaying:self];
	}	
}	

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	CDLOG(@"Denshion::CDLongAudioSource - audio player interrupted");
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
	CDLOG(@"Denshion::CDLongAudioSource - audio player resumed");
	[player play];
}	

@end


@interface CDAudioManager (PrivateMethods)

@end


@implementation CDAudioManager
#define BACKGROUND_MUSIC_CHANNEL kASC_Left

@synthesize soundEngine, willPlayBackgroundMusic;
static CDAudioManager *sharedManager;
static tAudioManagerState _sharedManagerState = kAMStateUninitialised;
static tAudioManagerMode configuredMode;
static int *configuredChannelGroupDefinitions;
static int configuredChannelGroupTotal;
static BOOL configured = FALSE;

// Init
+ (CDAudioManager *) sharedManager
{
	@synchronized(self)     {
		if (!sharedManager) {
			if (!configured) {
				//Set defaults here
				configuredMode = kAMM_FxPlusMusicIfNoOtherAudio;
				//Just create one channel group with all the sources
				//configuredChannelGroupDefinitions = new int[1];
				configuredChannelGroupDefinitions = (int *)malloc( sizeof(configuredChannelGroupDefinitions[0]) * 1);
				configuredChannelGroupDefinitions[0] = CD_MAX_SOURCES;
				configuredChannelGroupTotal = 1;
			}
			sharedManager = [[CDAudioManager alloc] init:configuredMode channelGroupDefinitions:configuredChannelGroupDefinitions channelGroupTotal:configuredChannelGroupTotal];
			_sharedManagerState = kAMStateInitialised;//This is only really relevant when using asynchronous initialisation
		}	
	}
	return sharedManager;
}

+ (tAudioManagerState) sharedManagerState {
	return _sharedManagerState;
}	

/**
 * Call this to set up audio manager asynchronously.  Initialisation is finished when sharedManagerState == kAMStateInitialised
 */
+ (void) initAsynchronously: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal {
	@synchronized(self) {
		if (_sharedManagerState == kAMStateUninitialised) {
			_sharedManagerState = kAMStateInitialising;
			[CDAudioManager configure:mode channelGroupDefinitions:channelGroupDefinitions channelGroupTotal:channelGroupTotal];
			CDAsynchInitialiser *initOp = [[[CDAsynchInitialiser alloc] init] autorelease];
			NSOperationQueue *opQ = [[[NSOperationQueue alloc] init] autorelease];
			[opQ addOperation:initOp];
		}	
	}
}	

+ (id) alloc
{
	@synchronized(self)     {
		NSAssert(sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

/*
 * Call this method before accessing the shared manager in order to configure the shared audio manager
 */
+ (void) configure: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal {
	configuredMode = mode;
	//configuredChannelGroupDefinitions = new int[channelGroupTotal];
	//NB: memory leak here if configure is called more than once, it is not intended to be used that way though (SO).
	configuredChannelGroupDefinitions = (int *)malloc( sizeof(configuredChannelGroupDefinitions[0]) * channelGroupTotal);
	if(!configuredChannelGroupDefinitions) {
		CDLOG(@"Denshion::CDAudioManager - configuredChannelGroupDefinitions memory allocation failed");
		//If this happens we are toast, basically run out of memory but we'll return to avoid a null
		//pointer reference below and keep clang happy.
		configured = FALSE;
		return;
	}
	
	for (int i=0; i < channelGroupTotal; i++) {
		configuredChannelGroupDefinitions[i] = channelGroupDefinitions[i];
	}	
	configuredChannelGroupTotal = channelGroupTotal;
	configured = TRUE;
}	

//Experimental TODO: review this
/*
- (void) determineCapabilities {
	Class audioSessionClass = NSClassFromString(@"AVAudioSession");
	if (audioSessionClass != nil) {
		CDLOG(@"Denshion::CDAudioManager - AVAudioSession exists");
	}	
}
*/ 

-(BOOL) isOtherAudioPlaying {
	UInt32 isPlaying;
	UInt32 varSize = sizeof(isPlaying);
	AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying, &varSize, &isPlaying);
	return (isPlaying != 0);
}

-(void) setMode:(tAudioManagerMode) mode {

	AudioSessionSetActive(NO);
	_mode = mode;
	switch (_mode) {
			
		case kAMM_FxOnly:
			//Share audio with other app
			CDLOG(@"Denshion::CDAudioManager - Audio will be shared");
			_audioSessionCategory = kAudioSessionCategory_AmbientSound;
			willPlayBackgroundMusic = NO;
			break;
			
		case kAMM_FxPlusMusic:
			//Use audio exclusively - if other audio is playing it will be stopped
			CDLOG(@"Denshion::CDAudioManager -  Audio will be exclusive");
			_audioSessionCategory = kAudioSessionCategory_SoloAmbientSound;
			willPlayBackgroundMusic = YES;
			break;
			
		case kAMM_MediaPlayback:
			//Use audio exclusively, ignore mute switch and sleep
			CDLOG(@"Denshion::CDAudioManager -  Media playback mode, audio will be exclusive");
			_audioSessionCategory = kAudioSessionCategory_MediaPlayback;
			willPlayBackgroundMusic = YES;
			break;
			
		case kAMM_PlayAndRecord:
			//Use audio exclusively, ignore mute switch and sleep, has inputs and outputs
			CDLOG(@"Denshion::CDAudioManager -  Play and record mode, audio will be exclusive");
			_audioSessionCategory = kAudioSessionCategory_PlayAndRecord;
			willPlayBackgroundMusic = YES;
			break;
			
		default:
			//kAudioManagerFxPlusMusicIfNoOtherAudio
			if ([self isOtherAudioPlaying]) {
				CDLOG(@"Denshion::CDAudioManager - Other audio is playing audio will be shared");
				_audioSessionCategory = kAudioSessionCategory_AmbientSound;
				willPlayBackgroundMusic = NO;
			} else {
				CDLOG(@"Denshion::CDAudioManager - Other audio is not playing audio will be exclusive");
				_audioSessionCategory = kAudioSessionCategory_SoloAmbientSound;
				willPlayBackgroundMusic = YES;
			}	
			
			break;
	}
	
	//Set audio session category
	if (willPlayBackgroundMusic) {
		//Work around to ensure background music is not decoded in software
		//on OS 3.0. Thanks to Bryan Acceleroto (SO 2009.07.02)
		UInt32 fakeCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(fakeCategory), &fakeCategory);
		AudioSessionSetActive(YES);
		AudioSessionSetActive(NO);
	}	
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(_audioSessionCategory), &_audioSessionCategory);
	AudioSessionSetActive(YES);
	
}	

- (id) init: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal {
	if ((self = [super init])) {
		
		//Initialise the audio session 
		AudioSessionInitialize(NULL, NULL,managerInterruptionCallback, self); 
	
		_mode = mode;
		backgroundMusicCompletionSelector = nil;
		_isObservingAppEvents = FALSE;
		_muteStoppedMusic = FALSE;
		[self setMode:mode];
		soundEngine = [[CDSoundEngine alloc] init:channelGroupDefinitions channelGroupTotal:channelGroupTotal];
		
		//Set up audioSource channels
		audioSourceChannels = [[NSMutableArray alloc] init];
		CDLongAudioSource *leftChannel = [[CDLongAudioSource alloc] init];
		CDLongAudioSource *rightChannel = [[CDLongAudioSource alloc] init];
		[audioSourceChannels insertObject:leftChannel atIndex:kASC_Left];	
		[audioSourceChannels insertObject:rightChannel atIndex:kASC_Right];
		[leftChannel release];
		[rightChannel release];
		//Used to support legacy APIs
		backgroundMusic = [self audioSourceForChannel:BACKGROUND_MUSIC_CHANNEL];
		backgroundMusic.delegate = self;
	}	
	return self;		
}	

-(void) dealloc {
	[self stopBackgroundMusic];
	[soundEngine release];
	if (_isObservingAppEvents) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
	AudioSessionSetActive(FALSE);
	if (configuredChannelGroupDefinitions) {
		free(configuredChannelGroupDefinitions);
	}
	[audioSourceChannels release];
	[super dealloc];
}	

/** Retrieves the audio source for the specified channel */
-(CDLongAudioSource*) audioSourceForChannel:(tAudioSourceChannel) channel 
{
	return (CDLongAudioSource*)[audioSourceChannels objectAtIndex:channel];
}	

/** Loads the data from the specified file path to the channel's audio source */
-(CDLongAudioSource*) audioSourceLoad:(NSString*) filePath channel:(tAudioSourceChannel) channel
{
	CDLongAudioSource *audioSource = [self audioSourceForChannel:channel];
	if (audioSource) {
		[audioSource load:filePath];
	}
	return audioSource;
}	

-(BOOL) isBackgroundMusicPlaying {
	return [self.backgroundMusic isPlaying];
}	

//NB: originally I tried using a route change listener and intended to store the current route,
//however, on a 3gs running 3.1.2 no route change is generated when the user switches the 
//ringer mute switch to off (i.e. enables sound) therefore polling is the only reliable way to
//determine ringer switch state
-(BOOL) isDeviceMuted {

#if TARGET_IPHONE_SIMULATOR
	//Calling audio route stuff on the simulator causes problems
	return NO;
#else	
	CFStringRef newAudioRoute;
	UInt32 propertySize = sizeof (CFStringRef);
	
	AudioSessionGetProperty (
							 kAudioSessionProperty_AudioRoute,
							 &propertySize,
							 &newAudioRoute
							 );
	
	if (newAudioRoute == NULL) {
		//Don't expect this to happen but playing safe otherwise a null in the CFStringCompare will cause a crash
		return YES;
	} else {	
		CFComparisonResult newDeviceIsMuted =	CFStringCompare (
																 newAudioRoute,
																 (CFStringRef) @"",
																 0
																 );
		
		return (newDeviceIsMuted == kCFCompareEqualTo);
	}	
#endif
}	

-(BOOL) mute {
	return _mute;
}	

-(void) setMute:(BOOL) muteValue {
	[soundEngine setMute:muteValue];
	_mute = muteValue;
	for( CDLongAudioSource *audioSource in audioSourceChannels) {
		audioSource.mute = muteValue;
	}	
}

-(CDLongAudioSource*) backgroundMusic
{
	return backgroundMusic;
}	

//Load background music ready for playing
-(void) preloadBackgroundMusic:(NSString*) filePath
{
	if (!willPlayBackgroundMusic) {
		CDLOG(@"Denshion::CDAudioManager - preload background music aborted because audio is not exclusive");
		return;
	}	
	[self.backgroundMusic load:filePath];	
}	

-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop
{
	if (!willPlayBackgroundMusic || _mute) {
		CDLOG(@"Denshion::CDAudioManager - play bgm aborted because audio is not exclusive or sound is muted");
		return;
	}
		
	[self.backgroundMusic load:filePath];
	if (loop) {
		[self.backgroundMusic setNumberOfLoops:-1];
	} else {
		[self.backgroundMusic setNumberOfLoops:0];
	}	
	[self.backgroundMusic play];
}

-(void) stopBackgroundMusic
{
	[self.backgroundMusic stop];
}

-(void) pauseBackgroundMusic
{
	[self.backgroundMusic pause];
}	

-(void) resumeBackgroundMusic
{
	[self.backgroundMusic resume];
}	

-(void) rewindBackgroundMusic
{
	[self.backgroundMusic rewind];
}	

-(void) setBackgroundMusicCompletionListener:(id) listener selector:(SEL) selector {
	backgroundMusicCompletionListener = listener;
	backgroundMusicCompletionSelector = selector;
}	

/*
 * Call this method to have the audio manager automatically handle application resign and
 * become active.  Pass a tAudioManagerResignBehavior to indicate the desired behavior
 * for resigning and becoming active again.
 *
 * If autohandle is YES then the applicationWillResignActive and applicationDidBecomActive 
 * methods are automatically called, otherwise you must call them yourself at the appropriate time.
 *
 * Based on idea of Dominique Bongard
 */
-(void) setResignBehavior:(tAudioManagerResignBehavior) resignBehavior autoHandle:(BOOL) autoHandle { 

	if (!_isObservingAppEvents && autoHandle) {
		[[NSNotificationCenter defaultCenter] addObserver:self	selector:@selector(applicationWillResignActive:) name:@"UIApplicationWillResignActiveNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self	selector:@selector(applicationDidBecomeActive:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self	selector:@selector(applicationWillTerminate:) name:@"UIApplicationWillTerminateNotification" object:nil];
		_isObservingAppEvents = TRUE;
	}
	_resignBehavior = resignBehavior;
}	

//Called when application resigns active only if setResignBehavior has been called 
- (void) applicationWillResignActive:(NSNotification *) notification
{
	
	switch (_resignBehavior) {

		case kAMRBStopPlay:
			
			for( CDLongAudioSource *audioSource in audioSourceChannels) {
				if (audioSource.isPlaying) {
					audioSource->systemPaused = YES;
					audioSource->systemPauseLocation = audioSource.audioSourcePlayer.currentTime;
					[audioSource stop];
				} else {
					//Music is either paused or stopped, if it is paused it will be restarted
					//by OS so we will stop it.
					audioSource->systemPaused = NO;
					[audioSource stop];
				}	
			}	
			break;
			
		case kAMRBStop:	
			//Stop music regardless of whether it is playing or not because if it was paused
			//then the OS would resume it
			for( CDLongAudioSource *audioSource in audioSourceChannels) {
				[audioSource stop];
			}	
			
		default:
			break;

	}			
	
	CDLOG(@"Denshion::CDAudioManager - handling resign active");
}

//Called when application becomes active only if setResignBehavior has been called 
- (void) applicationDidBecomeActive:(NSNotification *) notification
{

	switch (_resignBehavior) {
			
		case kAMRBStopPlay:
			
			//Music had been stopped but stop maintains current time
			//so playing again will continue from where music was before resign active
			for( CDLongAudioSource *audioSource in audioSourceChannels) {
				if (audioSource->systemPaused) {
					[audioSource resume];
					audioSource->systemPaused = NO;
				}	
			}	
    		break;
			
		default:
			break;
			
	}		
	CDLOG(@"Denshion::CDAudioManager - audio manager handling become active");
	
}

//Called when application terminates only if setResignBehavior has been called 
- (void) applicationWillTerminate:(NSNotification *) notification
{
	CDLOG(@"Denshion::CDAudioManager - audio manager handling terminate");
	[self stopBackgroundMusic];
}

/** The audio source completed playing */
- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource {
	CDLOG(@"Denshion::CDAudioManager - audio manager got told background music finished");
	if (backgroundMusicCompletionSelector != nil) {
		[backgroundMusicCompletionListener performSelector:backgroundMusicCompletionSelector];
	}	
}	

//Code to handle audio session interruption.  Thanks to Andy Fitter and Ben Britten.
-(void)audioSessionInterrupted 
{ 
    CDLOG(@"Denshion::CDAudioManager - Audio session interrupted"); 
	ALenum  error = AL_NO_ERROR;
    // Deactivate the current audio session 
    AudioSessionSetActive(NO); 
    // set the current context to NULL will 'shutdown' openAL 
    alcMakeContextCurrent(NULL); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CDLOG(@"Denshion::CDAudioManager - Error making context current %x\n", error);
	} 
    // now suspend your context to 'pause' your sound world 
    alcSuspendContext([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CDLOG(@"Denshion::CDAudioManager - Error suspending context %x\n", error);
	} 
	#pragma unused(error)
} 

//Code to handle audio session resumption.  Thanks to Andy Fitter and Ben Britten.
-(void)audioSessionResumed 
{ 
    ALenum  error = AL_NO_ERROR;
	CDLOG(@"Denshion::CDAudioManager - Audio session resumed"); 
    // Reset audio session 
    OSStatus result = AudioSessionSetProperty ( kAudioSessionProperty_AudioCategory, sizeof(_audioSessionCategory), &_audioSessionCategory ); 
	
	// Reactivate the current audio session 
    result = AudioSessionSetActive(YES); 
	#pragma unused(result)
	
    // Restore open al context 
    alcMakeContextCurrent([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CDLOG(@"Denshion::CDAudioManager - Error making context current%x\n", error);
	} 
    #pragma unused(error)
    // 'unpause' my context 
    alcProcessContext([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CDLOG(@"Denshion::CDAudioManager - Error processing context%x\n", error);
	}
}

+(void) end {
	[sharedManager release];
}	

@end
