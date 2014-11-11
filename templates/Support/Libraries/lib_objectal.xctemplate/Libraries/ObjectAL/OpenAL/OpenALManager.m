//
//  OpenALManager.m
//  ObjectAL
//
//  Created by Karl Stenerud on 10-09-25.
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

#import "OpenALManager.h"
#import "NSMutableArray+WeakReferences.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import "ALWrapper.h"
#import "ALDevice.h"
#import "OALAudioSession.h"
#import "OALAudioFile.h"


#pragma mark -
#pragma mark Asynchronous Operations

/** \cond */
/**
 * (INTERNAL USE) NSOperation for loading audio files asynchronously.
 */
@interface OAL_AsyncALBufferLoadOperation: NSOperation
{
	/** The URL of the sound file to play */
	NSURL* url;
	/** If true, reduce the sample to mono */
	bool reduceToMono;
	/** The target to inform when the operation completes */
	id target;
	/** The selector to call when the operation completes */
	SEL selector;
}

/** (INTERNAL USE) Create a new Asynchronous Operation.
 *
 * @param url the URL containing the sound file.
 * @param reduceToMono If true, reduce the sample to mono
 *        (stereo samples don't support panning or positional audio).
 * @param target the target to inform when the operation completes.
 * @param selector the selector to call when the operation completes.
 */ 
+ (id) operationWithUrl:(NSURL*) url
		   reduceToMono:(bool) reduceToMono
				 target:(id) target
			   selector:(SEL) selector;

/** (INTERNAL USE) Initialize an Asynchronous Operation.
 *
 * @param url the URL containing the sound file.
 * @param reduceToMono If true, reduce the sample to mono
 *        (stereo samples don't support panning or positional audio).
 * @param target the target to inform when the operation completes.
 * @param selector the selector to call when the operation completes.
 */ 
- (id) initWithUrl:(NSURL*) url
	  reduceToMono:(bool) reduceToMono
			target:(id) target
		  selector:(SEL) selector;

@end

@implementation OAL_AsyncALBufferLoadOperation

+ (id) operationWithUrl:(NSURL*) url
		   reduceToMono:(bool) reduceToMono
				 target:(id) target
			   selector:(SEL) selector
{
	return as_autorelease([[self alloc] initWithUrl:url
                                            reduceToMono:reduceToMono
                                                  target:target
                                                selector:selector]);
}

- (id) initWithUrl:(NSURL*) urlIn
	  reduceToMono:(bool) reduceToMonoIn
			target:(id) targetIn
		  selector:(SEL) selectorIn
{
	if(nil != (self = [super init]))
	{
		url = as_retain(urlIn);
		reduceToMono = reduceToMonoIn;
		target = targetIn;
		selector = selectorIn;
	}
	return self;
}

- (void) dealloc
{
	as_release(url);
	as_superdealloc();
}

- (void)main
{
	ALBuffer* buffer = [OALAudioFile bufferFromUrl:url reduceToMono:reduceToMono];
	[target performSelectorOnMainThread:selector withObject:buffer waitUntilDone:NO];
}

@end


#pragma mark -
#pragma mark Private Methods

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(OpenALManager);

/**
 * (INTERNAL USE) Private methods for OpenALManager.
 */
@interface OpenALManager ()

/** (INTERNAL USE) Called by SuspendHandler.
 */
- (void) setSuspended:(bool) value;

/** (INTERNAL USE) Real reference to the current context.
 */
@property(nonatomic,readwrite,assign) ALContext* realCurrentContext;

@end
/** \endcond */


#pragma mark -
#pragma mark OpenALManager

@implementation OpenALManager



#pragma mark Object Management

SYNTHESIZE_SINGLETON_FOR_CLASS(OpenALManager);

@synthesize realCurrentContext;

- (id) init
{
	if(nil != (self = [super init]))
	{
		OAL_LOG_DEBUG(@"%@: Init", self);

		suspendHandler = [[OALSuspendHandler alloc] initWithTarget:self selector:@selector(setSuspended:)];
		
		devices = [NSMutableArray newMutableArrayUsingWeakReferencesWithCapacity:5];

		operationQueue = [[NSOperationQueue alloc] init];

		[[OALAudioSession sharedInstance] addSuspendListener:self];
	}
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc", self);
	[[OALAudioSession sharedInstance] removeSuspendListener:self];

	as_release(operationQueue);
	as_release(suspendHandler);
	as_release(devices);
	as_superdealloc();
}


#pragma mark Properties

- (NSArray*) availableCaptureDevices
{
	return [ALWrapper getNullSeparatedStringList:nil attribute:ALC_CAPTURE_DEVICE_SPECIFIER];
}

- (NSArray*) availableDevices
{
	return [ALWrapper getNullSeparatedStringList:nil attribute:ALC_DEVICE_SPECIFIER];
}

- (ALContext*) currentContext
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return self.realCurrentContext;
	}
}

- (void) setCurrentContext:(ALContext *) context
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		self.realCurrentContext = context;
		[ALWrapper makeContextCurrent:self.realCurrentContext.context
                      deviceReference:self.realCurrentContext.device.device];
	}
}

- (NSString*) defaultCaptureDeviceSpecifier
{
	return [ALWrapper getString:nil attribute:ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER];
}

- (NSString*) defaultDeviceSpecifier
{
	return [ALWrapper getString:nil attribute:ALC_DEFAULT_DEVICE_SPECIFIER];
}

@synthesize devices;

- (ALdouble) mixerOutputFrequency
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getMixerOutputDataRate];
	}
}

- (void) setMixerOutputFrequency:(ALdouble) frequency
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}

		[ALWrapper setMixerOutputDataRate:frequency];
	}
}

- (ALint) renderingQuality
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return [ALWrapper getRenderingQuality];
	}
}

- (void) setRenderingQuality:(ALint) renderingQuality
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(self.suspended)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}

		[ALWrapper setRenderingQuality:renderingQuality];
	}
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

- (void) setSuspended:(bool) value
{
	if(value)
	{
		[ALWrapper makeContextCurrent:nil];
	}
	else
	{
		[ALWrapper makeContextCurrent:self.realCurrentContext.context
					  deviceReference:self.realCurrentContext.device.device];
	}
}


#pragma mark Buffers

- (ALBuffer*) bufferFromFile:(NSString*) filePath
{
	return [self bufferFromFile:filePath reduceToMono:NO];
}

- (ALBuffer*) bufferFromFile:(NSString*) filePath reduceToMono:(bool) reduceToMono
{
	return [self bufferFromUrl:[OALTools urlForPath:filePath] reduceToMono:reduceToMono];
}

- (ALBuffer*) bufferFromUrl:(NSURL*) url
{
	return [self bufferFromUrl:url reduceToMono:NO];
}

- (ALBuffer*) bufferFromUrl:(NSURL*) url reduceToMono:(bool) reduceToMono
{
	OAL_LOG_DEBUG(@"Load buffer from %@", url);

	return [OALAudioFile bufferFromUrl:url reduceToMono:reduceToMono];
}

- (NSString*) bufferAsyncFromFile:(NSString*) filePath
						   target:(id) target
						 selector:(SEL) selector
{
	return [self bufferAsyncFromFile:filePath
						reduceToMono:NO
							  target:target
							selector:selector];
}

- (NSString*) bufferAsyncFromFile:(NSString*) filePath
					 reduceToMono:(bool) reduceToMono
						   target:(id) target
						 selector:(SEL) selector
{
	return [self bufferAsyncFromUrl:[OALTools urlForPath:filePath]
					   reduceToMono:reduceToMono
							 target:target
						   selector:selector];
}

- (NSString*) bufferAsyncFromUrl:(NSURL*) url
						  target:(id) target
						selector:(SEL) selector
{
	return [self bufferAsyncFromUrl:url
					   reduceToMono:NO
							 target:target
						   selector:selector];
}

- (NSString*) bufferAsyncFromUrl:(NSURL*) url
					reduceToMono:(bool) reduceToMono
						  target:(id) target
						selector:(SEL) selector
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[operationQueue addOperation:
		 [OAL_AsyncALBufferLoadOperation operationWithUrl:url
											 reduceToMono:reduceToMono
												   target:target
												 selector:selector]];
	}
	return [url absoluteString];
}


#pragma mark Utility

- (void) clearAllBuffers
{
	OPTIONALLY_SYNCHRONIZED(devices)
	{
		for(ALDevice* device in devices)
		{
			[device clearBuffers];
		}
	}
}

#pragma mark Internal Use

- (void) notifyDeviceInitializing:(ALDevice*) device
{
	OPTIONALLY_SYNCHRONIZED(devices)
	{
		[devices addObject:device];
	}
}

- (void) notifyDeviceDeallocating:(ALDevice*) device
{
	OPTIONALLY_SYNCHRONIZED(devices)
	{
		[devices removeObject:device];
	}
}

@end
