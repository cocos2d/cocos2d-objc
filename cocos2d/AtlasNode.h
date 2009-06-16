/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "TextureAtlas.h"
#import "CocosNode.h"

/** AtlasNode is a subclass of CocosNode that implements the CocosNodeRGBA and
 CocosNodeTexture protocol
 
 It knows how to render a TextureAtlas object.
 If you are going to render a TextureAtlas consider subclassing AtlasNode (or a subclass of AtlasNode)
 
 All features from CocosNode are valid, plus the following features:
 - opacity and RGB colors
 */
@interface AtlasNode : CocosNode <CocosNodeRGBA, CocosNodeTexture> {

	// texture atlas
	TextureAtlas	*textureAtlas_;

	// chars per row
	int				itemsPerRow;
	// chars per column
	int				itemsPerColumn;
	
	// texture coordinate x increment
	float			texStepX;
	// texture coordinate y increment
	float			texStepY;
	
	// width of each char
	int				itemWidth;
	// height of each char
	int				itemHeight;

	// blend function
	ccBlendFunc		blendFunc_;

	// texture RGBA. 
	GLubyte	r_,g_,b_, opacity_;
	BOOL opacityModifyRGB_;
}

/** conforms to CocosNodeTexture protocol */
@property (readwrite,retain) TextureAtlas *textureAtlas;

/** conforms to CocosNodeTexture protocol */
@property (readwrite) ccBlendFunc blendFunc;

/** conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte r, g, b, opacity;


/** creates an AtlasNode  with an Atlas file the width and height of each item and the quantity of items to render*/
+(id) atlasWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c;

/** initializes an AtlasNode  with an Atlas file the width and height of each item and the quantity of items to render*/
-(id) initWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c;

/** updates the Atlas (indexed vertex array).
 * Shall be overriden in subclasses
 */
-(void) updateAtlasValues;
@end
