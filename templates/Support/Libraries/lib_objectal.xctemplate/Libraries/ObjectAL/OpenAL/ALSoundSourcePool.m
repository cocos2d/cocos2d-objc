//
//  SoundSourcePool.m
//  ObjectAL
//
//  Created by Karl Stenerud on 17/12/09.
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

#import "ALSoundSourcePool.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"


#pragma mark Private Methods

/**
 * Private interface to SoundSourcePool.
 */
@interface ALSoundSourcePool (Private)

/** Move a source to the head of the list.
 *
 * @param index the index of the source to move.
 */
- (void) moveToHead:(int) index;

@end


#pragma mark -
#pragma mark SoundSourcePool

@implementation ALSoundSourcePool

#pragma mark Object Management

+ (id) pool
{
	return as_autorelease([[self alloc] init]);
}

- (id) init
{
	if(nil != (self = [super init]))
	{
        OAL_LOG_DEBUG(@"%@: Init", self);
		sources = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void) dealloc
{
	OAL_LOG_DEBUG(@"%@: Dealloc", self);
	as_release(sources);
	as_superdealloc();
}


#pragma mark Properties

@synthesize sources;


#pragma mark Source Management

- (void) addSource:(id<ALSoundSource>) source
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[sources addObject:source];
	}
}

- (void) removeSource:(id<ALSoundSource>) source
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[sources removeObject:source];
	}
}

- (void) moveToHead:(int) index
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		id source = as_retain([sources objectAtIndex:(NSUInteger)index]);
		[sources removeObjectAtIndex:(NSUInteger)index];
		[sources addObject:source];
		as_release(source);
	}
}

- (id<ALSoundSource>) getFreeSource:(bool) attemptToInterrupt
{
	int index = 0;
	
	OPTIONALLY_SYNCHRONIZED(self)
	{
		// Try to find any free source.
		for(id<ALSoundSource> source in sources)
		{
			if(!source.playing)
			{
				[self moveToHead:index];
				return source;
			}
			index++;
		}
		
		if(attemptToInterrupt)
		{
			// Try to forcibly free a source.
			index = 0;
			for(id<ALSoundSource> source in sources)
			{
				if(!source.playing || source.interruptible)
				{
					[source stop];
					[self moveToHead:index];
					return source;
				}
				index++;
			}
		}
	}		
	return nil;
}

@end
