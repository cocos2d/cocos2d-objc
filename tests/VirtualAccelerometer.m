//
//  VirtualAccelerometer.m
//  cocos2d-port
//
//  Created by Joseph R. Cooper on 22/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "VirtualAccelerometer.h"
#define kAppIdentifier		@"ac3d"
#define kAccelReadingId 1
#define kTouchesBeganId 2
#define kTouchesMovedId 3

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
		[accelerometer setup];
	}
	return accelerometer;
}

- (void) openStreams
{
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}

- (void) dealloc
{	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_inStream release];
	
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream release];
	
	[_server release];
	
//	[_picker release];
//	[_window release];
	
	[super dealloc];
}

- (void) _showAlert:(NSString*)title
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void) setup {
	[_server release];
	_server = nil;
	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream release];
	_inStream = nil;
//	_inReady = NO;
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream release];
	_outStream = nil;
//	_outReady = NO;
	
	_server = [TCPServer new];
	[_server setDelegate:self];
	NSError* error;
	if(_server == nil || ![_server start:&error]) {
		NSLog(@"Failed creating server: %@", error);
		[self _showAlert:@"Failed creating server"];
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kAppIdentifier] name:nil]) {
		[self _showAlert:@"Failed advertising server"];
		return;
	}
	
	//[self presentPicker:nil];
}

 
/*
- (void) setup
{
	NSHost *host = [NSHost hostWithAddress:HOST];
    [NSStream getStreamsToHost:host port:PORT inputStream:&_inStream outputStream:&_outStream];
    [_inStream retain];
    [_outStream retain];
    [_inStream setDelegate:self];	
    [_outStream setDelegate:self];
    [_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
    [_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
    [_inStream open];
    [_outStream open];
}
*/

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	if (eventCode == NSStreamEventHasBytesAvailable)
	{
		int len;
		uint8_t ident;
		len = [_inStream read:(uint8_t*)&ident maxLength:sizeof(ident)];
		if (len >= sizeof(ident)) {
			switch (ident) {
				case kAccelReadingId: {
					float buffer[3];
					len = [_inStream read:(uint8_t*)&buffer maxLength:sizeof(buffer)];
					if (len >= sizeof(buffer)) {
						
						VirtualAcceleration *acceleration = [[VirtualAcceleration alloc] retain];
						
						acceleration.x = buffer[0];
						acceleration.y = buffer[1];
						acceleration.z = buffer[2];
						if (delegate != NULL) {
							[delegate accelerometer:self didAccelerate:acceleration];
						}
						[acceleration release];
					}
					break;
				}
				case kTouchesBeganId:
				case kTouchesMovedId: {
					float buffer2[2];
					len = [_inStream read:(uint8_t*)&buffer2 maxLength:sizeof(buffer2)];
					if (len >= sizeof(buffer2)) {
						if (delegate != NULL) {
							[delegate virtualTapWithX:buffer2[0] withY:buffer2[1]]; 
						}
					}
					break;
				}
			}		
		}
		
		//NSLog([NSString stringWithFormat:@"%.2f %.2f %.2f", buffer[0], buffer[1], buffer[2]]);
	}
}

- (void)didAcceptConnectionForServer:(TCPServer*)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	if (_inStream || _outStream || server != _server)
		return;
	
	[_server release];
	_server = nil;
	
	_inStream = istr;
	[_inStream retain];
	_outStream = ostr;
	[_outStream retain];
	
	[self openStreams];
}

@end
