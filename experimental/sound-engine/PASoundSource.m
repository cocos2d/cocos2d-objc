/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 by Florin Dumitrescu.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 *
 ***********************************************************************
 *
 * Part of the source code in this class has been provided by Apple.
 * For full distribution terms, see the top of MyOpenALSupport.h header file.
 *
 */

#import "PASoundSource.h"
#import "PASoundMgr.h"
#import "PASoundListener.h"
#import "ivorbiscodec.h"
#import "ivorbisfile.h"

#define kBuffSize (4096)
#define kSoundReferenceDistance 20.0f

void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei *outSampleRate);

void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei *outSampleRate)
{
	OSStatus						err = noErr;	
	UInt64							fileDataSize = 0;
	AudioStreamBasicDescription		theFileFormat;
	UInt32							thePropertySize = sizeof(theFileFormat);
	AudioFileID						afid = 0;
	void*							theData = NULL;
	
	// Open a file with ExtAudioFileOpen()
	err = AudioFileOpenURL(inFileURL, kAudioFileReadPermission, 0, &afid);
	if(err) {
		NSLog(@"MyGetOpenALAudioData: AudioFileOpenURL FAILED, Error = %ld", err);
		goto Exit;
	}
	
	// Get the audio data format
	err = AudioFileGetProperty(afid, kAudioFilePropertyDataFormat, &thePropertySize, &theFileFormat);
	if(err) {
		NSLog(@"PASoundEngine#MyGetOpenALAudioData: AudioFileGetProperty(kAudioFileProperty_DataFormat) FAILED, Error = %ld", err);
		goto Exit;
	}
	
	if (theFileFormat.mChannelsPerFrame > 2)  { 
		NSLog(@"PASoundEngine#MyGetOpenALAudioData - Unsupported Format, channel count is greater than stereo");
		goto Exit;
	}
	
	if ((theFileFormat.mFormatID != kAudioFormatLinearPCM) || (!TestAudioFormatNativeEndian(theFileFormat))) { 
		NSLog(@"PASoundEngine#MyGetOpenALAudioData - Unsupported Format, must be little-endian PCM");
		goto Exit;
	}
	
	if ((theFileFormat.mBitsPerChannel != 8) && (theFileFormat.mBitsPerChannel != 16)) { 
		NSLog(@"MyGetOpenALAudioData - Unsupported Format, must be 8 or 16 bit PCM\n");
		goto Exit;
	}
	
	
	thePropertySize = sizeof(fileDataSize);
	err = AudioFileGetProperty(afid, kAudioFilePropertyAudioDataByteCount, &thePropertySize, &fileDataSize);
	if(err) {
		NSLog(@"PASoundEngine#MyGetOpenALAudioData: AudioFileGetProperty(kAudioFilePropertyAudioDataByteCount) FAILED, Error = %ld", err);
		goto Exit;
	}
	
	// Read all the data into memory
	UInt32		dataSize = (UInt32) fileDataSize;
	theData = malloc(dataSize);
	if (theData)
	{
		AudioFileReadBytes(afid, false, 0, &dataSize, theData);
		if(err == noErr)
		{
			// success
			*outDataSize = (ALsizei)dataSize;
			*outDataFormat = (theFileFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
			*outSampleRate = (ALsizei)theFileFormat.mSampleRate;
		}
		else 
		{ 
			// failure
			free (theData);
			theData = NULL; // make sure to return NULL
			NSLog(@"PASoundEngine#MyGetOpenALAudioData: ExtAudioFileRead FAILED, Error = %ld", err);
			goto Exit;
		}	
	}
	
Exit:
	// Dispose the ExtAudioFileRef, it is no longer needed
	if (afid) AudioFileClose(afid);
	return theData;
}

@implementation PASoundSource

@synthesize file, extension, looped, isPlaying;

- (id)init {
    return nil;
}

// initializers with position
- (id)initWithPosition:(CGPoint)pos file:(NSString *)f extension:(NSString *)e looped:(BOOL)yn {
    if ((self = [super init])) {
        self.file = f;
        self.extension = e;
        self.looped = yn;
        self.isPlaying = NO;
        [self initBuffer];
        [self initSource];
        self.position = pos;
        self.orientation = 0.0f;
        gain = 1.0f;
    }
    return self;
}
- (id)initWithPosition:(CGPoint)pos file:(NSString *)f looped:(BOOL)yn{
    return [self initWithPosition:pos file:f extension:@"wav" looped:yn];
}
- (id)initWithPosition:(CGPoint)pos file:(NSString *)f {
    return [self initWithPosition:pos file:f extension:@"wav" looped:NO];
}

// initializers without position (will have to be spcified at play time) -- defaulting to CGPointZero
- (id)initWithFile:(NSString *)f extension:(NSString *)e looped:(BOOL)yn {
    return [self initWithPosition:CGPointZero file:f extension:e looped:yn];
}
- (id)initWithFile:(NSString *)f looped:(BOOL)yn {
    return [self initWithPosition:CGPointZero file:f extension:@"wav" looped:yn];
}
- (id)initWithFile:(NSString *)f {
    return [self initWithPosition:CGPointZero file:f extension:@"wav" looped:NO];
}

- (void)initBuffer {
	ALenum  error = AL_NO_ERROR;
	ALenum  format = AL_FORMAT_STEREO16;
	ALvoid* data = NULL;
	ALsizei size = 0;
	ALsizei freq = 0;
	
	NSBundle*				bundle = [NSBundle mainBundle];
	
	// get some audio data from a wave file
	CFURLRef fileURL = (CFURLRef)[[NSURL fileURLWithPath:[bundle pathForResource:self.file ofType:self.extension]] retain];
	
	if (fileURL) {
        
        // load buffer data based on the file format guessed from the extension
        if ([self.extension isEqualToString:@"wav"]) {
            // WAV
            data = MyGetOpenALAudioData(fileURL, &size, &format, &freq);
			
        } else if ([self.extension isEqualToString:@"ogg"]) {
			// XXX
			// XXX Big files will have a lot of performance problems
			// XXX
			// XXX is ov_open_callbacks more efficient ?
			// XXX			
            // OGG
            NSString *fsPath = [(NSURL *)fileURL path];
            FILE *fh;
            if ((fh = fopen([fsPath UTF8String], "r")) != NULL) {
                // open ogg file
                OggVorbis_File vf;
                int eof = 0;
                int current_section;
                
                if(ov_open(fh, &vf, NULL, 0) < 0) {
					NSLog(@"PASoundEngine: Input does not appear to be an Ogg bitstream");
					[NSException raise:@"PASoundEngine:InvalidOggFormat" format:@"InvalidOggFormat"];
                }
                
                // get meta info (sample rate & mono/stereo format)
                vorbis_info *vi = ov_info(&vf,-1);
                freq = (ALsizei)vi->rate;
                format = (vi->channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
                
                // decode data
                size = 0;				
				char tmpBuff[kBuffSize];
				char *newData;
                while(!eof) {
					
                    int ret = ov_read(&vf, &tmpBuff[0], kBuffSize, &current_section);
                    if (ret == 0) {
                        eof = 1;
					} else if (ret < 0) {
						/* error in the stream.  Not a problem, just reporting it in
						 case we (the app) cares.  In this case, we don't. */
						NSLog(@"PASoundEngine:Error reading buffer");
						[NSException raise:@"PASoundEngine:Error reading file" format:@"Error reading file"];						
                    } else {
						size += ret;
												
						// 1st malloc
						if( !data )
							newData = malloc(ret);
						else
							newData = realloc( data, size);

						if( ! newData ) {
							NSLog(@"PASoundEngine: Not enough memory");
							[NSException raise:@"PASoundEngine:NotEnoughMemory" format:@"NotEnoughMemory"];
						}
						data = newData;
						int dst = (int)data + (size-ret);
						memcpy( (char*)dst, &tmpBuff[0], ret);
					}
                }

                // close ogg file
                ov_clear(&vf);
            } else {
				NSLog(@"PASoundEngine: Could not open file");
				[NSException raise:@"PASoundEngine:InvalidOggFormat" format:@"InvalidOggFormat"];
            }
            fclose(fh);
        }
		
        CFRelease(fileURL);
        
        if((error = alGetError()) != AL_NO_ERROR) {
			NSLog(@"PASoundEngine: Error loading sound: %x", error);
			[NSException raise:@"PASoundEngine:ErrorLoadingSound" format:@"ErrorLoadingSound"];

		}
        
		alGenBuffers(1, &buffer);
		alBufferData(buffer, format, data, size, freq);
		free(data);
        
		if((error = alGetError()) != AL_NO_ERROR) {
			NSLog(@"PASoundEngine: Error attaching audio to buffer: %x", error);
		}		
	}
	else {
		NSLog(@"Could not find file");
		[NSException raise:@"PASoundEngine:CouldNotFindfile" format:@"CouldNotFindFile"];
	}
}

- (void)initSource {
    ALenum error = AL_NO_ERROR;
	alGetError(); // Clear the error
    
    alGenSources(1, &source);
    
	// Turn Looping ON?
    if (self.looped) {
        alSourcei(source, AL_LOOPING, AL_TRUE);        
    }
	
	// Set Source Reference Distance
	alSourcef(source, AL_REFERENCE_DISTANCE, kSoundReferenceDistance);
    
	// attach OpenAL Buffer to OpenAL Source
	alSourcei(source, AL_BUFFER, buffer);
	
	if((error = alGetError()) != AL_NO_ERROR) {
		NSLog(@"PASoundEngine: Error attaching buffer to source: %x", error);
		[NSException raise:@"PASoundEngine:AttachingToBuffer" format:@"AttachingToBuffer"];

	}    
}

- (void)setGain:(float)g {
    gain = g;
    alSourcef(source, AL_GAIN, g * [[PASoundMgr sharedSoundManager] soundsMasterGain]);
}
- (void)setRolloff:(float)factor{
    alSourcef(source, AL_ROLLOFF_FACTOR, factor);
}
- (void)setPitch:(float)factor {
    alSourcef(source, AL_PITCH, factor);
}

// play messages
- (void)playAtPosition:(CGPoint)p restart:(BOOL)r {
    CGPoint currentPos = [self position];
    ALint state;
    if ((p.x != currentPos.x) || (p.y != currentPos.y)) {
        [self setPosition:p];
    }
    alGetSourcei(source, AL_SOURCE_STATE, &state);
    if ((state == AL_PLAYING) && r) {
        // stop it before replaying
        [self stop];
        // get current state
        alGetSourcei(source, AL_SOURCE_STATE, &state);
    }
    if (state != AL_PLAYING) {
        alGetError();
        ALenum error;
        [self setGain:gain];
        alSourcePlay(source);
        if((error = alGetError()) != AL_NO_ERROR) {
            NSLog(@"PASoundEngine: Error starting source: %x", error);
        } else {
            // Mark our state as playing (the view looks at this)
            self.isPlaying = YES;
        }        
    }    
}
- (void)playAtPosition:(CGPoint)p {
    return [self playAtPosition:p restart:NO];
}
- (void)playWithRestart:(BOOL)r {
    return [self playAtPosition:self.position restart:r];
}
- (void)play {
    return [self playAtPosition:self.position restart:NO];    
}
- (void)playAtListenerPositionWithRestart:(BOOL)r {
    return [self playAtPosition:[[[PASoundMgr sharedSoundManager] listener] position] restart:r];
}
- (void)playAtListenerPosition {
    return [self playAtListenerPositionWithRestart:NO];
}

- (void)stop {
    alGetError();
    ALenum error;
	alSourceStop(source);
	if((error = alGetError()) != AL_NO_ERROR) {
		NSLog(@"PASoundEngine: Error stopping source: %x", error);
	} else {
		// Mark our state as not playing (the view looks at this)
		self.isPlaying = NO;
	}    
}

- (CGPoint)position {
    return position;
}
- (void)setPosition:(CGPoint)pos {
    float x,y;
    position = pos;
	switch ( [[CCDirector sharedDirector] deviceOrientation] ) {
		case CCDeviceOrientationLandscapeLeft:
			x = pos.x - 240.0f;
			y = 160.0f - pos.y;
			break;
		case CCDeviceOrientationLandscapeRight:
			// XXX: set correct orientation
			x = pos.x - 240.0f;
			y = 160.0f - pos.y;
			break;
		case CCDeviceOrientationPortrait:
			x = pos.x;
			y = pos.y;
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			// XXX: set correct orientation
			x = pos.x;
			y = pos.y;
			break;
	}
    float sourcePosAL[] = {x, y, 0.0f};
	alSourcefv(source, AL_POSITION, sourcePosAL);
}

- (float)orientation {
    return orientation;
}
- (void)setOrientation:(float)o {
    orientation = o;
}


- (void)dealloc {
    [self stop];
    
    alGetError();
    ALenum error;
    alSourcei(source, AL_BUFFER, 0); // dissasociate buffer
    alDeleteBuffers(1, &buffer);
	if((error = alGetError()) != AL_NO_ERROR) {
		printf("error deleting buffer: %x\n", error);
    }
    alDeleteSources(1, &source);
    
    [super dealloc];
}

@end
