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

	CCTextureAtlas	*textureAtlas_;
	ccBlendFunc		blendFunc_;
	
	BOOL useQuad_; //YES childs are quad particle systems, NO childs are point particle systems
	
	BOOL reorderDirty_; //YES if one of the childs is reordered
}

/** the texture atlas used for drawing the quads */
@property (nonatomic, retain) CCTextureAtlas* textureAtlas;
/** the blend function used for drawing the quads */
@property (nonatomic, readwrite) ccBlendFunc blendFunc;

/** initializes the particle system with CCTexture2D, a default capacity of 500, quad particle system and normal blending */
+(id)particleBatchNodeWithTexture:(CCTexture2D *)tex;

/** initializes the particle system with CCTexture2D, 
    a capacity of particles, which particle system to use and a choice between normal or additive blending
*/
+(id)particleBatchNodeWithTexture:(CCTexture2D *)tex capacity:(NSUInteger) capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive;

/** initializes the particle system with the name of a file on disk (for a list of supported formats look at the CCTexture2D class), 
 a default capacity of 500 particles, quad particle system and normal blending
 */
+(id)particleBatchNodeWithFile:(NSString*) imageFile;

/** initializes the particle system with the name of a file on disk (for a list of supported formats look at the CCTexture2D class), 
 a capacity of particles, which particle system to use and a choice between normal or additive blending
 */
+(id)particleBatchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive;

/** extracts texture data from a plist and puts the texture in the texture cache. Use it before loading the batch node */
+(BOOL) extractTextureFromPlist:(NSString*) plistFile;

/** initializes the particle system with CCTexture2D, 
 a capacity of particles, which particle system to use and a choice between normal or additive blending
 */
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive;

/** initializes the particle system with the name of a file on disk (for a list of supported formats look at the CCTexture2D class), 
 a capacity of particles, which particle system to use and a choice between normal or additive blending
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive;

/** only CCParticleSystemQuad is supported for the moment */
-(void) addChild:(CCParticleSystem*)child z:(NSInteger)z tag:(NSInteger) aTag;

/** helper method for addChild, adds room to texture atlas for particles of child */ 
-(void) insertChild:(CCParticleSystem*) pSystem inAtlasAtIndex:(NSUInteger)index;

/** helper method for removeChild, removes child's particles from texture atlas */ 
-(void) removeChildFromAtlas:(CCParticleSystem*) pSystem cleanup:(BOOL) doCleanUp;

/** disables a particle by inserting a 0'd quad into the texture atlas */
-(void) disableParticle:(NSUInteger) particleIndex;

/** switch between multiplied and premultiplied blending modes */ 
-(void) switchBlendingBetweenMultipliedAndPreMultiplied;

/** set a additive blending mode */
-(void) additiveBlending;

/** set a normal blending mode, taking premultiplied / non premultiplied into account */
-(void) normalBlending;

/** conforming to CCTextureProtocol */
-(void) updateBlendFunc;
-(void) setTexture:(CCTexture2D*)texture;
-(CCTexture2D*) texture;
@end
