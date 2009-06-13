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
	CCLOG(@"CDAsychInitialiser is initialising audio manager");
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
				configuredChannelGroupDefinitions = new int[1];
				configuredChannelGroupDefinitions[0] = CD_MAX_SOURCES;
				configuredChannelGroupTotal = 1;
			}
			[[CDAudioManager alloc] init:configuredMode channelGroupDefinitions:configuredChannelGroupDefinitions channelGroupTotal:configuredChannelGroupTotal];
			_sharedManagerState = kAMStateInitialised;//This is only really relevant when using asynchronous initialisation
		}	
		return sharedManager;
	}
	return nil;
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
		sharedManager = [super alloc];
		return sharedManager;
	}
	return nil;
}

/*
 * Call this method before accessing the shared manager in order to configure the shared audio manager
 */
+ (void) configure: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal {
	configuredMode = mode;
	configuredChannelGroupDefinitions = new int[channelGroupTotal];
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
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(_audioSessionCategory), &_audioSessionCategory);
		soundEngine = [[CDSoundEngine alloc] init:channelGroupDefinitions channelGroupTotal:channelGroupTotal];
	}	
	return self;		
}	

-(void) dealloc {
	[self stopBackgroundMusic];
	[lastBackgroundMusicFilename release];
	[soundEngine release];
	[super dealloc];
}	

-(BOOL) isBackgroundMusicPlaying {
	if (backgroundMusic != nil) {
		return backgroundMusic.isPlaying;
	} else {
		return FALSE;
	}	
}	

//Load background music ready for playing
-(void) preloadBackgroundMusic:(NSString*) filename
{
	if (!willPlayBackgroundMusic) {
		CCLOG(@"Denshion: preload background music aborted because audio is not exclusive");
		return;
	}	
	
	if (![filename isEqualToString:lastBackgroundMusicFilename]) {
		CCLOG(@"Denshion: preloading new or different background music file");
		if(backgroundMusic != nil)
		{
			[self stopBackgroundMusic];
		}
		NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
		backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
		
		if (backgroundMusic != nil) {
			[backgroundMusic prepareToPlay];
			backgroundMusic.delegate = self;
		}	
		lastBackgroundMusicFilename = [filename copy];
	}	
}	

-(void) playBackgroundMusic:(NSString*) filename loop:(BOOL) loop
{
	
	if (!willPlayBackgroundMusic) {
		CCLOG(@"Denshion: play background music aborted because audio is not exclusive");
		return;
	}	
	
	if (![filename isEqualToString:lastBackgroundMusicFilename]) {
		CCLOG(@"Denshion: playing new or different background music file");
		if(backgroundMusic != nil)
		{
			[self stopBackgroundMusic];
		}
		NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
		backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
		
		if (backgroundMusic != nil) {
			backgroundMusic.numberOfLoops = (loop ? -1:0);
			[backgroundMusic play];
			backgroundMusic.delegate = self;
		}	
		lastBackgroundMusicFilename = [filename copy];
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

-(void) stopBackgroundMusic
{
	if (backgroundMusic != nil) {
		[backgroundMusic stop];
		[backgroundMusic autorelease];
		backgroundMusic = nil;
		lastBackgroundMusicFilename = nil;
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
	
    // Restore open al context 
    alcMakeContextCurrent([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CCLOG(@"Denshion: Error making context current%x\n", error);
	} 
    // 'unpause' my context 
    alcProcessContext([soundEngine openALContext]); 
	if((error = alGetError()) != AL_NO_ERROR) {
		CCLOG(@"Denshion: Error processing context%x\n", error);
	} 

} 

@end

