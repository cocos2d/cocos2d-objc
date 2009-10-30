//
//  ParticlesScene.h
//  ParticlesTest
//
//  Created by Stas Skuratov on 7/9/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ParticleSmoke.h"

@class ParticlesLayer;

@interface ParticlesScene : CCScene
{
	ParticlesLayer *layer;
}

@property (nonatomic, retain) ParticlesLayer *layer;

- (void) start: (int) totalParticels;

@end

@interface ParticlesLayer : CCLayer
{
	ParticleSmoke2 *smoke;
}

@property (nonatomic, retain) ParticleSmoke2 *smoke;

- (void) start: (int) totalParticels;

@end
