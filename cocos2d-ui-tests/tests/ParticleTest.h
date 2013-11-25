//
//  CCLabelTTF
//  cocos2d-ui-tests-ios
//
//  Created by Andy Korth on November 25th, 2013.
//

#import "TestBase.h"

@interface ParticleTest : TestBase
{
  CCParticleSystem	*emitter;
  CCSprite			*background;
}

@property (readwrite,retain) CCParticleSystem *emitter;

@end
