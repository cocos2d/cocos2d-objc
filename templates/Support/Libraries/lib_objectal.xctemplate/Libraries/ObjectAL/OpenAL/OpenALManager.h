//
//  OpenALManager.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-09-25.
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
#import "SynthesizeSingleton.h"
#import "ALContext.h"
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <OpenAL/oalMacOSX_OALExtensions.h>
#else
#import <OpenAL/MacOSX_OALExtensions.h>
#endif


#pragma mark OpenALManager

/**
 * Manager class for OpenAL objects (ObjectAL).
 * Keeps track of devices that have been opened, and allows high level OpenAL management. <br>
 * Provides methods for loading ALBuffer objects from audio files. <br>
 * The OpenAL 1.1 specification is available at
 * http://connect.creativelabs.com/openal/Documentation <br>
 * Be sure to read through it (especially the part about distance models) as ObjectAL follows the
 * OpenAL object model. <br>
 *
 * Alternatively, you may opt to use OALSimpleAudio for a simpler interface.
 */
@interface OpenALManager : NSObject <OALSuspendManager>
{
	/** All opened devices */
	NSMutableArray* devices;
	
	/** Handles suspending and interrupting for this object. */
	OALSuspendHandler* suspendHandler;

	/** Operation queue for asynchronous loading. */
	NSOperationQueue* operationQueue;
}


#pragma mark Properties

/** List of available playback devices (NSString*). */
@property(nonatomic,readonly,retain) NSArray* availableDevices;

/** List of available capture devices (NSString*). */
@property(nonatomic,readonly,retain) NSArray* availableCaptureDevices;

/** The current context (some context operations require the context to be the "current" one).
 * WEAK reference.
 */
@property(nonatomic,readwrite,assign) ALContext* currentContext;

/** Name of the default capture device. */
@property(nonatomic,readonly,retain) NSString* defaultCaptureDeviceSpecifier;

/** Name of the default playback device. */
@property(nonatomic,readonly,retain) NSString* defaultDeviceSpecifier;

/** List of all open devices (ALDevice*). */
@property(nonatomic,readonly,retain) NSArray* devices;

/** The frequency of the output mixer. */
@property(nonatomic,readwrite,assign) ALdouble mixerOutputFrequency;

/** The rendering quality.
 *
 * Can be one of:
 * - ALC_MAC_OSX_SPATIAL_RENDERING_QUALITY_HIGH
 * - ALC_MAC_OSX_SPATIAL_RENDERING_QUALITY_LOW
 * - ALC_IPHONE_SPATIAL_RENDERING_QUALITY_HEADPHONES (iOS only)
 */
@property(nonatomic,readwrite,assign) ALint renderingQuality;


#pragma mark Object Management

/** Singleton implementation providing "sharedInstance" and "purgeSharedInstance" methods.
 *
 * <b>- (OpenALManager*) sharedInstance</b>: Get the shared singleton instance. <br>
 * <b>- (void) purgeSharedInstance</b>: Purge (deallocate) the shared instance.
 */
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(OpenALManager);


#pragma mark Buffers

/** Load an OpenAL buffer with the contents of an audio file.
 * The buffer's name will be the fully qualified URL of the path.
 *
 * See the class description note regarding sound file formats.
 *
 * @param filePath The path of the file containing the audio data.
 * @return An ALBuffer containing the audio data.
 */
- (ALBuffer*) bufferFromFile:(NSString*) filePath;

/** Load an OpenAL buffer with the contents of an audio file.
 * The buffer's name will be the fully qualified URL of the path.
 *
 * See the class description note regarding sound file formats.
 *
 * @param filePath The path of the file containing the audio data.
 * @param reduceToMono If true, reduce the sample to mono
 *        (stereo samples don't support panning or positional audio).
 * @return An ALBuffer containing the audio data.
 */
- (ALBuffer*) bufferFromFile:(NSString*) filePath reduceToMono:(bool) reduceToMono;

/** Load an OpenAL buffer with the contents of an audio file.
 * The buffer's name will be the fully qualified URL.
 *
 * See the class description note regarding sound file formats.
 *
 * @param url The URL of the file containing the audio data.
 * @return An ALBuffer containing the audio data.
 */
- (ALBuffer*) bufferFromUrl:(NSURL*) url;

/** Load an OpenAL buffer with the contents of an audio file.
 * The buffer's name will be the fully qualified URL.
 *
 * See the class description note regarding sound file formats.
 *
 * @param url The URL of the file containing the audio data.
 * @param reduceToMono If true, reduce the sample to mono
 *        (stereo samples don't support panning or positional audio).
 * @return An ALBuffer containing the audio data.
 */
- (ALBuffer*) bufferFromUrl:(NSURL*) url reduceToMono:(bool) reduceToMono;

/** Load an OpenAL buffer with the contents of an audio file asynchronously.
 * This method will schedule a request to have the buffer created and filled, and then call the
 * specified selector with the newly created buffer. <br>
 * The buffer's name will be the fully qualified URL of the path. <br>
 * Returns the fully qualified URL of the path, which you can match up to the buffer name in your
 * callback method.
 *
 * See the class description note regarding sound file formats.
 *
 * @param filePath The path of the file containing the audio data.
 * @param target The target to call when the buffer is loaded.
 * @param selector The selector to invoke when the buffer is loaded.
 * @return The fully qualified URL of the path.
 */
- (NSString*) bufferAsyncFromFile:(NSString*) filePath target:(id) target selector:(SEL) selector;

/** Load an OpenAL buffer with the contents of an audio file asynchronously.
 * This method will schedule a request to have the buffer created and filled, and then call the
 * specified selector with the newly created buffer. <br>
 * The buffer's name will be the fully qualified URL of the path. <br>
 * Returns the fully qualified URL of the path, which you can match up to the buffer name in your
 * callback method.
 *
 * See the class description note regarding sound file formats.
 *
 * @param filePath The path of the file containing the audio data.
 * @param reduceToMono If true, reduce the sample to mono
 *        (stereo samples don't support panning or positional audio).
 * @param target The target to call when the buffer is loaded.
 * @param selector The selector to invoke when the buffer is loaded.
 * @return The fully qualified URL of the path.
 */
- (NSString*) bufferAsyncFromFile:(NSString*) filePath
					 reduceToMono:(bool) reduceToMono
						   target:(id) target
						 selector:(SEL) selector;

/** Load an OpenAL buffer with the contents of a URL asynchronously.
 * This method will schedule a request to have the buffer created and filled, and then call the
 * specified selector with the newly created buffer. <br>
 * The buffer's name will be the fully qualified URL. <br>
 * Returns the fully qualified URL, which you can match up to the buffer name in your callback
 * method.
 *
 * See the class description note regarding sound file formats.
 *
 * @param url The URL of the file containing the audio data.
 * @param target The target to call when the buffer is loaded.
 * @param selector The selector to invoke when the buffer is loaded.
 * @return The fully qualified URL of the path.
 */
- (NSString*) bufferAsyncFromUrl:(NSURL*) url target:(id) target selector:(SEL) selector;

/** Load an OpenAL buffer with the contents of a URL asynchronously.
 * This method will schedule a request to have the buffer created and filled, and then call the
 * specified selector with the newly created buffer. <br>
 * The buffer's name will be the fully qualified URL. <br>
 * Returns the fully qualified URL, which you can match up to the buffer name in your callback
 * method.
 *
 * See the class description note regarding sound file formats.
 *
 * @param url The URL of the file containing the audio data.
 * @param reduceToMono If true, reduce the sample to mono
 *        (stereo samples don't support panning or positional audio).
 * @param target The target to call when the buffer is loaded.
 * @param selector The selector to invoke when the buffer is loaded.
 * @return The fully qualified URL of the path.
 */
- (NSString*) bufferAsyncFromUrl:(NSURL*) url
					reduceToMono:(bool) reduceToMono
						  target:(id) target
						selector:(SEL) selector;


#pragma mark Utility

/** Clear all references to sound data from ALL buffers, managed or not.
 */
- (void) clearAllBuffers;


#pragma mark Internal Use

/** \cond */
/** (INTERNAL USE) Notify that a device is initializing.
 */
- (void) notifyDeviceInitializing:(ALDevice*) device;

/** (INTERNAL USE) Notify that a device is deallocating.
 */
- (void) notifyDeviceDeallocating:(ALDevice*) device;
/** \endcond */

@end
