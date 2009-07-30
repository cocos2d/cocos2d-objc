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
	BOOL			visible;
	GLubyte			opacity;
}
@end
@implementation LayerData
- (void) dealloc
{
	CCLOG(@"deallocing %@",self);
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

	int max_x = (imageSize.width - margin*2 + spacing) / (tileSize.width + spacing);
//	int max_y = (imageSize.height - margin*2 + spacing) / (tileSize.height + spacing);
	
	rect.origin.x = (gid % max_x) * (tileSize.width + spacing) + margin;
	rect.origin.y = (gid / max_x) * (tileSize.height + spacing) + margin;

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
		tileset->name = [[attributeDict valueForKey:@"name"] retain];
		tileset->firstGid = [[attributeDict valueForKey:@"firstgid"] intValue];
		tileset->spacing = [[attributeDict valueForKey:@"spacing"] intValue];
		tileset->margin = [[attributeDict valueForKey:@"margin"] intValue];
		tileset->tileSize.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		tileset->tileSize.height = [[attributeDict valueForKey:@"tileheight"] intValue];
		
		[tilesets addObject:tileset];
		[tileset release];

	} else if([elementName isEqualToString:@"layer"]) {
		LayerData *layer = [LayerData new];
		layer->name = [[attributeDict valueForKey:@"name"] retain];
		layer->layerSize.width = [[attributeDict valueForKey:@"width"] intValue];
		layer->layerSize.height = [[attributeDict valueForKey:@"height"] intValue];
		layer->visible = ![[attributeDict valueForKey:@"visible"] isEqualToString:@"0"];
		if( [attributeDict valueForKey:@"opacity"] ){
			layer->opacity = 255 * [[attributeDict valueForKey:@"opacity"] floatValue];
		}else{
			layer->opacity = 255;
		}
		
		[layers addObject:layer];
		[layer release];
		
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
		
		[currentString setString:@""];
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
-(id) parseLayer:(LayerData*)layer tileset:(TilesetData*)tileset map:(MapData*)map;
-(void) setOrthoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize;
-(void) setIsoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize;
-(void) setHexTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize;
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
		
		[self setContentSize:CGSizeZero];

		MapData *map = [MapData formatWithTMXFile:tmxFile];
		NSAssert( [map->tilesets count] == 1, @"TMXTiledMap: only supports 1 tileset");
		
		int idx=0;
		TilesetData *tileset = [map->tilesets objectAtIndex:0];
		for( LayerData *layer in map->layers ) {
			if( layer->visible == NO ) continue;
			
			id child = [self parseLayer:layer tileset:tileset map:map];
			[self addChild:child z:idx tag:idx];
			
			// update content size with the max size
			CGSize childSize = [child contentSize];
			CGSize currentSize = [self contentSize];
			currentSize.width = MAX( currentSize.width, childSize.width );
			currentSize.height = MAX( currentSize.height, childSize.height );
			[self setContentSize:currentSize];
			
			idx++;
		}
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

// private
-(id) parseLayer:(LayerData*)layer tileset:(TilesetData*)tileset map:(MapData*)map
{
	AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:tileset->sourceImage capacity:100];
	tileset->imageSize = [[mgr texture] contentSize];

	// By default all the tiles are aliased
	// pros:
	//  - easier to render
	// cons:
	//  - difficult to scale / rotate / etc.
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
			
			// XXX: gid == 0 --> empty tile
			if( gid != 0 ) {
				CGRect rect;

				rect = [tileset tileForGID:gid];

				AtlasSprite *tile = [AtlasSprite spriteWithRect:rect spriteManager:mgr];
				[tile setOpacity:layer->opacity];
				tile.anchorPoint = CGPointZero;
				[mgr addChild:tile z:0 tag:pos];
				switch( map->orientation ) {
					case TMXOrientationOrtho:
						[self setOrthoTile:tile at:ccp(x,y) tileSize:tileset->tileSize layerSize:layer->layerSize];
						break;
					case TMXOrientationIso:
						[self setIsoTile:tile at:ccp(x,y) tileSize:tileset->tileSize layerSize:layer->layerSize];
						break;
					case TMXOrientationHex:
						[self setHexTile:tile at:ccp(x,y) tileSize:tileset->tileSize layerSize:layer->layerSize];
						break;
						
				}
			}
		}
	}	
	return mgr;
}

-(void) setOrthoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize
{
	int x = pos.x * tileSize.width + 0.49f;
	int y = (layerSize.height - pos.y) * tileSize.height + 0.49f;
	[tile setPosition:ccp( x,y)];
}

-(void) setIsoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize
{
	int x = tileSize.width /2  *(pos.x - pos.y) + 0.49f;
	int y = (layerSize.height - (pos.x + pos.y)) * tileSize.height/2 + 0.49f;
	[tile setPosition:ccp(x, y)];
}
-(void) setHexTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize
{
	float diffY = 0;
	if( (int)pos.x % 2 == 1 )
		diffY = -tileSize.height/2 ;
	
	int x =  pos.x * tileSize.width*3/4 + 0.49f;
	int y =  (layerSize.height - pos.y) * tileSize.height + diffY + 0.49f;
	
	[tile setPosition:ccp(x, y)];
}
@end
