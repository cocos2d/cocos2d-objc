/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Leonardo Kasperavičius
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CCParticleSystem.h"
#import "ccConfig.h"

@class CCSpriteFrame;
@class CCAnimation;

/** CCParticleSystemQuad is a subclass of CCParticleSystem

 It includes all the features of ParticleSystem.
 
 Special features and Limitations:	
  - Particle size can be any float number.
  - The system can be scaled
  - The particles can be rotated
  - On 1st and 2nd gen iPhones: It is only a bit slower that CCParticleSystemPoint
  - On 3rd gen iPhone and iPads: It is MUCH faster than CCParticleSystemPoint
  - It consumes more RAM and more GPU memory than CCParticleSystemPoint
  - It supports subrects
  - It supports batched rendering since 1.1
 @since v0.8
 */
@interface CCParticleSystemQuad : CCParticleSystem
{
	ccV3F_C4B_T2F_Quad	*quads_;		// quads to be rendered
	GLushort			*indices_;		// indices
	CGRect				textureRect_;
#if CC_USES_VBO
	GLuint				quadsID_;		// VBO id
#endif
	
	CGPoint particleAnchorPoint_;
	CCAnimation			*animation_;
}

@property (nonatomic, readwrite) ccV3F_C4B_T2F_Quad* quads;
/** animation that holds the sprite frames 
 @since 1.1
 */
@property (nonatomic, retain) CCAnimation* animation;

/** create system with properties from plist, batchnode and rect on the sprite sheet 
   use nil for batchNode to not use batch rendering 
   if rect is (0.0f,0.0f,0.0f,0.0f) the whole texture width and height will be used
*/ 
+(id) particleWithFile:(NSString*) plistFile batchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect;

-(id) initWithFile:(NSString *)plistFile batchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect;

-(id) initWithTotalParticles:(NSUInteger)numberOfParticles batchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect;

/** initialices the indices for the vertices */
-(void) initIndices;

/** initilizes the texture with a rectangle measured Points */
-(void) initTexCoordsWithRect:(CGRect)rect;

/** Sets a new CCSpriteFrame as particle.
 WARNING: this method is experimental. Use setTexture:withRect instead.
 uses the texture and the rect of the spriteframe to call setTexture:Rect:
 @since v0.99.4
 */
-(void) setDisplayFrame:(CCSpriteFrame*)spriteFrame;

/** Sets a new texture with a rect. The rect is in Points.
 @since v0.99.4
 */
-(void) setTexture:(CCTexture2D *)texture withRect:(CGRect)rect;

/** sets a animation that will be used for each particle, default particle anchorpoint of (0.5,0.5)
 @since 1.1
 */
-(void) setAnimation:(CCAnimation*) anim;
/** sets a animation that will be used for each particle, and the anchor point for each particle
	Note, offsets of sprite frames are not used
 @since 1.1
 */
-(void) setAnimation:(CCAnimation*) anim withAnchorPoint:(CGPoint) particleAP;

@end