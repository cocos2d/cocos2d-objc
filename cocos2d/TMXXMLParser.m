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

#import "ccMacros.h"
#import "TMXXMLParser.h"
#import "TMXTiledMap.h"
#import "Support/FileUtils.h"
#import "Support/base64.h"
#import "Support/ZipUtils.h"

#pragma mark -
#pragma mark TMXLayerInfo


@implementation TMXLayerInfo
-(id) init
{
	if( (self=[super init])) {
		ownTiles = YES;
	}
	return self;
}
- (void) dealloc
{
	CCLOG(@"deallocing %@",self);
	if( ownTiles && tiles ) {
		free( tiles );
		tiles = NULL;
	}
	[super dealloc];
}

@end

#pragma mark -
#pragma mark TMXTilesetInfo
@implementation TMXTilesetInfo
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

#pragma mark -
#pragma mark TMXMapInfo

@implementation TMXMapInfo
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
		TMXTilesetInfo *tileset = [TMXTilesetInfo new];
		tileset->name = [[attributeDict valueForKey:@"name"] retain];
		tileset->firstGid = [[attributeDict valueForKey:@"firstgid"] intValue];
		tileset->spacing = [[attributeDict valueForKey:@"spacing"] intValue];
		tileset->margin = [[attributeDict valueForKey:@"margin"] intValue];
		tileset->tileSize.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		tileset->tileSize.height = [[attributeDict valueForKey:@"tileheight"] intValue];
		
		[tilesets addObject:tileset];
		[tileset release];

	} else if([elementName isEqualToString:@"layer"]) {
		TMXLayerInfo *layer = [TMXLayerInfo new];
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

		TMXTilesetInfo *tileset = [tilesets lastObject];
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
		
		TMXLayerInfo *layer = [layers lastObject];
		
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
			
			layer->tiles = (unsigned int*) deflated;
		} else
			layer->tiles = (unsigned int*) buffer;
		
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
