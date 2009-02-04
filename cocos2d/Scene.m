/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "Scene.h"
#import "Director.h"

@implementation Scene
-(id) init
{
	if( ! (self=[super init]) )
		return nil;
	
	CGSize s = [[Director sharedDirector] winSize];
	relativeTransformAnchor = NO;

	transformAnchor.x = s.width / 2;
	transformAnchor.y = s.height / 2;
	
	return self;
}
@end
