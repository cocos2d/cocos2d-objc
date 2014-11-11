//
//  OALAudioTracks.h
//  ObjectAL
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

#import "OALAudioTrack.h"
#import "SynthesizeSingleton.h"
#import "OALSuspendHandler.h"


#pragma mark OALAudioTracks

/**
 * Keeps track of all AudioTrack objects.
 */
@interface OALAudioTracks : NSObject <OALSuspendManager>
{
	/** All instantiated audio tracks. */
	NSMutableArray* tracks;
	bool muted;
	bool paused;
    
    /** Timer to poll deviceCurrentTime so that it doesn't get reset on a device */
    NSTimer* deviceTimePoller;
	
	/** Handles suspending and interrupting for this object. */
	OALSuspendHandler* suspendHandler;
}

#pragma mark Properties

/** Pauses/unpauses all audio tracks. */
@property(nonatomic,readwrite,assign) bool paused;

/** Mutes/unmutes all audio tracks. */
@property(nonatomic,readwrite,assign) bool muted;

/** All instantiated audio tracks. */
@property(nonatomic,readonly,retain) NSArray* tracks;


#pragma mark Playback

/** Stop playback on all audio tracks.
 */
- (void) stopAllTracks;


#pragma mark Object Management

/** Singleton implementation providing "sharedInstance" and "purgeSharedInstance" methods.
 *
 * <b>- (OALAudioTracks*) sharedInstance</b>: Get the shared singleton instance. <br>
 * <b>- (void) purgeSharedInstance</b>: Purge (deallocate) the shared instance.
 */
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(OALAudioTracks);


#pragma mark Internal Use

/** \cond */
/** (INTERNAL USE) Notify that a track is initializing.
 */
- (void) notifyTrackInitializing:(OALAudioTrack*) track;

/** (INTERNAL USE) Notify that a track is deallocating.
 */
- (void) notifyTrackDeallocating:(OALAudioTrack*) track;
/** \endcond */

@end
