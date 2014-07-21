//
//  SoundSourcePool.h
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

#import "ccMacros.h"

#import "ALSoundSource.h"


#pragma mark ALSoundSourcePool

/**
 * A pool of sound sources, which can be fetched based on availability.
 */
@interface ALSoundSourcePool : NSObject
{
	/** All sources managed by this pool (id<ALSoundSource>). */
	NSMutableArray* sources;
}


#pragma mark Properties

/** All sources managed by this pool (id<ALSoundSource>). */
@property(nonatomic,readonly,retain) NSArray* sources;


#pragma mark Object Management

/** Make a new pool.
 * @return A new pool.
 */
+ (id) pool;


#pragma mark Source Management

/** Add a source to this pool.
 *
 * @param source The source to add.
 */
- (void) addSource:(id<ALSoundSource>) source;

/** Remove a source from this pool
 *
 * @param source The source to remove.
 */
- (void) removeSource:(id<ALSoundSource>) source;

/** Acquire a free or freeable source from this pool.
 * It first attempts to find a completely free source.
 * Failing this, it will attempt to interrupt a source and return that (if attemptToInterrupt
 * is TRUE).
 *
 * @param attemptToInterrupt If TRUE, attempt to interrupt sources to free them for use.
 * @return The freed sound source, or nil if no sources are freeable.
 */
- (id<ALSoundSource>) getFreeSource:(bool) attemptToInterrupt;

@end
