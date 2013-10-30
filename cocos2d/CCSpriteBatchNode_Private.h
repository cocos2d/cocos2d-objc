//
//  CCSpriteBatchNode_Private.h
//  cocos2d-osx
//
//  Created by Viktor on 10/29/13.
//
//

#import "CCSpriteBatchNode.h"

@interface CCSpriteBatchNode ()

/** returns the TextureAtlas that is used */
@property (nonatomic,readwrite,strong) CCTextureAtlas * textureAtlas;

/** descendants (children, grandchildren, etc) */
@property (nonatomic,readonly) NSArray *descendants;

-(void) increaseAtlasCapacity;

-(void) insertChild:(CCSprite*)child inAtlasAtIndex:(NSUInteger)index;
-(void) appendChild:(CCSprite*)sprite;
-(void) removeSpriteFromAtlas:(CCSprite*)sprite;


-(NSUInteger) rebuildIndexInOrder:(CCSprite*)parent atlasIndex:(NSUInteger)index;
-(NSUInteger) atlasIndexForChild:(CCSprite*)sprite atZ:(NSInteger)z;
/* Sprites use this to start sortChildren, don't call this manually */
- (void) reorderBatch:(BOOL) reorder;

/** removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from a CCSpriteBatchNode is very slow
 */
-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup;

@end

@interface CCSpriteBatchNode (QuadExtensions)
/** Inserts a quad at a certain index into the texture atlas. The CCSprite won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTMXMap) or a label with lots of characters (CCLabelBMFont)
 */
-(void) insertQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index;

/** Updates a quad at a certain index into the texture atlas. The CCSprite won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTMXMap) or a label with lots of characters (CCLabelBMFont)
 */
-(void) updateQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index;

/* This is the opposite of "addQuadFromSprite".
 It adds the sprite to the children and descendants array, but it doesn't add it to the texture atlas.
 */
-(id) addSpriteWithoutQuad:(CCSprite*)child z:(NSUInteger)z tag:(NSInteger)aTag;

@end
