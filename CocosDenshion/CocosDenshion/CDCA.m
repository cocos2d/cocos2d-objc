/*
 Copyright (c) 2011 Steve Oldmeadow
 
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

#import "CDCA.h"

@implementation CDCA
@synthesize state = state_;

static int const kCDCA_groupEffects = 0;
static int const kCDCA_groupEffectsComplete = 1;
static int const kCDCA_groupSoundSources = 2;

//Called when initialisation has successfully completed
-(void) postInitialisation {
	CDLOG(@"Denshion::CDCA postInitialisation");
	state_ = kCDCAStateInitialised;
	[self cdcaDidFinishInitialising];
}

-(void) postPreloadEffects {
	CDLOG(@"Denshion::CDCA postPreloadEffects");
	if (state_ == kCDCAStateInitialising) {
		[self postInitialisation];
	}	
}

-(void) setUpSourceGroups {
	
	int totalSources = _soundEngine.sourceTotal;
	int sourceGroups[3];
	sourceGroups[kCDCA_groupSoundSources] = [self totalSoundSources];
	sourceGroups[kCDCA_groupEffectsComplete] = [self totalUninterruptibleEffects];
	sourceGroups[kCDCA_groupEffects] = totalSources - (sourceGroups[kCDCA_groupSoundSources] + sourceGroups[kCDCA_groupEffectsComplete]);
	[_soundEngine defineSourceGroups:sourceGroups total:3];
	[_soundEngine setSourceGroupNonInterruptible:kCDCA_groupEffectsComplete isNonInterruptible:YES];
}	

//Called by NSNotificationCenter after audio manager initialises
-(void) postAudioManagerInitialised {
	CDLOG(@"Denshion::CDCA postAudioManagerInitialised");
	if (state_ == kCDCAStateInitialising) {
		_am = [CDAudioManager sharedManager];
		if (_am) {
			_soundEngine = _am.soundEngine;
			[self setResignBehavior];
			[self setUpSourceGroups];
			if (CD_PRELOAD_SOUND_TOTAL > 0) {
				//Load any preload files
				[[NSNotificationCenter defaultCenter] addObserver:self	selector:@selector(postPreloadEffects) name:kCDN_AsynchLoadComplete object:nil];
				NSMutableArray *loadRequests = [[NSMutableArray alloc] init];
				[loadRequests autorelease];
				for (int i=0; i < CD_PRELOAD_SOUND_TOTAL; i++) {
					int soundSlot = kCD_PreloadSoundIds[i];
					CDLOG(@"Denshion::CDCA adding preload file: %@ for slot: %i",kCD_SoundFiles[soundSlot],soundSlot);
					CDBufferLoadRequest* loadRequest = 
							[[CDBufferLoadRequest alloc] init:kCD_PreloadSoundIds[i] filePath:kCD_SoundFiles[soundSlot]];
					[loadRequest autorelease];
					[loadRequests addObject:loadRequest];
				}	
				[self buffersLoadAsynchronously:loadRequests];
			} else {
				[self postInitialisation]; 
			}	
		} else {
			//Something went wrong
			state_ = kCDCAStateFailed;	
		}	
	}	
}	

//When this returns YES asynchronous set up is complete
-(BOOL) ready {
	return ((state_ != kCDCAStateInitialising) && (state_ != kCDCAStateUninitialised));
}

-(int) firstFreeBufferId {
	return CD_SOUND_TOTAL;
}	
 
-(id) init
{
	if((self=[super init])) {
		CDLOGINFO(@"Denshion::CDCA initialising");
		state_ = kCDCAStateInitialising;
		mute_ = NO;
		enabled_ = YES;
		[CDAudioManager initAsynchronously:[self initialAudioManagerMode]];
		[[NSNotificationCenter defaultCenter] addObserver:self	selector:@selector(postAudioManagerInitialised) name:kCDN_AudioManagerInitialised object:nil];
	}
	return self;
}

// Memory
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_am = nil;
	_soundEngine = nil;
	[super dealloc];
}

-(CDSoundEngine*) soundEngine {
	return _soundEngine;
}	

-(CDAudioManager*) audioManager {
	return _am;
}	

#pragma mark CDCA - buffers
-(BOOL) bufferLoad:(int) soundId filePath:(NSString*) filePath {
	return [_am.soundEngine loadBuffer:soundId filePath:filePath];
}	

-(BOOL) bufferUnload:(int) soundId {
	return [_am.soundEngine unloadBuffer:soundId];
}	

-(void) buffersLoadAsynchronously:(NSArray *) loadRequests {
	return [_am.soundEngine loadBuffersAsynchronously:loadRequests];
}	

-(float) bufferDurationInSeconds:(int) soundId {
	return [_am.soundEngine bufferDurationInSeconds:soundId];
}

-(ALsizei) bufferSizeInBytes:(int) soundId {
	return [_am.soundEngine bufferSizeInBytes:soundId];
}

-(ALsizei) bufferFrequencyInHertz:(int) soundId {
	return [_am.soundEngine bufferFrequencyInHertz:soundId];
}	

#pragma mark CDCA - background music

-(void) backgroundMusicPreload:(NSString*) filePath {
	[_am preloadBackgroundMusic:filePath];
}

-(void) backgroundMusicPlay:(NSString*) filePath
{
	[_am playBackgroundMusic:filePath loop:TRUE];
}

-(void) backgroundMusicPlay:(NSString*) filePath loop:(BOOL) loop
{
	[_am playBackgroundMusic:filePath loop:loop];
}

-(void) backgroundMusicStop
{
	[_am stopBackgroundMusic];
}

-(void) backgroundMusicPause {
	[_am pauseBackgroundMusic];
}	

-(void) backgroundMusicResume {
	[_am resumeBackgroundMusic];
}	

-(void) backgroundMusicRewind {
	[_am rewindBackgroundMusic];
}

-(BOOL) backgroundMusicIsPlaying {
	return [_am isBackgroundMusicPlaying];
}	

-(BOOL) backgroundMusicWillPlay {
	return [_am willPlayBackgroundMusic];
}

-(float) backgroundMusicVolume
{
	return _am.backgroundMusic.volume;
}

-(void) setBackgroundMusicVolume:(float) volume
{
	_am.backgroundMusic.volume = volume;
}	

-(void) backgroundMusicSetMute:(BOOL) mute {
	_am.backgroundMusic.mute = mute;
}	

-(void) backgroundMusicSetEnabled:(BOOL) enabled {
	_am.backgroundMusic.enabled = enabled;
}	

-(BOOL) backgroundMusicIsMute {
	return _am.backgroundMusic.mute;
}	

-(BOOL) backgroundMusicIsEnabled {
	return _am.backgroundMusic.enabled;
}	

#pragma mark CDCA - sound effects

-(void) effectPlay:(NSUInteger) soundId;
{
	[self effectPlay:soundId pitch:kCD_PitchDefault pan:kCD_PanDefault gain:kCD_GainDefault];
}

-(void) effectPlayCompletely:(NSUInteger) soundId;
{
	[self effectPlayCompletely:soundId pitch:kCD_PitchDefault pan:kCD_PanDefault gain:kCD_GainDefault];
}

-(void) effectPlay:(NSUInteger) soundId pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain
{
	[_soundEngine playSound:soundId sourceGroupId:kCDCA_groupEffects pitch:pitch pan:pan gain:gain loop:NO];
}

-(void) effectPlayCompletely:(NSUInteger) soundId pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain
{
	[_soundEngine playSound:soundId sourceGroupId:kCDCA_groupEffectsComplete pitch:pitch pan:pan gain:gain loop:NO];
}

-(BOOL) effectsAreMute {
	return _am.soundEngine.mute;
}	

-(void) effectsSetMute:(BOOL) mute {
	_am.soundEngine.mute = mute;
}	

-(BOOL) effectsAreEnabled {
	return _am.soundEngine.enabled;
}	

-(void) effectsSetEnabled:(BOOL) enabled {
	_am.soundEngine.enabled = enabled;
}	

-(float) effectsVolume
{
	return _am.soundEngine.masterGain;
}	

-(void) setEffectsVolume:(float) volume
{
	_am.soundEngine.masterGain = volume;
}	

#pragma mark CDCA - Audio Interrupt Protocol
-(BOOL) mute
{
	return mute_;
}

-(void) setMute:(BOOL) muteValue
{
	if (mute_ != muteValue) {
		mute_ = muteValue;
		_am.mute = mute_;
	}	
}

-(BOOL) enabled
{
	return enabled_;
}

-(void) setEnabled:(BOOL) enabledValue
{
	if (enabled_ != enabledValue) {
		enabled_ = enabledValue;
		_am.enabled = enabled_;
	}	
}

#pragma mark CDCA - sound source

-(CDSoundSource *) soundSourceForSound:(NSUInteger) soundId {
	CDSoundSource *result = [_soundEngine soundSourceForSound:soundId sourceGroupId:kCDCA_groupSoundSources];
	CDLOGINFO(@"Denshion::CDCA sound source created for %i",soundId);
	return result;
}	

#pragma mark CDCA - overridable defaults
-(tAudioManagerMode) initialAudioManagerMode {
	return kAMM_FxPlusMusicIfNoOtherAudio;
}

-(int) totalSoundSources {
	//Size of the sound source pool, override in a sub class to use a different value.
	//e.g if you aren't using sound sources set this to 0.
	return 16;
}

-(int) totalUninterruptibleEffects {
	//Size of the uninterruptible effects pool, override in a sub class to use a different value.
	return 4;
}	

-(void)	setResignBehavior {
	[_am setResignBehavior:kAMRBStopPlay autoHandle:YES];
}	

-(void) cdcaDidFinishInitialising {
	//Default is to do nothing
}	

@end 

@implementation CDCAManager

static CDCA *_sharedCDCA = nil;

+ (CDCA *)sharedInstance
{
	if (!_sharedCDCA) {
		_sharedCDCA = [[CDCA alloc] init];
	}
	return _sharedCDCA;
}

@end