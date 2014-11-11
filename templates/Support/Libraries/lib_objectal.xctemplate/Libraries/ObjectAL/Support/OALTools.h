//
//  OALTools.h
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


/**
 * Miscellaneous tools used by ObjectAL.
 */
@interface OALTools : NSObject
{
}

/** Set the default bundle to use when looking up paths.
 *
 * @param bundle The new default bundle.
 */
+ (void) setDefaultBundle:(NSBundle*) bundle;

/** The default bundle used when looking up paths.
 *
 * return The default bundle.
 */
+ (NSBundle*) defaultBundle;

/** Returns the URL corresponding to the specified path.
 * If the path is not absolute (starts with a "/"), this method will look for
 * the file in the default bundle.
 *
 * @param path The path to convert to a URL.
 * @return The corresponding URL or nil if a URL could not be formed.
 */
+ (NSURL*) urlForPath:(NSString*) path;

/** Returns the URL corresponding to the specified path.
 * If the path is not absolute (starts with a "/"), this method will look for
 * the file in the specified bundle.
 *
 * @param path The path to convert to a URL.
 * @param bundle The bundle to look inside for relative paths.
 * @return The corresponding URL or nil if a URL could not be formed.
 */
+ (NSURL*) urlForPath:(NSString*) path bundle:(NSBundle*) bundle;

/** Notify an error if the specified ExtAudio error code indicates an error.
 * This will log the error and also potentially post an audio error notification
 * (OALAudioErrorNotification) if it is suspected that this error is a result of
 * the audio session getting corrupted.
 *
 * @param errorCode: The error code returned from an OS call.
 * @param function: The function name where the error occurred.
 * @param description: A printf-style description of what happened.
 */
+ (void) notifyExtAudioError:(OSStatus)errorCode
				 function:(const char*) function
			  description:(NSString*) description, ...;

/** Notify an error if the specified AudioSession error code indicates an error.
 * This will log the error and also potentially post an audio error notification
 * (OALAudioErrorNotification) if it is suspected that this error is a result of
 * the audio session getting corrupted.
 *
 * @param errorCode: The error code returned from an OS call.
 * @param function: The function name where the error occurred.
 * @param description: A printf-style description of what happened.
 */
+ (void) notifyAudioSessionError:(OSStatus)errorCode
					 function:(const char*) function
				  description:(NSString*) description, ...;

@end
