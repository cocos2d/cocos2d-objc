/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

#pragma mark AtlasSpriteManager

@class AtlasSprite;

/** AtlasSpriteManager is the object that draws all the AtlasSprite objects
 * that belongs to this Manager. Use 1 AtlasSpriteManager per TextureAtlas
*
 * Limitations:
 *  - The only object that is accepted as child is AtlasSprite
 *  - It's children are all Aliased or all Antialiased.
 * 
 * @since v0.7.1
 */
@interface AtlasSpriteManager : CocosNode <CocosNodeTexture>
{
	unsigned int totalSprites_;
	TextureAtlas *textureAtlas_;
	ccBlendFunc	blendFunc_;
}

/** returns the TextureAtlas that is used */
@property (readwrite,retain) TextureAtlas * textureAtlas;

/** conforms to CocosNodeTexture protocol */
@property (readwrite) ccBlendFunc blendFunc;

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

-(NSUInteger)indexForNewChildAtZ:(int)z;

/** creates an sprite with a rect in the AtlasSpriteManage */
-(AtlasSprite*) createSpriteWithRect:(CGRect)rect;

/** removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from an AtlasSpriteManager is very slow
 */
-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup;

/** removes a child given a reference. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from an AtlasSpriteManager is very slow
 */
-(void)removeChild: (AtlasSprite *)sprite cleanup:(BOOL)doCleanup;
@end
