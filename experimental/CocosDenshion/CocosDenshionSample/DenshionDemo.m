//
/* CocosDenshion Demo
 *
 * Copyright (C) 2009 Steve Oldmeadow
 *
 * Demonstration of how to use the CocosDenshion sound engine.
 * Based on cocos2d for iphone .72RC
 *
 * You can do anything you like with this software except using it
 * as the basis for a flatulence related application ;)  However,
 * any use of the CocosDenshion sound engine must comply with the
 * license for that.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 */

#import "DenshionDemo.h"
#import "ccMacros.h"

///////////////////////////////////////////////////////
//Sound ids, these equate to buffer identifiers
//which are 0 indexed and sequential.  You do not have
//to use all the identifiers but an exception will be
//thrown if you specify an identifier that is greater 
//than or equal to the total number of buffers
#define SND_ID_TONELOOP 0
#define SND_ID_DRUMLOOP 1
#define SND_ID_BALL 2
#define SND_ID_GUN 3
#define SND_ID_STAB 4
#define SND_ID_COWBELL 5
#define SND_ID_EXPLODE 6
#define SND_ID_KARATE 7

//Channel group ids, the channel groups define how voices
//will be shared.  If you wish you can simply have a single
//channel group and all sounds will share all the voices
#define CGROUP_DRUMLOOP 0
#define CGROUP_TONELOOP 1
#define CGROUP_DRUM_VOICES 2
#define CGROUP_FX_VOICES 3
#define CGROUP_NON_INTERRUPTIBLE 4

#define CGROUP_TOTAL 5
///////////////////////////////////////////////////////

#define SLIDER_POS_MAX 300.0f
#define SLIDER_POS_MIN 20.0f
#define SLIDER_POS_X 79.0f

#define PFC_X 317
#define PFC_Y 165
#define PFO_X 112
#define PFO_Y 108

#define FLASH_FADE_TOTAL 10
#define PAD_SLIDER_DIVISION 160

int touchedPads;
int flashFade[FLASH_FADE_TOTAL] = {255,200,180,150,130,110,100,90,80,50};
int flashIndex[FLASH_FADE_TOTAL];
BOOL toneLoopPlaying;
ALuint toneLoopSourceId;
CDSourceWrapper *toneSource;

@implementation DenshionLayer
-(id) init
{
	[super init];
	
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	Sprite* bg = [Sprite spriteWithFile:@"bg.png"];
	[bg setPosition:CGPointMake(480/2, 320/2)]; 
	[self addChild:bg ];
	
	slider = [Sprite spriteWithFile:@"slider.png"];
	[slider setPosition:CGPointMake(SLIDER_POS_X, ((SLIDER_POS_MAX - SLIDER_POS_MIN)/2) + SLIDER_POS_MIN)]; 
	[slider setRotation:180.0f];
	[slider retain];
	[self addChild:slider];
	
	//This is related to setting up the flashes that appear when a pad is hit
	int flashLocations[9][2] = {{PFC_X - PFO_X,PFC_Y - PFO_Y},{PFC_X,PFC_Y - PFO_Y},{PFC_X + PFO_X,PFC_Y - PFO_Y},
								{PFC_X - PFO_X,PFC_Y},{PFC_X,PFC_Y},{PFC_X + PFO_X,PFC_Y},
								{PFC_X - PFO_X,PFC_Y + PFO_Y},{PFC_X,PFC_Y + PFO_Y},{PFC_X + PFO_X,PFC_Y + PFO_Y}};

		
	padFlashes = [[NSMutableArray alloc] init];
	for (int i=0; i < 9; i++) {
		Sprite *flash = [Sprite spriteWithFile:@"flash.png"];
		[flash retain];
		[flash setPosition:CGPointMake(flashLocations[i][0],flashLocations[i][1])];
		flash.opacity = 128;
		flash.visible = FALSE;
		[padFlashes addObject:flash];
		[self addChild:flash];
	}
	
	for (int i=0; i < FLASH_FADE_TOTAL; i++) {
		flashIndex[i] = FLASH_FADE_TOTAL;//Use total as a sentinel value
	}	
	
	am = nil;
	soundEngine = nil;
		
	if ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
		//The audio manager is not initialised yet so kick off the sound loading as an NSOperation that will wait for
		//the audio manager
		NSInvocationOperation* bufferLoadOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadSoundBuffers:) object:nil] autorelease];
		NSOperationQueue *opQ = [[[NSOperationQueue alloc] init] autorelease]; 
		[opQ addOperation:bufferLoadOp];
		_appState = kAppStateAudioManagerInitialising;
	} else {
		[self loadSoundBuffers:nil];
		_appState = kAppStateSoundBuffersLoading;
	}	
	
	isTouchEnabled = YES;
	toneLoopPlaying = NO;
	toneSource = [[CDSourceWrapper alloc] init];
	[toneSource retain];
	[self schedule: @selector(tick:)];
	return self;
}

-(void) loadSoundBuffers:(NSObject*) data {
	
	//Wait for the audio manager if it is not initialised yet
	while ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
		[NSThread sleepForTimeInterval:0.1];
	}	
	

	//Load the buffers with audio data. There is no correspondence between voices/channels and
	//buffers.  For example you can play the same sound in multiple channel groups with different
	//pitch, pan and gain settings.
	//Buffers can be loaded with different sounds simply by calling loadBuffer again, however,
	//any sources attached to the buffer will be stopped if they are currently playing
	//Use: afconvert -f caff -d ima4 yourfile.wav to create an ima4 compressed version of a wave file
	CDSoundEngine *sse = [CDAudioManager sharedManager].soundEngine;
	
	//Code for loading buffers synchronously
	/*
	[sse loadBuffer:SND_ID_DRUMLOOP fileName:@"808_120bpm" fileType:@"caf"];
	[sse loadBuffer:SND_ID_TONELOOP fileName:@"sine440" fileType:@"caf"];
	[sse loadBuffer:SND_ID_BALL fileName:@"ballbounce" fileType:@"wav"];
	[sse loadBuffer:SND_ID_GUN fileName:@"machinegun" fileType:@"caf"];
	[sse loadBuffer:SND_ID_STAB fileName:@"rustylow" fileType:@"wav"];
	[sse loadBuffer:SND_ID_COWBELL fileName:@"cowbell" fileType:@"wav"];
	[sse loadBuffer:SND_ID_EXPLODE fileName:@"explodelow" fileType:@"wav"];
	[sse loadBuffer:SND_ID_KARATE fileName:@"karate" fileType:@"wav"];
	*/
	
	//Load sound buffers asynchrounously
	NSMutableArray *loadRequests = [[[NSMutableArray alloc] init] autorelease];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_DRUMLOOP fileName:@"808_120bpm.caf"] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_TONELOOP fileName:@"sine440.caf"] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_BALL fileName:@"ballbounce.wav"] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_GUN fileName:@"machinegun.caf"] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_STAB fileName:@"rustylow.wav"] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_COWBELL fileName:@"cowbell.wav"] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_EXPLODE fileName:@"explodelow.wav"] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_KARATE fileName:@"karate.wav"] autorelease]];
	[sse loadBuffersAsynchronously:loadRequests];
	_appState = kAppStateSoundBuffersLoading;
	
	//Sound engine is now set up. You can check the functioning property to see if everything worked.
	//In addition the loadBuffer method returns a boolean indicating whether it worked.
	//If your buffers loaded and the functioning = TRUE then you are set to play sounds.
	
}

-(void) tick: (ccTime) dt
{
	
	if (_appState == kAppStateReady) {
		am = [CDAudioManager sharedManager];
		soundEngine = am.soundEngine;

		float sliderValue = (((slider.position.y) - SLIDER_POS_MIN) / (SLIDER_POS_MAX - SLIDER_POS_MIN));// 0 to 1
		if (touchedPads > 0) {
			
			if ((touchedPads & (1 << 0)) != 0) {
				//Pad 1 touched - play a one shot kick sound in the drum voices channel group with normal pitch and pan and the
				//gain controlled by the slider
				[soundEngine playSound:SND_ID_BALL channelGroupId:CGROUP_DRUM_VOICES pitch:1.0f pan:0.0f gain:sliderValue loop:NO];
				flashIndex[0] = 0;
			}	
			
			if ((touchedPads & (1 << 1)) != 0) {
				//Pad 2 touched - play a one shot snare sound in the drum voices channel group with normal pitch and pan and the
				//gain controlled by the slider
				[soundEngine playSound:SND_ID_GUN channelGroupId:CGROUP_NON_INTERRUPTIBLE pitch:1.0f pan:0.0f gain:sliderValue loop:NO];
				flashIndex[1] = 0;
			}
			
			if ((touchedPads & (1 << 2)) != 0) {
				//Pad 3 touched - play a one shot hat sound in the drum voices channel group with normal pitch and pan and the
				//gain controlled by the slider
				[soundEngine playSound:SND_ID_STAB channelGroupId:CGROUP_FX_VOICES pitch:1.0f pan:((sliderValue * 2.0f) - 1.0f) gain:1.0f loop:NO];
				flashIndex[2] = 0;
			}
			
			if ((touchedPads & (1 << 3)) != 0) {
				//Pad 4 touched - play a one shot fx sound in the fx voices channel group with normal gain and pan and the
				//pitch controlled by the slider.  Slider mid point = normal pitch (1.0)
				[soundEngine playSound:SND_ID_EXPLODE channelGroupId:CGROUP_FX_VOICES pitch:sliderValue + 0.5f pan:0.0f gain:1.0f loop:NO];
				flashIndex[3] = 0;
			}
			
			if ((touchedPads & (1 << 4)) != 0) {
				//Pad 5 touched  - play a one shot fx sound in the fx voices channel group with normal gain and pan and the
				//pitch controlled by the slider.  Slider mid point = normal pitch (1.0)
				[soundEngine playSound:SND_ID_COWBELL channelGroupId:CGROUP_DRUM_VOICES pitch:sliderValue + 0.5f pan:0.0f gain:1.0f loop:NO];
				flashIndex[4] = 0;
			}

			if ((touchedPads & (1 << 5)) != 0) {
				//Pad 6 touched  - play a one shot fx sound in the fx voices channel group with normal pitch and gain and the
				//pan controlled by the slider.  Slider top = hard right, bottom = hard left, centre = middle
				[soundEngine playSound:SND_ID_KARATE channelGroupId:CGROUP_FX_VOICES pitch:1.0f pan:((sliderValue * 2.0f) - 1.0f) gain:1.0f loop:NO];
				flashIndex[5] = 0;
			}
			
			if ((touchedPads & (1 << 6)) != 0) {
				if (!toneSource.isPlaying) {
					//Pad 7 touched- play a looped sound with normal pitch, pan and gain in the loop channel group.
					//Any other sound playing in this channel group will be stopped as the group has only 1 voice.
					toneSource.sourceId = [am.soundEngine playSound:SND_ID_TONELOOP channelGroupId:CGROUP_TONELOOP pitch:1.0f pan:0.0f gain:1.0f loop:YES];
					toneLoopPlaying = YES;
				} else {
					[soundEngine stopSound:toneSource.sourceId];
					toneLoopPlaying = NO;
				}	
				
				flashIndex[6] = 0;
			}
			
			if ((touchedPads & (1 << 7)) != 0) {
				//Pad 8 touched - play a looped sound with normal pitch, pan and gain in the loop channel group.
				//Any other sound playing in this channel group will be stopped as the group has only 1 voice.
				[soundEngine playSound:SND_ID_DRUMLOOP channelGroupId:CGROUP_DRUMLOOP pitch:1.0f pan:0.0f gain:1.0f loop:YES];
				flashIndex[7] = 0;
			}

			if ((touchedPads & (1 << 8)) != 0) {
				//Pad 9 touched - stop all sounds in the loops channel group
				flashIndex[8] = 0;
				[soundEngine stopChannelGroup:CGROUP_DRUMLOOP];
				
				if (![am isBackgroundMusicPlaying]) {
					[am playBackgroundMusic:@"mula_tito_on_timbales.mp3" loop:FALSE];
				} else {
					[am pauseBackgroundMusic];
				}	
				
				//Play background music
				
				//Testing loading a buffer with a new sound
				//[soundEngine loadBuffer:SND_ID_TONELOOP fileName:@"bassloop" fileType:@"wav"];	
				
				//Testing deleting a buffer
				//[soundEngine unloadBuffer:SND_ID_KARATE];
				
				//Testing master gain setting
				//[soundEngine setMasterGain:sliderValue];
				
				//Testing mute feature
				//soundEngine.mute = !soundEngine.mute;

			}
		}	
		touchedPads = 0;
		
		if (toneLoopPlaying) {
			//Adjust pitch of tone loop to match slider - this technique can be used to adjust gain and pan too
			toneSource.pitch = sliderValue + 0.5f;
		}	
		
		//Update flashes
		for (int i=0; i < FLASH_FADE_TOTAL; i++) {
			 
			if (flashIndex[i] < FLASH_FADE_TOTAL) {
				Sprite *flash = [padFlashes objectAtIndex:i];
				if (flashIndex[i] == 0) {
					//Turn on visibility
					flash.visible = YES;
				} else if (flashIndex[i] == FLASH_FADE_TOTAL - 1) {
					//Turn off visibility
					flash.visible = NO;
				}	
				flash.opacity = flashFade[flashIndex[i]];
				flashIndex[i]++;
			}	
		}	
	} else if (_appState == kAppStateSoundBuffersLoading) {
		//Check if sound buffers have completed loading, asynchLoadProgress represents fraction of completion and 1.0 is complete.
		if ([CDAudioManager sharedManager].soundEngine.asynchLoadProgress >= 1.0f) {
			//Sounds have finished loading
			_appState = kAppStateReady;
			[[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)]; 
			[[CDAudioManager sharedManager].soundEngine setChannelGroupNonInterruptible:CGROUP_NON_INTERRUPTIBLE isNonInterruptible:TRUE];
		} else {
			//CCLOG(@"Denshion: sound buffers loading %0.2f",[CDAudioManager sharedManager].soundEngine.asynchLoadProgress);
		}	
	}	
	
}

- (void) backgroundMusicFinished {
	CCLOG(@"Denshion: backgroundMusicFinished selector called");
}	

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	NSArray *allTouches = [touches allObjects]; 
	for (UITouch *touch in allTouches) {
		CGPoint location = [touch locationInView: [touch view]];
		if (location.y < PAD_SLIDER_DIVISION) {
			//We are in the slider region
			if (location.x > SLIDER_POS_MAX) {
				[slider setPosition:CGPointMake(SLIDER_POS_X, SLIDER_POS_MAX)];	
			} else if (location.x < SLIDER_POS_MIN) {	
				[slider setPosition:CGPointMake(SLIDER_POS_X, SLIDER_POS_MIN)]; 
			} else {
				[slider setPosition:CGPointMake(SLIDER_POS_X, location.x)];
			}	
		} else {
			//We are in the pad region
			int col = (location.y - PAD_SLIDER_DIVISION) / (320/3);
			int row = (location.x / (320/3));
			
			touchedPads = touchedPads | (1 << ((row * 3) + col));
			//CCLOG(@"Pad touched %i %i %x", col,row,touchedPads);
		}	
	}
	
	return kEventHandled; 
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	//We are only interested in the slider for moving touches
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	if (location.y < PAD_SLIDER_DIVISION) {
		//We are in the slider region
		if (location.x > SLIDER_POS_MAX) {
			[slider setPosition:CGPointMake(SLIDER_POS_X, SLIDER_POS_MAX)];	
		} else if (location.x < SLIDER_POS_MIN) {	
			[slider setPosition:CGPointMake(SLIDER_POS_X, SLIDER_POS_MIN)]; 
		} else {
			[slider setPosition:CGPointMake(SLIDER_POS_X, location.x)];
		}	
	}
	return kEventHandled; 
}



-(void) dealloc
{
	
	for (Sprite *sprite in padFlashes) {
		[sprite release];
	}	
	
	[am release];
	[slider release];
	[toneSource release];
	[super dealloc];
}


-(void) onQuit: (id) sender
{
	
	[[Director sharedDirector] end];
	if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

-(void) setUpAudioManager:(NSObject*) data {
	
	//Channel groups define how voices are shared, the maximum number of voices is defined by 
	//CD_MAX_SOURCES in the CocosDenshion.h file
	//When a request is made to play a sound within a channel group the next available voice
	//is used.  If no voices are free then the least recently used voice is stopped and reused.
	int channelGroupCount = CGROUP_TOTAL;
	int channelGroups[CGROUP_TOTAL];
	channelGroups[CGROUP_DRUMLOOP] = 1;//This means only 1 loop will play at a time
	channelGroups[CGROUP_TONELOOP] = 1;//This means only 1 loop will play at a time
	channelGroups[CGROUP_DRUM_VOICES] = 8;//8 voices to be shared by the drums
	channelGroups[CGROUP_FX_VOICES] = 16;//16 voices to be shared by the fx
	channelGroups[CGROUP_NON_INTERRUPTIBLE] = 2;//2 voices that can't be interrupted
	
	//Initialise audio manager asynchronously as it can take a few seconds
	[CDAudioManager initAsynchronously:kAudioManagerFxPlusMusicIfNoOtherAudio channelGroupDefinitions:channelGroups channelGroupTotal:channelGroupCount];
}


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.multipleTouchEnabled = TRUE;
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeLeft];
	
	// show FPS
	[[Director sharedDirector] setDisplayFPS:NO];
	
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	
	
	// attach cocos2d to a window
	[[Director sharedDirector] attachInView:window];
	
	//Set up audio engine
	[self setUpAudioManager:nil];
	
	Scene *scene = [Scene node];
	
	[scene addChild: [DenshionLayer node]];
	
	[window makeKeyAndVisible];
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window dealloc];
	[super dealloc];
}

@end
