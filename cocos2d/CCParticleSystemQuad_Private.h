//
//  CCParticleSystemQuad_Private.h
//  cocos2d-osx
//
//  Created by Viktor on 10/29/13.
//
//

#import "CCParticleSystemQuad.h"

@interface CCParticleSystemQuad ()

/** initialices the indices for the vertices */
-(void) initIndices;

/** initilizes the texture with a rectangle measured Points */
-(void) initTexCoordsWithRect:(CGRect)rect;

/** Sets a new CCSpriteFrame as particle.
 WARNING: this method is experimental. Use setTexture:withRect instead.
 @since v0.99.4
 */
-(void)setSpriteFrame:(CCSpriteFrame*)spriteFrame;

@end
