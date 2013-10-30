//
//  CCParticleSystem_Private.h
//  cocos2d-ios
//
//  Created by Viktor on 10/29/13.
//
//

#import "CCParticleSystem.h"


@interface CCParticleSystem ()

/** weak reference to the CCSpriteBatchNode that renders the CCSprite */
@property (nonatomic,readwrite,unsafe_unretained) CCParticleBatchNode *batchNode;

@property (nonatomic,readwrite) NSUInteger atlasIndex;

//! should be overriden by subclasses
-(void) updateQuadWithParticle:(_CCParticle*)particle newPosition:(CGPoint)pos;
//! should be overriden by subclasses
-(void) postStep;

//! called in every loop.
-(void) update: (CCTime) dt;

-(void) updateWithNoTime;

//! whether or not the system is full
-(BOOL) isFull;

@end
