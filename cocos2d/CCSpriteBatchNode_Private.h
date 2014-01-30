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
 *
 */

#import "CCSpriteBatchNode.h"

@interface CCSpriteBatchNode ()

// Returns the TextureAtlas that is used.
@property (nonatomic,readwrite,strong) CCTextureAtlas * textureAtlas;

// Descendants (children, grandchildren, etc).
@property (nonatomic,readonly) NSArray *descendants;

// Increase atlas capacity.
-(void) increaseAtlasCapacity;

// Insert child sprite at specified index value.
-(void) insertChild:(CCSprite*)child inAtlasAtIndex:(NSUInteger)index;

// Append child sprite.
-(void) appendChild:(CCSprite*)sprite;

// Remove specified sprite from atlas.
-(void) removeSpriteFromAtlas:(CCSprite*)sprite;

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)parent atlasIndex:(NSUInteger)index;
-(NSUInteger) atlasIndexForChild:(CCSprite*)sprite atZ:(NSInteger)z;

// Sprites use this to sort children, do not call manually.
- (void) reorderBatch:(BOOL) reorder;

// Removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup;

@end

@interface CCSpriteBatchNode (QuadExtensions)

/* 
 Inserts a quad at a certain index into the texture atlas. The CCSprite won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTiledMap) or a label with lots of characters (CCLabelBMFont)
 */
-(void) insertQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index;

/*
 Updates a quad at a certain index into the texture atlas. The CCSprite won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTiledMap) or a label with lots of characters (CCLabelBMFont)
 */
-(void) updateQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index;

/* 
 This is the opposite of "addQuadFromSprite".
 It adds the sprite to the children and descendants array, but it doesn't add it to the texture atlas.
 */
-(id) addSpriteWithoutQuad:(CCSprite*)child z:(NSUInteger)z name:(NSString*)name;

@end
