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
#import "CCProtocols.h"
#import "CCTextureAtlas.h"
#import "ccMacros.h"
#import "Support/ccArray.h"

#pragma mark CCSpriteSheet

@class CCSprite;

/** CCSpriteSheet an optimization node: if it contains children, then it will draw in 1 single OpenGL call
 * (ofter know as a batch draw).
 *
 * A CCSpriteSheet can reference one and only one texture (one image file, one texture atlas).
 * Only the CCSprites that are contained in that texture can be added to the CCSpriteSheet.
 * All CCSprites added to a CCSpriteSheet are drawn in one OpenGL ES draw call.
 * If the CCSprites are not added to a CCSpriteSheet then an OpenGL ES draw call will be needed for each one, which is less efficient.
 *
 *
 * Limitations:
 *  - The only object that is accepted as child, grandchild, is CCSprite
 *  - It's children are all Aliased or all Antialiased.
 * 
 * @since v0.7.1
 */
@interface CCSpriteSheet : CCNode <CCTextureProtocol>
{
	CCTextureAtlas	*textureAtlas_;
	ccBlendFunc		blendFunc_;

	// all descendants: chlidren, gran children, etc...
	NSMutableArray	*descendants_;
//	ccArray			*descendants_;
}

/** returns the TextureAtlas that is used */
@property (nonatomic,readwrite,retain) CCTextureAtlas * textureAtlas;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** descendants (children, gran children, etc) */
@property (nonatomic,readonly) NSMutableArray *descendants;

/** creates a CCSpriteSheet with a texture2d and a default capacity of 29 children.
 The capacity will be increased in 33% in runtime if it run out of space.
 */
+(id)spriteSheetWithTexture:(CCTexture2D *)tex;
/** creates a CCSpriteSheet with a texture2d and capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 */
+(id)spriteSheetWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;
/** creates a CCSpriteSheet with a file image (.png, .jpeg, .pvr, etc) with a default capacity of 29 children.
 The capacity will be increased in 33% in runtime if it run out of space.
 The file will be loaded using the TextureMgr.
 */
+(id)spriteSheetWithFile:(NSString*) fileImage;
/** creates a CCSpriteSheet with a file image (.png, .jpeg, .pvr, etc) and capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 The file will be loaded using the TextureMgr.
*/
+(id)spriteSheetWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

/** initializes a CCSpriteSheet with a texture2d and capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 */
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;
/** initializes a CCSpriteSheet with a file image (.png, .jpeg, .pvr, etc) and a capacity of children.
 The capacity will be increased in 33% in runtime if it run out of space.
 The file will be loaded using the TextureMgr.
 */
-(id)initWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

-(void) increaseAtlasCapacity;

/** creates an sprite with a rect in the CCSpriteSheet.
 It's the same as:
   - create an standard CCSsprite
   - set the usingSpriteSheet = YES
   - set the textureAtlas to the same texture Atlas as the CCSpriteSheet
 @deprecated Use [CCSprite spriteWithSpriteSheet:rect] instead;
 */
-(CCSprite*) createSpriteWithRect:(CGRect)rect __attribute__((deprecated));

/** initializes a previously created sprite with a rect. This sprite will have the same texture as the CCSpriteSheet.
 It's the same as:
 - initialize an standard CCSsprite
 - set the usingSpriteSheet = YES
 - set the textureAtlas to the same texture Atlas as the CCSpriteSheet
 @since v0.99.0
 @deprecated Use [CCSprite initWithSpriteSheet:rect] instead;
*/ 
-(void) initSprite:(CCSprite*)sprite rect:(CGRect)rect __attribute__((deprecated));

/** removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from a CCSpriteSheet is very slow
 */
-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup;

/** removes a child given a reference. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from a CCSpriteSheet is very slow
 */
-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup;

-(void) insertChild:(CCSprite*)child inAtlasAtIndex:(NSUInteger)index;
-(void) removeSpriteFromAtlas:(CCSprite*)sprite;

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)parent atlasIndex:(NSUInteger)index;
-(NSUInteger) atlasIndexForChild:(CCSprite*)sprite atZ:(int)z;

@end
