//
//  ALDevice.m
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

#import "ALDevice.h"
#import "NSMutableArray+WeakReferences.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "ALWrapper.h"
#import "OpenALManager.h"


@implementation ALDevice

#pragma mark Object Management

+ (id) deviceWithDeviceSpecifier:(NSString*) deviceSpecifier
{
	return as_autorelease([[self alloc] initWithDeviceSpecifier:deviceSpecifier]);
}

- (id) initWithDeviceSpecifier:(NSString*) deviceSpecifier
{
	if(nil != (self = [super init]))
	{
		suspendHandler = [[OALSuspendHandler alloc] initWithTarget:nil selector:nil];
		
		contexts = [NSMutableArray newMutableArrayUsingWeakReferencesWithCapacity:5];
			
		[[OpenALManager sharedInstance] notifyDeviceInitializing:self];
		[[OpenALManager sharedInstance] addSuspendListener:self];
		
		OAL_LOG_DEBUG(@"%@: Init device %@", self, deviceSpecifier);
		
		device = [ALWrapper openDevice:deviceSpecifier];
		if(nil == device)
		{
			OAL_LOG_ERROR(@"%@: Failed to init device %@. Returning nil", self, deviceSpecifier);
			as_release(self);
			return nil;
		}
	}
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc", self);

	[[OpenALManager sharedInstance] removeSuspendListener:self];
	[[OpenALManager sharedInstance] notifyDeviceDeallocating:self];

    [ALWrapper closeDevice:device];
	
	as_release(contexts);
	as_release(suspendHandler);
	as_superdealloc();
}


#pragma mark Properties

@synthesize contexts;

@synthesize device;

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

#pragma mark Suspend Handler

- (void) addSuspendListener:(id<OALSuspendListener>) listener
{
	[suspendHandler addSuspendListener:listener];
}

- (void) removeSuspendListener:(id<OALSuspendListener>) listener
{
	[suspendHandler removeSuspendListener:listener];
}

- (bool) manuallySuspended
{
	return suspendHandler.manuallySuspended;
}

- (void) setManuallySuspended:(bool) value
{
	suspendHandler.manuallySuspended = value;
}

- (bool) interrupted
{
	return suspendHandler.interrupted;
}

- (void) setInterrupted:(bool) value
{
	suspendHandler.interrupted = value;
}

- (bool) suspended
{
	return suspendHandler.suspended;
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


#pragma mark Utility

- (void) clearBuffers
{
	OPTIONALLY_SYNCHRONIZED(contexts)
	{
		for(ALContext* context in contexts)
		{
			[context clearBuffers];
		}
	}
}


#pragma mark Internal Use

- (void) notifyContextInitializing:(ALContext*) context
{
	OPTIONALLY_SYNCHRONIZED(contexts)
	{
		[contexts addObject:context];
	}
}

- (void) notifyContextDeallocating:(ALContext*) context
{
	OPTIONALLY_SYNCHRONIZED(contexts)
	{
		if([OpenALManager sharedInstance].currentContext == context)
		{
			[OpenALManager sharedInstance].currentContext = nil;
		}
		[contexts removeObject:context];
	}
}

@end
