/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCDirector.h"
#import "CCCamera.h"
#import "ccMacros.h"

#import "Support/glu.h"

@implementation CCCamera

@synthesize dirty;

-(id) init
{
	if( (self=[super init]) )
		[self restore];
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | center = (%.2f,%.2f,%.2f)>", [self class], self, centerX, centerY, centerZ];
}


- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(void) restore
{
	CGSize s = [[CCDirector sharedDirector] displaySize];

	eyeX = s.width/2;
	eyeY = s.height/2;
	eyeZ = [CCCamera getZEye];
	
	centerX = s.width/2;
	centerY = s.height/2;
	centerZ = 0.0f;
	
	upX = 0.0f;
	upY = 1.0f;
	upZ = 0.0f;
	
	dirty = NO;
}

-(void) locate
{
	if( dirty ) {
		ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];

		glLoadIdentity();

		switch( orientation ) {
			case CCDeviceOrientationPortrait:
				break;
			case CCDeviceOrientationPortraitUpsideDown:
				glRotatef(-180,0,0,1);
				break;
			case CCDeviceOrientationLandscapeLeft:
				glRotatef(-90,0,0,1);
				break;
			case CCDeviceOrientationLandscapeRight:
				glRotatef(90,0,0,1);
				break;	
		}
		
		gluLookAt( eyeX, eyeY, eyeZ,
				centerX, centerY, centerZ,
				upX, upY, upZ
				);
		
		switch( orientation ) {
			case CCDeviceOrientationPortrait:
			case CCDeviceOrientationPortraitUpsideDown:
				// none
				break;
			case CCDeviceOrientationLandscapeLeft:
				glTranslatef(-80,80,0);
				break;
			case CCDeviceOrientationLandscapeRight:
				glTranslatef(-80,80,0);
				break;	
		}
	}
}

+(float) getZEye
{
	CGSize s = [[CCDirector sharedDirector] displaySize];
	return ( s.height / 1.1566f );
}

-(void) setEyeX: (float)x eyeY:(float)y eyeZ:(float)z
{
	eyeX = x;
	eyeY = y;
	eyeZ = z;
	dirty = YES;
}

-(void) setCenterX: (float)x centerY:(float)y centerZ:(float)z
{
	centerX = x;
	centerY = y;
	centerZ = z;
	dirty = YES;
}

-(void) setUpX: (float)x upY:(float)y upZ:(float)z
{
	upX = x;
	upY = y;
	upZ = z;
	dirty = YES;
}

-(void) eyeX: (float*)x eyeY:(float*)y eyeZ:(float*)z
{
	*x = eyeX;
	*y = eyeY;
	*z = eyeZ;
}

-(void) centerX: (float*)x centerY:(float*)y centerZ:(float*)z
{
	*x = centerX;
	*y = centerY;
	*z = centerZ;
}

-(void) upX: (float*)x upY:(float*)y upZ:(float*)z
{
	*x = upX;
	*y = upY;
	*z = upZ;
}

@end
