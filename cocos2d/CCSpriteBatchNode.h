/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
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


#import "CCNode.h"
#import "CCProtocols.h"
#import "CCTextureAtlas.h"
#import "ccMacros.h"

#pragma mark CCSpriteBatchNode

@class CCSprite;

/** CCSpriteBatchNode is like a batch node: if it contains children, it will draw them in 1 single OpenGL call
 * (often known as "batch draw").
 *
 * A CCSpriteBatchNode can reference one and only one texture (one image file, one texture atlas).
 * Only the CCSprites that are contained in that texture can be added to the CCSpriteBatchNode.
 * All CCSprites added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call.
 * If the CCSprites are not added to a CCSpriteBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient.
 *
 *
 * Limitations:
 *  - The only object that is accepted as child (or grandchild, grand-grandchild, etc...) is CCSprite or any subclass of CCSprite. eg: particles, labels and layer can't be added to a CCSpriteBatchNode.
 *  - Either all its children are Aliased or Antialiased. It can't be a mix. This is because "alias" is a property of the texture, and all the sprites share the same texture.
 *
 * @since v0.7.1
 */
@interface CCSpriteBatchNode : CCNode <CCTextureProtocol>
{
	CCTextureAtlas	*textureAtlas_;
	ccBlendFunc		blendFunc_;

	// all descendants: children, grandchildren, etc...
	CCArray	*descendants_;
}

/** returns the TextureAtlas that is used */
@property (nonatomic,readwrite,retain) CCTextureAtlas * textureAtlas;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** descendants (children, grandchildren, etc) */
@property (nonatomic,readonly) CCArray *descendants;

/** creates a CCSpriteBatchNode with a texture2d and a default capacity of 29 children.
 The capacity will be increased in 33% in runtime if it run out of space.
 */
+(id)batchNodeWithTexture:(CCTexture2D *)tex;

/** creates a CCSpriteBatchNode with a texture2d and capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 */
+(id)batchNodeWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;

/** creates a CCSpriteBatchNode with a file image (.png, .jpeg, .pvr, etc) with a default capacity of 29 children.
 The capacity will be increased in 33% in runtime if it run out of space.
 The file will be loaded using the TextureMgr.
 */
+(id)batchNodeWithFile:(NSString*) fileImage;

/** creates a CCSpriteBatchNode with a file image (.png, .jpeg, .pvr, etc) and capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 The file will be loaded using the TextureMgr.
*/
+(id)batchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

/** initializes a CCSpriteBatchNode with a texture2d and capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 */
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;
/** initializes a CCSpriteBatchNode with a file image (.png, .jpeg, .pvr, etc) and a capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 The file will be loaded using the TextureMgr.
 */
-(id)initWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

-(void) increaseAtlasCapacity;

/** removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from a CCSpriteBatchNode is very slow
 */
-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup;

/** removes a child given a reference. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from a CCSpriteBatchNode is very slow
 */
-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup;

-(void) insertChild:(CCSprite*)child inAtlasAtIndex:(NSUInteger)index;
-(void) appendChild:(CCSprite*)sprite;
-(void) removeSpriteFromAtlas:(CCSprite*)sprite;

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)parent atlasIndex:(NSUInteger)index;
-(NSUInteger) atlasIndexForChild:(CCSprite*)sprite atZ:(NSInteger)z;
/* Sprites use this to start sortChildren, don't call this manually */
- (void) reorderBatch:(BOOL) reorder;

@end

@interface CCSpriteBatchNode (QuadExtensions)
/** Adds a quad into the texture atlas but it won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTMXMap) or a label with lots of characters (CCLabelBMFont)
 */
-(id) addSpriteWithoutQuad:(CCSprite*)child z:(NSUInteger)z tag:(NSInteger)aTag;

/* This is the opposite of "addQuadFromSprite".
 It adds the sprite to the children and descendants array, but it doesn't add it to the texture atlas.
 */
-(void) addQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index;
@end
