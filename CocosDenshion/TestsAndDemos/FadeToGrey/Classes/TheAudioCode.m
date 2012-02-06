/**
 Tests for showing how to use fading with SimpleAudioEngine sound effects and background music.
 NB: on the simulator resetting takes a long time ~2 minutes and background music does not function properly.
 It is best to test on a device.
 */
#import "TheAudioCode.h"
#import "CCActionManager.h"

@implementation TheAudioCode

BOOL fadingOut;

-(id) init
{
	CDLOG(@">> Audio tests init");

	if( (self=[super init] )) {
		//Get a pointer to the sound engine
		sae = [SimpleAudioEngine sharedEngine];
		[[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];

		CCDirector *director = [CCDirector sharedDirector];
		actionManager = [director actionManager];

		//Test preloading two of our files, this will have no performance effect. In reality you would
		//probably do this during start up
		[sae preloadEffect:@"dp1.caf"];
		[sae preloadEffect:@"dp2.caf"];
		[sae preloadBackgroundMusic:@"bgm.mp3"];

		//Get sound sources for our files, we must retain them if we want to use them
		//outside this method.
		sound1 = [[sae soundSourceForFile:@"dp3.caf"] retain];
		sound2 = [[sae soundSourceForFile:@"dp1.caf"] retain];
		sound3 = [[sae soundSourceForFile:@"dp2.caf"] retain];
		CDLOG(@"Sound 1 duration %0.4f",sound1.durationInSeconds);

		//Used in test 3
		fadingOut = YES;
		sound3.gain = 0.0f;

		//Used in test 1
		sourceFader = [[CDSoundSourceFader alloc] init:sound1 interpolationType:kIT_SCurve startVal:1.0f endVal:0.0f];
		[sourceFader setStopTargetWhenComplete:YES];
		//Create a property modifier action to wrap the fader
		faderAction = [CDXPropertyModifierAction actionWithDuration:1.0f modifier:sourceFader];
		[faderAction retain];
		return self;
	}
	return self;
}

//NB: this dealloc is completely shutting down the audio system. It is used for testing for memory leaks.
//in practice you would most likely only release everything when your app terminates.
-(void) dealloc {
	//Stop any actions we may have started
	[actionManager removeAllActionsFromTarget:sound1];
	[actionManager removeAllActionsFromTarget:sound2];
	[actionManager removeAllActionsFromTarget:sound3];
	//This is to stop any actions that may be modifying the background music
	[actionManager removeAllActionsFromTarget:[[CDAudioManager sharedManager] audioSourceForChannel:kASC_Left]];
	//This is to stop any actions that may be running against the sound engine i.e. fade sound effects
	[actionManager removeAllActionsFromTarget:[CDAudioManager sharedManager].soundEngine];

	//Release all our retained objects
	[sound1 release];
	[sound2 release];
	[sound3 release];

	[sourceFader release];
	[faderAction release];
	//Tell the simple audio engine to shutdown
	[SimpleAudioEngine end];
	sae = nil;
	[super dealloc];
}

/**
 This test shows how to do a fade with a reused action and property modifier. The action and property modifier are created
 in the init and not released until this class is deallocated. This technique is useful in high performance situations where
 a sound is triggered frequently as it eliminates memory allocations and deallocations that would otherwise occur.
 */
-(void) testOne:(id) sender {
	CDLOG(@">>Test one");
	sound1.looping = YES;
	sound1.gain = 1.0f;
	[sound1 play];
	//Stop any actions that may already be running on our target
	[actionManager removeAllActionsFromTarget:sound1];
	//If these values haven't changed you don't have to set them again, this code is just to illustrate
	//that the property modifier's properties can be altered (except for its target)
	sourceFader.startValue = sound1.gain;
	sourceFader.endValue = 0.0f;
	sourceFader.stopTargetWhenComplete = YES;
	//Re-initialise the fader action, if you don't do this then the elapsed time won't be reset
	[faderAction initWithDuration:1.0f modifier:sourceFader];
	//Now just run our action.
	[actionManager addAction:faderAction target:sound1 paused:NO];
}

/**
 This test shows how to use the convenience method fadeSoundEffect to fade out a sound effect. It will result in a
 property modifier object and action being allocated and then deallocated when the fade finishes.
 As you can see it is much simpler than resuing the action and modifier as was done in testOne.
 Note that the sound effect will be stopped when the fade finishes.
 */
-(void) testTwo:(id) sender {
	CDLOG(@">>Test two");
	sound2.looping = YES;
	sound2.gain = 0.0f;
	[sound2 play];
	[CDXPropertyModifierAction fadeSoundEffect:2.0f finalVolume:1.0f curveType:kIT_SCurve shouldStop:YES effect:sound2];
}

/**
 This test alternates between fading a sound in and out using the convenience method fadeSoundEffect.
 Note that the sound does not stop when the fade in finishes, as would be normal but stops after the fade out.
 */
-(void) testThree:(id) sender {
	CDLOG(@">>Test three");
	//Stop any actions currently running
	CCDirector *director = [CCDirector sharedDirector];

	[[director actionManager] removeAllActionsFromTarget:sound3];
	if (!fadingOut) {
		//Fade it out
		[CDXPropertyModifierAction fadeSoundEffect:1.0f finalVolume:0.0f curveType:kIT_Linear shouldStop:YES effect:sound3];
	} else {
		//Fade it in
		sound3.looping = YES;
		[sound3 play];
		[CDXPropertyModifierAction fadeSoundEffect:1.0f finalVolume:1.0f curveType:kIT_Linear shouldStop:NO effect:sound3];
	}
	fadingOut = !fadingOut;
}

/**
 This test is a stress test, it rapidly plays back enough sounds to exhaust the number of allocated sources/voices.
 To perform the test some other audio should be running, the easiest thing is to run testThree and then run this.
 The audio generated by testThree should not cut out.
 */
-(void) testFour:(id) sender {
	CDLOG(@">>Test four");
	[sae playEffect:@"dp1.caf" pitch:0.5f pan:0.0f gain:1.0f];
	//Test locking
	float pitch = 2.0f;
	for (int i = 0; i < 32; i++) {
//		ALuint played =
		[sae playEffect:@"dp4.caf" pitch:pitch pan:0.0f gain:0.1f];
		//CDLOG(@"-->Played %i",played);
		pitch -= 1.5f/32.0f;
	}
}

/**
 Test fading out of background music. The test toggles between starting the music with no fade and fading it out.
 */
-(void) testFive:(id) sender {

	CDLOG(@">>Test five");
	if (![sae isBackgroundMusicPlaying]) {
		CDLOG(@">> Background music is not playing");
		[sae setBackgroundMusicVolume:1.0f];
		[sae rewindBackgroundMusic];
		[sae playBackgroundMusic:@"bgm.mp3"];
	} else {
		[CDXPropertyModifierAction fadeBackgroundMusic:2.0f finalVolume:0.0f curveType:kIT_Exponential shouldStop:YES];
	}

	//CDLOG(@">>Will play background music? %i",[[CDAudioManager sharedManager] willPlayBackgroundMusic]);
}

/**
 Test fading out sound effects. The volume of the audio of tests 1-4 will be modified but the background
 music must not be modified.  Beware that if you have faded out the sound effects then test 1-4 will not
 be audible.
 */
-(void) testSix:(id) sender {
	CDLOG(@">>Test six");
	if (sae.effectsVolume < 0.5f) {
		//Fade in
		[CDXPropertyModifierAction fadeSoundEffects:2.0f finalVolume:1.0f curveType:kIT_Linear shouldStop:NO];
	} else {
		//Fade out
		[CDXPropertyModifierAction fadeSoundEffects:2.0f finalVolume:0.0f curveType:kIT_Linear shouldStop:NO];
	}
}

/**
 Test unloading effects
 */
-(void) testSeven:(id) sender {
	[sae unloadEffect:@"dp1.caf"];
	[sae unloadEffect:@"dp2.caf"];
	//Try loading a non existant file
	[sae preloadEffect:@"nosuchfile.caf"];
	[sae preloadEffect:@"dp1.caf"];
	[sae playEffect:@"dp1.caf"];
}





/**
 Test fading out of a background music and starting another with fadein issue-1304
 */
-(void) testEight:(id) sender {

	CDLOG(@">>Test Eight");
	if (![sae isBackgroundMusicPlaying]) {
		CDLOG(@">> Background music is not playing");
		[sae setBackgroundMusicVolume:1.0f];
		[sae rewindBackgroundMusic];
		[sae playBackgroundMusic:@"bgm.mp3"];
	} else {


		CDLongAudioSource *player = [[CDAudioManager sharedManager] audioSourceForChannel:kASC_Left];
		CDLongAudioSourceFader* faderout = [[CDLongAudioSourceFader alloc] init:player interpolationType:kIT_Linear startVal:player.volume endVal:0.0f];
		[faderout setStopTargetWhenComplete:YES];
		//Create a property modifier action to wrap the fader 
		CDXPropertyModifierAction* fadeoutaction = [CDXPropertyModifierAction actionWithDuration:4 modifier:faderout];
		[faderout release];//Action will retain

		CDLongAudioSourceFader* faderin = [[CDLongAudioSourceFader alloc] init:player interpolationType:kIT_Linear startVal:0 endVal:1];
		[faderin setStopTargetWhenComplete:NO];
		CDXPropertyModifierAction* faderinaction = [CDXPropertyModifierAction actionWithDuration:4 modifier:faderin];
		[faderin release];



		CCSequence * action =[CCSequence actions:
							  fadeoutaction,
							  [CCCallFuncO actionWithTarget:sae selector:@selector(playBackgroundMusic:) object:@"Cyber Advance!.mp3"],
							  faderinaction,
							  Nil];

		
		CCActionManager *actionMgr = [[CCDirector sharedDirector] actionManager];
		[actionMgr addAction:action target:player paused:NO];

	}
}


@end
