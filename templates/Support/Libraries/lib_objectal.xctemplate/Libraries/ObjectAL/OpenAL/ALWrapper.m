//
//  OpenAL.m
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

#import "ALWrapper.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "OALNotifications.h"

/** Check the result of an AL call, logging an error if necessary.
 *
 * @return TRUE if the call was successful.
 */
#define CHECK_AL_CALL() checkIfSuccessful(__PRETTY_FUNCTION__)

/** Check the result of an ALC call, logging an error if necessary.
 *
 * @param DEVICE The device involved in the ALC call.
 * @return TRUE if the call was successful.
 */
#define CHECK_ALC_CALL(DEVICE) checkIfSuccessfulWithDevice(__PRETTY_FUNCTION__, (DEVICE))


/**
 * Private interface to ALWrapper.
 */
@interface ALWrapper (Private)

/** Decode an OpenAL supplied NULL-separated string list into an NSArray.
 *
 * @param source the string list as supplied by OpenAL.
 * @return the string list in an NSArray of NSString.
 */
+ (NSArray*) decodeNullSeparatedStringList:(const ALCchar*) source;

/** Decode an OpenAL supplied space-separated string list into an NSArray.
 *
 * @param source the string list as supplied by OpenAL.
 * @return the string list in an NSArray of NSString.
 */
+ (NSArray*) decodeSpaceSeparatedStringList:(const ALCchar*) source;

/** Check the OpenAL error status and log an error message if necessary.
 *
 * @param contextInfo Contextual information to add when logging an error.
 * @return TRUE if the operation was successful (no error).
 */
BOOL checkIfSuccessful(const char* contextInfo);

/** Check the OpenAL error status and log an error message if necessary.
 *
 * @param contextInfo Contextual information to add when logging an error.
 * @param device The device to check for errors on.
 * @return TRUE if the operation was successful (no error).
 */
BOOL checkIfSuccessfulWithDevice(const char* contextInfo, ALCdevice* device);

@end

#pragma mark -

@implementation ALWrapper

typedef ALvoid AL_APIENTRY (*alBufferDataStaticProcPtr) (const ALint bid,
														 ALenum format,
														 const ALvoid* data,
														 ALsizei size,
														 ALsizei freq);

static alcMacOSXGetMixerOutputRateProcPtr alcGetMacOSXMixerOutputRate = NULL;
static alcMacOSXMixerOutputRateProcPtr alcMacOSXMixerOutputRate = NULL;
static alcMacOSXRenderingQualityProcPtr alcMacOSXRenderingQuality = NULL;
static alcMacOSXGetRenderingQualityProcPtr alcMacOSXGetRenderingQuality = NULL;
static alBufferDataStaticProcPtr alBufferDataStatic = NULL;

static alcASAGetSourceProcPtr alcASAGetSource = NULL;
static alcASASetSourceProcPtr alcASASetSource = NULL;
static alcASAGetListenerProcPtr alcASAGetListener = NULL;
static alcASASetListenerProcPtr alcASASetListener = NULL;

static alSourceAddNotificationProcPtr alSourceAddNotification = NULL;
static alSourceRemoveNotificationProcPtr alSourceRemoveNotification = NULL;


#pragma mark -
#pragma mark Error Handling

static inline bool isValidError(ALenum error)
{
    // TODO: Monitor this and make sure it doesn't mask a real failure in OpenAL that
    // would require a restart of the audio session.
    return error != AL_NO_ERROR && error != -1;
}

BOOL checkIfSuccessful(const char* contextInfo)
{
	ALenum error = alGetError();
    if(isValidError(error))
	{
		OAL_LOG_ERROR_CONTEXT(contextInfo, @"%s (error code 0x%08x)", alGetString(error), error);
		[[NSNotificationCenter defaultCenter] postNotificationName:OALAudioErrorNotification object:[ALWrapper class]];
		return NO;
	}
	return YES;
}

BOOL checkIfSuccessfulWithDevice(const char* contextInfo, ALCdevice* device)
{
	ALenum error = alcGetError(device);
    if(isValidError(error))
	{
		OAL_LOG_ERROR_CONTEXT(contextInfo, @"%s (error code 0x%08x)", alcGetString(device, error), error);
		[[NSNotificationCenter defaultCenter] postNotificationName:OALAudioErrorNotification object:[ALWrapper class]];
		return NO;
	}
	return YES;
}


#pragma mark Internal Utility

+ (NSArray*) decodeNullSeparatedStringList:(const ALCchar*) source
{
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
	NSString* lastString = nil;
	
	for(const ALCchar* nextString = source; 0 != *nextString; nextString += [lastString length] + 1)
	{
		lastString = [NSString stringWithFormat:@"%s", nextString];
	}
	
	return array;
}

+ (NSArray*) decodeSpaceSeparatedStringList:(const ALCchar*) source
{
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
	ALCchar buffer[200];
	ALCchar* bufferPtr = buffer;
	const ALCchar* sourcePtr = source;

	for(;;)
	{
		*bufferPtr = *sourcePtr;
		if(' ' == *bufferPtr || bufferPtr >= buffer + 199)
		{
			*bufferPtr = 0;
		}
		if(0 == *bufferPtr)
		{
			[array addObject:[NSString stringWithFormat:@"%s", buffer]];
			bufferPtr = buffer;
		}
		else
		{
			bufferPtr++;
		}

		if(0 == *sourcePtr)
		{
			break;
		}

		sourcePtr++;
	}
	
	return array;
}


#pragma mark -
#pragma mark OpenAL Management

+ (bool) enable:(ALenum) capability
{
	bool result;
	@synchronized(self)
	{
		alEnable(capability);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) disable:(ALenum) capability
{
	bool result;
	@synchronized(self)
	{
		alDisable(capability);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) isEnabled:(ALenum) capability
{
	ALboolean result;
	@synchronized(self)
	{
		result = alIsEnabled(capability);
		CHECK_AL_CALL();
	}
	return result;
}


#pragma mark OpenAL Extensions

+ (bool) isExtensionPresent:(NSString*) extensionName
{
	ALboolean result;
	@synchronized(self)
	{
		result = alIsExtensionPresent([extensionName UTF8String]);
		CHECK_AL_CALL();
	}
	return result;
}

+ (void*) getProcAddress:(NSString*) functionName
{
	void* result;
	@synchronized(self)
	{
		result = alGetProcAddress([functionName UTF8String]);
		CHECK_AL_CALL();
	}
	return result;
}

+ (ALenum) getEnumValue:(NSString*) enumName
{
	ALenum result;
	@synchronized(self)
	{
		result = alGetEnumValue([enumName UTF8String]);
		CHECK_AL_CALL();
	}
	return result;
}


#pragma mark -
#pragma mark Device Management

+ (ALCdevice*) openDevice:(NSString*) deviceName
{
	ALCdevice* device;
	@synchronized(self)
	{
		device = alcOpenDevice([deviceName UTF8String]);
		if(NULL == device)
		{
			OAL_LOG_ERROR(@"Could not open device %@", deviceName);
		}
	}
	return device;
}

+ (bool) closeDevice:(ALCdevice*) device
{
	bool result;
	@synchronized(self)
	{
		alcCloseDevice(device);
		result = CHECK_ALC_CALL(device);
	}
	return result;
}


#pragma mark Device Extensions

+ (bool) isExtensionPresent:(ALCdevice*) device name:(NSString*) extensionName
{
	bool result;
	@synchronized(self)
	{
		result = alcIsExtensionPresent(device, [extensionName UTF8String]);
		CHECK_ALC_CALL(device);
	}
	return result;
}

+ (void*) getProcAddress:(ALCdevice*) device name:(NSString*) functionName
{
	void* result;
	@synchronized(self)
	{
		result = alcGetProcAddress(device, [functionName UTF8String]);
		CHECK_ALC_CALL(device);
	}
	return result;
}

+ (ALenum) getEnumValue:(ALCdevice*) device name:(NSString*) enumName
{
	ALenum result;
	@synchronized(self)
	{
		result = alcGetEnumValue(device, [enumName UTF8String]);
		CHECK_ALC_CALL(device);
	}
	return result;
}


#pragma mark Device Properties

+ (NSString*) getString:(ALCdevice*) device attribute:(ALenum) attribute
{
	const ALCchar* result;
	@synchronized(self)
	{
		result = alcGetString(device, attribute);
		CHECK_ALC_CALL(device);
	}
	return [NSString stringWithFormat:@"%s", result];
}

+ (NSArray*) getNullSeparatedStringList:(ALCdevice*) device attribute:(ALenum) attribute
{
	const ALCchar* result;
	@synchronized(self)
	{
		result = alcGetString(device, attribute);
		CHECK_ALC_CALL(device);
	}
	return [self decodeNullSeparatedStringList:result];
}

+ (NSArray*) getSpaceSeparatedStringList:(ALCdevice*) device attribute:(ALenum) attribute
{
	const ALCchar* result;
	@synchronized(self)
	{
		result = alcGetString(device, attribute);
		CHECK_ALC_CALL(device);
	}
	return [self decodeSpaceSeparatedStringList:result];
}

+ (ALint) getInteger:(ALCdevice*) device attribute:(ALenum) attribute
{
	ALint result = 0;
	[self getIntegerv:device attribute:attribute size:1 data:&result];
	return result;
}

+ (bool) getIntegerv:(ALCdevice*) device attribute:(ALenum) attribute size:(ALsizei) size data:(ALCint*) data
{
	bool result;
	@synchronized(self)
	{
		alcGetIntegerv(device, attribute, size, data);
		result = CHECK_ALC_CALL(device);
	}
	return result;
}


#pragma mark Capture

+ (ALCdevice*) openCaptureDevice:(NSString*) deviceName frequency:(ALCuint) frequency format:(ALCenum) format bufferSize:(ALCsizei) bufferSize
{
	ALCdevice* result;
	@synchronized(self)
	{
		result = alcCaptureOpenDevice([deviceName UTF8String], frequency, format, bufferSize);
		if(nil == result)
		{
			OAL_LOG_ERROR(@"Could not open capture device %@", deviceName);
		}
	}
	return result;
}

+ (bool) closeCaptureDevice:(ALCdevice*) device
{
	bool result;
	@synchronized(self)
	{
		alcCaptureCloseDevice(device);
		result = CHECK_ALC_CALL(device);
	}
	return result;
}

+ (bool) startCapture:(ALCdevice*) device
{
	bool result;
	@synchronized(self)
	{
		alcCaptureStop(device);
		result = CHECK_ALC_CALL(device);
	}
	return result;
}

+ (bool) stopCapture:(ALCdevice*) device
{
	bool result;
	@synchronized(self)
	{
		alcCaptureStop(device);
		result = CHECK_ALC_CALL(device);
	}
	return result;
}

+ (bool) captureSamples:(ALCdevice*) device buffer:(ALCvoid*) buffer numSamples:(ALCsizei) numSamples
{
	bool result;
	@synchronized(self)
	{
		alcCaptureSamples(device, buffer, numSamples);
		result = CHECK_ALC_CALL(device);
	}
	return result;
}


#pragma mark -
#pragma mark Context Management

+ (ALCcontext*) createContext:(ALCdevice*) device attributes:(ALCint*) attributes
{
	ALCcontext* result;
	@synchronized(self)
	{
		result = alcCreateContext(device, attributes);
		CHECK_ALC_CALL(device);
	}
	return result;
}

+ (bool) makeContextCurrent:(ALCcontext*) context
{
	return [self makeContextCurrent:context deviceReference:nil];
}

+ (bool) makeContextCurrent:(ALCcontext*) context deviceReference:(ALCdevice*) deviceReference
{
	@synchronized(self)
	{
		if(!alcMakeContextCurrent(context))
		{
			if(nil != deviceReference)
			{
				CHECK_ALC_CALL(deviceReference);
			}
			else
			{
				OAL_LOG_ERROR(@"Could not make context %p current.  Pass in a device reference for better diagnostic info.", context);
			}
			return NO;
		}
	}
	return YES;
}

+ (void) processContext:(ALCcontext*) context
{
	@synchronized(self)
	{
		alcProcessContext(context);
		// No way to check for error from here
	}
}

+ (void) suspendContext:(ALCcontext*) context
{
	@synchronized(self)
	{
		alcSuspendContext(context);
		// No way to check for error from here
	}
}

+ (void) destroyContext:(ALCcontext*) context
{
	@synchronized(self)
	{
		alcDestroyContext(context);
		// No way to check for error from here
	}
}

+ (ALCcontext*) getCurrentContext
{
	ALCcontext* result;
	@synchronized(self)
	{
		result = alcGetCurrentContext();
	}
	return result;
}

+ (ALCdevice*) getContextsDevice:(ALCcontext*) context
{
	return [self getContextsDevice:context deviceReference:nil];
}

+ (ALCdevice*) getContextsDevice:(ALCcontext*) context deviceReference:(ALCdevice*) deviceReference
{
	ALCdevice* result;
	@synchronized(self)
	{
		if(nil == (result = alcGetContextsDevice(context)))
		{
			if(nil != deviceReference)
			{
				CHECK_ALC_CALL(deviceReference);
			}
			else
			{
				OAL_LOG_ERROR(@"Could not get device for context %p.  Pass in a device reference for better diagnostic info.", context);
			}
		}
	}
	return result;
}


#pragma mark Context Properties

+ (bool) getBoolean:(ALenum) parameter
{
	ALboolean result;
	@synchronized(self)
	{
		result = alGetBoolean(parameter);
		CHECK_AL_CALL();
	}
	return result;
}

+ (ALdouble) getDouble:(ALenum) parameter
{
	ALdouble result;
	@synchronized(self)
	{
		result = alGetDouble(parameter);
		CHECK_AL_CALL();
	}
	return result;
}

+ (ALfloat) getFloat:(ALenum) parameter
{
	ALfloat result;
	@synchronized(self)
	{
		result = alGetFloat(parameter);
		CHECK_AL_CALL();
	}
	return result;
}

+ (ALint) getInteger:(ALenum) parameter
{
	ALint result;
	@synchronized(self)
	{
		result = alGetInteger(parameter);
		CHECK_AL_CALL();
	}
	return result;
}

+ (NSString*) getString:(ALenum) parameter
{
	const ALchar* result;
	@synchronized(self)
	{
		result = alGetString(parameter);
		CHECK_AL_CALL();
	}
	return [NSString stringWithFormat:@"%s", result];
}

+ (NSArray*) getNullSeparatedStringList:(ALenum) parameter
{
	const ALchar* result;
	@synchronized(self)
	{
		result = alGetString(parameter);
		CHECK_AL_CALL();
	}
	return [self decodeNullSeparatedStringList:result];
}

+ (NSArray*) getSpaceSeparatedStringList:(ALenum) parameter
{
	const ALchar* result;
	@synchronized(self)
	{
		result = alGetString(parameter);
		CHECK_AL_CALL();
	}
	return [self decodeSpaceSeparatedStringList:result];
}

+ (bool) getBooleanv:(ALenum) parameter values:(ALboolean*) values
{
	bool result;
	@synchronized(self)
	{
		alGetBooleanv(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getDoublev:(ALenum) parameter values:(ALdouble*) values
{
	bool result;
	@synchronized(self)
	{
		alGetDoublev(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getFloatv:(ALenum) parameter values:(ALfloat*) values
{
	bool result;
	@synchronized(self)
	{
		alGetFloatv(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getIntegerv:(ALenum) parameter values:(ALint*) values
{
	bool result;
	@synchronized(self)
	{
		alGetIntegerv(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) distanceModel:(ALenum) value
{
	bool result;
	@synchronized(self)
	{
		alDistanceModel(value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) dopplerFactor:(ALfloat) value
{
	bool result;
	@synchronized(self)
	{
		alDopplerFactor(value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) speedOfSound:(ALfloat) value
{
	bool result;
	@synchronized(self)
	{
		alSpeedOfSound(value);
		result = CHECK_AL_CALL();
	}
	return result;
}


#pragma mark -
#pragma mark Listener Properties

+ (bool) listenerf:(ALenum) parameter value:(ALfloat) value
{
	bool result;
	@synchronized(self)
	{
		alListenerf(parameter, value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) listener3f:(ALenum) parameter v1:(ALfloat) v1 v2:(ALfloat) v2 v3:(ALfloat) v3
{
	bool result;
	@synchronized(self)
	{
		alListener3f(parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) listenerfv:(ALenum) parameter values:(ALfloat*) values
{
	bool result;
	@synchronized(self)
	{
		alListenerfv(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) listeneri:(ALenum) parameter value:(ALint) value
{
	bool result;
	@synchronized(self)
	{
		alListeneri(parameter, value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) listener3i:(ALenum) parameter v1:(ALint) v1 v2:(ALint) v2 v3:(ALint) v3
{
	bool result;
	@synchronized(self)
	{
		alListener3i(parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) listeneriv:(ALenum) parameter values:(ALint*) values
{
	bool result;
	@synchronized(self)
	{
		alListeneriv(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}


+ (ALfloat) getListenerf:(ALenum) parameter
{
	ALfloat value;
	@synchronized(self)
	{
		alGetListenerf(parameter, &value);
		CHECK_AL_CALL();
	}
	return value;
}

+ (bool) getListener3f:(ALenum) parameter v1:(ALfloat*) v1 v2:(ALfloat*) v2 v3:(ALfloat*) v3
{
	bool result;
	@synchronized(self)
	{
		alGetListener3f(parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getListenerfv:(ALenum) parameter values:(ALfloat*) values
{
	bool result;
	@synchronized(self)
	{
		alGetListenerfv(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (ALint) getListeneri:(ALenum) parameter
{
	ALint value;
	@synchronized(self)
	{
		alGetListeneri(parameter, &value);
		CHECK_AL_CALL();
	}
	return value;
}

+ (bool) getListener3i:(ALenum) parameter v1:(ALint*) v1 v2:(ALint*) v2 v3:(ALint*) v3
{
	bool result;
	@synchronized(self)
	{
		alGetListener3i(parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getListeneriv:(ALenum) parameter values:(ALint*) values
{
	bool result;
	@synchronized(self)
	{
		alGetListeneriv(parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}


#pragma mark -
#pragma mark Source Management

+ (bool) genSources:(ALuint*) sourceIds numSources:(ALsizei) numSources
{
	bool result;
	@synchronized(self)
	{
		alGenSources(numSources, sourceIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (ALuint) genSource
{
	ALuint sourceId;
	@synchronized(self)
	{
		[self genSources:&sourceId numSources:1];
		sourceId = CHECK_AL_CALL() ? sourceId : (ALuint)AL_INVALID;
	}
	return sourceId;
}

+ (bool) deleteSources:(ALuint*) sourceIds numSources:(ALsizei) numSources
{
	bool result;
	@synchronized(self)
	{
		alDeleteSources(numSources, sourceIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) deleteSource:(ALuint) sourceId
{
	bool result;
	@synchronized(self)
	{
		[self deleteSources:&sourceId numSources:1];
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) isSource:(ALuint) sourceId
{
	bool result;
	@synchronized(self)
	{
		result = alIsSource(sourceId);
		CHECK_AL_CALL();
	}
	return result;
}


#pragma mark Source Properties

+ (bool) sourcef:(ALuint) sourceId parameter:(ALenum) parameter value:(ALfloat) value
{
	bool result;
	@synchronized(self)
	{
		alSourcef(sourceId, parameter, value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) source3f:(ALuint) sourceId parameter:(ALenum) parameter v1:(ALfloat) v1 v2:(ALfloat) v2 v3:(ALfloat) v3
{
	bool result;
	@synchronized(self)
	{
		alSource3f(sourceId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourcefv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALfloat*) values
{
	bool result;
	@synchronized(self)
	{
		alSourcefv(sourceId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourcei:(ALuint) sourceId parameter:(ALenum) parameter value:(ALint) value
{
	bool result;
	@synchronized(self)
	{
		alSourcei(sourceId, parameter, value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) source3i:(ALuint) sourceId parameter:(ALenum) parameter v1:(ALint) v1 v2:(ALint) v2 v3:(ALint) v3
{
	bool result;
	@synchronized(self)
	{
		alSource3i(sourceId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourceiv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALint*) values
{
	bool result;
	@synchronized(self)
	{
		alSourceiv(sourceId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}


+ (ALfloat) getSourcef:(ALuint) sourceId parameter:(ALenum) parameter
{
	ALfloat value;
	@synchronized(self)
	{
		alGetSourcef(sourceId, parameter, &value);
		CHECK_AL_CALL();
	}
	return value;
}

+ (bool) getSource3f:(ALuint) sourceId parameter:(ALenum) parameter v1:(ALfloat*) v1 v2:(ALfloat*) v2 v3:(ALfloat*) v3
{
	bool result;
	@synchronized(self)
	{
		alGetSource3f(sourceId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getSourcefv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALfloat*) values
{
	bool result;
	@synchronized(self)
	{
		alGetSourcefv(sourceId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (ALint) getSourcei:(ALuint) sourceId parameter:(ALenum) parameter
{
	ALint value;
	@synchronized(self)
	{
		alGetSourcei(sourceId, parameter, &value);
		CHECK_AL_CALL();
	}
	return value;
}

+ (bool) getSource3i:(ALuint) sourceId parameter:(ALenum) parameter v1:(ALint*) v1 v2:(ALint*) v2 v3:(ALint*) v3
{
	bool result;
	@synchronized(self)
	{
		alGetSource3i(sourceId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getSourceiv:(ALuint) sourceId parameter:(ALenum) parameter values:(ALint*) values
{
	bool result;
	@synchronized(self)
	{
		alGetSourceiv(sourceId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}


#pragma mark Source Playback

+ (bool) sourcePlay:(ALuint) sourceId
{
	bool result;
	@synchronized(self)
	{
		alSourcePlay(sourceId);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourcePlayv:(ALuint*) sourceIds numSources:(ALsizei) numSources
{
	bool result;
	@synchronized(self)
	{
		alSourcePlayv(numSources, sourceIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourcePause:(ALuint) sourceId
{
	bool result;
	@synchronized(self)
	{
		alSourcePause(sourceId);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourcePausev:(ALuint*) sourceIds numSources:(ALsizei) numSources
{
	bool result;
	@synchronized(self)
	{
		alSourcePausev(numSources, sourceIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourceStop:(ALuint) sourceId
{
	bool result;
	@synchronized(self)
	{
		alSourceStop(sourceId);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourceStopv:(ALuint*) sourceIds numSources:(ALsizei) numSources
{
	bool result;
	@synchronized(self)
	{
		alSourceStopv(numSources, sourceIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourceRewind:(ALuint) sourceId
{
	bool result;
	@synchronized(self)
	{
		alSourceRewind(sourceId);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourceRewindv:(ALuint*) sourceIds numSources:(ALsizei) numSources
{
	bool result;
	@synchronized(self)
	{
		alSourceRewindv(numSources, sourceIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourceQueueBuffers:(ALuint) sourceId numBuffers:(ALsizei) numBuffers bufferIds:(ALuint*) bufferIds
{
	bool result;
	@synchronized(self)
	{
		alSourceQueueBuffers(sourceId, numBuffers, bufferIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) sourceUnqueueBuffers:(ALuint) sourceId numBuffers:(ALsizei) numBuffers bufferIds:(ALuint*) bufferIds
{
	bool result;
	@synchronized(self)
	{
		alSourceUnqueueBuffers(sourceId, numBuffers, bufferIds);
		result = CHECK_AL_CALL();
	}
	return result;
}


#pragma mark -
#pragma mark Buffer Management

+ (bool) genBuffers:(ALuint*) bufferIds numBuffers:(ALsizei) numBuffers
{
	bool result;
	@synchronized(self)
	{
		alGenBuffers(numBuffers, bufferIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (ALuint) genBuffer
{
	ALuint bufferId;
	@synchronized(self)
	{
		[self genBuffers:&bufferId numBuffers:1];
		bufferId = CHECK_AL_CALL() ? bufferId : (ALuint)AL_INVALID;
	}
	return bufferId;
}

+ (bool) deleteBuffers:(ALuint*) bufferIds numBuffers:(ALsizei) numBuffers
{
	bool result;
	@synchronized(self)
	{
		alDeleteBuffers(numBuffers, bufferIds);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) deleteBuffer:(ALuint) bufferId
{
	bool result;
	@synchronized(self)
	{
		[self deleteBuffers:&bufferId numBuffers:1];
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) isBuffer:(ALuint) bufferId
{
	bool result;
	@synchronized(self)
	{
		result = alIsBuffer(bufferId);
		CHECK_AL_CALL();
	}
	return result;
}

+ (bool) bufferData:(ALuint) bufferId format:(ALenum) format data:(const ALvoid*) data size:(ALsizei) size frequency:(ALsizei) frequency
{
	bool result;
	@synchronized(self)
	{
		alBufferData(bufferId, format, data, size, frequency);
		result = CHECK_AL_CALL();
	}
	return result;
}


#pragma mark Buffer Properties

+ (bool) bufferf:(ALuint) bufferId parameter:(ALenum) parameter value:(ALfloat) value
{
	bool result;
	@synchronized(self)
	{
		alBufferf(bufferId, parameter, value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) buffer3f:(ALuint) bufferId parameter:(ALenum) parameter v1:(ALfloat) v1 v2:(ALfloat) v2 v3:(ALfloat) v3
{
	bool result;
	@synchronized(self)
	{
		alBuffer3f(bufferId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) bufferfv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALfloat*) values
{
	bool result;
	@synchronized(self)
	{
		alBufferfv(bufferId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) bufferi:(ALuint) bufferId parameter:(ALenum) parameter value:(ALint) value
{
	bool result;
	@synchronized(self)
	{
		alBufferi(bufferId, parameter, value);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) buffer3i:(ALuint) bufferId parameter:(ALenum) parameter v1:(ALint) v1 v2:(ALint) v2 v3:(ALint) v3
{
	bool result;
	@synchronized(self)
	{
		alBuffer3i(bufferId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) bufferiv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALint*) values
{
	bool result;
	@synchronized(self)
	{
		alBufferiv(bufferId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}


+ (ALfloat) getBufferf:(ALuint) bufferId parameter:(ALenum) parameter
{
	ALfloat value;
	@synchronized(self)
	{
		alGetBufferf(bufferId, parameter, &value);
		CHECK_AL_CALL();
	}
	return value;
}

+ (bool) getBuffer3f:(ALuint) bufferId parameter:(ALenum) parameter v1:(ALfloat*) v1 v2:(ALfloat*) v2 v3:(ALfloat*) v3
{
	bool result;
	@synchronized(self)
	{
		alGetBuffer3f(bufferId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getBufferfv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALfloat*) values
{
	bool result;
	@synchronized(self)
	{
		alGetBufferfv(bufferId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (ALint) getBufferi:(ALuint) bufferId parameter:(ALenum) parameter
{
	ALint value;
	@synchronized(self)
	{
		alGetBufferi(bufferId, parameter, &value);
		CHECK_AL_CALL();
	}
	return value;
}

+ (bool) getBuffer3i:(ALuint) bufferId parameter:(ALenum) parameter v1:(ALint*) v1 v2:(ALint*) v2 v3:(ALint*) v3
{
	bool result;
	@synchronized(self)
	{
		alGetBuffer3i(bufferId, parameter, v1, v2, v3);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) getBufferiv:(ALuint) bufferId parameter:(ALenum) parameter values:(ALint*) values
{
	bool result;
	@synchronized(self)
	{
		alGetBufferiv(bufferId, parameter, values);
		result = CHECK_AL_CALL();
	}
	return result;
}


#pragma mark -
#pragma mark Apple Extensions

+ (void) initialize
{
    alcGetMacOSXMixerOutputRate = (alcMacOSXGetMixerOutputRateProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcMacOSXGetMixerOutputRate");
    alcMacOSXMixerOutputRate = (alcMacOSXMixerOutputRateProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcMacOSXMixerOutputRate");
    alcMacOSXRenderingQuality = (alcMacOSXRenderingQualityProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcMacOSXRenderingQuality");
    alcMacOSXGetRenderingQuality = (alcMacOSXGetRenderingQualityProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcMacOSXGetRenderingQuality");
    alBufferDataStatic = (alBufferDataStaticProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alBufferDataStatic");

    alcASAGetListener = (alcASAGetListenerProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcASAGetListener");
    alcASASetListener = (alcASASetListenerProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcASASetListener");
    alcASAGetSource = (alcASAGetSourceProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcASAGetSource");
    alcASASetSource = (alcASASetSourceProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcASASetSource");

    alSourceAddNotification = (alSourceAddNotificationProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alSourceAddNotification");
    alSourceRemoveNotification = (alSourceRemoveNotificationProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alSourceRemoveNotification");
}

+ (ALdouble) getMixerOutputDataRate
{
	if(NULL == alcGetMacOSXMixerOutputRate)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcGetMacOSXMixerOutputRate. Returning 0");
        return 0;
	}
	
	ALdouble result;
	@synchronized(self)
	{
		result = alcGetMacOSXMixerOutputRate();
		CHECK_AL_CALL();
	}
	return result;
}

+ (bool) setMixerOutputDataRate:(ALdouble) frequency
{
	if(NULL == alcMacOSXMixerOutputRate)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcMacOSXMixerOutputRate");
        return false;
	}
	
	bool result;
	@synchronized(self)
	{
        alcMacOSXMixerOutputRate(frequency);
		result = CHECK_AL_CALL();
    }
    return result;
}

+ (bool) bufferDataStatic:(ALuint) bufferId format:(ALenum) format data:(const ALvoid*) data size:(ALsizei) size frequency:(ALsizei) frequency
{
	if(NULL == alBufferDataStatic)
	{
        OAL_LOG_WARNING(@"No proc ptr for alBufferDataStatic. Returning false");
        return false;
	}
	
	bool result;
	@synchronized(self)
	{
		alBufferDataStatic((ALint)bufferId, format, data, size, frequency);
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) asaGetListenerb:(ALuint) property
{
	if(NULL == alcASAGetListener)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASAGetListener. Returning false");
        return false;
	}
	
    ALuint value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
	{
        alcASAGetListener(property, &value, &size);
        CHECK_AL_CALL();
    }
    return value;
}

+ (ALint) asaGetListeneri:(ALuint) property
{
	if(NULL == alcASAGetListener)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASAGetListener. Returning -1");
        return -1;
	}
	
    ALint value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
	{
        alcASAGetListener(property, &value, &size);
        CHECK_AL_CALL();
    }
    return value;
}

+ (ALfloat) asaGetListenerf:(ALuint) property
{
	if(NULL == alcASAGetListener)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASAGetListener. Returning 0");
        return 0;
	}
	
    ALfloat value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
	{
        alcASAGetListener(property, &value, &size);
        CHECK_AL_CALL();
    }
    return value;
}

+ (bool) asaListenerb:(ALuint) property value:(bool) value
{
	if(NULL == alcASASetListener)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetListener");
        return false;
	}
	
    bool result;
    ALuint v = value;
	@synchronized(self)
	{
        alcASASetListener(property, &v, sizeof(v));
		result = CHECK_AL_CALL();
	}
	return result;

}

+ (bool) asaListeneri:(ALuint) property value:(ALint) value
{
	if(NULL == alcASASetListener)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetListener");
        return false;
	}
	
    bool result;
    ALint v = value;
	@synchronized(self)
	{
        alcASASetListener(property, &v, sizeof(v));
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) asaListenerf:(ALuint) property value:(ALfloat) value
{
	if(NULL == alcASASetListener)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetListener");
        return false;
	}
	
    bool result;
    ALfloat v = value;
	@synchronized(self)
	{
        alcASASetListener(property, &v, sizeof(v));
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) asaGetSourceb:(ALuint) sourceId property:(ALuint) property
{
	ALint value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
	{
        alcASAGetSource(property, sourceId, &value, &size);
		CHECK_AL_CALL();
	}
	return value;
}

+ (ALint) asaGetSourcei:(ALuint) sourceId property:(ALuint) property
{
	ALint value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
	{
        alcASAGetSource(property, sourceId, &value, &size);
		CHECK_AL_CALL();
	}
	return value;
}

+ (ALfloat) asaGetSourcef:(ALuint) sourceId property:(ALuint) property
{
	ALfloat value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
	{
        alcASAGetSource(property, sourceId, &value, &size);
		CHECK_AL_CALL();
	}
	return value;
}

+ (bool) asaSourceb:(ALuint) sourceId property:(ALuint) property value:(bool) value
{
	if(NULL == alcASASetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetSource");
        return false;
	}
	
    bool result;
    ALint v = value;
	@synchronized(self)
    {
        alcASASetSource(property, sourceId, &v, sizeof(v));
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) asaSourcei:(ALuint) sourceId property:(ALuint) property value:(ALint) value
{
	if(NULL == alcASASetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetSource");
        return false;
	}
	
    bool result;
    ALint v = value;
	@synchronized(self)
    {
        alcASASetSource(property, sourceId, &v, sizeof(v));
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) asaSourcef:(ALuint) sourceId property:(ALuint) property value:(ALfloat) value
{
	if(NULL == alcASASetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetSource");
        return false;
	}

    bool result;
    ALfloat v = value;
	@synchronized(self)
    {
        alcASASetSource(property, sourceId, &v, sizeof(v));
		result = CHECK_AL_CALL();
	}
	return result;
}

+ (bool) setReverbSendLevel:(float) level onSource:(ALuint) sourceID
{
	if(NULL == alcASASetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetSource");
        return false;
	}
	
    bool result;
    ALfloat value = level;
	@synchronized(self)
    {
        alcASASetSource(ALC_ASA_REVERB_SEND_LEVEL, sourceID, &value, sizeof(value));
		result = CHECK_AL_CALL();
	}
    return result;
}

+ (float) getSourceReverbSendLevel:(ALuint) sourceID
{
	if(NULL == alcASAGetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASAGetSource. Returning 0");
        return 0;
	}
	
    ALfloat value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
    {
        alcASAGetSource(ALC_ASA_REVERB_SEND_LEVEL, sourceID, &value, &size);
		CHECK_AL_CALL();
	}
    return value;
}

+ (bool) setOcclusion:(float) occlusion onSource:(ALuint) sourceID
{
	if(NULL == alcASASetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetSource");
        return false;
	}

	bool result;
    ALfloat value = occlusion;
	@synchronized(self)
    {
        alcASASetSource(ALC_ASA_OCCLUSION, sourceID, &value, sizeof(value));
		result = CHECK_AL_CALL();
	}
    return result;
}

+ (float) getSourceOcclusion:(ALuint) sourceID
{
	if(NULL == alcASAGetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASAGetSource. Returning 0");
        return 0;
	}
	
    ALfloat value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
    {
        alcASAGetSource(ALC_ASA_OCCLUSION, sourceID, &value, &size);
		CHECK_AL_CALL();
	}
    return value;
}

+ (bool) setObstruction:(float) obstruction onSource:(ALuint) sourceID
{
	if(NULL == alcASASetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASASetSource");
        return false;
	}
	
	bool result;
    ALfloat value = obstruction;
	@synchronized(self)
    {
        alcASASetSource(ALC_ASA_OBSTRUCTION, sourceID, &value, sizeof(value));
		result = CHECK_AL_CALL();
	}
    return result;
}

+ (float) getSourceObstruction:(ALuint) sourceID
{
	if(NULL == alcASAGetSource)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcASAGetSource. Returning 0");
        return 0;
	}
	
    ALfloat value = 0;
    ALuint size = sizeof(value);
	@synchronized(self)
    {
        alcASAGetSource(ALC_ASA_OBSTRUCTION, sourceID, &value, &size);
		CHECK_AL_CALL();
	}
    return value;
}

+ (bool) setRenderingQuality:(ALint) quality
{
	if(NULL == alcMacOSXRenderingQuality)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcMacOSXRenderingQuality");
        return false;
	}

	bool result;
	@synchronized(self)
    {
        alcMacOSXRenderingQuality(quality);
		result = CHECK_AL_CALL();
	}
    return result;
}

+ (ALint) getRenderingQuality
{
	if(NULL == alcMacOSXGetRenderingQuality)
	{
        OAL_LOG_WARNING(@"No proc ptr for alcMacOSXGetRenderingQuality. Returning 0");
        return 0;
	}

    ALint value = 0;
    @synchronized(self)
    {
        value = alcMacOSXGetRenderingQuality();
		CHECK_AL_CALL();
	}
    return value;
}

+ (bool) addNotification:(ALuint) notificationID
                onSource:(ALuint) source
                callback:(alSourceNotificationProc) callback
                userData:(void*) userData
{
	if(NULL == alSourceAddNotification)
	{
        OAL_LOG_WARNING(@"No proc ptr for alSourceAddNotification");
        return false;
	}

	bool result;
	@synchronized(self)
    {
        alSourceAddNotification(source, notificationID, callback, userData);
		result = CHECK_AL_CALL();
	}
    return result;
}

+ (bool) removeNotification:(ALuint) notificationID
                   onSource:(ALuint) source
                   callback:(alSourceNotificationProc) callback
                   userData:(void*) userData
{
	if(NULL == alSourceRemoveNotification)
	{
        OAL_LOG_WARNING(@"No proc ptr for alSourceRemoveNotification");
        return false;
	}

	bool result;
	@synchronized(self)
    {
        alSourceRemoveNotification(source, notificationID, callback, userData);
		result = CHECK_AL_CALL();
	}
    return result;
}

@end
