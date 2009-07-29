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

#import "TiledMapTMX.h"
#import "AtlasSprite.h"
#import "Support/FileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/base64.h"
#import "Support/ZipUtils.h"

#pragma mark -
#pragma mark TMXTilesetFormat
@implementation TMXTilesetFormat
@end

#pragma mark -
#pragma mark TMXLayerFormat
@implementation TMXLayerFormat
@end

#pragma mark -
#pragma mark TMXMapFormat
@implementation TMXMapFormat
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
			CCLOG(@"TiledMapTMX: Error parsing TMX file: %@", parseError);
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

		TMXTilesetFormat *tileset = [TMXTilesetFormat new];
		tileset->name = [attributeDict valueForKey:@"name"];
		tileset->firstGid = [[attributeDict valueForKey:@"firstgid"] intValue];
		tileset->spacing = [[attributeDict valueForKey:@"spacing"] intValue];
		tileset->margin = [[attributeDict valueForKey:@"margin"] intValue];
		tileset->tileSize.width = [[attributeDict valueForKey:@"tilewidth"] intValue];
		tileset->tileSize.height = [[attributeDict valueForKey:@"tileheight"] intValue];
		
		[tilesets addObject:tileset];
	} else if([elementName isEqualToString:@"layer"]) {

		TMXLayerFormat *layer = [TMXLayerFormat new];
		layer->name = [attributeDict valueForKey:@"name"];
		layer->layerSize.width = [[attributeDict valueForKey:@"width"] intValue];
		layer->layerSize.height = [[attributeDict valueForKey:@"height"] intValue];
		
		[layers addObject:layer];
		
	} else if([elementName isEqualToString:@"image"]) {

		TMXTilesetFormat *tileset = [tilesets lastObject];
		tileset->name = [attributeDict valueForKey:@"source"];

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
		
		TMXLayerFormat *layer = [layers lastObject];
		
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
	NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
}

@end

#pragma mark -
#pragma mark TiledMapTMX

@interface TiledMapTMX (Private)
-(NSString*) atlasNameFromFntFile:(NSString*)fntFile;
@end

@implementation TiledMapTMX

@synthesize opacity=opacity_, color=color_;

#pragma mark BitmapFontAtlas - Creation & Init
+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}


-(id) initWithTMXFile:(NSString*)tmxFile
{
	TMXMapFormat *format = [TMXMapFormat formatWithTMXFile:tmxFile];
	if( format->orientation == TMXOrientationHex )
		CCLOG(@"hexagonal format");

	if ((self=[super initWithFile:@"tankbrigade.bmp" capacity:100])) {

		opacity_ = 255;
		color_ = ccWHITE;

		contentSize_ = CGSizeZero;
		
		opacityModifyRGB_ = [[textureAtlas_ texture] hasPremultipliedAlpha];

		anchorPoint_ = ccp(0.5f, 0.5f);
		
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

#pragma mark BitmapFontAtlas - CocosNodeRGBA protocol

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	for( AtlasSprite* child in children )
		[child setColor:color_];
}

-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b
{
	[self setColor:ccc3(r,g,b)];
}

-(void) setOpacity:(GLubyte)opacity
{
	opacity_ = opacity;
	
	for( id child in children )
		[child setOpacity:opacity_];
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
	for( id child in children)
		[child setOpacityModifyRGB:modify];
}
-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}
@end
