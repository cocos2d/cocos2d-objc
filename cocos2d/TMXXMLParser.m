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

@synthesize name=name_, layerSize=layerSize_, tiles=tiles_, visible=visible_,opacity=opacity_, ownTiles=ownTiles_, minGID=minGID_, maxGID=maxGID_;

-(id) init
{
	if( (self=[super init])) {
		ownTiles_ = YES;
		minGID_ = 100000;
		maxGID_ = 0;
		self.name = nil;
		tiles_ = NULL;
	}
	return self;
}
- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@",self);
	
	[name_ release];

	if( ownTiles_ && tiles_ ) {
		free( tiles_ );
		tiles_ = NULL;
	}
	[super dealloc];
}

@end

#pragma mark -
#pragma mark TMXTilesetInfo
@implementation TMXTilesetInfo

@synthesize name=name_, firstGid=firstGid_, tileSize=tileSize_, spacing=spacing_, margin=margin_, sourceImage=sourceImage_, imageSize=imageSize_;

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	[sourceImage_ release];
	[name_ release];
	[super dealloc];
}

-(CGRect) rectForGID:(unsigned int)gid
{
	CGRect rect;
	rect.size = tileSize_;
	
	gid = gid - firstGid_;
	
	int max_x = (imageSize_.width - margin_*2 + spacing_) / (tileSize_.width + spacing_);
	//	int max_y = (imageSize.height - margin*2 + spacing) / (tileSize.height + spacing);
	
	rect.origin.x = (gid % max_x) * (tileSize_.width + spacing_) + margin_;
	rect.origin.y = (gid / max_x) * (tileSize_.height + spacing_) + margin_;
	
	return rect;
}
@end

#pragma mark -
#pragma mark TMXMapInfo

@implementation TMXMapInfo

@synthesize orientation=orientation_, mapSize=mapSize_, layers=layers_, tilesets=tilesets_, tileSize=tileSize_;

+(id) formatWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	if( (self=[super init])) {
		
		self.tilesets = [NSMutableArray arrayWithCapacity:4];
		self.layers = [NSMutableArray arrayWithCapacity:4];
	
		// tmp vars
		currentString = [[NSMutableString alloc] initWithCapacity:1024];
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
			CCLOG(@"cocos2d: TMXTiledMap: Error parsing TMX file: %@", parseError);
		}
		
		[parser release];
	}
	return self;
}
- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	[tilesets_ release];
	[layers_ release];
	[currentString release];
	[super dealloc];
}

// the XML parser calls here with all the elements
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	if([elementName isEqualToString:@"map"]) {
		NSString *version = [attributeDict valueForKey:@"version"];
		if( ! [version isEqualToString:@"1.0"] )
			CCLOG(@"cocos2d: TMXFormat: Unsupported TMX version: %@", version);
		NSString *orientationStr = [attributeDict valueForKey:@"orientation"];
		if( [orientationStr isEqualToString:@"orthogonal"])
			orientation_ = TMXOrientationOrtho;
		else if ( [orientationStr isEqualToString:@"isometric"])
			orientation_ = TMXOrientationIso;
		else if( [orientationStr isEqualToString:@"hexagonal"])
			orientation_ = TMXOrientationHex;
		else
			CCLOG(@"cocos2d: TMXFomat: Unsupported orientation: %@", orientation_);

		mapSize_.width = [[attributeDict valueForKey:@"width"] intValue];
		mapSize_.height = [[attributeDict valueForKey:@"height"] intValue];
		tileSize_.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		tileSize_.height = [[attributeDict valueForKey:@"tileheight"] intValue];

	} else if([elementName isEqualToString:@"tileset"]) {
		TMXTilesetInfo *tileset = [TMXTilesetInfo new];
		tileset.name = [attributeDict valueForKey:@"name"];
		tileset.firstGid = [[attributeDict valueForKey:@"firstgid"] intValue];
		tileset.spacing = [[attributeDict valueForKey:@"spacing"] intValue];
		tileset.margin = [[attributeDict valueForKey:@"margin"] intValue];
		CGSize s;
		s.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		s.height = [[attributeDict valueForKey:@"tileheight"] intValue];
		tileset.tileSize = s;
		
		[tilesets_ addObject:tileset];
		[tileset release];

	} else if([elementName isEqualToString:@"layer"]) {
		TMXLayerInfo *layer = [TMXLayerInfo new];
		layer.name = [attributeDict valueForKey:@"name"];
		
		CGSize s;
		s.width = [[attributeDict valueForKey:@"width"] intValue];
		s.height = [[attributeDict valueForKey:@"height"] intValue];
		layer.layerSize = s;
		
		layer.visible = ![[attributeDict valueForKey:@"visible"] isEqualToString:@"0"];
		if( [attributeDict valueForKey:@"opacity"] ){
			layer.opacity = 255 * [[attributeDict valueForKey:@"opacity"] floatValue];
		}else{
			layer.opacity = 255;
		}
		
		[layers_ addObject:layer];
		[layer release];
		
	} else if([elementName isEqualToString:@"image"]) {

		TMXTilesetInfo *tileset = [tilesets_ lastObject];
		tileset.sourceImage = [attributeDict valueForKey:@"source"];

	} else if([elementName isEqualToString:@"data"]) {
		NSString *encoding = [attributeDict valueForKey:@"encoding"];
		NSString *compression = [attributeDict valueForKey:@"compression"];
		
		if( [encoding isEqualToString:@"base64"] ) {
			layerAttribs |= TMXLayerAttribBase64;
			storingCharacters = YES;
			
			if( [compression isEqualToString:@"gzip"] )
				layerAttribs |= TMXLayerAttribGzip;
		}
		
		NSAssert( layerAttribs != TMXLayerAttribNone, @"TMX tile map: Only base64 and/or gzip maps are supported");
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	int len = 0;

	if([elementName isEqualToString:@"data"] && layerAttribs&TMXLayerAttribBase64) {
		storingCharacters = NO;
		
		TMXLayerInfo *layer = [layers_ lastObject];
		
		unsigned char *buffer;
		len = base64Decode((unsigned char*)[currentString UTF8String], [currentString length], &buffer);
		if( ! buffer ) {
			CCLOG(@"cocos2d: TiledMap: decode data error");
			return;
		}
		
		if( layerAttribs & TMXLayerAttribGzip ) {
			unsigned char *deflated;
			inflateMemory(buffer, len, &deflated);
			free( buffer );
			
			if( ! deflated ) {
				CCLOG(@"cocos2d: TiledMap: inflate data error");
				return;
			}
			
			layer.tiles = (unsigned int*) deflated;
		} else
			layer.tiles = (unsigned int*) buffer;
		
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
	CCLOG(@"cocos2d: Error on XML Parse: %@", [parseError localizedDescription] );
}

@end
