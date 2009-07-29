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

#import <UIKit/UIKit.h>
#include <zlib.h>

#import "TMXTiledMap.h"
#import "AtlasSprite.h"
#import "Support/FileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/base64.h"
#import "Support/ZipUtils.h"

enum
{
	TMXOrientationOrtho,
	TMXOrientationHex,
	TMXOrientationIso,
};

#pragma mark -
#pragma mark LayerData

@interface LayerData : NSObject
{
@public
	NSString		*name;
	CGSize			layerSize;
	unsigned char	*tiles;
}
@end
@implementation LayerData
- (void) dealloc
{
	CCLOG(@"dealling %@",self);
	if( tiles )
		free(tiles);
	[super dealloc];
}

@end

#pragma mark -
#pragma mark TilesetData

@interface TilesetData : NSObject
{
@public
	NSString	*name;
	int			firstGid;
	CGSize		tileSize;
	int			spacing;
	int			margin;
	
	// filename containing the tiles (should be spritesheet / texture atlas)
	NSString	*sourceImage;
	
	// size in pixels of the image
	CGSize		imageSize;
}
-(CGRect) tileForGID:(unsigned int)gid;
@end
@implementation TilesetData
- (void) dealloc
{
	CCLOG(@"deallocing %@", self);
	[sourceImage release];
	[name release];
	[super dealloc];
}

-(CGRect) tileForGID:(unsigned int)gid
{
	CGRect rect;
	rect.size = tileSize;
	
	gid = gid - firstGid;

	int max_x = (imageSize.width - margin*2) / (tileSize.width + spacing);
//	int max_y = (imageSize.height - margin*2) / (tileSize.height + spacing);
	
	rect.origin.x = (gid % max_x) * (tileSize.width + spacing) + margin + 1;
	rect.origin.y = (gid / max_x) * (tileSize.height + spacing) + margin + 1;

	return rect;
}
@end

enum {
	TMXLayerAttribNone = 1 << 0,
	TMXLayerAttribBase64 = 1 << 1,
	TMXLayerAttribGzip = 1 << 2,
};

#pragma mark -
#pragma mark MapData

@interface MapData : NSObject
{
@public
	int	orientation;
	
	// tmp variables
	NSMutableString *currentString;
    BOOL			storingCharacters;	
	int				layerAttribs;
	
	// map width & height
	CGSize	mapSize;
	
	// tiles width & height
	CGSize	tileSize;
	
	// Layers
	NSMutableArray *layers;
	
	// tilesets
	NSMutableArray *tilesets;
}

/** creates a TMX Format with a tmx file */
+(id) formatWithTMXFile:(NSString*)tmxFile;
/** initializes a TMX format witha  tmx file */
-(id) initWithTMXFile:(NSString*)tmxFile;
@end

@implementation MapData
+(id) formatWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	if( (self=[super init])) {
		
		tilesets = [[NSMutableArray arrayWithCapacity:4] retain];
		layers = [[NSMutableArray arrayWithCapacity:4] retain];
	
		// tmp vars
		currentString = [[NSMutableString alloc] initWithCapacity:200];
		storingCharacters = NO;
		layerAttribs = TMXLayerAttribNone;
		
		NSURL *url = [NSURL fileURLWithPath:[FileUtils fullPathFromRelativePath:tmxFile]];
		NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		// we'll do the parsing
		[parser setDelegate:self];
		[parser setShouldProcessNamespaces:NO];
		[parser setShouldReportNamespacePrefixes:NO];
		[parser setShouldResolveExternalEntities:NO];
		[parser parse];
		
		NSError *parseError = [parser parserError];
		if(parseError) {
			CCLOG(@"TMXTiledMap: Error parsing TMX file: %@", parseError);
		}
		
		[parser release];
	}
	return self;
}
- (void) dealloc
{
	CCLOG(@"deallocing %@", self);
	[tilesets release];
	[layers release];
	[currentString release];
	[super dealloc];
}

// the XML parser calls here with all the elements
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	if([elementName isEqualToString:@"map"]) {
		NSString *version = [attributeDict valueForKey:@"version"];
		if( ! [version isEqualToString:@"1.0"] )
			CCLOG(@"TMXFormat: Unsupported TMX version: %@", version);
		NSString *orientationStr = [attributeDict valueForKey:@"orientation"];
		if( [orientationStr isEqualToString:@"orthogonal"])
			orientation = TMXOrientationOrtho;
		else if ( [orientationStr isEqualToString:@"isometric"])
			orientation = TMXOrientationIso;
		else if( [orientationStr isEqualToString:@"hexagonal"])
			orientation = TMXOrientationHex;
		else
			CCLOG(@"TMXFomat: Unsupported orientation: %@", orientation);

		mapSize.width = [[attributeDict valueForKey:@"width"] intValue];
		mapSize.height = [[attributeDict valueForKey:@"height"] intValue];
		tileSize.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		tileSize.height = [[attributeDict valueForKey:@"tileheight"] intValue];
	} else if([elementName isEqualToString:@"tileset"]) {

		TilesetData *tileset = [TilesetData new];
		tileset->name = [attributeDict valueForKey:@"name"];
		tileset->firstGid = [[attributeDict valueForKey:@"firstgid"] intValue];
		tileset->spacing = [[attributeDict valueForKey:@"spacing"] intValue];
		tileset->margin = [[attributeDict valueForKey:@"margin"] intValue];
		tileset->tileSize.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		tileset->tileSize.height = [[attributeDict valueForKey:@"tileheight"] intValue];
		
		[tilesets addObject:tileset];
	} else if([elementName isEqualToString:@"layer"]) {

		LayerData *layer = [LayerData new];
		layer->name = [[attributeDict valueForKey:@"name"] retain];
		layer->layerSize.width = [[attributeDict valueForKey:@"width"] intValue];
		layer->layerSize.height = [[attributeDict valueForKey:@"height"] intValue];
		
		[layers addObject:layer];
		
	} else if([elementName isEqualToString:@"image"]) {

		TilesetData *tileset = [tilesets lastObject];
		tileset->sourceImage = [[attributeDict valueForKey:@"source"] retain];

	} else if([elementName isEqualToString:@"data"]) {

		NSString *encoding = [attributeDict valueForKey:@"encoding"];
		NSString *compression = [attributeDict valueForKey:@"compression"];
		
		if( [encoding isEqualToString:@"base64"] ) {
			layerAttribs |= TMXLayerAttribBase64;
			storingCharacters = YES;
			
			if( [compression isEqualToString:@"gzip"] )
				layerAttribs |= TMXLayerAttribGzip;
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	int len = 0;

	if([elementName isEqualToString:@"data"] && layerAttribs&TMXLayerAttribBase64) {
		storingCharacters = NO;
		
		LayerData *layer = [layers lastObject];
		
		unsigned char *buffer;
		len = base64Decode((unsigned char*)[currentString UTF8String], [currentString length], &buffer);
		if( ! buffer ) {
			CCLOG(@"TiledMap: decode data error");
			return;
		}
		
		if( layerAttribs & TMXLayerAttribGzip ) {
			unsigned char *deflated;
			len = inflateMemory(buffer, len, &deflated);
			free( buffer );
			
			if( ! deflated ) {
				CCLOG(@"TiledMap: inflate data error");
				return;
			}
			
			layer->tiles = deflated;
		} else
			layer->tiles = buffer;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingCharacters)
		[currentString appendString:string];
}


//
// the level did not load, file not found, etc.
//
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	CCLOG(@"Error on XML Parse: %@", [parseError localizedDescription] );
}

@end

#pragma mark -
#pragma mark TMXTiledMap

@interface TMXTiledMap (Private)
-(void) parseLayer:(LayerData*)layer tileset:(TilesetData*)tileset zOrder:(int)zOrder;
@end

@implementation TMXTiledMap

+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	NSAssert(tmxFile != nil, @"TMXTiledMap: tmx file should not bi nil");

	if ((self=[super init])) {
		MapData *map = [MapData formatWithTMXFile:tmxFile];
		NSAssert( [map->tilesets count] == 1, @"TMXTiledMap: only supports 1 tileset");
		
		int idx=0;
		TilesetData *tileset = [map->tilesets objectAtIndex:0];
		for( LayerData *layer in map->layers) {
			[self parseLayer:layer tileset:tileset zOrder:idx++];
		}
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

// private
-(void) parseLayer:(LayerData*)layer tileset:(TilesetData*)tileset zOrder:(int)z
{
	AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:tileset->sourceImage capacity:100];
	tileset->imageSize = [[mgr texture] contentSize];
	
	[[mgr texture] setAliasTexParameters];

	CFByteOrder o = CFByteOrderGetCurrent();
	
	unsigned int *tiles = (unsigned int*) layer->tiles;
	for( unsigned int y=0; y < layer->layerSize.height; y++ ) {
		for( unsigned int x=0; x < layer->layerSize.width; x++ ) {

			unsigned int pos = x + layer->layerSize.width * y;
			unsigned int gid = tiles[ pos ];

			// gid are stored in little endian.
			// if host is big endian, then swap
			if( o == CFByteOrderBigEndian )
				gid = CFSwapInt32( gid );
			
			// gid == 0 --> empty tile
			if( gid != 0 ) {
				CGRect rect;

				rect = [tileset tileForGID:gid];

				AtlasSprite *tile = [AtlasSprite spriteWithRect:rect spriteManager:mgr];
				tile.anchorPoint = CGPointZero;
				[mgr addChild:tile z:0 tag:pos];
				[tile setPosition:ccp( x * tileset->tileSize.width, (layer->layerSize.height - y) * tileset->tileSize.height ) ];
			}
		}
	}
	
	[self addChild:mgr z:z tag:z];
}

@end
