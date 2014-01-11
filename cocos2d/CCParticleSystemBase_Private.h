/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 */

#import "CCParticleSystemBase.h"

@interface CCParticleSystemBase ()

// Weak reference to the CCSpriteBatchNode that particle.
@property (nonatomic,readwrite,unsafe_unretained) CCParticleBatchNode *batchNode;

// Altas Index.
@property (nonatomic,readwrite) NSUInteger atlasIndex;

// Should be overriden by subclasses.
-(void) updateQuadWithParticle:(_CCParticle*)particle newPosition:(CGPoint)pos;

// Should be overriden by subclasses.
-(void) postStep;

// Update.
-(void) update: (CCTime) dt;

// Update without time.
-(void) updateWithNoTime;

// System full status.
-(BOOL) isFull;

@end
