/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCNode.h"
#import "CCTextureAtlas.h"
#import "ccMacros.h"

#pragma mark CCAtlasSpriteManager

@class CCAtlasSprite;

/** AtlasSpriteManager is the object that draws all the AtlasSprite objects
 * that belongs to this Manager. Use 1 AtlasSpriteManager per TextureAtlas
*
 * Limitations:
 *  - The only object that is accepted as child is AtlasSprite
 *  - It's children are all Aliased or all Antialiased.
 * 
 * @since v0.7.1
 */
@interface CCAtlasSpriteManager : CCNode <CCNodeTexture>
{
	CCTextureAtlas *textureAtlas_;
	ccBlendFunc	blendFunc_;
}

/** returns the TextureAtlas that is used */
@property (nonatomic,readwrite,retain) CCTextureAtlas * textureAtlas;

/** conforms to CCNodeTexture protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** creates an AtlasSpriteManager with a texture2d */
+(id)spriteManagerWithTexture:(CCTexture2D *)tex;
/** creates an AtlasSpriteManager with a texture2d and capacity */
+(id)spriteManagerWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;
/** creates an AtlasSpriteManager with a file image (.png, .jpeg, .pvr, etc).
 The file will be loaded using the TextureMgr.
 */
+(id)spriteManagerWithFile:(NSString*) fileImage;
/** creates an AtlasSpriteManager with a file image (.png, .jpeg, .pvr, etc) and capacity. 
 The file will be loaded using the TextureMgr.
*/
+(id)spriteManagerWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

/** initializes an AtlasSpriteManager with a texture2d and capacity */
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;
/** initializes an AtlasSpriteManager with a file image (.png, .jpeg, .pvr, etc).
 The file will be loaded using the TextureMgr.
 */
-(id)initWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

-(NSUInteger)indexForNewChildAtZ:(int)z;
-(void) increaseAtlasCapacity;

/** creates an sprite with a rect in the CCAtlasSpriteManage */
-(CCAtlasSprite*) createSpriteWithRect:(CGRect)rect;

/** removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from an AtlasSpriteManager is very slow
 */
-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup;

/** removes a child given a reference. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from an AtlasSpriteManager is very slow
 */
-(void)removeChild: (CCAtlasSprite *)sprite cleanup:(BOOL)doCleanup;
@end
