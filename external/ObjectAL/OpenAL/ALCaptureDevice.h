//
//  ALCaptureDevice.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-01-11.
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


#pragma mark ALCaptureDevice

/**
 * *UNIMPLEMENTED FOR IOS* An OpenAL device for capturing sound data.
 * Note: This functionality is NOT implemented in iOS OpenAL! <br>
 * This class is a placeholder in case such functionality is added in a future iOS SDK.
 */
@interface ALCaptureDevice : NSObject
{
	ALCdevice* device;
}


#pragma mark Properties

/** The number of capture samples available. */
@property(nonatomic,readonly,assign) int captureSamples;

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
 * @param deviceSpecifier The name of the device to open (nil = default device).
 * @param frequency The frequency to capture at.
 * @param format The audio format to capture as.
 * @param bufferSize The size of buffer that the device must allocate for audio capture.
 * @return A new capture device.
 */
+ (id) deviceWithDeviceSpecifier:(NSString*) deviceSpecifier
					   frequency:(ALCuint) frequency
						  format:(ALCenum) format
					  bufferSize:(ALCsizei) bufferSize;

/** Open the specified device.
 *
 * @param deviceSpecifier The name of the device to open (nil = default device).
 * @param frequency The frequency to capture at.
 * @param format The audio format to capture as.
 * @param bufferSize The size of buffer that the device must allocate for audio capture.
 * @return The initialized capture device.
 */
- (id) initWithDeviceSpecifier:(NSString*) deviceSpecifier
					 frequency:(ALCuint) frequency
						format:(ALCenum) format
					bufferSize:(ALCsizei) bufferSize;


#pragma mark Audio Capture

/** Start capturing samples.
 *
 * @return TRUE if the operation was successful.
 */
- (bool) startCapture;

/** Stop capturing samples.
 *
 * @return TRUE if the operation was successful.
 */
- (bool) stopCapture;

/** Move captured samples to the specified buffer.
 * This method will fail if less than the specified number of samples have been captured.
 *
 * @param numSamples The number of samples to move.
 * @param buffer the buffer to move the samples into.
 * @return TRUE if the operation was successful.
 */
- (bool) moveSamples:(ALCsizei) numSamples toBuffer:(ALCvoid*) buffer;


#pragma mark Extensions

/** Check if the specified extension is present.
 *
 * @param name The name of the extension to check.
 * @return TRUE if the extension is present.
 */
- (bool) isExtensionPresent:(NSString*) name;

/** Get the address of the specified procedure (C function address).
 *
 * @param functionName The name of the procedure to get.
 * @return the procedure's address, or NULL if it wasn't found.
 */
- (void*) getProcAddress:(NSString*) functionName;


@end
