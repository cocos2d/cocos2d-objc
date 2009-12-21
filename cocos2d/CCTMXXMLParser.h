/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */

/*
 * Internal TMX parser
 *
 * IMPORTANT: These classed should not be documented using doxygen strings
 * since the user should not use them.
 *
 */
 

enum {
	TMXLayerAttribNone = 1 << 0,
	TMXLayerAttribBase64 = 1 << 1,
	TMXLayerAttribGzip = 1 << 2,
};

enum {
	TMXPropertyNone,
	TMXPropertyMap,
	TMXPropertyLayer,
	TMXPropertyObjectGroup,
	TMXPropertyObject,
};

/* CCTMXLayerInfo contains the information about the layers like:
 - Layer name
 - Layer size
 - Layer opacity at creation time (it can be modified at runtime)
 - Whether the layer is visible (if it's not visible, then the CocosNode won't be created)
 
 This information is obtained from the TMX file.
 */
@interface CCTMXLayerInfo : NSObject
{
	NSString			*name_;
	CGSize				layerSize_;
	unsigned int		*tiles_;
	BOOL				visible_;
	unsigned char		opacity_;
	BOOL				ownTiles_;
	unsigned int		minGID_;
	unsigned int		maxGID_;
	NSMutableDictionary	*properties_;	
}

@property (nonatomic,readwrite,retain) NSString *name;
@property (nonatomic,readwrite,assign) CGSize layerSize;
@property (nonatomic,readwrite,assign) unsigned int *tiles;
@property (nonatomic,readwrite,assign) BOOL visible;
@property (nonatomic,readwrite,assign) unsigned char opacity;
@property (nonatomic,readwrite,assign) BOOL ownTiles;
@property (nonatomic,readwrite,assign) unsigned int minGID;
@property (nonatomic,readwrite,assign) unsigned int maxGID;
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;

@end

/* CCTMXTilesetInfo contains the information about the tilesets like:
 - Tileset name
 - Tilset spacing
 - Tileset margin
 - size of the tiles
 - Image used for the tiles
 - Image size
 
 This information is obtained from the TMX file. 
 */
@interface CCTMXTilesetInfo : NSObject
{
	NSString		*name_;
	unsigned int	firstGid_;
	CGSize			tileSize_;
	unsigned int	spacing_;
	unsigned int	margin_;
	
	// filename containing the tiles (should be spritesheet / texture atlas)
	NSString	*sourceImage_;
	
	// size in pixels of the image
	CGSize		imageSize_;
}
@property (nonatomic,readwrite,retain) NSString *name;
@property (nonatomic,readwrite,assign) unsigned int firstGid;
@property (nonatomic,readwrite,assign) CGSize tileSize;
@property (nonatomic,readwrite,assign) unsigned int spacing;
@property (nonatomic,readwrite,assign) unsigned int margin;
@property (nonatomic,readwrite,retain) NSString *sourceImage;
@property (nonatomic,readwrite,assign) CGSize imageSize;

-(CGRect) rectForGID:(unsigned int)gid;
@end

/* CCTMXMapInfo contains the information about the map like:
 - Map orientation (hexagonal, isometric or orthogonal)
 - Tile size
 - Map size
 
 And it also contains:
 - Layers (an array of TMXLayerInfo objects)
 - Tilesets (an array of TMXTilesetInfo objects)
 - ObjectGroups (an array of TMXObjectGroupInfo objects)
 
 This information is obtained from the TMX file.
 
 */
@interface CCTMXMapInfo : NSObject
{	
	NSMutableString		*currentString;
    BOOL				storingCharacters;	
	int					layerAttribs;
	int					parentElement;
	
	// tmx filename
	NSString *filename_;

	// map orientation
	int	orientation_;	
	
	// map width & height
	CGSize	mapSize_;
	
	// tiles width & height
	CGSize	tileSize_;
	
	// Layers
	NSMutableArray *layers_;
	
	// tilesets
	NSMutableArray *tilesets_;
		
	// ObjectGroups
	NSMutableArray *objectGroups_;
	
	// properties
	NSMutableDictionary *properties_;
}

@property (nonatomic,readwrite,assign) int orientation;
@property (nonatomic,readwrite,assign) CGSize mapSize;
@property (nonatomic,readwrite,assign) CGSize tileSize;
@property (nonatomic,readwrite,retain) NSMutableArray *layers;
@property (nonatomic,readwrite,retain) NSMutableArray *tilesets;
@property (nonatomic,readwrite,retain) NSString *filename;
@property (nonatomic,readwrite,retain) NSMutableArray *objectGroups;
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;

/** creates a TMX Format with a tmx file */
+(id) formatWithTMXFile:(NSString*)tmxFile;
/** initializes a TMX format witha  tmx file */
-(id) initWithTMXFile:(NSString*)tmxFile;
@end

