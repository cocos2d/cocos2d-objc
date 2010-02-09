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

#include <zlib.h>
#import <UIKit/UIKit.h>

#import "ccMacros.h"
#import "CCTMXXMLParser.h"
#import "CCTMXTiledMap.h"
#import "CCTMXObjectGroup.h"
#import "Support/CCFileUtils.h"
#import "Support/base64.h"
#import "Support/ZipUtils.h"

#pragma mark -
#pragma mark TMXLayerInfo


@implementation CCTMXLayerInfo

@synthesize name=name_, layerSize=layerSize_, tiles=tiles_, visible=visible_,opacity=opacity_, ownTiles=ownTiles_, minGID=minGID_, maxGID=maxGID_, properties=properties_;

-(id) init
{
	if( (self=[super init])) {
		ownTiles_ = YES;
		minGID_ = 100000;
		maxGID_ = 0;
		self.name = nil;
		tiles_ = NULL;
		self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	}
	return self;
}
- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@",self);
	
	[name_ release];
	[properties_ release];

	if( ownTiles_ && tiles_ ) {
		free( tiles_ );
		tiles_ = NULL;
	}
	[super dealloc];
}

@end

#pragma mark -
#pragma mark TMXTilesetInfo
@implementation CCTMXTilesetInfo

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

@implementation CCTMXMapInfo

@synthesize orientation=orientation_, mapSize=mapSize_, layers=layers_, tilesets=tilesets_, tileSize=tileSize_, filename=filename_, objectGroups=objectGroups_, properties=properties_;

+(id) formatWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	if( (self=[super init])) {
		
		self.tilesets = [NSMutableArray arrayWithCapacity:4];
		self.layers = [NSMutableArray arrayWithCapacity:4];
		self.filename = [CCFileUtils fullPathFromRelativePath:tmxFile];
		self.objectGroups = [NSMutableArray arrayWithCapacity:4];
		self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	
		// tmp vars
		currentString = [[NSMutableString alloc] initWithCapacity:1024];
		storingCharacters = NO;
		layerAttribs = TMXLayerAttribNone;
		parentElement = TMXPropertyNone;
		
		NSURL *url = [NSURL fileURLWithPath:filename_];
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
	[filename_ release];
	[currentString release];
	[objectGroups_ release];
	[properties_ release];
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
			orientation_ = CCTMXOrientationOrtho;
		else if ( [orientationStr isEqualToString:@"isometric"])
			orientation_ = CCTMXOrientationIso;
		else if( [orientationStr isEqualToString:@"hexagonal"])
			orientation_ = CCTMXOrientationHex;
		else
			CCLOG(@"cocos2d: TMXFomat: Unsupported orientation: %@", orientation_);

		mapSize_.width = [[attributeDict valueForKey:@"width"] intValue];
		mapSize_.height = [[attributeDict valueForKey:@"height"] intValue];
		tileSize_.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		tileSize_.height = [[attributeDict valueForKey:@"tileheight"] intValue];

		// The parent element is now "map"
		parentElement = TMXPropertyMap;
	} else if([elementName isEqualToString:@"tileset"]) {
		CCTMXTilesetInfo *tileset = [CCTMXTilesetInfo new];
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
		CCTMXLayerInfo *layer = [CCTMXLayerInfo new];
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
		
		// The parent element is now "layer"
		parentElement = TMXPropertyLayer;
	
	} else if([elementName isEqualToString:@"objectgroup"]) {
		
		CCTMXObjectGroup *objectGroup = [[CCTMXObjectGroup alloc] init];
		objectGroup.groupName = [attributeDict valueForKey:@"name"];
		CGPoint positionOffset;
		positionOffset.x = [[attributeDict valueForKey:@"x"] intValue] * tileSize_.width;
		positionOffset.y = [[attributeDict valueForKey:@"y"] intValue] * tileSize_.height;
		objectGroup.positionOffset = positionOffset;
		
		[objectGroups_ addObject:objectGroup];
		[objectGroup release];
		
		// The parent element is now "objectgroup"
		parentElement = TMXPropertyObjectGroup;
			
	} else if([elementName isEqualToString:@"image"]) {

		CCTMXTilesetInfo *tileset = [tilesets_ lastObject];
		
		// build full path
		NSString *imagename = [attributeDict valueForKey:@"source"];		
		NSString *path = [filename_ stringByDeletingLastPathComponent];		
		tileset.sourceImage = [path stringByAppendingPathComponent:imagename];

	} else if([elementName isEqualToString:@"data"]) {
		NSString *encoding = [attributeDict valueForKey:@"encoding"];
		NSString *compression = [attributeDict valueForKey:@"compression"];
		
		if( [encoding isEqualToString:@"base64"] ) {
			layerAttribs |= TMXLayerAttribBase64;
			storingCharacters = YES;
			
			if( [compression isEqualToString:@"gzip"] )
				layerAttribs |= TMXLayerAttribGzip;
			
			NSAssert( !compression || [compression isEqualToString:@"gzip"], @"TMX: unsupported compression method" );
		}
		
		NSAssert( layerAttribs != TMXLayerAttribNone, @"TMX tile map: Only base64 and/or gzip maps are supported" );
		
	} else if([elementName isEqualToString:@"object"]) {
	
		CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];
		
		// The value for "type" was blank or not a valid class name
		// Create an instance of TMXObjectInfo to store the object and its properties
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:5];
		
		// Set the name of the object to the value for "name"
		[dict setValue:[attributeDict valueForKey:@"name"] forKey:@"name"];
		
		// Assign all the attributes as key/name pairs in the properties dictionary
		[dict setValue:[attributeDict valueForKey:@"type"] forKey:@"type"];
		int x = [[attributeDict valueForKey:@"x"] intValue] + objectGroup.positionOffset.x;
		[dict setValue:[NSNumber numberWithInt:x] forKey:@"x"];
		int y = [[attributeDict valueForKey:@"y"] intValue] + objectGroup.positionOffset.y;
		// Correct y position. (Tiled uses Flipped, cocos2d uses Standard)
		y = (mapSize_.height * tileSize_.height) - y - [[attributeDict valueForKey:@"height"] intValue];
		[dict setValue:[NSNumber numberWithInt:y] forKey:@"y"];
		[dict setValue:[attributeDict valueForKey:@"width"] forKey:@"width"];
		[dict setValue:[attributeDict valueForKey:@"height"] forKey:@"height"];
		
		// Add the object to the objectGroup
		[[objectGroup objects] addObject:dict];
		[dict release];
		
		// The parent element is now "object"
		parentElement = TMXPropertyObject;
		
	} else if([elementName isEqualToString:@"property"]) {
	
		if ( parentElement == TMXPropertyNone ) {
		
			CCLOG( @"TMX tile map: Parent element is unsupported. Cannot add property named '%@' with value '%@'",
			[attributeDict valueForKey:@"name"], [attributeDict valueForKey:@"value"] );
			
		} else if ( parentElement == TMXPropertyMap ) {
		
			// The parent element is the map
			[properties_ setValue:[attributeDict valueForKey:@"value"] forKey:[attributeDict valueForKey:@"name"]];
			
		} else if ( parentElement == TMXPropertyLayer ) {
		
			// The parent element is the last layer
			CCTMXLayerInfo *layer = [layers_ lastObject];
			// Add the property to the layer
			[[layer properties] setValue:[attributeDict valueForKey:@"value"] forKey:[attributeDict valueForKey:@"name"]];
			
		} else if ( parentElement == TMXPropertyObjectGroup ) {
			
			// The parent element is the last object group
			CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];
			[[objectGroup properties] setValue:[attributeDict valueForKey:@"value"] forKey:[attributeDict valueForKey:@"name"]];
			
		} else if ( parentElement == TMXPropertyObject ) {
			
			// The parent element is the last object
			CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];
			NSMutableDictionary *dict = [[objectGroup objects] lastObject];
			
			NSString *propertyName = [attributeDict valueForKey:@"name"];
			NSString *propertyValue = [attributeDict valueForKey:@"value"];

			[dict setValue:propertyValue forKey:propertyName];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	int len = 0;

	if([elementName isEqualToString:@"data"] && layerAttribs&TMXLayerAttribBase64) {
		storingCharacters = NO;
		
		CCTMXLayerInfo *layer = [layers_ lastObject];
		
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
			
	} else if ([elementName isEqualToString:@"map"]) {
		// The map element has ended
		parentElement = TMXPropertyNone;
		
	}	else if ([elementName isEqualToString:@"layer"]) {
		// The layer element has ended
		parentElement = TMXPropertyNone;
		
	} else if ([elementName isEqualToString:@"objectgroup"]) {
		// The objectgroup element has ended
		parentElement = TMXPropertyNone;
		
	} else if ([elementName isEqualToString:@"object"]) {
		// The object element has ended
		parentElement = TMXPropertyNone;
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
