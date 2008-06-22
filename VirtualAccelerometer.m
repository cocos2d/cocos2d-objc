//
//  VirtualAccelerometer.m
//  cocos2d-port
//
//  Created by Joseph R. Cooper on 22/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "VirtualAccelerometer.h"
#define HOST @"192.168.1.83"
#define PORT 0xAC3d

@implementation VirtualAcceleration

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize timestamp;

@end


@implementation VirtualAccelerometer
VirtualAccelerometer* accelerometer = NULL;

@synthesize updateInterval;
@synthesize delegate;

+ (VirtualAccelerometer *)sharedAccelerometer
{
	if (accelerometer == NULL) {
		accelerometer = [[VirtualAccelerometer alloc] retain];
		[accelerometer connect];
	}
	return accelerometer;
}


- (void) connect
{
    NSHost *host = [NSHost hostWithAddress:HOST];
    [NSStream getStreamsToHost:host port:PORT inputStream:&iStream outputStream:&oStream];
    [iStream retain];
    [oStream retain];
    [iStream setDelegate:self];	
    [oStream setDelegate:self];
    [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
    [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
    [iStream open];
    [oStream open];
}


- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	if (eventCode == NSStreamEventHasBytesAvailable)
	{
		float buffer[3];
		[iStream read:(uint8_t*)&buffer maxLength:sizeof(buffer)];
		
		VirtualAcceleration *acceleration = [VirtualAcceleration alloc];
		acceleration.x = buffer[0];
		acceleration.y = buffer[1];
		acceleration.z = buffer[2];

		if (delegate != NULL) {
			[delegate accelerometer:self didAccelerate:acceleration];
		}
	}
}

@end
