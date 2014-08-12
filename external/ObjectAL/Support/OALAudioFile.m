//
//  OALAudioFile.m
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

#import "OALAudioFile.h"


#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"


@implementation OALAudioFile

+ (OALAudioFile*) fileWithUrl:(NSURL*) url
				 reduceToMono:(bool) reduceToMono
{
	return as_autorelease([[self alloc] initWithUrl:url reduceToMono:reduceToMono]);
}


- (id) initWithUrl:(NSURL*) urlIn
	  reduceToMono:(bool) reduceToMonoIn
{
	if(nil != (self = [super init]))
	{
		url = as_retain(urlIn);
		reduceToMono = reduceToMonoIn;

		OSStatus error = 0;
		UInt32 size;
		
		if(nil == url)
		{
			OAL_LOG_ERROR(@"Cannot open NULL file / url");
			goto done;
		}

#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
		// Open the file
		if(noErr != (error = ExtAudioFileOpenURL((as_bridge CFURLRef)url, &fileHandle)))
		{
			REPORT_EXTAUDIO_CALL(error, @"Could not open url %@", url);
			goto done;
		}

		// Get some info about the file
		size = sizeof(SInt64);
		if(noErr != (error = ExtAudioFileGetProperty(fileHandle,
													 kExtAudioFileProperty_FileLengthFrames,
													 &size,
													 &totalFrames)))
		{
			REPORT_EXTAUDIO_CALL(error, @"Could not get frame count for file (url = %@)", url);
			goto done;
		}
		
		
		size = sizeof(AudioStreamBasicDescription);
		if(noErr != (error = ExtAudioFileGetProperty(fileHandle,
													 kExtAudioFileProperty_FileDataFormat,
													 &size,
													 &streamDescription)))
		{
			REPORT_EXTAUDIO_CALL(error, @"Could not get audio format for file (url = %@)", url);
			goto done;
		}
		
		// Specify the new audio format (anything not changed remains the same)
		streamDescription.mFormatID = kAudioFormatLinearPCM;
		streamDescription.mFormatFlags = kAudioFormatFlagsNativeEndian |
		kAudioFormatFlagIsSignedInteger |
		kAudioFormatFlagIsPacked;
		// Force to 16 bit since iOS doesn't seem to like 8 bit.
		streamDescription.mBitsPerChannel = 16;

		originalChannelsPerFrame = streamDescription.mChannelsPerFrame > 2 ? 2 : streamDescription.mChannelsPerFrame;
		if(reduceToMono)
		{
			streamDescription.mChannelsPerFrame = 1;
		}
		
		if(streamDescription.mChannelsPerFrame > 2)
		{
			// Don't allow more than 2 channels (stereo)
			OAL_LOG_WARNING(@"Audio stream in %@ contains %ld channels. Capping at 2",
							url,
							(long)streamDescription.mChannelsPerFrame);
			streamDescription.mChannelsPerFrame = 2;
		}

		streamDescription.mBytesPerFrame = streamDescription.mChannelsPerFrame * streamDescription.mBitsPerChannel / 8;
		streamDescription.mFramesPerPacket = 1;
		streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * 1 /* streamDescription.mFramesPerPacket */;
		
		// Set the new audio format
		if(noErr != (error = ExtAudioFileSetProperty(fileHandle,
													 kExtAudioFileProperty_ClientDataFormat,
													 sizeof(AudioStreamBasicDescription),
													 &streamDescription)))
		{
			REPORT_EXTAUDIO_CALL(error, @"Could not set new audio format for file (url = %@)", url);
			goto done;
		}
		
#elif __CC_PLATFORM_ANDROID
		// Open the file
		oggPath = [[url path] UTF8String];
		rawFILE = fopen(oggPath, "rb");
		if (NULL == rawFILE) {
			error = !noErr;
			goto done;
		}
		error = ov_open(rawFILE, &oggFile, NULL, 0);
		if (0 != error) {
			fclose(rawFILE);
			rawFILE = NULL;
			error = !noErr;
			goto done;
		}

		// Get info
		vorbis_info *info = ov_info(&oggFile, -1);
		if (info) {
			channelsPerFrame = info->channels;
			sampleRate = (UInt32)info->rate;
			bitsPerChannel = 16;
			bytesPerFrame = (channelsPerFrame * bitsPerChannel) / 8;
		} else {
			fclose(rawFILE);
			rawFILE = NULL;
			error = !noErr;
			goto done;
		}

		// Get frame count
		totalFrames = (SInt64) ov_pcm_total(&oggFile, -1);
#endif
	done:
		if(noErr != error)
		{
			as_release(self);
			return nil;
		}
		
	}
	return self;
}

- (void) dealloc
{
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
	if(nil != fileHandle)
	{
		REPORT_EXTAUDIO_CALL(ExtAudioFileDispose(fileHandle), @"Error closing file (url = %@)", url);
		fileHandle = nil;
	}
#elif __CC_PLATFORM_ANDROID
	if (rawFILE) {
		fclose(rawFILE);
	}
#endif

	as_release(url);
	as_superdealloc();
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@: %p: %@>", [self class], self, url];
}

@synthesize url;

#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
- (AudioStreamBasicDescription*) streamDescription
{
	return &streamDescription;
}
#elif __CC_PLATFORM_ANDROID
@synthesize sampleRate;
@synthesize channelsPerFrame;
@synthesize bitsPerChannel;
@synthesize bytesPerFrame;
@synthesize framesPerPacket;
@synthesize bytesPerPacket;
#endif

@synthesize totalFrames;

- (bool) reduceToMono
{
	return reduceToMono;
}

- (void) setReduceToMono:(bool) value
{
	@synchronized(self)
	{
		if(value != reduceToMono)
		{
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
			OSStatus error;
			reduceToMono = value;
			streamDescription.mChannelsPerFrame = reduceToMono ? 1 : originalChannelsPerFrame;
			if(noErr != (error = ExtAudioFileSetProperty(fileHandle,
														 kExtAudioFileProperty_ClientDataFormat,
														 sizeof(AudioStreamBasicDescription),
														 &streamDescription)))
			{
				REPORT_EXTAUDIO_CALL(error, @"Could not set new audio format for file (url = %@)", url);
			}
#elif __CC_PLATFORM_ANDROID
#warning setReduceToMono unimplemented
#endif
		}
	}
}

- (void*) audioDataWithStartFrame:(SInt64) startFrame
						numFrames:(SInt64) numFrames
					   bufferSize:(UInt32*) bufferSize
{
	@synchronized(self)
	{
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
		if(nil == fileHandle)
		{
			OAL_LOG_ERROR(@"Attempted to read from closed file. Returning nil (url = %@)", url);
			return nil;
		}
		
		OSStatus error;
		UInt32 numFramesRead;
		AudioBufferList bufferList;
		UInt32 bufferOffset = 0;

		
		// < 0 means read to the end of the file.
		if(numFrames < 0)
		{
			numFrames = totalFrames - startFrame;
		}
		
		// Allocate some memory to hold the data
		UInt32 streamSizeInBytes = (UInt32)(streamDescription.mBytesPerFrame * numFrames);
		void* streamData = malloc(streamSizeInBytes);
		if(nil == streamData)
		{
			OAL_LOG_ERROR(@"Could not allocate %ld bytes for audio buffer from file (url = %@)",
						  (long)streamSizeInBytes,
						  url);
			goto onFail;
		}
		
		if(noErr != (error = ExtAudioFileSeek(fileHandle, startFrame)))
		{
			REPORT_EXTAUDIO_CALL(error, @"Could not seek to %lld in file (url = %@)",
								 startFrame,
								 url);
			goto onFail;
		}
		
		
		bufferList.mNumberBuffers = 1;
		bufferList.mBuffers[0].mNumberChannels = streamDescription.mChannelsPerFrame;
		for(UInt32 framesToRead = (UInt32) numFrames; framesToRead > 0; framesToRead -= numFramesRead)
		{
			bufferList.mBuffers[0].mDataByteSize = streamDescription.mBytesPerFrame * framesToRead;
			bufferList.mBuffers[0].mData = (char*)streamData + bufferOffset;
			
			numFramesRead = framesToRead;
			if(noErr != (error = ExtAudioFileRead(fileHandle, &numFramesRead, &bufferList)))
			{
				REPORT_EXTAUDIO_CALL(error, @"Could not read audio data in file (url = %@)",
									 url);
				goto onFail;
			}
			bufferOffset += streamDescription.mBytesPerFrame * numFramesRead;
			if(numFramesRead == 0)
			{
				// Sometimes the stream description was wrong and you hit an EOF prematurely
				break;
			}
		}
		
		if(nil != bufferSize)
		{
			// Use however many bytes were actually read
			*bufferSize = bufferOffset;
		}
		
		return streamData;
		
	onFail:
		if(nil != streamData)
		{
			free(streamData);
		}
		return nil;
#elif __CC_PLATFORM_ANDROID
		UInt32 numFramesRead;
		UInt32 bufferOffset = 0;

		// < 0 means read to the end of the file.
		if(numFrames < 0)
		{
			numFrames = totalFrames - startFrame;
		}

		// Allocate some memory to hold the data
		UInt32 streamSizeInBytes = (UInt32)(bytesPerFrame * numFrames);
		char* streamData = malloc(streamSizeInBytes);
		if(nil == streamData)
		{
			OAL_LOG_ERROR(@"Could not allocate %ld bytes for audio buffer from file (url = %@)",
						  (long)streamSizeInBytes,
						  url);
			goto onFail;
		}

		int ov_res = ov_pcm_seek(&oggFile, startFrame);
		if(0 != ov_res)
		{
			REPORT_EXTAUDIO_CALL((OSStatus)ov_res, @"Could not seek to %lld in file (url = %@)",
								 startFrame,
								 url);
			goto onFail;
		}

		int bitStream = 0;
		int chunkSize = 0;
		UInt32 bytesToRead = (UInt32) numFrames * bytesPerFrame;
		UInt32 bytesRead = 0;
		for(bytesRead = 0; bytesRead < bytesToRead; bytesRead += chunkSize)
		{
			chunkSize = (int) ov_read(&oggFile,
								(char*)(streamData + bytesRead),
								(int)(streamSizeInBytes - bytesRead),
								&bitStream);
			if (chunkSize < 0)
			{
				REPORT_EXTAUDIO_CALL((OSStatus)chunkSize, @"Could not read audio data in file (url = %@)",
									 url);
				goto onFail;
			} else if (chunkSize == 0) {
				break;
			}
		}

		if(nil != bufferSize)
		{
			// Use however many bytes were actually read
			*bufferSize = bytesRead;
		}

		return (void*)streamData;

	onFail:
		if(nil != streamData)
		{
			free(streamData);
		}
		return nil;
#endif
	}
}


- (ALBuffer*) bufferNamed:(NSString*) name
			   startFrame:(SInt64) startFrame
				numFrames:(SInt64) numFrames
{
	@synchronized(self)
	{
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
		if(nil == fileHandle)
		{
			OAL_LOG_ERROR(@"Attempted to read from closed file. Returning nil (url = %@)", url);
			return nil;
		}
		
		UInt32 bufferSize;
		void* streamData = [self audioDataWithStartFrame:startFrame numFrames:numFrames bufferSize:&bufferSize];
		if(nil == streamData)
		{
			return nil;
		}
		
		ALenum audioFormat;
		if(1 == streamDescription.mChannelsPerFrame)
		{
			if(8 == streamDescription.mBitsPerChannel)
			{
				audioFormat = AL_FORMAT_MONO8;
			}
			else
			{
				audioFormat = AL_FORMAT_MONO16;
			}
		}
		else
		{
			if(8 == streamDescription.mBitsPerChannel)
			{
				audioFormat = AL_FORMAT_STEREO8;
			}
			else
			{
				audioFormat = AL_FORMAT_STEREO16;
			}
		}
		
		return [ALBuffer bufferWithName:name
								   data:streamData
								   size:(ALsizei)bufferSize
								 format:audioFormat
							  frequency:(ALsizei)streamDescription.mSampleRate];
#elif __CC_PLATFORM_ANDROID
		UInt32 bufferSize;
		void* streamData = [self audioDataWithStartFrame:startFrame numFrames:numFrames bufferSize:&bufferSize];
		if(nil == streamData)
		{
			return nil;
		}

		ALenum audioFormat;
		if(1 == channelsPerFrame)
		{
			if(8 == bitsPerChannel)
			{
				audioFormat = AL_FORMAT_MONO8;
			}
			else
			{
				audioFormat = AL_FORMAT_MONO16;
			}
		}
		else
		{
			if(8 == bitsPerChannel)
			{
				audioFormat = AL_FORMAT_STEREO8;
			}
			else
			{
				audioFormat = AL_FORMAT_STEREO16;
			}
		}

		return [ALBuffer bufferWithName:name
								   data:streamData
								   size:(ALsizei)bufferSize
								 format:audioFormat
							  frequency:(ALsizei)sampleRate];
#endif
	}
}

+ (ALBuffer*) bufferFromUrl:(NSURL*) url reduceToMono:(bool) reduceToMono
{
	id file = [[self alloc] initWithUrl:url reduceToMono:reduceToMono];
	ALBuffer* buffer = [file bufferNamed:[url description]
							  startFrame:0
							   numFrames:-1];
	as_release(file);
	return buffer;
}

@end

