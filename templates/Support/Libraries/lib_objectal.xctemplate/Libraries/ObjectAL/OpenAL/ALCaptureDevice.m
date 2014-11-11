//
//  ALCaptureDevice.m
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

#import "ALCaptureDevice.h"
#import "ALWrapper.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"


@implementation ALCaptureDevice

#pragma mark Object Management

+ (id) deviceWithDeviceSpecifier:(NSString*) deviceSpecifier
					   frequency:(ALCuint) frequency
						  format:(ALCenum) format
					  bufferSize:(ALCsizei) bufferSize
{
	return as_autorelease([[self alloc] initWithDeviceSpecifier:deviceSpecifier
                                                      frequency:frequency
                                                         format:format
                                                     bufferSize:bufferSize]);
}

- (id) initWithDeviceSpecifier:(NSString*) deviceSpecifier
					 frequency:(ALCuint) frequency
						format:(ALCenum) format
					bufferSize:(ALCsizei) bufferSize
{
	if(nil != (self = [super init]))
	{
		device = [ALWrapper openCaptureDevice:deviceSpecifier
									frequency:frequency
									   format:format
								   bufferSize:bufferSize];
	}
	return self;
}

- (void) dealloc
{
    [ALWrapper closeDevice:device];

	as_superdealloc();
}


#pragma mark Properties

@synthesize device;

- (int) captureSamples
{
	return [ALWrapper getInteger:device attribute:ALC_CAPTURE_SAMPLES];
}

- (NSArray*) extensions
{
	return [ALWrapper getSpaceSeparatedStringList:device attribute:ALC_EXTENSIONS];
}

- (int) majorVersion
{
	return [ALWrapper getInteger:device attribute:ALC_MAJOR_VERSION];
}

- (int) minorVersion
{
	return [ALWrapper getInteger:device attribute:ALC_MINOR_VERSION];
}


#pragma mark Audio Capture

- (bool) moveSamples:(ALCsizei) numSamples toBuffer:(ALCvoid*) buffer
{
	return [ALWrapper captureSamples:device buffer:buffer numSamples:numSamples];
}

- (bool) startCapture
{
	return [ALWrapper startCapture:device];
}

- (bool) stopCapture
{
	return [ALWrapper stopCapture:device];
}


#pragma mark Extensions

- (bool) isExtensionPresent:(NSString*) name
{
	return [ALWrapper isExtensionPresent:device name:name];
}

- (void*) getProcAddress:(NSString*) functionName
{
	return [ALWrapper getProcAddress:device name:functionName];
}


@end
