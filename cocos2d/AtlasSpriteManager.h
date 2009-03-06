/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CocosNode.h"
#import "TextureAtlas.h"
#import "ccMacros.h"

@class AtlasSprite;

/** AtlasSpriteManager is the object that draws all the AtlasSprite objects
 * that belongs to this Manager. Use 1 AtlasSpriteManager per TextureAtlas
 */
@interface AtlasSpriteManager : CocosNode
{
@private
	unsigned int mTotalSprites;
	TextureAtlas *mAtlas;
	NSMutableArray *mSprites;
}

/** returns the TextureAtlas that is used */
@property (readonly) TextureAtlas * atlas;

/** creates an AtlasSpriteManager with a texture2d */
+(id)spriteManagerWithTexture:(Texture2D *)tex;
/** creates an AtlasSpriteManager with a texture2d and capacity */
+(id)spriteManagerWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity;
/** creates an AtlasSpriteManager with a file image (.png, .jpeg, .pvr, etc) */
+(id)spriteManagerWithFile:(NSString*) fileImage;
/** creates an AtlasSpriteManager with a file image (.png, .jpeg, .pvr, etc) and capacity */
+(id)spriteManagerWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

/** initializes an AtlasSpriteManager with a texture2d and capacity */
-(id)initWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity;
/** initializes an AtlasSpriteManager with a file image (.png, .jpeg, .pvr, etc) */
-(id)initWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

/** creates and add a new AtlasSprite in the AtlasSpriteManger given a rect */
-(AtlasSprite *)createNewSpriteWithRect:(CGRect)rect;
-(int)reserveIndexForSprite;
-(AtlasSprite *)addSprite:(AtlasSprite *)newSprite;

/** removes an AtlasSprite from the AtlasSpriteManager giving an AtlasSprite reference */
-(void)removeSprite:(AtlasSprite *)sprite;
/** removes an AtlasSprite from the AtlasSpriteManager giving an index */
-(void)removeSpriteAtIndex:(int)index;
/** removes all the AltasSprites from the AtlasSpriteManager */
-(void)removeAllSprites;

/* returns the number of AtlasSprites */
-(int)numberOfSprites;
/* returns an AtlasSprite reference giving for an index */
-(AtlasSprite *)spriteAtIndex:(int)index;

@end
