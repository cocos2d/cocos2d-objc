/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 mark@abitofthought.com 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "Director.h"

@interface FastDirector : Director {
	BOOL isRunning;
}

/** returns a shared instance of the director */
+(FastDirector *)sharedDirector;

@end
