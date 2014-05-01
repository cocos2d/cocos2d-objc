/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
#import "CCTiledMap.h"
#import "CCTiledMapObjectGroup.h"
#import "Support/base64.h"
#import "Support/ZipUtils.h"
#import "Support/CCFileUtils.h"

#pragma mark -
#pragma mark TMXLayerInfo


@implementation CCTiledMapLayerInfo

@synthesize name = _name, layerSize = _layerSize, tiles = _tiles, visible = _visible, opacity = _opacity, ownTiles = _ownTiles, minGID = _minGID, maxGID = _maxGID, properties = _properties;
@synthesize offset = _offset;
-(id) init
{
	if( (self=[super init])) {
		_ownTiles = YES;
		_minGID = 100000;
		_maxGID = 0;
		self.name = nil;
		_tiles = NULL;
		_offset = CGPointZero;
		self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	}
	return self;
}
- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@",self);


	if( _ownTiles && _tiles ) {
		free( _tiles );
		_tiles = NULL;
	}
}

@end

#pragma mark -
#pragma mark TMXTilesetInfo
@implementation CCTiledMapTilesetInfo

@synthesize name = _name, firstGid = _firstGid, tileSize = _tileSize, spacing = _spacing, margin = _margin, sourceImage = _sourceImage, imageSize = _imageSize;
@synthesize tileOffset = _tileOffset, tileAnchorPoint = _tileAnchorPoint;

/**
 Custom Setter:
 Sets the _tileOffset property (expressed in pixels) as specified in the TMX file (should be double for retina).
 Then it calculates the anchorPoint for the tiles (expressed as %), and stores it in the _tileAnchorPoint readonly property.
 The CCTMXLayer is then responsible for  setting the anchorPoint of its tile sprites.
 (implemented in -[CCTMXLayer setupTileSprite:position:withGID:])
 */
- (void)setTileOffset:(CGPoint)tileOffset
{
	_tileOffset = tileOffset;
	NSAssert((self.tileSize.width > 0 && self.tileSize.height > 0), @"Error in [CCTMXTilesetInfo setTileOffset:], tileSize is Zero");
	float normalizedOffsetX = tileOffset.x / _tileSize.width;
	float normalizedOffsetY = tileOffset.y / _tileSize.height;
	_tileAnchorPoint = CGPointMake(normalizedOffsetX, normalizedOffsetY);
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
}

-(CGRect) rectForGID:(unsigned int)gid
{
	CGRect rect;
	rect.size = _tileSize;

	gid &= kCCFlippedMask;
	gid = gid - _firstGid;

	int max_x = (_imageSize.width - _margin*2 + _spacing) / (_tileSize.width + _spacing);
	//	int max_y = (imageSize.height - margin*2 + spacing) / (tileSize.height + spacing);

	rect.origin.x = (gid % max_x) * (_tileSize.width + _spacing) + _margin;
	rect.origin.y = (gid / max_x) * (_tileSize.height + _spacing) + _margin;

	return rect;
}
@end

#pragma mark -
#pragma mark CCTMXMapInfo

@interface CCTiledMapInfo (Private)
/* initalises parsing of an XML file, either a tmx (Map) file or tsx (Tileset) file */
-(void) parseXMLFile:(NSString *)xmlFilename;
/* initalises parsing of an XML string, either a tmx (Map) string or tsx (Tileset) string */
- (void) parseXMLString:(NSString *)xmlString;
/* handles the work of parsing for parseXMLFile: and parseXMLString: */
- (void) parseXMLData:(NSData*)data;
@end

@implementation CCTiledMapInfo

@synthesize orientation = _orientation, mapSize = _mapSize, layers = _layers, tilesets = _tilesets, tileSize = _tileSize, filename = _filename, resources = _resources, objectGroups = _objectGroups, properties = _properties;
@synthesize tileProperties = _tileProperties;

+(id) formatWithTMXFile:(NSString*)tmxFile
{
	return [[self alloc] initWithFile:tmxFile];
}

+(id) formatWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath
{
	return [[self alloc] initWithXML:tmxString resourcePath:resourcePath];
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
	_currentString = [[NSMutableString alloc] initWithCapacity:1024];
	_storingCharacters = NO;
	_layerAttribs = TMXLayerAttribNone;
	_parentElement = TMXPropertyNone;
	_currentFirstGID = 0;
}

-(id) initWithXML:(NSString *)tmxString resourcePath:(NSString*)resourcePath
{
	if( (self=[super init])) {
		[self internalInit:nil resourcePath:resourcePath];
		[self parseXMLString:tmxString];
	}
	return self;
}

-(id) initWithFile:(NSString*)tmxFile
{
	if( (self=[super init])) {
		[self internalInit:tmxFile resourcePath:nil];
		[self parseXMLFile:_filename];
	}
	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
}

- (void) parseXMLData:(NSData*)data
{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];

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
	NSURL *url = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathForFilename:xmlFilename] ];
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
			_orientation = CCTiledMapOrientationOrtho;
		else if ( [orientationStr isEqualToString:@"isometric"])
			_orientation = CCTiledMapOrientationIso;
		else
			CCLOG(@"cocos2d: TMXFomat: Unsupported orientation: %d", _orientation);

		_mapSize.width = [[attributeDict objectForKey:@"width"] intValue];
		_mapSize.height = [[attributeDict objectForKey:@"height"] intValue];
		_tileSize.width = [[attributeDict objectForKey:@"tilewidth"] intValue];
		_tileSize.height = [[attributeDict objectForKey:@"tileheight"] intValue];

		// The parent element is now "map"
		_parentElement = TMXPropertyMap;
	} else if([elementName isEqualToString:@"tileset"]) {

		// If this is an external tileset then start parsing that
		NSString *externalTilesetFilename = [attributeDict objectForKey:@"source"];
		if (externalTilesetFilename) {
			// Tileset file will be relative to the map file. So we need to convert it to an absolute path
			NSString *dir = [_filename stringByDeletingLastPathComponent];	// Directory of map file
			if (!dir)
				dir = _resources;
			externalTilesetFilename = [dir stringByAppendingPathComponent:externalTilesetFilename];	// Append path to tileset file

			_currentFirstGID = [[attributeDict objectForKey:@"firstgid"] intValue];
		
			[self parseXMLFile:externalTilesetFilename];
		} else {
			CCTiledMapTilesetInfo *tileset = [CCTiledMapTilesetInfo new];
			tileset.name = [attributeDict objectForKey:@"name"];
			if(_currentFirstGID == 0) {
				tileset.firstGid = [[attributeDict objectForKey:@"firstgid"] intValue];
			} else {
				tileset.firstGid = _currentFirstGID;
				_currentFirstGID = 0;
			}
			tileset.spacing = [[attributeDict objectForKey:@"spacing"] intValue];
			tileset.margin = [[attributeDict objectForKey:@"margin"] intValue];
			CGSize s;
			s.width = [[attributeDict objectForKey:@"tilewidth"] intValue];
			s.height = [[attributeDict objectForKey:@"tileheight"] intValue];
			tileset.tileSize = s;
			tileset.tileOffset = CGPointZero; //default offset (0,0)

			[_tilesets addObject:tileset];
		}

	}
	else if([elementName isEqualToString:@"tileoffset"]) {
		//should only be found within a tileset. Getting the parent.
		CCTiledMapTilesetInfo *tileset = [_tilesets lastObject];
		CGPoint offset = CGPointMake([[attributeDict objectForKey:@"x"] floatValue],
									 [[attributeDict objectForKey:@"y"] floatValue]);
		tileset.tileOffset = offset;
	}
	else if([elementName isEqualToString:@"tile"]) {
		CCTiledMapTilesetInfo* info = [_tilesets lastObject];
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:3];
		_parentGID =  [info firstGid] + [[attributeDict objectForKey:@"id"] intValue];
		[_tileProperties setObject:dict forKey:[NSNumber numberWithInt:_parentGID]];

		_parentElement = TMXPropertyTile;

	} else if([elementName isEqualToString:@"layer"]) {
		CCTiledMapLayerInfo *layer = [CCTiledMapLayerInfo new];
		layer.name = [attributeDict objectForKey:@"name"];

		CGSize s;
		s.width = [[attributeDict objectForKey:@"width"] intValue];
		s.height = [[attributeDict objectForKey:@"height"] intValue];
		layer.layerSize = s;

		layer.visible = ![[attributeDict objectForKey:@"visible"] isEqualToString:@"0"];

		if( [attributeDict objectForKey:@"opacity"] ){
			layer.opacity = [[attributeDict objectForKey:@"opacity"] floatValue];
		} else {
			layer.opacity = 1.0;
		}

		int x = [[attributeDict objectForKey:@"x"] intValue];
		int y = [[attributeDict objectForKey:@"y"] intValue];
		layer.offset = ccp(x,y);

		[_layers addObject:layer];

		// The parent element is now "layer"
		_parentElement = TMXPropertyLayer;

	} else if([elementName isEqualToString:@"objectgroup"]) {

		CCTiledMapObjectGroup *objectGroup = [[CCTiledMapObjectGroup alloc] init];
		objectGroup.groupName = [attributeDict objectForKey:@"name"];
		CGPoint positionOffset;
		positionOffset.x = [[attributeDict objectForKey:@"x"] intValue] * _tileSize.width;
		positionOffset.y = [[attributeDict objectForKey:@"y"] intValue] * _tileSize.height;
		objectGroup.positionOffset = positionOffset;

		[_objectGroups addObject:objectGroup];

		// The parent element is now "objectgroup"
		_parentElement = TMXPropertyObjectGroup;

	} else if([elementName isEqualToString:@"image"]) {

		CCTiledMapTilesetInfo *tileset = [_tilesets lastObject];

		// build full path
		NSString *imagename = [attributeDict objectForKey:@"source"];
		NSString *path = [_filename stringByDeletingLastPathComponent];
		if (!path)
			path = _resources;
		tileset.sourceImage = [path stringByAppendingPathComponent:imagename];

	} else if([elementName isEqualToString:@"data"]) {
		NSString *encoding = [attributeDict objectForKey:@"encoding"];
		NSString *compression = [attributeDict objectForKey:@"compression"];

		if( [encoding isEqualToString:@"base64"] ) {
			_layerAttribs |= TMXLayerAttribBase64;
			_storingCharacters = YES;

			if( [compression isEqualToString:@"gzip"] )
				_layerAttribs |= TMXLayerAttribGzip;

			else if( [compression isEqualToString:@"zlib"] )
				_layerAttribs |= TMXLayerAttribZlib;

			NSAssert( !compression || [compression isEqualToString:@"gzip"] || [compression isEqualToString:@"zlib"], @"TMX: unsupported compression method" );
		}

		NSAssert( _layerAttribs != TMXLayerAttribNone, @"TMX tile map: Only base64 and/or gzip/zlib maps are supported" );

	} else if([elementName isEqualToString:@"object"]) {

		CCTiledMapObjectGroup *objectGroup = [_objectGroups lastObject];

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
			y = (_mapSize.height * _tileSize.height) - y - [[attributeDict objectForKey:@"height"] intValue];
			[dict setObject:[NSNumber numberWithInt:y] forKey:@"y"];
		}
		
		// Add the object to the objectGroup
		[[objectGroup objects] addObject:dict];

		// The parent element is now "object"
		_parentElement = TMXPropertyObject;

	} else if([elementName isEqualToString:@"property"]) {

		if ( _parentElement == TMXPropertyNone ) {

			CCLOG( @"TMX tile map: Parent element is unsupported. Cannot add property named '%@' with value '%@'",
			[attributeDict objectForKey:@"name"], [attributeDict objectForKey:@"value"] );

		} else if ( _parentElement == TMXPropertyMap ) {

			// The parent element is the map
			[_properties setObject:[attributeDict objectForKey:@"value"] forKey:[attributeDict objectForKey:@"name"]];

		} else if ( _parentElement == TMXPropertyLayer ) {

			// The parent element is the last layer
			CCTiledMapLayerInfo *layer = [_layers lastObject];
			// Add the property to the layer
			[[layer properties] setObject:[attributeDict objectForKey:@"value"] forKey:[attributeDict objectForKey:@"name"]];

		} else if ( _parentElement == TMXPropertyObjectGroup ) {

			// The parent element is the last object group
			CCTiledMapObjectGroup *objectGroup = [_objectGroups lastObject];
			[[objectGroup properties] setObject:[attributeDict objectForKey:@"value"] forKey:[attributeDict objectForKey:@"name"]];

		} else if ( _parentElement == TMXPropertyObject ) {

			// The parent element is the last object
			CCTiledMapObjectGroup *objectGroup = [_objectGroups lastObject];
			NSMutableDictionary *dict = [[objectGroup objects] lastObject];

			NSString *propertyName = [attributeDict objectForKey:@"name"];
			NSString *propertyValue = [attributeDict objectForKey:@"value"];

			[dict setObject:propertyValue forKey:propertyName];

		} else if ( _parentElement == TMXPropertyTile ) {

			NSMutableDictionary* dict = [_tileProperties objectForKey:[NSNumber numberWithInt:_parentGID]];
			NSString *propertyName = [attributeDict objectForKey:@"name"];
			NSString *propertyValue = [attributeDict objectForKey:@"value"];
			[dict setObject:propertyValue forKey:propertyName];
		}

	} else if ([elementName isEqualToString:@"polygon"]) {
		
		// find parent object's dict and add polygon-points to it
		CCTiledMapObjectGroup *objectGroup = [_objectGroups lastObject];
		NSMutableDictionary *dict = [[objectGroup objects] lastObject];
		[dict setObject:[attributeDict objectForKey:@"points"] forKey:@"polygonPoints"];
		
	} else if ([elementName isEqualToString:@"polyline"]) {
		
		// find parent object's dict and add polyline-points to it
		CCTiledMapObjectGroup *objectGroup = [_objectGroups lastObject];
		NSMutableDictionary *dict = [[objectGroup objects] lastObject];
		[dict setObject:[attributeDict objectForKey:@"points"] forKey:@"polylinePoints"];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	int len = 0;

	if([elementName isEqualToString:@"data"] && _layerAttribs&TMXLayerAttribBase64) {
		_storingCharacters = NO;

		CCTiledMapLayerInfo *layer = [_layers lastObject];

		unsigned char *buffer;
		len = base64Decode((unsigned char*)[_currentString UTF8String], (unsigned int) [_currentString length], &buffer);
		if( ! buffer ) {
			CCLOG(@"cocos2d: TiledMap: decode data error");
			return;
		}

		if( _layerAttribs & (TMXLayerAttribGzip | TMXLayerAttribZlib) ) {
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

		[_currentString setString:@""];

	} else if ([elementName isEqualToString:@"map"]) {
		// The map element has ended
		_parentElement = TMXPropertyNone;

	}	else if ([elementName isEqualToString:@"layer"]) {
		// The layer element has ended
		_parentElement = TMXPropertyNone;

	} else if ([elementName isEqualToString:@"objectgroup"]) {
		// The objectgroup element has ended
		_parentElement = TMXPropertyNone;

	} else if ([elementName isEqualToString:@"object"]) {
		// The object element has ended
		_parentElement = TMXPropertyNone;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_storingCharacters)
		[_currentString appendString:string];
}


//
// the level did not load, file not found, etc.
//
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	CCLOG(@"cocos2d: Error on XML Parse: %@", [parseError localizedDescription] );
}

@end
