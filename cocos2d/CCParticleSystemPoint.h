/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

#define CC_MAX_PARTICLE_SIZE 64

/** CCParticleSystemPoint is a subclass of CCParticleSystem
 Attributes of a Particle System:
 * All the attributes of Particle System

 Features:
  * consumes small memory: uses 1 vertex (x,y) per particle, no need to assign tex coordinates
  * size can't be bigger than 64
  * the system can't be scaled since the particles are rendered using GL_POINT_SPRITE
 
 Limitations:
  * On 3rd gen iPhone devices and iPads, this node performs MUCH slower than CCParticleSystemQuad.
 */
@interface CCParticleSystemPoint : CCParticleSystem
{	
	// Array of (x,y,size) 
	ccPointSprite *vertices;
	// vertices buffer id
#if CC_USES_VBO
	GLuint	verticesID;
#endif
}
@end

