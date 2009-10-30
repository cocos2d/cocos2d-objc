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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@class PASoundSource;

@interface SoundEngineTest : CCLayer
{
    CCSprite *listenerSprite;
    CCSprite *source1Sprite;
    CCSprite *source2Sprite;
    
    PASoundSource *source1;
    PASoundSource *source2;
    PASoundSource *bgTrack;
}

- (void)selectedBackForwardMenuItem:(id)sender;
- (void)selectedCenterMenuItem:(id)sender;
- (void)loop:(ccTime)t;

@end
