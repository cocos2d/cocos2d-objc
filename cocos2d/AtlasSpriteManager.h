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

#import "cocos2d/cocos2d.h"

@class AtlasSprite;

@interface AtlasSpriteManager : CocosNode
{
@private
	unsigned int mTotalSprites;
	TextureAtlas *mAtlas;
	NSMutableArray *mSprites;
}

+(id)allocWithTexture:(Texture2D *)tex;
+(id)allocWithTexture:(Texture2D *)tex withCapacity:(int)capacity;
-(id)initWithTexture:(Texture2D *)tex withCapacity:(int)capacity;

-(AtlasSprite *)createNewSpriteWithParameters:(NSDictionary *)parameters;
-(int)reserveIndexForSprite;
-(AtlasSprite *)addSprite:(AtlasSprite *)newSprite;

-(void)removeSprite:(AtlasSprite *)sprite;
-(void)removeSpriteAtIndex:(int)index;
-(void)removeAllSprites;

-(TextureAtlas *)atlas;

-(int)numberOfSprites;
-(AtlasSprite *)spriteAtIndex:(int)index;
-(NSEnumerator *)spriteEnumerator;

@end
