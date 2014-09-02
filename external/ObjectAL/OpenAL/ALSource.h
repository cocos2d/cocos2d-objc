//
//  ALSource.h
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

#import "ccMacros.h"

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import "ALSoundSource.h"
#import "ALBuffer.h"
#import "OALAction.h"
#import "OALSuspendHandler.h"

@class ALContext;
@class ALSource;


typedef void (^OALSourceNotificationCallback)(ALSource* source, ALuint notificationID, ALvoid* userData);

#pragma mark ALSource

/**
 * A source represents an object that emits sound which can be heard by a listener.
 * This source can have position, velocity, and direction.
 */
@interface ALSource : NSObject <ALSoundSource, OALSuspendManager>
{
	ALuint sourceId;
	bool interruptible;
	float gain;
	bool muted;

	/** Shadow value which keeps the correct state value
	 * for AL_PLAYING and AL_PAUSED.
	 * We need this due to a buggy OpenAL implementation.
	 */
	int shadowState;
	
	/** Used to abort a pending playback resume if the user calls
	 * stop or pause.
	 */
	bool abortPlaybackResume;

	ALBuffer* buffer;
	ALContext* context;

	/** Current action operating on the gain control. */
	OALAction* gainAction;

	/** Current action operating on the pan control. */
	OALAction* panAction;

	/** Current action operating on the pitch control. */
	OALAction* pitchAction;
	
	/** Handles suspending and interrupting for this object. */
	OALSuspendHandler* suspendHandler;
}


#pragma mark Properties

/** The sound buffer this source is attached to (set to nil to detach the currently attached
 * buffer).
 */
@property(nonatomic,readwrite,retain) ALBuffer* buffer;

/** How many buffers this source has queued. */
@property(nonatomic,readonly,assign) int buffersQueued;

/** How many of these buffers have been processed during playback. */
@property(nonatomic,readonly,assign) int buffersProcessed;

/** The context this source was opened on. */
@property(nonatomic,readonly,retain) ALContext* context;

/** The offset into the current buffer (in bytes). */
@property(nonatomic,readwrite,assign) float offsetInBytes;

/** The offset into the current buffer (in samples). */
@property(nonatomic,readwrite,assign) float offsetInSamples;

/** The offset into the current buffer (in seconds). */
@property(nonatomic,readwrite,assign) float offsetInSeconds;

/** OpenAL's ID for this source. */
@property(nonatomic,readonly,assign) ALuint sourceId;

/** The state of this source. */
@property(nonatomic,readwrite,assign) int state;


#pragma mark Object Management

/** Create a new source.
 *
 * @return A new source.
 */
+ (id) source;

/** Create a new source on the specified context.
 *
 * @param context the context to create the source on.
 * @return A new source.
 */
+ (id) sourceOnContext:(ALContext*) context;

/** Initialize a new source on the specified context.
 *
 * @param context the context to create the source on.
 * @return A new source.
 */
- (id) initOnContext:(ALContext*) context;


#pragma mark Playback

/** Play the currently attached buffer.
 *
 * @return the source playing the sound, or nil if the sound could not be played.
 */
- (id<ALSoundSource>) play;


#pragma mark Queued Playback

/** Add a buffer to the buffer queue.
 *
 * @param buffer the buffer to add to the queue.
 * @return TRUE if the operation was successful.
 */
- (bool) queueBuffer:(ALBuffer*) buffer;

/** Add a buffer to the buffer queue, repeating it multiple times.
 *
 * @param buffer the buffer to add to the queue.
 * @param repeats the number of times to repeat the buffer in the queue.
 * @return TRUE if the operation was successful.
 */
- (bool) queueBuffer:(ALBuffer*) buffer repeats:(NSUInteger) repeats;

/** Add buffers to the buffer queue.
 *
 * @param buffers the buffers to add to the queue.
 * @return TRUE if the operation was successful.
 */
- (bool) queueBuffers:(NSArray*) buffers;

/** Add buffers to the buffer queue, repeating it multiple times.
 * The buffers will be played in order, repeating the specified number of times.
 *
 * @param buffers the buffers to add to the queue.
 * @param repeats the number of times to repeat the buffer in the queue.
 * @return TRUE if the operation was successful.
 */
- (bool) queueBuffers:(NSArray*) buffers repeats:(NSUInteger) repeats;

/** Remove a buffer from the buffer queue.
 *
 * @param buffer the buffer to remove from the queue.
 * @return TRUE if the operation was successful.
 */
- (bool) unqueueBuffer:(ALBuffer*) buffer;

/** Remove buffers from the buffer queue
 *
 * @param buffers the buffers to remove from the queue.
 * @return TRUE if the operation was successful.
 */
- (bool) unqueueBuffers:(NSArray*) buffers;


#pragma mark Notifications

/** Register to receive notifications about an event on this source. (iOS 5.0+)
 *
 * The following notification types are recognized:
 * AL_SOURCE_STATE - Sent when a source's state changes.
 * AL_BUFFERS_PROCESSED - Sent when all buffers have been processed.
 * AL_QUEUE_HAS_LOOPED - Sent when a looping source has looped to it's start point.
 *
 * @param notificationID The kind of notification to be informed of (see above).
 * @param callback The block to call for notification.
 * @param userData a pointer that will be passed to the callback.
 */
- (void) registerNotification:(ALuint) notificationID
                     callback:(OALSourceNotificationCallback) callback
                     userData:(void*) userData;

/** Unregister notifications for a notification type on this source. (iOS 5.0+)
 *
 * @param notificationID The kind of notification to remove.
 */
- (void) unregisterNotification:(ALuint) notificationID;

/** Unregister all notifications for this source. (iOS 5.0+)
 */
- (void) unregisterAllNotifications;

@end
