//
//  OpenAL.h
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
#import <OpenAL/alc.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <OpenAL/oalMacOSX_OALExtensions.h>
#else
#import <OpenAL/MacOSX_OALExtensions.h>
#endif


/**
 * A thin wrapper around the C OpenAL API, with a few convenience methods thrown in.
 * Wherever possible, methods return the requested data rather than requiring a pointer to be
 * passed in. 
 * Besides collecting the API calls into a single global object, all calls are combined with an
 * error check.
 * Any OpenAL errors that occur will be logged if error logging is enabled.
 */
@interface ALWrapper : NSObject
{
}

#pragma mark -
#pragma mark Buffers

/** Generate buffers.
 *
 * @param bufferIds Pointer to an array that will receive the buffer IDs.
 * @param numBuffers the number of buffers to generate.
 * @return TRUE if the operation was successful.
 */
+ (bool) genBuffers:(ALuint*) bufferIds numBuffers:(ALsizei) numBuffers;

/** Generate a buffer.
 *
 * @return the buffer's ID.
 */
+ (ALuint) genBuffer;

/** Delete buffers.
 *
 * @param bufferIds Pointer to an array containing the buffer IDs.
 * @param numBuffers the number of buffers to delete.
 * @return TRUE if the operation was successful.
 */
+ (bool) deleteBuffers:(ALuint*) bufferIds numBuffers:(ALsizei) numBuffers;

/** Delete a buffer.
 *
 * @param bufferId The ID of the buffer to delete.
 * @return TRUE if the operation was successful.
 */
+ (bool) deleteBuffer:(ALuint) bufferId;

/** Check if the speified buffer exists.
 *
 * @param bufferId The ID of the buffer to query.
 * @return TRUE if the buffer exists.
 */
+ (bool) isBuffer:(ALuint) bufferId;

/** Load data into a buffer.
 *
 * @param bufferId The ID of the buffer to load data into.
 * @param format The format of the data being loaded (typically AL_FORMAT_MONO16 or 
 *        AL_FORMAT_STEREO16).
 * @param data The audio data.
 * @param size The size of the data in bytes.
 * @param frequency The sample frequency of the data.
 */
+ (bool) bufferData:(ALuint) bufferId
			 format:(ALenum) format
			   data:(const ALvoid*) data
			   size:(ALsizei) size
		  frequency:(ALsizei) frequency;

#pragma mark Setters

/** Write a float paramter to a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) bufferf:(ALuint) bufferId parameter:(ALenum) parameter value:(ALfloat) value;

/** Write a 3 float paramter to a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter the parameter to write to.
 * @param v1 The first value to write.
 * @param v2 The second value to write.
 * @param v3 The third value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) buffer3f:(ALuint) bufferId
		parameter:(ALenum) parameter
			   v1:(ALfloat) v1
			   v2:(ALfloat) v2
			   v3:(ALfloat) v3;

/** Write a float array paramter to a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to write to.
 * @param values The values to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) bufferfv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALfloat*) values;

/** Write an integer paramter to a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) bufferi:(ALuint) bufferId parameter:(ALenum) parameter value:(ALint) value;

/** Write a 3 integer paramter to a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to write to.
 * @param v1 The first value to write.
 * @param v2 The second value to write.
 * @param v3 The third value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) buffer3i:(ALuint) bufferId
		parameter:(ALenum) parameter
			   v1:(ALint) v1
			   v2:(ALint) v2
			   v3:(ALint) v3;

/** Write an integer array paramter to a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to write to.
 * @param values The values to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) bufferiv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALint*) values;

#pragma mark Getters

/** Read a float paramter from a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to read.
 * @return The parameter's value.
 */
+ (ALfloat) getBufferf:(ALuint) bufferId parameter:(ALenum) parameter;

/** Read a 3 float paramter from a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to read.
 * @param v1 The first value to read.
 * @param v2 The second value to read.
 * @param v3 The third value to read.
 * @return TRUE if the operation was successful.
 */
+ (bool) getBuffer3f:(ALuint) bufferId
		   parameter:(ALenum) parameter
				  v1:(ALfloat*) v1
				  v2:(ALfloat*) v2
				  v3:(ALfloat*) v3;

/** Read a float array paramter from a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to read.
 * @param values An array to store the values.
 * @return TRUE if the operation was successful.
 */
+ (bool) getBufferfv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALfloat*) values;

/** Read an integer paramter from a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to read.
 * @return The parameter's value.
 */
+ (ALint) getBufferi:(ALuint) bufferId parameter:(ALenum) parameter;

/** Read a 3 integer paramter from a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to read.
 * @param v1 The first value to read.
 * @param v2 The second value to read.
 * @param v3 The third value to read.
 * @return TRUE if the operation was successful.
 */
+ (bool) getBuffer3i:(ALuint) bufferId
		   parameter:(ALenum) parameter
				  v1:(ALint*) v1
				  v2:(ALint*) v2
				  v3:(ALint*) v3;

/** Read an integer array paramter from a buffer.
 *
 * @param bufferId The buffer's ID.
 * @param parameter The parameter to read.
 * @param values An array to store the values.
 * @return TRUE if the operation was successful.
 */
+ (bool) getBufferiv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALint*) values;



#pragma mark -
#pragma mark Sources

/** Generate sources.
 *
 * @param sourceIds Pointer to an array that will receive the source IDs.
 * @param numSources the number of sources to generate.
 * @return TRUE if the operation was successful.
 */
+ (bool) genSources:(ALuint*) sourceIds numSources:(ALsizei) numSources;

/** Generate a source.
 *
 * @return the source's ID.
 */
+ (ALuint) genSource;

/** Delete sources.
 *
 * @param sourceIds Pointer to an array containing the source IDs.
 * @param numSources the number of sources to delete.
 * @return TRUE if the operation was successful.
 */
+ (bool) deleteSources:(ALuint*) sourceIds numSources:(ALsizei) numSources;

/** Delete a source.
 *
 * @param sourceId The ID of the source to delete.
 * @return TRUE if the operation was successful.
 */
+ (bool) deleteSource:(ALuint) sourceId;

/** Check if the speified source exists.
 *
 * @param sourceId The ID of the source to query.
 * @return TRUE if the buffer exists.
 */
+ (bool) isSource:(ALuint) sourceId;

#pragma mark Playback

/** Play a source.
 *
 * @param sourceId The ID of the source to play.
 * @return TRUE if the buffer exists.
 */
+ (bool) sourcePlay:(ALuint) sourceId;

/** Play a bunch of sources.
 *
 * @param sourceIds The sources to play.
 * @param numSources The number of sources in sourceIds.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourcePlayv:(ALuint*) sourceIds numSources:(ALsizei) numSources;

/** Pause a source.
 *
 * @param sourceId The ID of the source to pause.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourcePause:(ALuint) sourceId;

/** Pause a bunch of sources.
 *
 * @param sourceIds The sources to pause.
 * @param numSources The number of sources in sourceIds.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourcePausev:(ALuint*) sourceIds numSources:(ALsizei) numSources;

/** Stop a source.
 *
 * @param sourceId The ID of the source to stop.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourceStop:(ALuint) sourceId;

/** Stop a bunch of sources.
 *
 * @param sourceIds The sources to stop.
 * @param numSources The number of sources in sourceIds.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourceStopv:(ALuint*) sourceIds numSources:(ALsizei) numSources;

/** Rewind a source.
 *
 * @param sourceId The ID of the source to rewind.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourceRewind:(ALuint) sourceId;

/** Rewind a bunch of sources.
 *
 * @param sourceIds The sources to rewind.
 * @param numSources The number of sources in sourceIds.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourceRewindv:(ALuint*) sourceIds numSources:(ALsizei) numSources;

/** Queue buffers into a source for sequential playback.
 *
 * @param sourceId The source to use for playback.
 * @param numBuffers The number of buffers to queue.
 * @param bufferIds The IDs of the buffers to queue.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourceQueueBuffers:(ALuint) sourceId
				 numBuffers:(ALsizei) numBuffers
				  bufferIds:(ALuint*) bufferIds;

/** Unqueue previously queued buffers.
 *
 * @param sourceId The source the buffers were previously queued in.
 * @param numBuffers The number of buffers to unqueue.
 * @param bufferIds The IDs of the buffers to unqueue.
 * @return TRUE if the operation is successful.
 */
+ (bool) sourceUnqueueBuffers:(ALuint) sourceId
				   numBuffers:(ALsizei) numBuffers
					bufferIds:(ALuint*) bufferIds;

#pragma mark Setters

/** Write a float paramter to a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) sourcef:(ALuint) sourceId parameter:(ALenum) parameter value:(ALfloat) value;

/** Write a 3 float paramter to a source.
 *
 * @param sourceId The source's ID.
 * @param parameter the parameter to write to.
 * @param v1 The first value to write.
 * @param v2 The second value to write.
 * @param v3 The third value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) source3f:(ALuint) sourceId
		parameter:(ALenum) parameter
			   v1:(ALfloat) v1
			   v2:(ALfloat) v2
			   v3:(ALfloat) v3;

/** Write a float array paramter to a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to write to.
 * @param values The values to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) sourcefv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALfloat*) values;

/** Write an integer paramter to a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) sourcei:(ALuint) sourceId parameter:(ALenum) parameter value:(ALint) value;

/** Write a 3 integer paramter to a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to write to.
 * @param v1 The first value to write.
 * @param v2 The second value to write.
 * @param v3 The third value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) source3i:(ALuint) sourceId
		parameter:(ALenum) parameter
			   v1:(ALint) v1
			   v2:(ALint) v2
			   v3:(ALint) v3;

/** Write an integer array paramter to a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to write to.
 * @param values The values to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) sourceiv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALint*) values;

#pragma mark Getters

/** Read a float paramter from a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to read.
 * @return The parameter's value.
 */
+ (ALfloat) getSourcef:(ALuint) sourceId parameter:(ALenum) parameter;

/** Read a 3 float paramter from a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to read.
 * @param v1 The first value to read.
 * @param v2 The second value to read.
 * @param v3 The third value to read.
 * @return TRUE if the operation was successful.
 */
+ (bool) getSource3f:(ALuint) sourceId
		   parameter:(ALenum) parameter
				  v1:(ALfloat*) v1
				  v2:(ALfloat*) v2
				  v3:(ALfloat*) v3;

/** Read a float array paramter from a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to read.
 * @param values An array to store the values.
 * @return TRUE if the operation was successful.
 */
+ (bool) getSourcefv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALfloat*) values;

/** Read an integer paramter from a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to read.
 * @return The parameter's value.
 */
+ (ALint) getSourcei:(ALuint) sourceId parameter:(ALenum) parameter;

/** Read a 3 integer paramter from a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to read.
 * @param v1 The first value to read.
 * @param v2 The second value to read.
 * @param v3 The third value to read.
 * @return TRUE if the operation was successful.
 */
+ (bool) getSource3i:(ALuint) sourceId
		   parameter:(ALenum) parameter
				  v1:(ALint*) v1
				  v2:(ALint*) v2
				  v3:(ALint*) v3;

/** Read an integer array paramter from a source.
 *
 * @param sourceId The source's ID.
 * @param parameter The parameter to read.
 * @param values An array to store the values.
 * @return TRUE if the operation was successful.
 */
+ (bool) getSourceiv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALint*) values;

#pragma mark -
#pragma mark Listener

/** Write a float paramter to the current listener.
 *
 * @param parameter The parameter to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) listenerf:(ALenum) parameter value:(ALfloat) value;

/** Write a 3 float paramter to the current listener.
 *
 * @param parameter the parameter to write to.
 * @param v1 The first value to write.
 * @param v2 The second value to write.
 * @param v3 The third value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) listener3f:(ALenum) parameter v1:(ALfloat) v1 v2:(ALfloat) v2 v3:(ALfloat) v3;

/** Write a float array paramter to the current listener.
 *
 * @param parameter The parameter to write to.
 * @param values The values to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) listenerfv:(ALenum) parameter values:(ALfloat*) values;

/** Write an integer paramter to the current listener.
 *
 * @param parameter The parameter to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) listeneri:(ALenum) parameter value:(ALint) value;

/** Write a 3 integer paramter to the current listener.
 *
 * @param parameter The parameter to write to.
 * @param v1 The first value to write.
 * @param v2 The second value to write.
 * @param v3 The third value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) listener3i:(ALenum) parameter v1:(ALint) v1 v2:(ALint) v2 v3:(ALint) v3;

/** Write an integer array paramter to the current listener.
 *
 * @param parameter The parameter to write to.
 * @param values The values to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) listeneriv:(ALenum) parameter values:(ALint*) values;


/** Read a float paramter from the current listener.
 *
 * @param parameter The parameter to read.
 * @return The parameter's value.
 */
+ (ALfloat) getListenerf:(ALenum) parameter;

/** Read a 3 float paramter from the current listener.
 *
 * @param parameter The parameter to read.
 * @param v1 The first value to read.
 * @param v2 The second value to read.
 * @param v3 The third value to read.
 * @return TRUE if the operation was successful.
 */
+ (bool) getListener3f:(ALenum) parameter v1:(ALfloat*) v1 v2:(ALfloat*) v2 v3:(ALfloat*) v3;

/** Read a float array paramter from the current listener.
 *
 * @param parameter The parameter to read.
 * @param values An array to store the values.
 * @return TRUE if the operation was successful.
 */
+ (bool) getListenerfv:(ALenum) parameter values:(ALfloat*) values;

/** Read an integer paramter from the current listener.
 *
 * @param parameter The parameter to read.
 * @return The parameter's value.
 */
+ (ALint) getListeneri:(ALenum) parameter;

/** Read a 3 integer paramter from the current listener.
 *
 * @param parameter The parameter to read.
 * @param v1 The first value to read.
 * @param v2 The second value to read.
 * @param v3 The third value to read.
 * @return TRUE if the operation was successful.
 */
+ (bool) getListener3i:(ALenum) parameter v1:(ALint*) v1 v2:(ALint*) v2 v3:(ALint*) v3;

/** Read an integer array paramter from the current listener.
 *
 * @param parameter The parameter to read.
 * @param values An array to store the values.
 * @return TRUE if the operation was successful.
 */
+ (bool) getListeneriv:(ALenum) parameter values:(ALint*) values;

#pragma mark -
#pragma mark State Functions

/** Enable a capability.
 *
 * @param capability The capability to enable.
 * @return TRUE if the operation was successful.
 */
+ (bool) enable:(ALenum) capability;

/** Disable a capability.
 *
 * @param capability The capability to disable.
 * @return TRUE if the operation was successful.
 */
+ (bool) disable:(ALenum) capability;

/** Check if a capability is enabled.
 *
 * @param capability The capability to check.
 * @return TRUE if the capability is enabled.
 */
+ (bool) isEnabled:(ALenum) capability;

/** Get a boolean parameter.
 *
 * @param parameter The parameter to fetch.
 * @return The parameter's current value.
 */
+ (bool) getBoolean:(ALenum) parameter;

/** Get a double parameter.
 *
 * @param parameter The parameter to fetch.
 * @return The parameter's current value.
 */
+ (ALdouble) getDouble:(ALenum) parameter;

/** Get a float parameter.
 *
 * @param parameter The parameter to fetch.
 * @return The parameter's current value.
 */
+ (ALfloat) getFloat:(ALenum) parameter;

/** Get an integer parameter.
 *
 * @param parameter The parameter to fetch.
 * @return The parameter's current value.
 */
+ (ALint) getInteger:(ALenum) parameter;

/** Get a string parameter.
 *
 * @param parameter The parameter to fetch.
 * @return The parameter's current value.
 */
+ (NSString*) getString:(ALenum) parameter;

/** Get a string list parameter. Use this method for OpenAL parameters that return a null
 * separated list.
 *
 * @param parameter The parameter to fetch.
 * @return The parameter's current value (as an array of NSString*).
 */
+ (NSArray*) getNullSeparatedStringList:(ALenum) parameter;

/** Get a string list parameter. Use this method for OpenAL parameters that return a space
 * separated list.
 *
 * @param parameter The parameter to fetch.
 * @return The parameter's current value (as an array of NSString*).
 */
+ (NSArray*) getSpaceSeparatedStringList:(ALenum) parameter;

/** Get a boolean array parameter.
 *
 * @param parameter The parameter to fetch.
 * @param values An array to hold the result.
 * @return TRUE if the operation was successful.
 */
+ (bool) getBooleanv:(ALenum) parameter values:(ALboolean*) values;

/** Get a double array parameter.
 *
 * @param parameter The parameter to fetch.
 * @param values An array to hold the result.
 * @return TRUE if the operation was successful.
 */
+ (bool) getDoublev:(ALenum) parameter values:(ALdouble*) values;

/** Get a float array parameter.
 *
 * @param parameter The parameter to fetch.
 * @param values An array to hold the result.
 * @return TRUE if the operation was successful.
 */
+ (bool) getFloatv:(ALenum) parameter values:(ALfloat*) values;

/** Get an integer array parameter.
 *
 * @param parameter The parameter to fetch.
 * @param values An array to hold the result.
 * @return TRUE if the operation was successful.
 */
+ (bool) getIntegerv:(ALenum) parameter values:(ALint*) values;

/** Set the distance model.
 *
 * @param value The value to set.
 * @return TRUE if the operation was successful.
 */
+ (bool) distanceModel:(ALenum) value;

/** Set the doppler factor.
 *
 * @param value The value to set.
 * @return TRUE if the operation was successful.
 */
+ (bool) dopplerFactor:(ALfloat) value;

/** Set the speed of sound.
 *
 * @param value The value to set.
 * @return TRUE if the operation was successful.
 */
+ (bool) speedOfSound:(ALfloat) value;

/** Check if an extension is present.
 *
 * @param extensionName The name of the extension to check.
 * @return TRUE if the extension is present.
 */
+ (bool) isExtensionPresent:(NSString*) extensionName;

/** Get the address of a procedure.
 *
 * @param functionName The name of the procedure to fetch.
 * @return A pointer to the procedure, or NULL if it wasn't found.
 */
+ (void*) getProcAddress:(NSString*) functionName;

/** Get the enum value from its name.
 *
 * @param enumName the name of the enum value.
 * @return The enum value.
 */
+ (ALenum) getEnumValue:(NSString*) enumName;


#pragma mark -
#pragma mark ALC
#pragma mark -

#pragma mark Context device functions

/** Open a device.
 *
 * @param deviceName The name of the device to open (nil = open the default device).
 * @return The opened device, or nil on failure.
 */
+ (ALCdevice*) openDevice:(NSString*) deviceName;

/** Close a device.
 *
 * @param device The device to close.
 * @return TRUE if the operation was successful.
 */
+ (bool) closeDevice:(ALCdevice*) device;



#pragma mark Context management functions

/** Create an OpenAL context.
 *
 * @param device The device to open the context on.
 * @param attributes The attributes to use when creating the context.
 * @return The new context.
 */
+ (ALCcontext*) createContext:(ALCdevice*) device attributes:(ALCint*) attributes;

/** Make the specified context the current context.
 *
 * @param context the context to make current.
 * @return TRUE if the operation was successful.
 */
+ (bool) makeContextCurrent:(ALCcontext*) context;

/** Make the specified context the current context, passing in a device reference for more
 * informative logging info.
 *
 * @param context The context to make current.
 * @param deviceReference The device reference to use when logging an error.
 * @return TRUE if the operation was successful.
 */
+ (bool) makeContextCurrent:(ALCcontext*) context deviceReference:(ALCdevice*) deviceReference;

/** Process a context.
 *
 * @param context The contect to process.
 * @return TRUE if the operation was successful.
 */
+ (void) processContext:(ALCcontext*) context;

/** Suspend a context.
 *
 * @param context The contect to suspend.
 * @return TRUE if the operation was successful.
 */
+ (void) suspendContext:(ALCcontext*) context;

/** Destroy a context.
 *
 * @param context The contect to destroy.
 * @return TRUE if the operation was successful.
 */
+ (void) destroyContext:(ALCcontext*) context;

/** Get the current context.
 *
 * @return the current context.
 */
+ (ALCcontext*) getCurrentContext;

/** Get the device a context was created from.
 *
 * @param context The context.
 * @return The context's device.
 */
+ (ALCdevice*) getContextsDevice:(ALCcontext*) context;

/** Get the device a context was created from, passing in a device reference for more
 * informative logging info.
 *
 * @param context The context.
 * @param deviceReference The device reference to use when logging an error.
 * @return The context's device.
 */
+ (ALCdevice*) getContextsDevice:(ALCcontext*) context
				 deviceReference:(ALCdevice*) deviceReference;



#pragma mark Context extension functions

/** Check if an extension is present on a device.
 *
 * @param device The device to check for an extension on.
 * @param extensionName The name of the extension to check for.
 * @return TRUE if the extension is present.
 */
+ (bool) isExtensionPresent:(ALCdevice*) device name:(NSString*) extensionName;

/** Get the address of a procedure for a device.
 *
 * @param device The device to check on.
 * @param functionName The name of the procedure to check for.
 * @return The procedure's address, or NULL if not found.
 */
+ (void*) getProcAddress:(ALCdevice*) device name:(NSString*) functionName;

/** Get the enum value from its name.
 *
 * @param device The device to check on.
 * @param enumName the name of the enum value.
 * @return The enum value.
 */
+ (ALenum) getEnumValue:(ALCdevice*) device name:(NSString*) enumName;



#pragma mark Context state functions

/** Get a string attribute.
 *
 * @param device The device to read the attribute from.
 * @param attribute The attribute to fetch.
 * @return The parameter's current value.
 */
+ (NSString*) getString:(ALCdevice*) device attribute:(ALenum) attribute;

/** Get a string list attribute. Use this method for OpenAL attributes that return a null
 * separated list.
 *
 * @param device The device to read the attribute from.
 * @param attribute The attribute to fetch.
 * @return The parameter's current value (as an array of NSString*).
 */
+ (NSArray*) getNullSeparatedStringList:(ALCdevice*) device attribute:(ALenum) attribute;

/** Get a string list attribute. Use this method for OpenAL attributes that return a space
 * separated list.
 *
 * @param device The device to read the attribute from.
 * @param attribute The attribute to fetch.
 * @return The parameter's current value (as an array of NSString*).
 */
+ (NSArray*) getSpaceSeparatedStringList:(ALCdevice*) device attribute:(ALenum) attribute;

/** Get an integer attribute.
 *
 * @param device The device to read the attribute from.
 * @param attribute The attribute to fetch.
 * @return The parameter's current value.
 */
+ (ALint) getInteger:(ALCdevice*) device attribute:(ALenum) attribute;

/** Get an integer array attribute.
 *
 * @param device The device to read the attribute from.
 * @param attribute The attribute to read.
 * @param size the size of the receiving array.
 * @param data An array to store the values.
 * @return TRUE if the operation was successful.
 */
+ (bool) getIntegerv:(ALCdevice*) device
		   attribute:(ALenum) attribute
				size:(ALsizei) size
				data:(ALCint*) data;



#pragma mark Context capture functions

/** *UNSUPPORTED ON IOS* Open an audio capture device.
 *
 * @param deviceName The name of the device to open (nil = open the default device).
 * @param frequency The sampling frequency to use.
 * @param format The format to capture the data as.
 * @param bufferSize The size of capture buffer to use.
 * @return The opened device, or nil if an error occurred.
 */
+ (ALCdevice*) openCaptureDevice:(NSString*) deviceName
					   frequency:(ALCuint) frequency
						  format:(ALCenum) format
					  bufferSize:(ALCsizei) bufferSize;

/** Close a capture device.
 *
 * @param device The device to close.
 * @return TRUE if the operation was successful.
 */
+ (bool) closeCaptureDevice:(ALCdevice*) device;

/** Start capturing audio data.
 *
 * @param device The device to capture on.
 * @return TRUE if the operation was successful.
 */
+ (bool) startCapture:(ALCdevice*) device;

/** Stop capturing audio data.
 *
 * @param device The device capturing audio data.
 * @return TRUE if the operation was successful.
 */
+ (bool) stopCapture:(ALCdevice*) device;

/** Get captured samples from a device.
 *
 * @param device the device to fetch samples from.
 * @param buffer the buffer to copy the samples into.
 * @param numSamples the number of samples to fetch.
 */
+ (bool) captureSamples:(ALCdevice*) device
				 buffer:(ALCvoid*) buffer
			 numSamples:(ALCsizei) numSamples;


#pragma mark iOS extensions

/** Get the iOS device's mixer outut data rate.
 *
 * @return The mixer output data rate.
 */
+ (ALdouble) getMixerOutputDataRate;

/** Set the iOS device's mixer output data rate.
 *
 * @param frequency The output data rate (frequency).
 */
+ (bool) setMixerOutputDataRate:(ALdouble) frequency;

/** Load data into a buffer. Unlike "bufferData", with this method the buffer will
 * use the passed in data buffer direcly rather than allocating its own memory
 * and copying from the data buffer.
 *
 * @param bufferId The ID of the buffer to load data into.
 * @param format The format of the data being loaded (typically AL_FORMAT_MONO16 or
 *        AL_FORMAT_STEREO16).
 * @param data The audio data.
 * @param size The size of the data in bytes.
 * @param frequency The sample frequency of the data.
 */
+ (bool) bufferDataStatic:(ALuint) bufferId
				   format:(ALenum) format
					 data:(const ALvoid*) data
					 size:(ALsizei) size
				frequency:(ALsizei) frequency;

/** Read a boolean ASA property from a listener.
 *
 * @param property The property to read.
 * @return The property's value.
 */
+ (bool) asaGetListenerb:(ALuint) property;

/** Read an integer ASA property from a listener.
 *
 * @param property The property to read.
 * @return The property's value.
 */
+ (ALint) asaGetListeneri:(ALuint) property;

/** Read a floating point ASA property from a listener.
 *
 * @param property The property to read.
 * @return The property's value.
 */
+ (ALfloat) asaGetListenerf:(ALuint) property;

/** Write a boolean ASA value to a listener.
 *
 * @param property The property to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) asaListenerb:(ALuint) property value:(bool) value;

/** Write an integer ASA value to a listener.
 *
 * @param property The property to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) asaListeneri:(ALuint) property value:(ALint) value;

/** Write a floating point ASA value to a listener.
 *
 * @param property The property to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) asaListenerf:(ALuint) property value:(ALfloat) value;

/** Read a boolean ASA property from a source.
 *
 * @param sourceId The source's ID.
 * @param property The property to read.
 * @return The property's value.
 */
+ (bool) asaGetSourceb:(ALuint) sourceId property:(ALuint) property;

/** Read an integer ASA property from a source.
 *
 * @param sourceId The source's ID.
 * @param property The property to read.
 * @return The property's value.
 */
+ (ALint) asaGetSourcei:(ALuint) sourceId property:(ALuint) property;

/** Read a floating point ASA property from a source.
 *
 * @param sourceId The source's ID.
 * @param property The property to read.
 * @return The property's value.
 */
+ (ALfloat) asaGetSourcef:(ALuint) sourceId property:(ALuint) property;

/** Write a boolean ASA value to a source.
 *
 * @param sourceId The source's ID.
 * @param property The property to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) asaSourceb:(ALuint) sourceId property:(ALuint) property value:(bool) value;

/** Write an integer ASA value to a source.
 *
 * @param sourceId The source's ID.
 * @param property The property to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) asaSourcei:(ALuint) sourceId property:(ALuint) property value:(ALint) value;

/** Write a floating point ASA value to a source.
 *
 * @param sourceId The source's ID.
 * @param property The property to write to.
 * @param value The value to write.
 * @return TRUE if the operation was successful.
 */
+ (bool) asaSourcef:(ALuint) sourceId property:(ALuint) property value:(ALfloat) value;

/** Set the rendering quality. The value may be one of:
 *
 * ALC_MAC_OSX_SPATIAL_RENDERING_QUALITY_HIGH
 * ALC_MAC_OSX_SPATIAL_RENDERING_QUALITY_LOW
 * ALC_IPHONE_SPATIAL_RENDERING_QUALITY_HEADPHONES (iOS only)
 *
 * @param quality The quality.
 */
+ (bool) setRenderingQuality:(ALint) quality;

/** Get the rendering quality.
 *
 * @return The current rendering quality.
 */
+ (ALint) getRenderingQuality;

/** Add a notification callback to a source.
 *
 * The following notification types are recognized:
 * AL_SOURCE_STATE - Sent when a source's state changes.
 * AL_BUFFERS_PROCESSED - Sent when all buffers have been processed.
 * AL_QUEUE_HAS_LOOPED - Sent when a looping source has looped to it's start point.
 *
 * @param notificationID The kind of notification to be informed of (see above).
 * @param source The source ID.
 * @param callback The function to call for notification.
 * @param userData a pointer that will be passed to the callback.
 * @return TRUE if the operation was successful.
 */
+ (bool) addNotification:(ALuint) notificationID
                onSource:(ALuint) source
                callback:(alSourceNotificationProc) callback
                userData:(void*) userData;

/** Remove a notification callback from a source.
 *
 * @param notificationID The kind of notification (see addNotification).
 * @param source The source ID.
 * @param callback The function to be unregistered.
 * @param userData not actually needed but part of the API.
 * @return TRUE if the operation was successful.
 */
+ (bool) removeNotification:(ALuint) notificationID
                   onSource:(ALuint) source
                   callback:(alSourceNotificationProc) callback
                   userData:(void*) userData;

@end
