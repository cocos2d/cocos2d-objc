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
#import "ccMacros.h"

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

#if TARGET_IPHONE_SIMULATOR	
//Workaround for issue in simulator.
//See: audioPlayerDidFinishPlaying
float realBackgroundMusicVolume = -1.0f;
#endif


//NSOperation object used to asynchronously initialise 
@implementation CDAsynchInitialiser

-(void) main {
	[super main];
	[CDAudioManager sharedManager];
}	

@end

@implementation CDAudioManager
@synthesize soundEngine, backgroundMusic, willPlayBackgroundMusic;
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
				configuredMode = kAudioManagerFxPlusMusicIfNoOtherAudio;
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
		CCLOG(@"Denshion: configuredChannelGroupDefinitions memory allocation failed");
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


- (id) init: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal {
	if ((self = [super init])) {
		//Initialise the audio session 
		AudioSessionInitialize(NULL, NULL,managerInterruptionCallback, self); 
	
		_mode = mode;
		backgroundMusicCompletionSelector = nil;
		_isObservingAppEvents = FALSE;
		_systemPausedMusic = FALSE;
		_muteStoppedMusic = FALSE;
		
		switch (_mode) {
				
			case kAudioManagerFxOnly:
				//Share audio with other app
				CCLOG(@"Denshion: Audio will be shared");
				_audioSessionCategory = kAudioSessionCategory_AmbientSound;
				willPlayBackgroundMusic = FALSE;
				break;
				
			case kAudioManagerFxPlusMusic:
				//Use audio exclusively - if other audio is playing it will be stopped
				CCLOG(@"Denshion: Audio will be exclusive");
				_audioSessionCategory = kAudioSessionCategory_SoloAmbientSound;
				willPlayBackgroundMusic = TRUE;
				break;
				
			default:
				//kAudioManagerFxPlusMusicIfNoOtherAudio
				CCLOG(@"Denshion: Checking for other audio");
				UInt32 isPlaying;
				UInt32 varSize = sizeof(isPlaying);
				AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying, &varSize, &isPlaying);
				if (isPlaying != 0) {
					CCLOG(@"Denshion: Other audio is playing audio will be shared");
					_audioSessionCategory = kAudioSessionCategory_AmbientSound;
					willPlayBackgroundMusic = FALSE;
					_audioWasPlayingAtStartup = TRUE;
				} else {
					CCLOG(@"Denshion: Other audio is not playing audio will be exclusive");
					_audioSessionCategory = kAudioSessionCategory_SoloAmbientSound;
					willPlayBackgroundMusic = TRUE;
					_audioWasPlayingAtStartup = FALSE;
				}	
				
				break;
		}
		
		//Set audio session category
		if (willPlayBackgroundMusic) {
			//Work around to ensure background music is not decoded in software
			//on OS 3.0. Thanks to Bryan Acceleroto (SO 2009.07.02)
			UInt32 fakeCategory = kAudioSessionCategory_MediaPlayback;
			AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(fakeCategory), &fakeCategory);
			AudioSessionSetActive(TRUE);
			AudioSessionSetActive(FALSE);
		}	
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(_audioSessionCategory), &_audioSessionCategory);
		AudioSessionSetActive(TRUE);
		soundEngine = [[CDSoundEngine alloc] init:channelGroupDefinitions channelGroupTotal:channelGroupTotal];
	}	
	return self;		
}	

-(void) dealloc {
	[self stopBackgroundMusic];
	[lastBackgroundMusicFilePath release];
	[soundEngine release];
	if (_isObservingAppEvents) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}	
	[super dealloc];
}	

-(BOOL) isBackgroundMusicPlaying {
	if (backgroundMusic != nil) {
		return backgroundMusic.isPlaying;
	} else {
		return FALSE;
	}	
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

/**
 * Setting mute to true will stop all sounds currently playing and prevent further sounds from playing.
 * If background music was playing when sound was muted it will be resumed when sound is unmuted.
 */
-(void) setMute:(BOOL) muteValue {
	
	[soundEngine setMute:muteValue];
	_mute = muteValue;
	if (_mute) {
		if ([self isBackgroundMusicPlaying]) {
			[self stopBackgroundMusic:FALSE];
			_muteStoppedMusic = TRUE;
		} else {
			_muteStoppedMusic = FALSE;
		}	
	} else {
		if (_muteStoppedMusic) {
			[self resumeBackgroundMusic];
			_muteStoppedMusic = FALSE;
		}	
	}	
}	

//Load background music ready for playing
-(void) preloadBackgroundMusic:(NSString*) filePath
{
	if (!willPlayBackgroundMusic) {
		CCLOG(@"Denshion: preload background music aborted because audio is not exclusive");
		return;
	}	
	
	if (![filePath isEqualToString:lastBackgroundMusicFilePath]) {
		CCLOG(@"Denshion: loading new or different background music file %@", filePath);
		if(backgroundMusic != nil)
		{
			[self stopBackgroundMusic:TRUE];
		}
		NSString *path = [CCFileUtils fullPathFromRelativePath:filePath];
		backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];

		if (backgroundMusic != nil) {
			[backgroundMusic prepareToPlay];
			backgroundMusic.delegate = self;
		}	
		lastBackgroundMusicFilePath = [filePath copy];
	}	
}	

-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop
{
	if (!willPlayBackgroundMusic || _mute) {
		CCLOG(@"Denshion: play bgm aborted because audio is not exclusive or sound is muted");
		return;
	}	
	
	if (![filePath isEqualToString:lastBackgroundMusicFilePath]) {
		[self preloadBackgroundMusic:filePath];		
		backgroundMusic.numberOfLoops = (loop ? -1:0);
		[backgroundMusic play];
	} else {
		CCLOG(@"Denshion: request to play current background music file");
		[self pauseBackgroundMusic];
		[self rewindBackgroundMusic];
#if TARGET_IPHONE_SIMULATOR
		//Workaround for issue in simulator.
		//See: audioPlayerDidFinishPlaying
		//Need to restore volume and loop count to correct values
		if (realBackgroundMusicVolume >= 0.0f) {
			backgroundMusic.volume = realBackgroundMusicVolume;
		}
#endif		
		backgroundMusic.numberOfLoops = (loop ? -1:0);//Reset loop count because track may have been preloaded
		[backgroundMusic play];
	}	
}

//Kept for backwards compatibility with 1.5 interface
-(void) stopBackgroundMusic
{
	[self stopBackgroundMusic:TRUE];
}

//@param release - if TRUE AVAudioPlayer instance will be released
-(void) stopBackgroundMusic:(BOOL) release
{
	if (backgroundMusic != nil) {
		[backgroundMusic stop];
		if (release) {
			[backgroundMusic autorelease];
			backgroundMusic = nil;
			lastBackgroundMusicFilePath = nil;
		}	
	}	
}

-(void) pauseBackgroundMusic
{
	if (backgroundMusic != nil) {
		[backgroundMusic pause];
	}	
}	

-(void) resumeBackgroundMusic
{
	if (backgroundMusic != nil) {
		[backgroundMusic play];
	}	
}	

-(void) rewindBackgroundMusic
{
	if (backgroundMusic != nil) {
		backgroundMusic.currentTime = 0;;
	}	
}	

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	CCLOG(@"Denshion: audio player interrupted");
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
	CCLOG(@"Denshion: audio player resumed");
	[player play];
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
			if (backgroundMusic.isPlaying) {
				_systemPausedMusic = TRUE;
				[self stopBackgroundMusic:FALSE];
			} else {
				//Music is either paused or stopped, if it is paused it will be restarted
				//by OS so we will stop it.
				_systemPausedMusic = FALSE;
				[self stopBackgroundMusic:FALSE];
			}	
			break;
			
		case kAMRBStop:	
			//Stop music regardless of whether it is playing or not because if it was paused
			//then the OS would resume it
			[self stopBackgroundMusic:FALSE];
			
		default:
			break;

	}			
	
	CCLOG(@"Denshion: audio manager handling resign active");
}

//Called when application becomes active only if setResignBehavior has been called 
- (void) applicationDidBecomeActive:(NSNotification *) notification
{

	switch (_resignBehavior) {
			
		case kAMRBStopPlay:
			if (_systemPausedMusic) {
				//Music had been stopped but stop maintains current time
				//so playing again will continue from where music was before resign active
				[self resumeBackgroundMusic];
				_systemPausedMusic = FALSE;
			}	
			break;
			
		default:
			break;
			
	}		
	CCLOG(@"Denshion: audio manager handling become active");
	
}

//Called when application terminates only if setResignBehavior has been called 
- (void) applicationWillTerminate:(NSNotification *) notification
{
	CCLOG(@"Denshion: audio manager handling terminate");
	[self stopBackgroundMusic];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	CCLOG(@"Denshion: audio player finished");
	if (backgroundMusicCompletionSelector != nil) {
		[backgroundMusicCompletionListener performSelector:backgroundMusicCompletionSelector];
	}	
#if TARGET_IPHONE_SIMULATOR	
	CCLOG(@"Denshion: workaround for OpenAL clobbered audio issue");
	//This is a workaround for an issue in the 2.2 and 2.2.1 simulator.  Problem is 
	//that OpenAL audio playback is clobbered when an AVAudioPlayer stops.  Workaround
	//is to keep the player playing on an endless loop with 0 volume and then when
	//it is played again reset the volume and set loop count appropriately.
	player.numberOfLoops = -1;
	realBackgroundMusicVolume = player.volume;
	player.volume = 0;
	[player play];
#endif	
}	


//Code to handle audio session interruption.  Thanks to Andy Fitter and Ben Britten.
-(void)audioSessionInterrupted 
{ 
    CCLOG(@"Denshion: Audio session interrupted"); 
	ALenum  error = AL_NO_ERROR;
    // Deactivate the current audio session 
    AudioSessionSetActive(NO); 
    // set the current context to NULL will 'shutdown' openAL 
    alcMakeContextCurrent(NULL); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CCLOG(@"Denshion: Error making context current %x\n", error);
	} 
    // now suspend your context to 'pause' your sound world 
    alcSuspendContext([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CCLOG(@"Denshion: Error suspending context %x\n", error);
	} 
	#pragma unused(error)
} 

//Code to handle audio session resumption.  Thanks to Andy Fitter and Ben Britten.
-(void)audioSessionResumed 
{ 
    ALenum  error = AL_NO_ERROR;
	CCLOG(@"Denshion: Audio session resumed"); 
    // Reset audio session 
    OSStatus result = AudioSessionSetProperty ( kAudioSessionProperty_AudioCategory, sizeof(_audioSessionCategory), &_audioSessionCategory ); 
	
	// Reactivate the current audio session 
    result = AudioSessionSetActive(YES); 
	#pragma unused(result)
	
    // Restore open al context 
    alcMakeContextCurrent([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CCLOG(@"Denshion: Error making context current%x\n", error);
	} 
    #pragma unused(error)
    // 'unpause' my context 
    alcProcessContext([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CCLOG(@"Denshion: Error processing context%x\n", error);
	}
}



@end
