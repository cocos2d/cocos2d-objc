/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Copyright (c) 2011 Marco Tillemans
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

#import "CCNode.h"
@class CCTextureAtlas;
@class CCParticleSystem;

//don't use lazy sorting for particle systems
@interface CCNode (extension)
-(void) setZOrder:(NSUInteger) z;
@end

/** CCParticleBatchNode is like a batch node: if it contains children, it will draw them in 1 single OpenGL call
 * (often known as "batch draw").
 *
 * A CCParticleBatchNode can reference one and only one texture (one image file, one texture atlas).
 * Only the CCParticleSystems that are contained in that texture can be added to the CCSpriteBatchNode.
 * All CCParticleSystems added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call.
 * If the CCParticleSystems are not added to a CCParticleBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient.
 *
 *
 * Limitations:
 * - At the moment only CCParticleSystemQuad is supported
 * - All systems need to be drawn with the same parameters, blend function, aliasing, texture
 *
 * Most efficient usage
 * - Initialize the ParticleBatchNode with the texture and enough capacity for all the particle systems
 * - Initialize all particle systems and add them as child to the batch node
 * @since v1.1
 */

@interface CCParticleBatchNode : CCNode <CCTextureProtocol> {

	CCTextureAtlas	*_textureAtlas;
	ccBlendFunc		_blendFunc;
}

/** the texture atlas used for drawing the quads */
@property (nonatomic, strong) CCTextureAtlas* textureAtlas;
/** the blend function used for drawing the quads */
@property (nonatomic, readwrite) ccBlendFunc blendFunc;

/** initializes the particle system with CCTexture2D, a default capacity of 500 */
+(id)batchNodeWithTexture:(CCTexture *)tex;

/** initializes the particle system with the name of a file on disk (for a list of supported formats look at the CCTexture2D class), a default capacity of 500 particles */
+(id)batchNodeWithFile:(NSString*) imageFile;

/** initializes the particle system with CCTexture2D, a capacity of particles, which particle system to use */
+(id)batchNodeWithTexture:(CCTexture *)tex capacity:(NSUInteger) capacity;

/** initializes the particle system with the name of a file on disk (for a list of supported formats look at the CCTexture2D class), a capacity of particles */
+(id)batchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

/** initializes the particle system with CCTexture2D, a capacity of particles */
-(id)initWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity;

/** initializes the particle system with the name of a file on disk (for a list of supported formats look at the CCTexture2D class), a capacity of particles */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity;

/** Add a child into the CCParticleBatchNode */
-(void) addChild:(CCParticleSystem*)child z:(NSInteger)z tag:(NSInteger) aTag;

/** Inserts a child into the CCParticleBatchNode */
-(void) insertChild:(CCParticleSystem*) pSystem inAtlasAtIndex:(NSUInteger)index;

/** remove child from the CCParticleBatchNode */
-(void) removeChild:(CCParticleSystem*) pSystem cleanup:(BOOL)doCleanUp;

/** disables a particle by inserting a 0'd quad into the texture atlas */
-(void) disableParticle:(NSUInteger) particleIndex;
@end
