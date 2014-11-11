//
//  ALBuffer.h
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

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

@class ALDevice;


#pragma mark ALBuffer

/**
 * A buffer for audio data that will be played via a SoundSource.
 * @see SoundSource
 */
@interface ALBuffer : NSObject
{
	ALDevice* device;
	ALuint bufferId;
	NSString* name;
	ALenum format;
	float duration;
	/** The uncompressed sound data to play. */
	void* bufferData;
	bool freeDataOnDestroy;
	ALBuffer* parentBuffer;
}


#pragma mark Properties

/** The size of a sample in bits. */
@property(nonatomic,readonly,assign) ALint bits;

/** The ID assigned to this buffer by OpenAL. */
@property(nonatomic,readonly,assign) ALuint bufferId;

/** The number of channels the buffer data plays in. */
@property(nonatomic,readonly,assign) ALint channels;

/** The device this buffer was created for. */
@property(nonatomic,readonly,retain) ALDevice* device;

/** The format of the audio data (see al.h, AL_FORMAT_XXX). */
@property(nonatomic,readonly,assign) ALenum format;

/** The frequency this buffer runs at. */
@property(nonatomic,readonly,assign) ALint frequency;

/** The name given to this buffer upon creation. You may change it at runtime if you wish. */
@property(nonatomic,readwrite,retain) NSString* name;

/** The size, in bytes, of the currently loaded buffer data. */
@property(nonatomic,readonly,assign) ALint size;

/** The duration of the sample in this buffer, in seconds. */
@property(nonatomic,readonly,assign) float duration;

/** If true, calls free() on the audio data when this object gets destroyed.
 * Default: YES
 */
@property(nonatomic,readwrite,assign) bool freeDataOnDestroy;

/** The parent buffer (which owns the uncompressed data) */
@property(nonatomic,readwrite,retain) ALBuffer* parentBuffer;

#pragma mark Object Management

/** Make a new buffer.
 *
 * @param name Optional name that you can use to identify this buffer in your code.
 * @param data The sound data. Note: ALBuffer will call free() on this data when it is destroyed!
 * @param size The size of the data in bytes.
 * @param format The format of the data (see the Core Audio documentation).
 * @param frequency The sampling frequency in Hz.
 * @return A new buffer.
 */
+ (id) bufferWithName:(NSString*) name
				 data:(void*) data
				 size:(ALsizei) size
			   format:(ALenum) format
			frequency:(ALsizei) frequency;

/** Initialize the buffer.
 *
 * @param name Optional name that you can use to identify this buffer in your code.
 * @param data The sound data. Note: ALBuffer will call free() on this data when it is destroyed!
 * @param size The size of the data in bytes.
 * @param format The format of the data (see the Core Audio documentation).
 * @param frequency The sampling frequency in Hz.
 * @return The initialized buffer.
 */
- (id) initWithName:(NSString*) name
			   data:(void*) data
			   size:(ALsizei) size
			 format:(ALenum) format
		  frequency:(ALsizei) frequency;

/** Returns a part of the buffer as a new buffer. You can use this method to split a buffer
 * into a sub-buffers. The sub-buffers retain a reference to their parent buffer, and share
 * the same memory. Therefore, modifying the parent buffer contents will affect its slices
 * and vice-versa.
 *
 * @param sliceName Optional name that you can use to identify the created buffer in your code.
 * @param offset The offset in sound frames where the slice starts.
 * @param size The size of the slice in frames.
 * @return The requested buffer.
 */
- (ALBuffer*)sliceWithName:(NSString *) sliceName offset:(ALsizei) offset size:(ALsizei) size;


@end
