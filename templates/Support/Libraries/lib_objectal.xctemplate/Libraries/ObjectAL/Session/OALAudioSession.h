//
//  OALAudioSession.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-12-19.
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SynthesizeSingleton.h"
#import "OALSuspendHandler.h"


/**
 * Handles the audio session and interrupts.
 */
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface OALAudioSession : NSObject <AVAudioSessionDelegate, OALSuspendManager>
#else
@interface OALAudioSession : NSObject <OALSuspendManager>
#endif
{
    /** The current audio session category */
	NSString* audioSessionCategory;
    
    /** Flag signifying that we are currently handling an error notification.
     * This prevents onAudioError: from becoming reentrant due to
     * self.manuallySuspended setting off a chain of calls that result in
     * another error notification broadcast.
     */
    bool handlingErrorNotification;
	
	bool handleInterruptions;
	bool allowIpod;
	bool ipodDucking;
	bool useHardwareIfAvailable;
	bool honorSilentSwitch;
	
	bool audioSessionActive;
	
	/** If true, the audio session was active when the interrupt occurred. */
	bool audioSessionWasActive;
	
	/** Handles suspending and interrupting for this object. */
	OALSuspendHandler* suspendHandler;
	
	/** Marks the last time the audio session was reset due to error.
	 * This is used to avoid getting stuck in a rapid-fire reset-error loop.
	 */
	NSDate* lastResetTime;
}



#pragma mark Properties

/** The current audio session category.
 * If this value is explicitly set, the other session properties "allowIpod",
 * "useHardwareIfAvailable", "honorSilentSwitch", and "ipodDucking" may be modified
 * to remain compatible with the category.
 *
 * @see AVAudioSessionCategory
 *
 * Default value: nil
 */
@property(nonatomic,readwrite,retain) NSString* audioSessionCategory;

/** If YES, allow ipod music to continue playing (NOT SUPPORTED ON THE SIMULATOR).
 * Note: If this is enabled, and another app is playing music, background audio
 * playback will use the SOFTWARE codecs, NOT hardware. <br>
 *
 * If allowIpod = NO, the application will ALWAYS use hardware decoding. <br>
 *
 * @see useHardwareIfAvailable
 *
 * Default value: YES
 */
@property(nonatomic,readwrite,assign) bool allowIpod;

/** If YES, ipod music will duck (lower in volume) when the audio session activates.
 *
 * Default value: NO
 */
@property(nonatomic,readwrite,assign) bool ipodDucking;

/** Determines what to do if no other application is playing audio and allowIpod = YES
 * (NOT SUPPORTED ON THE SIMULATOR). <br>
 *
 * If NO, the application will ALWAYS use software decoding. The advantage to this is that
 * the user can background your application and then start audio playing from another
 * application. If useHardwareIfAvailable = YES, the user won't be able to do this. <br>
 *
 * If this is set to YES, the application will use hardware decoding if no other application
 * is currently playing audio. However, no other application will be able to start playing
 * audio if it wasn't playing already. <br>
 *
 * Note: This switch has no effect if allowIpod = NO. <br>
 *
 * @see allowIpod
 *
 * Default value: YES
 */
@property(nonatomic,readwrite,assign) bool useHardwareIfAvailable;

/** If true, mute when backgrounded, screen locked, or the ringer switch is
 * turned off (NOT SUPPORTED ON THE SIMULATOR). <br>
 *
 * Default value: YES
 */
@property(nonatomic,readwrite,assign) bool honorSilentSwitch;

/** If true, automatically handle interruptions. <br>
 *
 * Default value: YES
 */
@property(nonatomic,readwrite,assign) bool handleInterruptions;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
/** Delegate that will receive all audio session events (WEAK reference).
 */
@property(nonatomic,readwrite,assign) id<AVAudioSessionDelegate> audioSessionDelegate;
#endif

/** If true, the audio session is active */
@property(nonatomic,readwrite,assign) bool audioSessionActive;

/** The preferred I/O buffer duration, in seconds. Lower values give less
 * playback latencey, but use more CPU.
 * @deprecated Use AVAudioSession instead.
 */
@property(nonatomic,readwrite,assign) float preferredIOBufferDuration __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_6_1);

/** If true, another application (usually iPod) is playing music.
 * @deprecated Use AVAudioSession instead.
 */
@property(nonatomic,readonly,assign) bool ipodPlaying __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_6_1);

/** Get the device's final hardware output volume, as controlled by
 * the volume button on the side of the device.
 * @deprecated Use AVAudioSession instead.
 */
@property(nonatomic,readonly,assign) float hardwareVolume __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_6_1);

/** Check if the hardware mute switch is on (not supported on the simulator or iOS 5+).
 * Note: If headphones are plugged in, hardwareMuted will always return FALSE
 *       regardless of the switch state.
 *
 * Note: Please file a bug report with Apple to get this functionality restored in iOS 5!
 */
@property(nonatomic,readonly,assign) bool hardwareMuted __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_5_0);

/** Check what hardware route the audio is taking, such as "Speaker" or "Headphone"
 * (not supported on the simulator).
 * @deprecated Use AVAudioSession instead.
 */
@property(nonatomic,readonly,retain) NSString* audioRoute __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_6_1);


#pragma mark Object Management

/** Singleton implementation providing "sharedInstance" and "purgeSharedInstance" methods.
 *
 * <b>- (OALAudioSupport*) sharedInstance</b>: Get the shared singleton instance. <br>
 * <b>- (void) purgeSharedInstance</b>: Purge (deallocate) the shared instance.
 */
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(OALAudioSession);


#pragma mark Utility

/** Force an interrupt end. This can be useful in cases where a buggy OS
 * fails to end an interrupt.
 *
 * Be VERY CAREFUL when using this!
 */
- (void) forceEndInterruption;

@end
