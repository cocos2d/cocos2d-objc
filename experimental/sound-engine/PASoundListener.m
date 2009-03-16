/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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
    return [self initWithPosition:cpv(240,160)]; // middle of screen
}
- (id)initWithPosition:(cpVect)pos {
    if ((self = [super init])) {
        self.position = pos;
        self.orientation = 0;
    }
    return self;
}


- (cpVect)position {
    return position;
}
- (void)setPosition:(cpVect)pos {
    position = pos;
    float x,y;
    if ([[Director sharedDirector] landscape]) {
        x = pos.x - 240.0;
        y = 160.0 - pos.y;
    } else {
        x = pos.x;
        y = pos.y;
    }
    float listenerPosAL[] = {x, y, 0.};
	// Move our listener coordinates
	alListenerfv(AL_POSITION, listenerPosAL);    
}

- (float)orientation {
    return orientation;
}
- (void)setOrientation:(float)o {
    orientation = o;
//    float ori[] = {cos(o + M_PI_2), sin(o + M_PI_2), 0., 0., 0., 1.};
    float ori[] = {0., 1., 0., 0., 0., 1.}; // I want my listener to stay heads-up always, regardless of the ship's orientation
	// Set our listener orientation (rotation)
	alListenerfv(AL_ORIENTATION, ori);
}


- (void)dealloc {
    [super dealloc];
}

@end
