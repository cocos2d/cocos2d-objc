//
//  ObjectAL.h
//  ObjectAL
//
//  Created by Karl Stenerud on 15/12/09.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//

// Actions
#import "OALAction.h"
#import "OALAudioActions.h"
#import "OALUtilityActions.h"
#import "OALActionManager.h"

// AudioTrack
#import "OALAudioTrack.h"
#import "OALAudioTracks.h"
#import "OALAudioTrackNotifications.h"

// OpenAL
#import "ALTypes.h"
#import "ALBuffer.h"
#import "ALCaptureDevice.h"
#import "ALContext.h"
#import "ALDevice.h"
#import "ALListener.h"
#import "ALSource.h"
//#import "ALWrapper.h"
#import "ALChannelSource.h"
#import "ALSoundSourcePool.h"
#import "OpenALManager.h"
#import "OALAudioFile.h"

// Other
//#import "OALNotifications.h"
#import "OALAudioSession.h"
#import "OALSimpleAudio.h"



/** \mainpage ObjectAL for iPhone
 
 <strong>iOS Audio development, minus the headache.</strong> <br><br>
 
 Version 2.2 <br> <br>
 
 Copyright 2009-2013 Karl Stenerud <br><br>
 
 Released under the <a href="http://www.apache.org/licenses/LICENSE-2.0">Apache License v2.0</a>
 
 <br> <br>
 \section contents_sec Contents
 - \ref intro_sec
 - \ref objectal_and_openal_sec
 - \ref add_objectal_sec (also, installing the documentation into XCode)
 - \ref configuration_sec
 - \ref audio_formats_sec
 - \ref choosing_sec
 - \ref use_iossimpleaudio_sec
 - \ref use_objectal_sec
 - \ref other_examples_sec
 - \ref ios_issues_sec
 - \ref simulator_issues_sec
 
 
 <br> <br>
 \section intro_sec Introduction
 
 <strong>ObjectAL for iPhone</strong> is designed to be a simpler, more intuitive interface to
 OpenAL and AVAudioPlayer.
 There are four main parts to <strong>ObjectAL for iPhone</strong>:<br/><br/>
 
 \image html ObjectAL-Overview1.png
 \image latex ObjectAL-Overview1.eps

 - <a class="el" href="index.html#objectal_and_openal_sec">ObjectAL</a>
   gives you full access to the OpenAL system without the hassle of the C API.
   All OpenAL operations can be performed using first class objects and properties, without needing
   to muddle around with arrays of data, maintain IDs, or pass around pointers to basic types.
   ObjectALManager also provides sound loading routines.

 - OALAudioTrack provides a simpler interface to AVAudioPlayer, allowing you to play, stop,
   pause, fade, and mute background music tracks.
 
 - OALAudioSession handles audio session management in iOS devices, and provides an easy
   way to configure session behavior such as how to handle iPod-style music and the silent
   switch.
 
 - OALSimpleAudio layers on top of the other three, providing an even simpler interface for
   playing background music and sound effects.
  
 
 <br> <br>
 \section objectal_and_openal_sec ObjectAL and OpenAL
 
 <strong>ObjectAL</strong> follows the same basic principles as the
 <a href="http://connect.creativelabs.com/openal">OpenAL API by Creative Labs</a>.
 
 \image html ObjectAL-Overview2.png
 \image latex ObjectAL-Overview2.eps
 
 - OpenALManager provides some overall controls that affect everything, manages the current
   context, and provides audio loading routines.
 
 - ALDevice represents a physical audio device. <br>
   Each device can have one or more contexts (ALContext) created on it, and can have multiple
   buffers (ALBuffer) associated with it.

 - ALContext controls the overall sound environment, such as distance model, doppler effect, and
   speed of sound. <br>
   Each context has one listener (ALListener), and can have multiple sources (ALSource) opened on
   it (up to a maximum of 32 overall on iPhone).
 
 - ALListener represents the listener of sounds originating on its context (one listener per
   context). It has position, orientation, and velocity.
 
 - ALSource is a sound emitting source that plays sound data from an ALBuffer. It has position,
   direction, velocity, as well as other properties which determine how the sound is emitted.
 
 - ALChannelSource allows you to reserve a certain number of sources for special purposes.
 
 - ALBuffer is simply a container for sound data. Only linear PCM is supported directly, but
   OpenALManager load methods, and OALSimpleAudio effect preload and play methods, will
   automatically convert any formats that don't require hardware decoding (though conversion
   results in a longer loading time).
 
 <strong>Note:</strong> While OpenAL allows for multiple devices and contexts, in practice
 you'll only use one device and one context when using OpenAL under iOS.

 Further information regarding the more advanced features of OpenAL (such as distance models)
 are available via the
 <a href="http://connect.creativelabs.com/openal/Documentation/Forms/AllItems.aspx">
 OpenAL Documentation at Creative Labs</a>. <br>
 In particular, read up on the various property values for sources and listeners (such as Doppler
 Shift) in the
 <a href="http://connect.creativelabs.com/openal/Documentation/OpenAL_Programmers_Guide.pdf">OpenAL Programmer's Guide</a>,
 and distance models in section 3 of the
 <a href="http://connect.creativelabs.com/openal/Documentation/OpenAL%201.1%20Specification.pdf">OpenAL Specification</a>.
 
 
 <br> <br>
 \section add_objectal_sec Adding ObjectAL to your project
 
 To add ObjectAL to your project, do the following:

 <ol>
	<li>Copy ObjectAL/ObjectAL from this project into your project.
        You can simply drag it into the "Groups & Files" section in xcode if you
        like (be sure to select "Copy items into destination group's folder"). <br/>
		Alternatively, you can build ObjectAL as a static library (as it's configured to do in the
		ObjectAL demo project).<br/><br/>
	</li>

	<li>Add the following frameworks to your project:
		<ul>
			<li>OpenAL.framework</li>
			<li>AudioToolbox.framework</li>
			<li>AVFoundation.framework</li>
		</ul><br/>
	</li>
 
	<li>Start using ObjectAL!<br/><br/></li>
 </ol>
 <br/>
 <strong>Note:</strong> The demos in this project use
 <a href="http://www.cocos2d-iphone.org">Cocos2d</a>, a very nice 2d game engine. However,
 ObjectAL doesn't require it. You can just as easily use ObjectAL in your Cocoa app or anything
 you wish.
 <br/> <br/>
 <strong>Note #2:</strong> You do NOT have to provide a link to the Apache license from within your
 application. Simply including a copy of the license in your project is sufficient.

 <br>
 \subsection install_dox Installing the ObjectAL Documentation into XCode
 
 By installing the ObjectAL documentation into XCode's Developer Documentation system, you gain
 the ability to look up ObjectAL classes and methods just like you'd look up Apple classes and
 methods. You can install the ObjectAL documentation into XCode's Developer Documentation
 system by doing the following: 
 -# Install <a href="http://www.doxygen.org">Doxygen</a>. You can either use the OSX installer or
    <a href="http://mxcl.github.io/homebrew/">Homebrew</a>.
 -# Build the "Documentation" target in this project.
 -# Open the developer documentation and type "ObjectAL" into the search box.
 
 
 <br> <br>
 \section configuration_sec Compile-Time Configuration
 
 <strong>ObjectALConfig.h</strong> contains configuration defines that will affect at a high level
 how ObjectAL behaves. Look inside <strong>ObjectALConfig.h</strong> to see what can be
 configured, and what each configuration value does. <br>
 The recommended values are fine for most users, but Cocos2D users may want to set
 OBJECTAL_CFG_USE_COCOS2D_ACTIONS so that the audio actions (such as fade) use the Cocos2D action manager.
 
 
 <br> <br>
 \section audio_formats_sec Audio Formats
 
 The audio formats officially supported by Apple are
 <a href="http://developer.apple.com/library/ios/#documentation/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html">
 defined here</a>.
 <br><br>
 
 \subsection audio_formats_avaudioplayer OALAudioTrack Supported Formats
 
 OALAudioTrack supports all hardware and software decoded formats.
 <br><br>
 
 \subsection audio_formats_openal OpenAL Supported Formats
 
 OpenAL officially supports 8 or 16 bit PCM data only. However, Apple's implementation
 only seems to work with 16 bit data. <br>
 
 The effects preloading/playing methods in OALSimpleAudio and the buffer loading methods
 in OpenALManager can load any audio file that can be software decoded. However, there
 is a cost incurred at load time converting to a native OpenAL format. To avoid this,
 convert all of your samples to a CAFF container with 16-bit little endian integer PCM
 format and the same sample rate as "mixerOutputFrequency" in OpenALManager
 (by default, 44100Hz). Note, however, that uncompressed files can get quite large.<br>
 
 Convert to iOS native uncompressed format using Apple's "afconvert" command line tool:
 
 \code afconvert -f caff -d LEI16@44100 sourcefile.wav destfile.caf \endcode
 
 Alternatively, if sound file load time is not an issue for you, you can lower your app
 footprint size (for over-the-air app download) by using a compressed format. <br>
 
 Convert to AAC compressed format with CAFF container using Apple's "afconvert" command
 line tool:
 
 \code afconvert -f caff -d aac sourcefile.wav destfile.caf \endcode
 
 
 <br> <br>
 \section choosing_sec Choosing Playback Types
 
 <strong>OpenAL</strong> (ALSource, or effects in OALSimpleAudio) and
 <strong>AVAudioPlayer</strong> (OALAudioTrack, or background audio in OALSimpleAudio)
 are playback technologies built for different purposes. OpenAL is designed for game-style
 short sound effects that have no playback delay. AVAudioPlayer is designed for music
 playback. You can of course mix and match as you please.
 
 <table>
   <tr>
     <td></td>
     <td><strong>OpenAL</strong></td>
     <td><strong>AVAudioPlayer</strong></td>
   </tr>
   <tr>
     <td><strong>Playback Delay</strong></td>
     <td>None</td>
     <td>Small delay if not preloaded</td>
   </tr>
   <tr>
     <td><strong>Format on Disk</strong></td>
     <td><a href="http://developer.apple.com/library/ios/#documentation/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html">
		 Any software decodable format</a></td>
     <td><a href="http://developer.apple.com/library/ios/#documentation/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html">
         Any software decodable format, or any hardware format if using hardware</a></td>
   </tr>
   <tr>
     <td><strong>Decoding</strong></td>
     <td>During load</td>
     <td>During playback</td>
   </tr>
   <tr>
     <td><strong>Memory Use</strong></td>
     <td>Entire file loaded and decompressed into memory</td>
     <td>File streamed realtime (very low memory use)</td>
   </tr>
   <tr>
     <td><strong>Max Simult. Sources</strong></td>
     <td>32</td>
     <td>As many as the CPU can handle</td>
   </tr>
   <tr>
     <td><strong>Playback Performance</strong></td>
     <td>Good</td>
     <td>Excellent with 1 track (if using hardware). Good with 2 tracks. Not so good with more
         (each non-hardware track taxes the CPU significantly, especially if the files are compressed).</td>
   </tr>
   <tr>
     <td><strong>Looped Playback</strong></td>
     <td>Yes (on or off)</td>
     <td>Yes (specify number of loops or -1 = forever)</td>
   </tr>
 <tr>
     <td><strong>Panning</strong></td>
     <td>Yes (mono files only)</td>
     <td>Yes (iOS 4.0+ only)</td>
   </tr>
   <tr>
     <td><strong>Positional Audio</strong></td>
     <td>Yes (mono files only)</td>
     <td>No</td>
   </tr>
   <tr>
     <td><strong>Modify Pitch</strong></td>
     <td>Yes</td>
     <td>No</td>
   </tr>
   <tr>
     <td><strong>Audio Power Metering</strong></td>
     <td>No</td>
     <td>Yes</td>
   </tr>
 </table>
 

 <br> <br>
 \section use_iossimpleaudio_sec Using OALSimpleAudio
 
 By far, the easiest component to use is OALSimpleAudio. You sacrifice some power for
 ease-of-use, but for many projects it is more than sufficient. You can also use your own instances
 of OALAudioTrack, ALSource, ALBuffer and such alongside of OALSimpleAudio if you want (just be sure
 to set OALSimpleAudio's reservedSources to less than 32 if you want to make your own instances of
 ALSource).
 
 Here is a code example using purely OALSimpleAudio:
 
 \code
// OALSimpleAudioSample.h

@interface OALSimpleAudioSample : NSObject
{
	// No objects to keep track of...
}

@end


// OALSimpleAudioSample.m

#import "OALSimpleAudioSample.h"
#import "ObjectAL.h"


#define SHOOT_SOUND @"shoot.caf"
#define EXPLODE_SOUND @"explode.caf"

#define INGAME_MUSIC_FILE @"bg_music.mp3"
#define GAMEOVER_MUSIC_FILE @"gameover_music.mp3"


@implementation OALSimpleAudioSample

- (id) init
{
	if(nil != (self = [super init]))
	{
		// We don't want ipod music to keep playing since
		// we have our own bg music.
		[OALSimpleAudio sharedInstance].allowIpod = NO;
		
		// Mute all audio if the silent switch is turned on.
		[OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
		
		// This loads the sound effects into memory so that
		// there's no delay when we tell it to play them.
		[[OALSimpleAudio sharedInstance] preloadEffect:SHOOT_SOUND];
		[[OALSimpleAudio sharedInstance] preloadEffect:EXPLODE_SOUND];
	}
	return self;
}

- (void) onGameStart
{
	// Play the BG music and loop it.
	[[OALSimpleAudio sharedInstance] playBg:INGAME_MUSIC_FILE loop:YES];
}

- (void) onGamePause
{
	[OALSimpleAudio sharedInstance].paused = YES;
}

- (void) onGameResume
{
	[OALSimpleAudio sharedInstance].paused = NO;
}

- (void) onGameOver
{
	// Could use stopEverything here if you want
	[[OALSimpleAudio sharedInstance] stopAllEffects];
	
	// We only play the game over music through once.
	[[OALSimpleAudio sharedInstance] playBg:GAMEOVER_MUSIC_FILE];
}

- (void) onShipShotABullet
{
	[[OALSimpleAudio sharedInstance] playEffect:SHOOT_SOUND];
}

- (void) onShipGotHit
{
	[[OALSimpleAudio sharedInstance] playEffect:EXPLODE_SOUND];
}

- (void) onQuitToMainMenu
{
	// Stop all music and sound effects.
	[[OALSimpleAudio sharedInstance] stopEverything];	
	
	// Unload all sound effects and bg music so that it doesn't fill
	// memory unnecessarily.
	[[OALSimpleAudio sharedInstance] unloadAllEffects];
}

@end
 \endcode
 
 
 <br> <br>
 \section use_objectal_sec Using the OpenAL Objects and OALAudioTrack
 
 The OpenAL objects and OALAudioTrack offer you much more power at the cost
 of complexity.
 Here's the same thing as above, done using OpenAL components and OALAudioTrack:
 
 \code
// OpenALAudioTrackSample.h

#import <Foundation/Foundation.h>
#import "ObjectAL.h"


@interface OpenALAudioTrackSample : NSObject
{
	// Sound Effects
	ALDevice* device;
	ALContext* context;
	ALChannelSource* channel;
	ALBuffer* shootBuffer;	
	ALBuffer* explosionBuffer;
	
	// Background Music
	OALAudioTrack* musicTrack;
}

@end


// OpenALAudioTrackSample.m

#import "OpenALAudioTrackSample.h"


#define SHOOT_SOUND @"shoot.caf"
#define EXPLODE_SOUND @"explode.caf"

#define INGAME_MUSIC_FILE @"bg_music.mp3"
#define GAMEOVER_MUSIC_FILE @"gameover_music.mp3"


@implementation OpenALAudioTrackSample

- (id) init
{
	if(nil != (self = [super init]))
	{
		// Create the device and context.
		// Note that it's easier to just let OALSimpleAudio handle
		// these rather than make and manage them yourself.
		device = [[ALDevice deviceWithDeviceSpecifier:nil] retain];
		context = [[ALContext contextOnDevice:device attributes:nil] retain];
		[OpenALManager sharedInstance].currentContext = context;
		
		// Deal with interruptions for me!
		[OALAudioSession sharedInstance].handleInterruptions = YES;
		
		// We don't want ipod music to keep playing since
		// we have our own bg music.
		[OALAudioSession sharedInstance].allowIpod = NO;
		
		// Mute all audio if the silent switch is turned on.
		[OALAudioSession sharedInstance].honorSilentSwitch = YES;
		
		// Take all 32 sources for this channel.
		// (we probably won't use that many but what the heck!)
		channel = [[ALChannelSource channelWithSources:32] retain];
		
		// Preload the buffers so we don't have to load and play them later.
		shootBuffer = [[[OpenALManager sharedInstance]
						bufferFromFile:SHOOT_SOUND] retain];
		explosionBuffer = [[[OpenALManager sharedInstance]
							bufferFromFile:EXPLODE_SOUND] retain];
		
		// Background music track.
		musicTrack = [[OALAudioTrack track] retain];
	}
	return self;
}

- (void) dealloc
{
	[musicTrack release];
	
	[channel release];
	[shootBuffer release];
	[explosionBuffer release];
	
	// Note: You'll likely only have one device and context open throughout
	// your program, so in a real program you'd be better off making a
	// singleton object that manages the device and context, rather than
	// allocating/deallocating it here.
	// Most of the demos just let OALSimpleAudio manage the device and context
	// for them.
	[context release];
	[device release];
	
	[super dealloc];
}

- (void) onGameStart
{
	// Play the BG music and loop it forever.
	[musicTrack playFile:INGAME_MUSIC_FILE loops:-1];
}

- (void) onGamePause
{
	musicTrack.paused = YES;
	channel.paused = YES;
}

- (void) onGameResume
{
	channel.paused = NO;
	musicTrack.paused = NO;
}

- (void) onGameOver
{
	[channel stop];
	[musicTrack stop];
	
	// We only play the game over music through once.
	[musicTrack playFile:GAMEOVER_MUSIC_FILE];
}

- (void) onShipShotABullet
{
	[channel play:shootBuffer];
}

- (void) onShipGotHit
{
	[channel play:explosionBuffer];
}

- (void) onQuitToMainMenu
{
	// Stop all music and sound effects.
	[channel stop];
	[musicTrack stop];
}

@end
 \endcode
 
 
 
 <br> <br>
 \section other_examples_sec Other Examples
 
 The demo scenes in this distribution have been crafted to demonstrate common uses of this library.
 Try them out and go through the code to see how it's done. I've done my best to keep the code
 readable. Really!
 
 You can try out the demos by building and running the OALDemo target for iOS or OSX.
 
 The current demos are:
 - <strong>SingleSourceDemo</strong>: Demonstrates using a location based source and a listener.
 - <strong>TwoSourceDemo</strong>: Demonstrates using two location based sources and a listener.
 - <strong>VolumePitchPanDemo</strong>: Demonstrates using gain, pitch, and pan controls.
 - <strong>CrossFadeDemo</strong>: Demonstrates crossfading between two sources.
 - <strong>ChannelsDemo</strong>: Demonstrates using audio channels.
 - <strong>FadeDemo</strong>: Demonstrates realtime fading with OALAudioTrack and ALSource.
 - <strong>AudioTrackDemo</strong>: Demonstrates using multiple OALAudioTrack objects.
 - <strong>PlanetKillerDemo</strong>: Demonstrates using OALSimpleAudio in a game setting.
 - <strong>IntroAndMainTrackDemo</strong>: Demonstrates a short intro track followed by a main loop track.
 - <strong>SourceNotificationsDemo</strong>: Demonstrates using OpenAL playback notifications.
 - <strong>HardwareDemo</strong>: Demonstrates hardware monitoring features.
 - <strong>AudioSessionDemo</strong>: Allows you to play with various audio session settings.

 
 
 <br> <br>
 \section ios_issues_sec iOS Issues that can impede playback
 
 Certain versions of iOS have bugs or quirks, requiring workarounds. ObjectAL tries to handle
 most of these automatically, but there are cases that require specific handling by the developer.
 These are:

 <br>
 \subsection mpmovieplayercontroller_ios3 MPMoviePlayerController on iOS 3.x
 
 In iOS 3.x, MPMoviePlayerController doesn't play nice, and takes over the audio session when
 you play a video. In order to mitigate this, you must manually suspend OpenAL, play the video,
 and then manually unsuspend once video playback finishes:
 
 \code
- (void) playVideo
{	
	if([myMoviePlayer respondsToSelector:@selector(view)])
	{
		[myMoviePlayer setFullscreen:YES animated:YES];
	}
	else
	{
		// No "view" method means we are < 4.0
		// Manually suspend so iOS 3.x doesn't clobber our session!
		[OpenALManager sharedInstance].manuallySuspended = YES;
	}

	[myMoviePlayer play];
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(movieFinishedCallback:)
	 name:MPMoviePlayerPlaybackDidFinishNotification
	 object:myMoviePlayer];
}

-(void)movieFinishedCallback:(NSNotification *)notification
{
	if([myMoviePlayer respondsToSelector:@selector(view)])
	{
		if (myMoviePlayer.fullscreen)
		{
			[myMoviePlayer setFullscreen:NO animated:YES];
		}
	}
	else
	{
		// No "view" method means we are < 4.0
		// Manually unsuspend
		[OpenALManager sharedInstance].manuallySuspended = NO;
	}
}
 \endcode
 <br>
 \subsection mpmusicplayercontroller_ios4_0 MPMusicPlayerController on iOS 4.0

 On iOS 4.0, MPMusicPlayerController sends an interrupt when it begins playback, but doesn't send
 a corresponding "end interrupt" when it ends. To work around this, force an "end interrupt"
 after starting playback:
 \code
	[[OALAudioSession sharedInstance] forceEndInterruption];
 \endcode

 
 
 <br> <br>
 \section simulator_issues_sec Simulator Issues
 
 As you've likely heard time and time again, the simulator is no substitute for the real thing.
 The simulator is buggy. It can run faster or slower than a real device. It fails system calls
 that a real device doesn't. It shows graphics glitches that a real device doesn't. Sounds stop
 working, clicks and static, dogs and cats living together, etc, etc.
 When things look wrong, try it on a real device before bugging people.
 
 
 <br>
 \subsection simulator_limitations Simulator Limitations
 
 The simulator does not support setting audio modes, so setting allowIpod or honorSilentSwitch
 in OALAudioSession will have no effect in the simulator.
 
 
 <br>
 \subsection simulator_errors Error Codes on the Simulator
 
 From time to time, the simulator can get confused, and start spitting out spurious errors.
 When this happens, check on a real device to make sure it's not just a simulator issue.
 Usually quitting and restarting the simulator will fix it, but sometimes you may have to reboot
 your machine as well.
 
 
 <br>
 \subsection simulator_playback Playback Issues
 
 The simulator is notoriously finicky when it comes to audio playback. Any number of programs
 you've installed on your mac can cause the simulator to stop playing bg music, or effects, or
 both!
 
 Some things to check when sound stops working:
 - Try resetting and restarting the simulator.
 - Try restarting XCode, cleaning, and recompiling your project.
 - Try rebooting your computer.
 - Open "Audio MIDI Setup" (type "midi" into spotlight to find it) and make sure "Built-in Output"
 is set to 44100.0 Hz.
 - Go to System Preferences -> Sound -> Output, and ensure that "Play sound effects through" is set
   to "Internal Speakers"
 - Go to System Preferences -> Sound -> Input, and ensure that it is using internal sound devices.
 - Go to System Preferences -> Sound -> Sound Effects, and ensure "Play user interface sound
   effects" is checked.
 - Some codecs may cause problems with sound playback. Try removing them.
 - Programs that redirect audio can wreak havoc on the simulator. Try removing them.
 
*/
