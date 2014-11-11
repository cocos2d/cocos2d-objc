//
//  ObjectALMacros.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-08-02.
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

#import "ObjectALConfig.h"
#import "OALTools.h"


/* Don't clobber any existing defines by the same name */
#ifdef LEVEL_NONE
#define OAL_BAK_LEVEL_NONE LEVEL_NONE
#undef LEVEL_NONE
#endif
#ifdef LEVEL_ERROR
#define OAL_BAK_LEVEL_ERROR LEVEL_ERROR
#undef LEVEL_ERROR
#endif
#ifdef LEVEL_WARNING
#define OAL_BAK_LEVEL_WARNING LEVEL_WARNING
#undef LEVEL_WARNING
#endif
#ifdef LEVEL_INFO
#define OAL_BAK_LEVEL_INFO LEVEL_INFO
#undef LEVEL_INFO
#endif
#ifdef LEVEL_DEBUG
#define OAL_BAK_LEVEL_DEBUG LEVEL_DEBUG
#undef LEVEL_DEBUG
#endif
#define LEVEL_NONE 0
#define LEVEL_ERROR 1
#define LEVEL_WARNING 2
#define LEVEL_INFO 3
#define LEVEL_DEBUG 4


#pragma mark -
#pragma mark Configuration


#pragma mark -
#pragma mark ARC

#pragma mark -
#pragma mark Synchronization

#if OBJECTAL_CFG_SYNCHRONIZED_OPERATIONS

#define OPTIONALLY_SYNCHRONIZED(A) @synchronized(A)

#else

#define OPTIONALLY_SYNCHRONIZED(A)

#endif /* OBJECTAL_CFG_SYNCHRONIZED_OPERATIONS */


#pragma mark -
#pragma mark Logging


#pragma mark -
#pragma mark General Logging

/** Base log call. This is called by other logging macros.
 *
 * @param FMT_STRING The format string to use. Must contain %s for the context and %@ for the message.
 * @param CONTEXT The calling context, as a C string (typically __PRETTY_FUNCTION__).
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#define OAL_LOG_BASE(FMT_STRING, CONTEXT, FMT, ...)	\
	NSLog(FMT_STRING, (CONTEXT), [NSString stringWithFormat:(FMT), ##__VA_ARGS__])

/** Write a "Debug" log entry.
 *
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#if OBJECTAL_CFG_LOG_LEVEL >= 4
#define OAL_LOG_DEBUG(FMT, ...) OAL_LOG_BASE(@"OAL Debug: %s: %@", __PRETTY_FUNCTION__, FMT, ##__VA_ARGS__)
#else /* OBJECTAL_CFG_LOG_LEVEL */
#define OAL_LOG_DEBUG(FMT, ...)
#endif /* OBJECTAL_CFG_LOG_LEVEL */

/** Write an "Info" log entry.
 *
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#if OBJECTAL_CFG_LOG_LEVEL >= 3
#define OAL_LOG_INFO(FMT, ...) OAL_LOG_BASE(@"OAL Info: %s: %@", __PRETTY_FUNCTION__, FMT, ##__VA_ARGS__)
#else /* OBJECTAL_CFG_LOG_LEVEL */
#define OAL_LOG_INFO(FMT, ...)
#endif /* OBJECTAL_CFG_LOG_LEVEL */

/** Write a "Warning" log entry.
 *
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#if OBJECTAL_CFG_LOG_LEVEL >= 2
#define OAL_LOG_WARNING(FMT, ...) OAL_LOG_BASE(@"OAL Warning: %s: %@", __PRETTY_FUNCTION__, FMT, ##__VA_ARGS__)
#else /* OBJECTAL_CFG_LOG_LEVEL */
#define OAL_LOG_WARNING(FMT, ...)
#endif /* OBJECTAL_CFG_LOG_LEVEL */

/** Write an "Error" log entry.
 *
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#if OBJECTAL_CFG_LOG_LEVEL >= 1
#define OAL_LOG_ERROR(FMT, ...) OAL_LOG_BASE(@"OAL Error: %s: %@", __PRETTY_FUNCTION__, FMT, ##__VA_ARGS__)
#else /* OBJECTAL_CFG_LOG_LEVEL */
#define OAL_LOG_ERROR(FMT, ...)
#endif /* OBJECTAL_CFG_LOG_LEVEL */

/** Write an "Error" log entry with context.
 *
 * @param CONTEXT The calling context, as a C string (typically __PRETTY_FUNCTION__).
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#if OBJECTAL_CFG_LOG_LEVEL >= 1
#define OAL_LOG_ERROR_CONTEXT(CONTEXT, FMT, ...) OAL_LOG_BASE(@"OAL Error: %s: %@", CONTEXT, FMT, ##__VA_ARGS__)
#else /* OBJECTAL_CFG_LOG_LEVEL */
#define OAL_LOG_ERROR_CONTEXT(CONTEXT, FMT, ...)
#endif /* OBJECTAL_CFG_LOG_LEVEL */

#pragma mark -
#pragma mark Special Purpose Logging

/** Report on the specified AudioSession error code, logging an error if the code does not indicate success.
 *
 * @param ERROR_CODE The error code.
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#define REPORT_AUDIOSESSION_CALL(ERROR_CODE, FMT, ...) \
if(noErr != (ERROR_CODE)) \
{ \
	[OALTools notifyAudioSessionError:(ERROR_CODE) function:__PRETTY_FUNCTION__ description:(FMT), ##__VA_ARGS__]; \
}


#if OBJECTAL_CFG_LOG_LEVEL > 0

/** Report on the specified ExtAudio error code, logging an error if the code does not indicate success.
 *
 * @param ERROR_CODE The error code.
 * @param FMT Message with NSLog() style formatting.
 * @param ... Arguments
 */
#define REPORT_EXTAUDIO_CALL(ERROR_CODE, FMT, ...) \
if(noErr != (ERROR_CODE)) \
{ \
	[OALTools notifyExtAudioError:(ERROR_CODE) function:__PRETTY_FUNCTION__ description:(FMT), ##__VA_ARGS__]; \
}

#else

// ExtAudio calls aren't dependent on the audio session so we'd never post an audio session error from here.
#define REPORT_EXTAUDIO_CALL(ERROR_CODE, FMT, ...)

#endif /* OBJECTAL_CFG_LOG_LEVEL > 0 */



/* Restore any backed up defines */
#undef LEVEL_ERROR
#ifdef OAL_BAK_LEVEL_ERROR
#define LEVEL_ERROR OAL_BAK_LEVEL_ERROR
#undef OAL_BAK_LEVEL_ERROR
#endif
#undef LEVEL_WARNING
#ifdef OAL_BAK_LEVEL_WARNING
#define LEVEL_WARNING OAL_BAK_LEVEL_WARNING
#undef OAL_BAK_LEVEL_WARNING
#endif
#undef LEVEL_INFO
#ifdef OAL_BAK_LEVEL_INFO
#define LEVEL_INFO OAL_BAK_LEVEL_INFO
#undef OAL_BAK_LEVEL_INFO
#endif
#undef LEVEL_DEBUG
#ifdef OAL_BAK_LEVEL_DEBUG
#define LEVEL_DEBUG OAL_BAK_LEVEL_DEBUG
#undef OAL_BAK_LEVEL_DEBUG
#endif
