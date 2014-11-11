//
//  ALDevice.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-01-09.
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
#import <OpenAL/alc.h>
#import "ALContext.h"
#import "OALSuspendHandler.h"


#pragma mark ALDevice

/**
 * A device is a logical mapping to an audio device through the OpenAL implementation.
 */
@interface ALDevice : NSObject <OALSuspendManager>
{
	ALCdevice* device;
	/** All contexts opened from this device. */
	NSMutableArray* contexts;
	
	/** Handles suspending and interrupting for this object. */
	OALSuspendHandler* suspendHandler;
}


#pragma mark Properties

/** All contexts created on this device (ALContext*). */
@property(nonatomic,readonly,retain) NSArray* contexts;

/** The OpenAL device pointer. */
@property(nonatomic,readonly,assign) ALCdevice* device;

/** List of strings describing all extensions available on this device (NSString*). */
@property(nonatomic,readonly,retain) NSArray* extensions;

/** The specification revision for this implementation (major version). */
@property(nonatomic,readonly,assign) int majorVersion;

/** The specification revision for this implementation (minor version). */
@property(nonatomic,readonly,assign) int minorVersion;


#pragma mark Object Management

/** Open the specified device.
 *
 * @param deviceSpecifier The device to open (nil = default device).
 * @return A new device.
 */
+ (id) deviceWithDeviceSpecifier:(NSString*) deviceSpecifier;

/** Initialize with the specified device.
 *
 * @param deviceSpecifier The device to open (nil = default device).
 * @return the initialized device.
 */
- (id) initWithDeviceSpecifier:(NSString*) deviceSpecifier;


#pragma mark Extensions

/** Check if the specified extension is present.
 *
 * @param name The extension to check.
 * @return TRUE if the extension is present.
 */
- (bool) isExtensionPresent:(NSString*) name;

/** Get the address of the specified procedure (C function address).
 *
 * @param functionName the name of the procedure to get.
 * @return the procedure's address, or NULL if it wasn't found.
 */
- (void*) getProcAddress:(NSString*) functionName;


#pragma mark Utility

/** Clear all buffers being used by sources of contexts opened on this device.
 */
- (void) clearBuffers;


#pragma mark Internal Use

/** \cond */
/** (INTERNAL USE) Used by ALContext to announce initialization.
 *
 * @param context The context that is initializing.
 */
- (void) notifyContextInitializing:(ALContext*) context;

/** (INTERNAL USE) Used by ALContext to announce deallocation.
 *
 * @param context The context that is deallocating.
 */
- (void) notifyContextDeallocating:(ALContext*) context;
/** \endcond */

@end
