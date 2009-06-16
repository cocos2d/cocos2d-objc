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
 */

#import "PASoundListener.h"


@implementation PASoundListener

- (id)init {
    return [self initWithPosition:ccp(240,160)]; // middle of screen
}
- (id)initWithPosition:(CGPoint)pos {
    if ((self = [super init])) {
        self.position = pos;
        self.orientation = 0;
    }
    return self;
}


- (CGPoint)position {
    return position;
}
- (void)setPosition:(CGPoint)pos {
    position = pos;
    float x,y;
	switch ( [[Director sharedDirector] deviceOrientation] ) {
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
    float listenerPosAL[] = {x, y, 0.0f};
	// Move our listener coordinates
	alListenerfv(AL_POSITION, listenerPosAL);    
}

- (float)orientation {
    return orientation;
}
- (void)setOrientation:(float)o {
    orientation = o;
//    float ori[] = {cos(o + M_PI_2), sin(o + M_PI_2), 0., 0., 0., 1.};
    float ori[] = {0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f}; // I want my listener to stay heads-up always, regardless of the ship's orientation
	// Set our listener orientation (rotation)
	alListenerfv(AL_ORIENTATION, ori);
}


- (void)dealloc {
    [super dealloc];
}

@end
