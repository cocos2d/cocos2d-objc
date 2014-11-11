//
//  OALAudioFile.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-12-24.
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
#import <AudioToolbox/AudioToolbox.h>
#import "ALBuffer.h"


/**
 * Maintains an open audio file and allows loading data from that file into
 * new ALBuffer objects.
 */
@interface OALAudioFile : NSObject
{
	NSURL* url;
	bool reduceToMono;
	SInt64 totalFrames;

	/** A description of the audio data in this file. */
	AudioStreamBasicDescription streamDescription;

	/** The OS specific file handle */
	ExtAudioFileRef fileHandle;

	/** The actual number of channels in the audio data if not reducing to mono */
	UInt32 originalChannelsPerFrame;
}

/** The URL of the audio file */
@property(nonatomic,readonly,retain) NSURL* url;

/** A description of the audio data in this file. */
@property(nonatomic,readonly,assign) AudioStreamBasicDescription* streamDescription;

/** The total number of audio frames in this file */
@property(nonatomic,readonly,assign) SInt64 totalFrames;

/** If YES, reduce any stereo data to mono (stereo samples don't support panning or positional audio). */
@property(nonatomic,readwrite,assign) bool reduceToMono;

/** Open the audio file at the specified URL.
 *
 * @param url The URL to open the audio file from.
 * @param reduceToMono If YES, reduce any stereo track to mono
                       (stereo samples don't support panning or positional audio).
 * @return a new audio file object.
 */
+ (OALAudioFile*) fileWithUrl:(NSURL*) url
				 reduceToMono:(bool) reduceToMono;

/** Initialize this object with the audio file at the specified URL.
 *
 * @param url The URL to open the audio file from.
 * @param reduceToMono If YES, reduce any stereo track to mono
                       (stereo samples don't support panning or positional audio).
 * @return the initialized audio file object.
 */
- (id) initWithUrl:(NSURL*) url
	  reduceToMono:(bool) reduceToMono;

/** Read audio data from this file into a new buffer.
 *
 * @param startFrame The starting audio frame to read data from.
 * @param numFrames The number of frames to read.
 * @param bufferSize On successful return, contains the size of the returned buffer, in bytes.
 * @return The audio data or nil on error.  You are responsible for calling free() on the data.
 */
- (void*) audioDataWithStartFrame:(SInt64) startFrame
						numFrames:(SInt64) numFrames
					   bufferSize:(UInt32*) bufferSize;

/** Create a new ALBuffer with the contents of this file.
 *
 * @param name The name to be given to this ALBuffer.
 * @param startFrame The starting audio frame to read data from.
 * @param numFrames The number of frames to read.
 * @return a new ALBuffer containing the audio data.
 */
- (ALBuffer*) bufferNamed:(NSString*) name
			   startFrame:(SInt64) startFrame
				numFrames:(SInt64) numFrames;

/** Convenience method to load the entire contents of a URL into a new ALBuffer.
 *
 * @param url The URL to open the audio file from.
 * @param reduceToMono If YES, reduce any stereo track to mono
                       (stereo samples don't support panning or positional audio).
 * @return an ALBuffer object.
 */
+ (ALBuffer*) bufferFromUrl:(NSURL*) url
			   reduceToMono:(bool) reduceToMono;

@end
