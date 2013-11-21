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

/**
 
 CCParticleSystemQuad

 ### Special features and Limitations
 
 - Particle size can be any float number.
 - The system can be scaled.
 - The particles can be rotated.
 - It supports subrects.
 - It supports batched rendering for improved performance.

 */

@interface CCParticleSystemQuad : CCParticleSystem {
    
    // Quads to be rendered
	ccV3F_C4B_T2F_Quad	*_quads;
    
    // Indices
	GLushort			*_indices;
    
    // VAO
	GLuint				_VAOname;
    
    //0: vertex  1: indices
	GLuint				_buffersVBO[2];
}

/**
 *  Set particle system texture using specified texture and texture coords value.
 *
 *  @param texture Texture.
 *  @param rect    Texture coords.
 */
-(void) setTexture:(CCTexture *)texture withRect:(CGRect)rect;

@end

