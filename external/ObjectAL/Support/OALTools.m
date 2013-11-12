//
//  OALTools.m
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

#import "OALTools.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "OALNotifications.h"
#import "CCFileUtils.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation OALTools

static NSBundle* g_defaultBundle;

+ (void) initialize
{
    g_defaultBundle = as_retain([NSBundle mainBundle]);
}

+ (void) setDefaultBundle:(NSBundle*) bundle
{
    as_autorelease_noref(g_defaultBundle);
    g_defaultBundle = as_retain(bundle);
}

+ (NSBundle*) defaultBundle
{
    return g_defaultBundle;
}

+ (NSURL*) urlForPath:(NSString*) path
{
    return [self urlForPath:path bundle:g_defaultBundle];
}

+ (NSURL*) urlForPath:(NSString*) path bundle:(NSBundle*) bundle
{
	if(nil == path)
	{
		return nil;
	}
	
    NSString* fullPath = [[CCFileUtils sharedFileUtils] fullPathForFilename:path];
    if(nil == fullPath)
    {
        OAL_LOG_ERROR(@"Could not find full path of file %@", path);
        return nil;
    }
	
	return [NSURL fileURLWithPath:fullPath];
}

+ (void) notifyExtAudioError:(OSStatus)errorCode
				 function:(const char*) function
			  description:(NSString*) description, ...
{
	if(noErr != errorCode)
	{
		NSString* errorString;
		
		switch(errorCode)
		{
#ifdef __IPHONE_3_1
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_1
			case kExtAudioFileError_CodecUnavailableInputConsumed:
				errorString = @"Write function interrupted - last buffer written";
				break;
			case kExtAudioFileError_CodecUnavailableInputNotConsumed:
				errorString = @"Write function interrupted - last buffer not written";
				break;
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_1 */
#endif /* __IPHONE_3_1 */
			case kExtAudioFileError_InvalidProperty:
				errorString = @"Invalid property";
				break;
			case kExtAudioFileError_InvalidPropertySize:
				errorString = @"Invalid property size";
				break;
			case kExtAudioFileError_NonPCMClientFormat:
				errorString = @"Non-PCM client format";
				break;
			case kExtAudioFileError_InvalidChannelMap:
				errorString = @"Wrong number of channels for format";
				break;
			case kExtAudioFileError_InvalidOperationOrder:
				errorString = @"Invalid operation order";
				break;
			case kExtAudioFileError_InvalidDataFormat:
				errorString = @"Invalid data format";
				break;
			case kExtAudioFileError_MaxPacketSizeUnknown:
				errorString = @"Max packet size unknown";
				break;
			case kExtAudioFileError_InvalidSeek:
				errorString = @"Seek offset out of bounds";
				break;
			case kExtAudioFileError_AsyncWriteTooLarge:
				errorString = @"Async write too large";
				break;
			case kExtAudioFileError_AsyncWriteBufferOverflow:
				errorString = @"Async write could not be completed in time";
				break;
			default:
				errorString = @"Unknown ext audio error";
		}

		va_list args;
		va_start(args, description);
		description = [[NSString alloc] initWithFormat:description arguments:args];
		va_end(args);
		OAL_LOG_ERROR_CONTEXT(function, @"%@ (error code 0x%08lx: %@)", description, (unsigned long)errorCode, errorString);
		as_release(description);
	}
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
+ (void) notifyAudioSessionError:(OSStatus)errorCode
					 function:(const char*) function
				  description:(NSString*) description, ...
{
	if(noErr != errorCode)
	{
		NSString* errorString;
		bool postNotification = NO;
		
		switch(errorCode)
		{
			case kAudioSessionNotInitialized:
				errorString = @"Audio session not initialized";
				postNotification = YES;
				break;
			case kAudioSessionAlreadyInitialized:
				errorString = @"Audio session already initialized";
				postNotification = YES;
				break;
			case kAudioSessionInitializationError:
				errorString = @"Audio sesion initialization error";
				postNotification = YES;
				break;
			case kAudioSessionUnsupportedPropertyError:
				errorString = @"Unsupported audio session property";
				break;
			case kAudioSessionBadPropertySizeError:
				errorString = @"Bad audio session property size";
				break;
			case kAudioSessionNotActiveError:
				errorString = @"Audio session is not active";
				postNotification = YES;
				break;
#if 0 // Documented but not implemented on iOS
			case kAudioSessionNoHardwareError:
				errorString = @"Hardware not available for audio session";
				postNotification = YES;
				break;
#endif
#ifdef __IPHONE_3_1
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_1
			case kAudioSessionNoCategorySet:
				errorString = @"No audio session category set";
				postNotification = YES;
				break;
			case kAudioSessionIncompatibleCategory:
				errorString = @"Incompatible audio session category";
				postNotification = YES;
				break;
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_1 */
#endif /* __IPHONE_3_1 */
			default:
				errorString = @"Unknown audio session error";
				postNotification = YES;
		}

#if OBJECTAL_CFG_LOG_LEVEL > 0
		va_list args;
		va_start(args, description);
		description = [[NSString alloc] initWithFormat:description arguments:args];
		va_end(args);
		OAL_LOG_ERROR_CONTEXT(function, @"%@ (error code 0x%08x: %@)", description, errorCode, errorString);
		as_release(description);
#else
        #pragma unused(function)
        #pragma unused(description)
        #pragma unused(errorString)
#endif /* OBJECTAL_CFG_LOG_LEVEL > 0 */
		
		if(postNotification)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:OALAudioErrorNotification object:self];
		}
	}
}
#else
+ (void) notifyAudioSessionError:(__unused OSStatus)errorCode
                        function:(__unused const char*) function
                     description:(__unused NSString*) description, ...
{

}
#endif

@end
