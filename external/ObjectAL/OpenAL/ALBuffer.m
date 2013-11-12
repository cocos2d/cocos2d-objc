//
//  ALBuffer.m
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

#import "ALBuffer.h"
#import "ALWrapper.h"
#import "OpenALManager.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"


@implementation ALBuffer


#pragma mark Object Management

+ (id) bufferWithName:(NSString*) name
                 data:(void*) data
                 size:(ALsizei) size
               format:(ALenum) format
            frequency:(ALsizei) frequency
{
	return as_autorelease([[self alloc] initWithName:name
                                                     data:data
                                                     size:size
                                                   format:format
                                                frequency:frequency]);
}

- (id) initWithName:(NSString*) nameIn
               data:(void*) data
               size:(ALsizei) size
             format:(ALenum) formatIn
          frequency:(ALsizei) frequency
{
	if(nil != (self = [super init]))
	{
		OAL_LOG_DEBUG(@"%@: Init", self);
		self.name = nameIn;
		bufferId = [ALWrapper genBuffer];
		if(nil == [OpenALManager sharedInstance].currentContext)
		{
			OAL_LOG_ERROR(@"Cannot allocate a buffer without a current context. Make sure [OpenALManager sharedInstance].currentContext is valid");
			as_release(self);
			return nil;
		}
		device = as_retain([OpenALManager sharedInstance].currentContext.device);
		bufferData = data;
		format = formatIn;
		freeDataOnDestroy = YES;
		parentBuffer = nil;

		[ALWrapper bufferDataStatic:bufferId format:format data:bufferData size:size frequency:frequency];
		
		duration = (float)self.size / ((float)(self.frequency * self.channels * self.bits) / 8);
	}
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc", self);
	[ALWrapper deleteBuffer:bufferId];
	as_release(device);
	as_release(name);
	as_release(parentBuffer);
	if(freeDataOnDestroy)
	{
		free(bufferData);
	}

	as_superdealloc();
}

- (NSString*) description
{
	NSString* nameStr = NSNotFound == [name rangeOfString:@"://"].location ? name : [name lastPathComponent];
	return [NSString stringWithFormat:@"<%@: %p: %@>", [self class], self, nameStr];
}

#pragma mark Properties

- (ALint) bits
{
	return [ALWrapper getBufferi:bufferId parameter:AL_BITS];	
}

@synthesize bufferId;

- (ALint) channels
{
	return [ALWrapper getBufferi:bufferId parameter:AL_CHANNELS];	
}

@synthesize device;

@synthesize format;

- (ALint) frequency
{
	return [ALWrapper getBufferi:bufferId parameter:AL_FREQUENCY];	
}

@synthesize name;

- (ALint) size
{
	return [ALWrapper getBufferi:bufferId parameter:AL_SIZE];	
}

@synthesize duration;

@synthesize freeDataOnDestroy;

@synthesize parentBuffer;

#pragma mark Buffer slicing

- (ALBuffer*)sliceWithName:(NSString *) sliceName offset:(ALsizei) offset size:(ALsizei) size
{
	int frameSize = self.channels * self.bits / 8;
	int byteOffset = offset * frameSize;
	int byteSize = size * frameSize;

	if (offset < 0)
	{
		OAL_LOG_ERROR(@"%@: Buffer offset %d is too small. Returning nil", self, offset);
		return nil;
	}

	if (size < 1)
	{
		OAL_LOG_ERROR(@"%@: Buffer size %d is too small. Returning nil", self, size);
		return nil;
	}

	if (byteOffset + byteSize > (ALsizei)self.size)
	{
		OAL_LOG_ERROR(@"%@: Buffer offset+size goes beyond end of buffer (%d + %d > %d). Returning nil", self, offset, size, self.size / frameSize);
		return nil;
	}

	ALBuffer * slice = [ALBuffer bufferWithName:sliceName data:(void*)(byteOffset + (char*)bufferData) size:byteSize
										 format:self.format frequency:self.frequency];
	slice.freeDataOnDestroy = NO;
	slice.parentBuffer = self;
	return slice;
}

@end
