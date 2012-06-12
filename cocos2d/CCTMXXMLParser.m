/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */


#import <Foundation/Foundation.h>
#include <zlib.h>

#import "ccMacros.h"
#import "Support/CGPointExtension.h"
#import "CCTMXXMLParser.h"
#import "CCTMXTiledMap.h"
#import "CCTMXObjectGroup.h"
#import "Support/base64.h"
#import "Support/ZipUtils.h"
#import "Support/CCFileUtils.h"

#pragma mark -
#pragma mark TMXLayerInfo


@implementation CCTMXLayerInfo

@synthesize name = name_, layerSize = layerSize_, tiles = tiles_, visible = visible_, opacity = opacity_, ownTiles = ownTiles_, minGID = minGID_, maxGID = maxGID_, properties = properties_;
@synthesize offset = offset_;
-(id) init
{
	if( (self=[super init])) {
		ownTiles_ = YES;
		minGID_ = 100000;
		maxGID_ = 0;
		self.name = nil;
		tiles_ = NULL;
		offset_ = CGPointZero;
		self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	}
	return self;
}
- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@",self);

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

@synthesize name = name_, firstGid = firstGid_, tileSize = tileSize_, spacing = spacing_, margin = margin_, sourceImage = sourceImage_, imageSize = imageSize_;

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[sourceImage_ release];
	[name_ release];
	[super dealloc];
}

-(CGRect) rectForGID:(unsigned int)gid
{
	CGRect rect;
	rect.size = tileSize_;

	gid &= kCCFlippedMask;
	gid = gid - firstGid_;

	int max_x = (imageSize_.width - margin_*2 + spacing_) / (tileSize_.width + spacing_);
	//	int max_y = (imageSize.height - margin*2 + spacing) / (tileSize.height + spacing);

	rect.origin.x = (gid % max_x) * (tileSize_.width + spacing_) + margin_;
	rect.origin.y = (gid / max_x) * (tileSize_.height + spacing_) + margin_;

	return rect;
}
@end

#pragma mark -
#pragma mark CCTMXMapInfo

@interface CCTMXMapInfo (Private)
/* initalises parsing of an XML file, either a tmx (Map) file or tsx (Tileset) file */
-(void) parseXMLFile:(NSString *)xmlFilename;
/* initalises parsing of an XML string, either a tmx (Map) string or tsx (Tileset) string */
- (void) parseXMLString:(NSString *)xmlString;
/* handles the work of parsing for parseXMLFile: and parseXMLString: */
- (void) parseXMLData:(NSData*)data;
@end

@implementation CCTMXMapInfo

@synthesize orientation = orientation_, mapSize = mapSize_, layers = layers_, tilesets = tilesets_, tileSize = tileSize_, filename = filename_, resources = resources_, objectGroups = objectGroups_, properties = properties_;
@synthesize tileProperties = tileProperties_;

+(id) formatWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

+(id) formatWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath
{
	return [[[self alloc] initWithXML:tmxString resourcePath:resourcePath] autorelease];
}

- (void) internalInit:(NSString*)tmxFileName resourcePath:(NSString*)resourcePath
{
	self.tilesets = [NSMutableArray arrayWithCapacity:4];
	self.layers = [NSMutableArray arrayWithCapacity:4];
	self.filename = tmxFileName;
	self.resources = resourcePath;
	self.objectGroups = [NSMutableArray arrayWithCapacity:4];
	self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	self.tileProperties = [NSMutableDictionary dictionaryWithCapacity:5];

	// tmp vars
	currentString = [[NSMutableString alloc] initWithCapacity:1024];
	storingCharacters = NO;
	layerAttribs = TMXLayerAttribNone;
	parentElement = TMXPropertyNone;
}

-(id) initWithXML:(NSString *)tmxString resourcePath:(NSString*)resourcePath
{
	if( (self=[super init])) {
		[self internalInit:nil resourcePath:resourcePath];
		[self parseXMLString:tmxString];
	}
	return self;
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	if( (self=[super init])) {
		[self internalInit:tmxFile resourcePath:nil];
		[self parseXMLFile:filename_];
	}
	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[tilesets_ release];
	[layers_ release];
	[filename_ release];
	[resources_ release];
	[currentString release];
	[objectGroups_ release];
	[properties_ release];
	[tileProperties_ release];
	[super dealloc];
}

- (void) parseXMLData:(NSData*)data
{
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];

	// we'll do the parsing
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
     NSAssert1( ![parser parserError], @"Error parsing TMX data: %@.", [NSString stringWithCharacters:[data bytes] length:[data length]] );
}

- (void) parseXMLString:(NSString *)xmlString
{
	NSData* data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	[self parseXMLData:data];	
}

- (void) parseXMLFile:(NSString *)xmlFilename
{
	NSURL *url = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:xmlFilename] ];
	NSData *data = [NSData dataWithContentsOfURL:url];
	[self parseXMLData:data];
}

// the XML parser calls here with all the elements
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"map"]) {
		NSString *version = [attributeDict objectForKey:@"version"];
		if( ! [version isEqualToString:@"1.0"] )
			CCLOG(@"cocos2d: TMXFormat: Unsupported TMX version: %@", version);
		NSString *orientationStr = [attributeDict objectForKey:@"orientation"];
		if( [orientationStr isEqualToString:@"orthogonal"])
			orientation_ = CCTMXOrientationOrtho;
		else if ( [orientationStr isEqualToString:@"isometric"])
			orientation_ = CCTMXOrientationIso;
		else if( [orientationStr isEqualToString:@"hexagonal"])
			orientation_ = CCTMXOrientationHex;
		else
			CCLOG(@"cocos2d: TMXFomat: Unsupported orientation: %d", orientation_);

		mapSize_.width = [[attributeDict objectForKey:@"width"] intValue];
		mapSize_.height = [[attributeDict objectForKey:@"height"] intValue];
		tileSize_.width = [[attributeDict objectForKey:@"tilewidth"] intValue];
		tileSize_.height = [[attributeDict objectForKey:@"tileheight"] intValue];

		// The parent element is now "map"
		parentElement = TMXPropertyMap;
	} else if([elementName isEqualToString:@"tileset"]) {

		// If this is an external tileset then start parsing that
		NSString *externalTilesetFilename = [attributeDict objectForKey:@"source"];
		if (externalTilesetFilename) {
				// Tileset file will be relative to the map file. So we need to convert it to an absolute path
				NSString *dir = [filename_ stringByDeletingLastPathComponent];	// Directory of map file
				if (!dir)
					dir = resources_;
				externalTilesetFilename = [dir stringByAppendingPathComponent:externalTilesetFilename];	// Append path to tileset file

				[self parseXMLFile:externalTilesetFilename];
		} else {

			CCTMXTilesetInfo *tileset = [CCTMXTilesetInfo new];
			tileset.name = [attributeDict objectForKey:@"name"];
			tileset.firstGid = [[attributeDict objectForKey:@"firstgid"] intValue];
			tileset.spacing = [[attributeDict objectForKey:@"spacing"] intValue];
			tileset.margin = [[attributeDict objectForKey:@"margin"] intValue];
			CGSize s;
			s.width = [[attributeDict objectForKey:@"tilewidth"] intValue];
			s.height = [[attributeDict objectForKey:@"tileheight"] intValue];
			tileset.tileSize = s;

			[tilesets_ addObject:tileset];
			[tileset release];
		}

	}else if([elementName isEqualToString:@"tile"]){
		CCTMXTilesetInfo* info = [tilesets_ lastObject];
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:3];
		parentGID_ =  [info firstGid] + [[attributeDict objectForKey:@"id"] intValue];
		[tileProperties_ setObject:dict forKey:[NSNumber numberWithInt:parentGID_]];

		parentElement = TMXPropertyTile;

	}else if([elementName isEqualToString:@"layer"]) {
		CCTMXLayerInfo *layer = [CCTMXLayerInfo new];
		layer.name = [attributeDict objectForKey:@"name"];

		CGSize s;
		s.width = [[attributeDict objectForKey:@"width"] intValue];
		s.height = [[attributeDict objectForKey:@"height"] intValue];
		layer.layerSize = s;

		layer.visible = ![[attributeDict objectForKey:@"visible"] isEqualToString:@"0"];

		if( [attributeDict objectForKey:@"opacity"] )
			layer.opacity = 255 * [[attributeDict objectForKey:@"opacity"] floatValue];
		else
			layer.opacity = 255;

		int x = [[attributeDict objectForKey:@"x"] intValue];
		int y = [[attributeDict objectForKey:@"y"] intValue];
		layer.offset = ccp(x,y);

		[layers_ addObject:layer];
		[layer release];

		// The parent element is now "layer"
		parentElement = TMXPropertyLayer;

	} else if([elementName isEqualToString:@"objectgroup"]) {

		CCTMXObjectGroup *objectGroup = [[CCTMXObjectGroup alloc] init];
		objectGroup.groupName = [attributeDict objectForKey:@"name"];
		CGPoint positionOffset;
		positionOffset.x = [[attributeDict objectForKey:@"x"] intValue] * tileSize_.width;
		positionOffset.y = [[attributeDict objectForKey:@"y"] intValue] * tileSize_.height;
		objectGroup.positionOffset = positionOffset;

		[objectGroups_ addObject:objectGroup];
		[objectGroup release];

		// The parent element is now "objectgroup"
		parentElement = TMXPropertyObjectGroup;

	} else if([elementName isEqualToString:@"image"]) {

		CCTMXTilesetInfo *tileset = [tilesets_ lastObject];

		// build full path
		NSString *imagename = [attributeDict objectForKey:@"source"];
		NSString *path = [filename_ stringByDeletingLastPathComponent];
		if (!path)
			path = resources_;
		tileset.sourceImage = [path stringByAppendingPathComponent:imagename];

	} else if([elementName isEqualToString:@"data"]) {
		NSString *encoding = [attributeDict objectForKey:@"encoding"];
		NSString *compression = [attributeDict objectForKey:@"compression"];

		if( [encoding isEqualToString:@"base64"] ) {
			layerAttribs |= TMXLayerAttribBase64;
			storingCharacters = YES;

			if( [compression isEqualToString:@"gzip"] )
				layerAttribs |= TMXLayerAttribGzip;

			else if( [compression isEqualToString:@"zlib"] )
				layerAttribs |= TMXLayerAttribZlib;

			NSAssert( !compression || [compression isEqualToString:@"gzip"] || [compression isEqualToString:@"zlib"], @"TMX: unsupported compression method" );
		}

		NSAssert( layerAttribs != TMXLayerAttribNone, @"TMX tile map: Only base64 and/or gzip/zlib maps are supported" );

	} else if([elementName isEqualToString:@"object"]) {

		CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];

		// The value for "type" was blank or not a valid class name
		// Create an instance of TMXObjectInfo to store the object and its properties
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];

		// Parse everything automatically
		NSArray *array = [NSArray arrayWithObjects:@"name", @"type", @"width", @"height", @"gid", nil];
		for( id key in array ) {
			NSObject *obj = [attributeDict objectForKey:key];
			if( obj )
				[dict setObject:obj forKey:key];
		}
		
		// But X and Y since they need special treatment
		// X
		NSString *value = [attributeDict objectForKey:@"x"];
		if( value ) {
			int x = [value intValue] + objectGroup.positionOffset.x;
			[dict setObject:[NSNumber numberWithInt:x] forKey:@"x"];
		}
		
		// Y
		value = [attributeDict objectForKey:@"y"];
		if( value )  {
		int y = [value intValue] + objectGroup.positionOffset.y;

			// Correct y position. (Tiled uses Flipped, cocos2d uses Standard)
			y = (mapSize_.height * tileSize_.height) - y - [[attributeDict objectForKey:@"height"] intValue];
			[dict setObject:[NSNumber numberWithInt:y] forKey:@"y"];
		}
		
		// Add the object to the objectGroup
		[[objectGroup objects] addObject:dict];
		[dict release];

		// The parent element is now "object"
		parentElement = TMXPropertyObject;

	} else if([elementName isEqualToString:@"property"]) {

		if ( parentElement == TMXPropertyNone ) {

			CCLOG( @"TMX tile map: Parent element is unsupported. Cannot add property named '%@' with value '%@'",
			[attributeDict objectForKey:@"name"], [attributeDict objectForKey:@"value"] );

		} else if ( parentElement == TMXPropertyMap ) {

			// The parent element is the map
			[properties_ setObject:[attributeDict objectForKey:@"value"] forKey:[attributeDict objectForKey:@"name"]];

		} else if ( parentElement == TMXPropertyLayer ) {

			// The parent element is the last layer
			CCTMXLayerInfo *layer = [layers_ lastObject];
			// Add the property to the layer
			[[layer properties] setObject:[attributeDict objectForKey:@"value"] forKey:[attributeDict objectForKey:@"name"]];

		} else if ( parentElement == TMXPropertyObjectGroup ) {

			// The parent element is the last object group
			CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];
			[[objectGroup properties] setObject:[attributeDict objectForKey:@"value"] forKey:[attributeDict objectForKey:@"name"]];

		} else if ( parentElement == TMXPropertyObject ) {

			// The parent element is the last object
			CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];
			NSMutableDictionary *dict = [[objectGroup objects] lastObject];

			NSString *propertyName = [attributeDict objectForKey:@"name"];
			NSString *propertyValue = [attributeDict objectForKey:@"value"];

			[dict setObject:propertyValue forKey:propertyName];

		} else if ( parentElement == TMXPropertyTile ) {

			NSMutableDictionary* dict = [tileProperties_ objectForKey:[NSNumber numberWithInt:parentGID_]];
			NSString *propertyName = [attributeDict objectForKey:@"name"];
			NSString *propertyValue = [attributeDict objectForKey:@"value"];
			[dict setObject:propertyValue forKey:propertyName];
		}

	} else if ([elementName isEqualToString:@"polygon"]) {
		
		// find parent object's dict and add polygon-points to it
		CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];
		NSMutableDictionary *dict = [[objectGroup objects] lastObject];
		[dict setObject:[attributeDict objectForKey:@"points"] forKey:@"polygonPoints"];
		
	} else if ([elementName isEqualToString:@"polyline"]) {
		
		// find parent object's dict and add polyline-points to it
		CCTMXObjectGroup *objectGroup = [objectGroups_ lastObject];
		NSMutableDictionary *dict = [[objectGroup objects] lastObject];
		[dict setObject:[attributeDict objectForKey:@"points"] forKey:@"polylinePoints"];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	int len = 0;

	if([elementName isEqualToString:@"data"] && layerAttribs&TMXLayerAttribBase64) {
		storingCharacters = NO;

		CCTMXLayerInfo *layer = [layers_ lastObject];

		unsigned char *buffer;
		len = base64Decode((unsigned char*)[currentString UTF8String], (unsigned int) [currentString length], &buffer);
		if( ! buffer ) {
			CCLOG(@"cocos2d: TiledMap: decode data error");
			return;
		}

		if( layerAttribs & (TMXLayerAttribGzip | TMXLayerAttribZlib) ) {
			unsigned char *deflated;
			CGSize s = [layer layerSize];
			int sizeHint = s.width * s.height * sizeof(uint32_t);

			int inflatedLen = ccInflateMemoryWithHint(buffer, len, &deflated, sizeHint);
			NSAssert( inflatedLen == sizeHint, @"CCTMXXMLParser: Hint failed!");

			inflatedLen = (int)&inflatedLen; // XXX: to avoid warings in compiler

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
