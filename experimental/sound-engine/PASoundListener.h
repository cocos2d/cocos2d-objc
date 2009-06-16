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

#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#import "cocos2d.h"

@interface PASoundListener : NSObject {
    CGPoint position;
    float orientation;
}

@property (readwrite, assign) CGPoint position;
@property (readwrite, assign) float orientation;

- (id)initWithPosition:(CGPoint)pos;

@end
