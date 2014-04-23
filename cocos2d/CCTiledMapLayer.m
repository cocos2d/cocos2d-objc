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

#import "CCTiledMapLayer.h"
#import "CCTiledMap.h"
#import "CCTMXXMLParser.h"
#import "CCSprite.h"
#import "CCSpriteBatchNode.h"
#import "CCTextureCache.h"
#import "CCShader.h"
#import "Support/CGPointExtension.h"
#import "CCNode_Private.h"
#import "CCSprite_Private.h"
#import "CCTiledMapLayer_Private.h"
#import "CCTexture_Private.h"


#pragma mark -
#pragma mark CCTMXLayer

@interface CCTiledMapLayer ()
-(CGPoint) positionForIsoAt:(CGPoint)pos;
-(CGPoint) positionForOrthoAt:(CGPoint)pos;

-(CGPoint) calculateLayerOffset:(CGPoint)offset;

/* optimization methos */
-(CCSprite*) updateTileForGID:(uint32_t)gid at:(CGPoint)pos;

/* The layer recognizes some special properties, like cc_vertez */
-(void) parseInternalProperties;
- (void) setupTileSprite:(CCSprite*) sprite position:(CGPoint)pos withGID:(uint32_t)gid;

-(NSInteger) vertexZForPos:(CGPoint)pos;
@end

@implementation CCTiledMapLayer {
	NSString *_layerName;
	NSUInteger _layerOrientation;
	NSMutableDictionary *_properties;
	CCTiledMapTilesetInfo	*_tileset;
	
	// Number of rows and columns of tiles in the layer.
	int _mapRows, _mapColumns;
	
	// Size of a tile in points.
	int _tileWidth, _tileHeight;
	
	// Tightly packed array of TMX tile GIDs.
	uint32_t *_tiles;
	
	// Only used when vertexZ is used.
	NSInteger _vertexZvalue;
	BOOL _useAutomaticVertexZ;
}

#pragma mark CCTMXLayer - init & alloc & dealloc

+(id) layerWithTilesetInfo:(CCTiledMapTilesetInfo*)tilesetInfo layerInfo:(CCTiledMapLayerInfo*)layerInfo mapInfo:(CCTiledMapInfo*)mapInfo
{
	return [[self alloc] initWithTilesetInfo:tilesetInfo layerInfo:layerInfo mapInfo:mapInfo];
}

-(id) initWithTilesetInfo:(CCTiledMapTilesetInfo*)tilesetInfo layerInfo:(CCTiledMapLayerInfo*)layerInfo mapInfo:(CCTiledMapInfo*)mapInfo
{
	CGSize size = layerInfo.layerSize;

	CCTexture *tex = nil;
	if( tilesetInfo )
		tex = [[CCTextureCache sharedTextureCache] addImage:tilesetInfo.sourceImage];

	if((self = [super init])) {
		self.texture = tex;
		self.shader = [CCShader positionTextureColorShader];
		
		// layerInfo
		self.layerName = layerInfo.name;
		_mapColumns = size.width;
		_mapRows = size.height;
		_tiles = layerInfo.tiles;
		self.opacity = layerInfo.opacity;
		self.properties = [NSMutableDictionary dictionaryWithDictionary:layerInfo.properties];

		// tilesetInfo
		self.tileset = tilesetInfo;

		// mapInfo
		_tileWidth = mapInfo.tileSize.width;
		_tileHeight = mapInfo.tileSize.height;
		_layerOrientation = mapInfo.orientation;
		
		CGFloat pixelsToPoints = tex ? 1.0/tex.contentScale : 1.0;
		
		// offset (after layer orientation is set);
		CGPoint offset = [self calculateLayerOffset:layerInfo.offset];
		[self setPosition:ccpMult(offset, pixelsToPoints)];

		[self setContentSize:CGSizeMake( _mapColumns * _tileWidth * pixelsToPoints, _mapRows * _tileHeight * pixelsToPoints )];

		_useAutomaticVertexZ= NO;
		_vertexZvalue = 0;
	}

	return self;
}

- (void) dealloc
{
	free(_tiles);
	_tiles = NULL;
}

-(CGSize)layerSize
{
	return CGSizeMake(_mapColumns, _mapRows);
}

-(void)setLayerSize:(CGSize)layerSize
{
	_mapColumns = layerSize.width;
	_mapRows = layerSize.height;
}

-(CGSize)mapTileSize
{
	return CGSizeMake(_tileWidth, _tileHeight);
}

-(void)setMapTileSize:(CGSize)mapTileSize
{
	_tileWidth = mapTileSize.width;
	_tileHeight = mapTileSize.height;
}

#pragma mark CCTMXLayer - setup Tiles

//-(CCSprite*) reusedTileWithRect:(CGRect)rect
//{	
//	if( ! _reusedTile ) {
//		_reusedTile = [[CCSprite alloc] initWithTexture:self.texture rect:rect rotated:NO];
//	}
//	else
//	{
//		// XXX HACK: Needed because if "batch node" is nil,
//		// then the Sprite'squad will be reset
////		[_reusedTile setBatchNode:nil];
//
//		// Re-init the sprite
//		[_reusedTile setTextureRect:rect rotated:NO untrimmedSize:rect.size];
//
//		// restore the batch node
////		[_reusedTile setBatchNode:self];
//	}
//
//	return _reusedTile;
//}

-(void) setupTiles
{
	// Optimization: quick hack that sets the image size on the tileset
	_tileset.imageSize = [self.texture contentSizeInPixels];

	// By default all the tiles are aliased
	// pros:
	//  - easier to render
	// cons:
	//  - difficult to scale / rotate / etc.
	[self.texture setAliasTexParameters];

	// Parse cocos2d properties
	[self parseInternalProperties];
}

#pragma mark CCTMXLayer - Properties

-(id) propertyNamed:(NSString *)propertyName
{
	return [_properties valueForKey:propertyName];
}

-(void) parseInternalProperties
{
	// if cc_vertex=automatic, then tiles will be rendered using vertexz

	NSString *vertexz = [self propertyNamed:@"cc_vertexz"];
	if( vertexz ) {

		// If "automatic" is on, then parse the "cc_alpha_func" too
		if( [vertexz isEqualToString:@"automatic"] ) {
			_useAutomaticVertexZ = YES;
		} else {
			_vertexZvalue = [vertexz intValue];
		}
	}
}

#pragma mark CCTMXLayer - obtaining tiles/gids

-(CCSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < _mapColumns && pos.y < _mapRows && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( _tiles, @"TMXLayer: the tiles map has been released");

	CCSprite *tile = nil;
	uint32_t gid = [self tileGIDAt:pos];

	// if GID == 0, then no tile is present
	if( gid ) {
		int z = pos.x + pos.y * _mapColumns;

        NSString* zStr = [NSString stringWithFormat:@"%d",z];
		tile = (CCSprite*) [self getChildByName:zStr recursively:NO];

		if( ! tile ) {
			CGRect rect = CC_RECT_SCALE([_tileset rectForGID:gid], 1.0/self.texture.contentScale);
			tile = [[CCSprite alloc] initWithTexture:self.texture rect:rect];

            CGPoint p = [self positionAt:pos];
            [tile setPosition:p];
			[tile setVertexZ: [self vertexZForPos:pos]];
			tile.anchorPoint = CGPointZero;
			tile.opacity = self.opacity;

			//#warning TODO was this needed? Seems bizzare.
//			NSUInteger indexForZ = [self atlasIndexForExistantZ:z];
//			[self addSpriteWithoutQuad:tile z:indexForZ name:zStr];
		}
	}
	return tile;
}

-(uint32_t) tileGIDAt:(CGPoint)pos
{
	return [self tileGIDAt:pos withFlags:NULL];
}

-(uint32_t) tileGIDAt:(CGPoint)pos withFlags:(ccTMXTileFlags*)flags
{
	NSAssert( pos.x < _mapColumns && pos.y < _mapRows && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( _tiles, @"TMXLayer: the tiles map has been released");

	NSInteger idx = pos.x + pos.y * _mapColumns;

	// Bits on the far end of the 32-bit global tile ID are used for tile flags

	uint32_t tile = _tiles[idx];
	
	// issue1264, flipped tiles can be changed dynamically
	if (flags)
		*flags = tile & kCCFlipedAll;

	return ( tile & kCCFlippedMask);
}

#pragma mark CCTMXLayer - adding helper methods

#warning TODO
- (void) setupTileSprite:(CCSprite*) sprite position:(CGPoint)pos withGID:(uint32_t)gid
{
	[sprite setPosition: [self positionAt:pos]];
	[sprite setVertexZ: [self vertexZForPos:pos]];
	//sprite.anchorPoint = CGPointZero; // was the default
//	[sprite setOpacity:_opacity/255.0];
	
	//issue 1264, flip can be undone as well
	sprite.flipX = NO;
	sprite.flipY = NO;
	sprite.rotation = 0;
	//sprite.anchorPoint = ccp(0,0); // was the default
	
	// All tile sprites in the layer should have the same anchorpoint.
	// The default anchor point is defined in the TMX file (within the tileset node) and stored in the
	// CCTMXTilesetInfo* property of the CCTMXLayer.
	sprite.anchorPoint = _tileset.tileAnchorPoint;
	
	// Rotation in tiled is achieved using 3 flipped states, flipping across the horizontal, vertical, and diagonal axes of the tiles.
	if (gid & kCCTMXTileDiagonalFlag)
	{
		// put the anchor in the middle for ease of rotation.
		sprite.anchorPoint = ccp(0.5f,0.5f);
		[sprite setPosition: ccp([self positionAt:pos].x + sprite.contentSize.height/2,
								 [self positionAt:pos].y + sprite.contentSize.width/2 )
		 ];

		uint32_t flag = gid & (kCCTMXTileHorizontalFlag | kCCTMXTileVerticalFlag );

		// handle the 4 diagonally flipped states.
		if (flag == kCCTMXTileHorizontalFlag)
		{
			sprite.rotation = 90;
		}
		else if (flag == kCCTMXTileVerticalFlag)
		{
			sprite.rotation = 270;
		}
		else if (flag == (kCCTMXTileVerticalFlag | kCCTMXTileHorizontalFlag) )
		{
			sprite.rotation = 90;
			sprite.flipX = YES;
		}
		else
		{
			sprite.rotation = 270;
			sprite.flipX = YES;
		}
	}
	else
	{
		if (gid & kCCTMXTileHorizontalFlag)
			sprite.flipX = YES;
		
		if (gid & kCCTMXTileVerticalFlag)
			sprite.flipY = YES;
	}
}

-(CCSprite *) updateTileForGID:(uint32_t)gid at:(CGPoint)pos
{
	return nil;
//	CGRect rect = CC_RECT_SCALE([_tileset rectForGID:gid], 1.0/self.texture.contentScale);
//	int z = pos.x + pos.y * _mapColumns;
//
//	CCSprite *tile = [self reusedTileWithRect:rect];
//	[self setupTileSprite:tile position:pos withGID:gid];
//	_tiles[z] = gid;
//
//	return tile;
}

#pragma mark CCTMXLayer - atlasIndex and Z

#pragma mark CCTMXLayer - adding / remove tiles
-(void) setTileGID:(uint32_t)gid at:(CGPoint)pos
{
	[self setTileGID:gid at:pos withFlags:NO];	
}

-(void) setTileGID:(uint32_t)gid at:(CGPoint)pos withFlags:(ccTMXTileFlags)flags
{
	NSAssert( pos.x < _mapColumns && pos.y < _mapRows && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( _tiles, @"TMXLayer: the tiles map has been released");
	NSAssert( gid == 0 || gid >= _tileset.firstGid, @"TMXLayer: invalid gid" );

	ccTMXTileFlags currentFlags;
	uint32_t currentGID = [self tileGIDAt:pos withFlags:&currentFlags];
	
	if (currentGID != gid || currentFlags != flags )
	{
		uint32_t gidAndFlags = gid | flags;

		// setting gid=0 is equal to remove the tile
		if( gid == 0 )
			[self removeTileAt:pos];

		// empty tile. create a new one
		else if( currentGID == 0 )
			[self updateTileForGID:gidAndFlags at:pos];

		// modifying an existing tile with a non-empty tile
		else {

			int z = pos.x + pos.y * _mapColumns;
            NSString* zStr = [NSString stringWithFormat:@"%d", z];
			CCSprite *sprite = (CCSprite*)[self getChildByName:zStr recursively:NO];
			if( sprite ) {
			CGRect rect = CC_RECT_SCALE([_tileset rectForGID:gid], 1.0/self.texture.contentScale);

				[sprite setTextureRect:rect rotated:NO untrimmedSize:rect.size];

				if (flags) 
					[self setupTileSprite:sprite position:[sprite position] withGID:gidAndFlags];

				_tiles[z] = gidAndFlags;
			} else
				[self updateTileForGID:gidAndFlags at:pos];
		}
	}
}

-(void) addChild: (CCNode*)node z:(NSInteger)z tag:(NSInteger)tag
{
	NSAssert(NO, @"addChild: is not supported on CCTMXLayer. Instead use setTileGID:at:/tileAt:");
}

-(void) removeTileAt:(CGPoint)pos
{
	NSAssert( pos.x < _mapColumns && pos.y < _mapRows && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( _tiles, @"TMXLayer: the tiles map has been released");

	uint32_t gid = [self tileGIDAt:pos];

	if( gid ) {
		NSUInteger z = pos.x + pos.y * _mapColumns;

		// remove tile from GID map
		_tiles[z] = 0;
	}
}

#pragma mark CCTMXLayer - obtaining positions, offset

-(CGPoint) calculateLayerOffset:(CGPoint)pos
{
	switch( _layerOrientation ) {
		case CCTiledMapOrientationOrtho:
			return ccp( pos.x * _tileWidth, -pos.y *_tileHeight);
		case CCTiledMapOrientationIso:
			return ccp(
				(_tileWidth /2) * (pos.x - pos.y),
				(_tileHeight /2 ) * (-pos.x - pos.y)
			);
		default: return CGPointZero;
	}
}

-(CGPoint) positionAt:(CGPoint)pos
{
	CGPoint ret = CGPointZero;
	switch( _layerOrientation ) {
		case CCTiledMapOrientationOrtho:
			ret = [self positionForOrthoAt:pos];
			break;
		case CCTiledMapOrientationIso:
			ret = [self positionForIsoAt:pos];
			break;
	}

	return ccpMult(ret, 1.0/self.texture.contentScale);
}

-(CGPoint) positionForOrthoAt:(CGPoint)pos
{
	return ccp(
		pos.x * _tileWidth,
		(_mapRows - pos.y - 1) * _tileHeight
	);
}

-(CGPoint) positionForIsoAt:(CGPoint)pos
{
	return ccp(
		_tileWidth /2 * ( _mapColumns + pos.x - pos.y - 1),
		_tileHeight /2 * (( _mapRows * 2 - pos.x - pos.y) - 2)
	);
}

-(CGPoint) positionForHexAt:(CGPoint)pos
{
	float diffY = ((int)pos.x % 2 == 1 ? -_tileHeight/2 : 0);

	return ccp(
		pos.x * _tileWidth*3/4,
		(_mapRows - pos.y - 1) * _tileHeight + diffY
	);
}

-(NSInteger) vertexZForPos:(CGPoint)pos
{
	if( _useAutomaticVertexZ ) {
		switch( _layerOrientation ) {
			case CCTiledMapOrientationIso: {
				NSUInteger maxVal = _mapColumns + _mapRows;
				return -(maxVal - (pos.x + pos.y));
			}
			
			case CCTiledMapOrientationOrtho: return -(_mapRows-pos.y);
			default: NSAssert(NO, @"TMX invalid value");
		}
	}
	
	return _vertexZvalue;
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	// Convert from tile coordinates to clip coordinates
	GLKMatrix4 fromTileSpace = GLKMatrix4Multiply(*transform, GLKMatrix4MakeScale(_tileWidth, _tileHeight, 1));
	
	// Inverting the matrix lets you convert from clip coordinates to tile coordinates.
	bool isInvertible = YES;
	GLKMatrix4 toTileSpace = GLKMatrix4Invert(fromTileSpace, &isInvertible);
	NSAssert(isInvertible, @"Attempted to draw a tilemap using a bad transform. (Scale is zero maybe?)");
	
	// Clip coordinates just go from [-1, 1] so it's fairly easy to convert the bounds to tile coordinates.
	GLKVector4 tileSpaceCenter = GLKVector4Make(toTileSpace.m30, toTileSpace.m31, toTileSpace.m32, toTileSpace.m33);
	float tileSpaceHalfWidth = fmaxf(fabsf(toTileSpace.m00 + toTileSpace.m10), fabsf(toTileSpace.m00 - toTileSpace.m10));
	float tileSpaceHalfHeight = fmaxf(fabsf(toTileSpace.m01 + toTileSpace.m11), fabsf(toTileSpace.m01 - toTileSpace.m11));
	
	// TODO Needs to handle perspective? Will make it easy to generate *huge* ranges.
	
	// Calculating visible tile bounds.
	int xmin = MAX(0, floorf(tileSpaceCenter.x - tileSpaceHalfWidth));
	int xmax = MIN(_mapColumns, ceilf(tileSpaceCenter.x + tileSpaceHalfWidth));
	int ymin = _mapRows - MIN(_mapRows, ceilf(tileSpaceCenter.y + tileSpaceHalfHeight));
	int ymax = _mapRows - MAX(0, floorf(tileSpaceCenter.y - tileSpaceHalfHeight));
	
	// Count the number of tiles to be drawn.
	int tileCount = 0;
	
	for(int tileY = ymin; tileY < ymax; tileY++){
		for(int tileX = xmin; tileX < xmax; tileX++){
			int index = tileX + tileY*_mapColumns;
			uint32_t gid = _tiles[index];
			
			// Blank tiles have a GID of 0.
			if(gid != 0) tileCount++;
		}
	}
	
	// No tiles on screen. Skip rendering.
	if(tileCount == 0) return;
	
	GLKVector2 zero2 = GLKVector2Make(0, 0);
	GLKVector4 color = GLKVector4Make(_displayColor.r, _displayColor.g, _displayColor.b, _displayColor.a);
	
	CCTexture *tex = self.texture;
	float scale = 1.0/tex.contentScale;
	float scaleW = scale/self.texture.pixelWidth;
	float scaleH = scale/self.texture.pixelHeight;
	
	// Number of tiles per row in the tile sheet.
	int tilesetFirstGid = _tileset.firstGid;
	int tilesetMargin = _tileset.margin;
	int tilesetSpacing = _tileset.spacing;
	int tilesetTileW = _tileset.tileSize.width;
	int tilesetTileH = _tileset.tileSize.height;
	int tilesPerSheetRow = (_tileset.imageSize.width - tilesetMargin*2 + tilesetSpacing) / (_tileset.tileSize.width + _tileset.spacing);
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:tileCount*2 andVertexes:tileCount*4 withState:self.renderState];
	int vertex_cursor = 0;
	int triangle_cursor = 0;
	
	for(int tileY = ymin; tileY < ymax; tileY++){
		for(int tileX = xmin; tileX < xmax; tileX++){
			int index = tileX + tileY*_mapColumns;
			uint32_t gid = _tiles[index];
			
			// Skip blank tiles.
			if(gid == 0) continue;
			
			// Need to normalize these before storing them to BOOLs to avoid truncation.
			BOOL diagonalFlip   = !!(gid & kCCTMXTileDiagonalFlag);
			BOOL horizontalFlip = !!(gid & kCCTMXTileHorizontalFlag);
			BOOL verticalFlip   = !!(gid & kCCTMXTileVerticalFlag);
			
			// Calculate the vertex positions (in points).
			int x = tileX*_tileWidth;
			int y = (_mapRows - tileY - 1)*_tileHeight;
			
			int x1 = tilesetTileW, y1 =            0;
			int x2 = tilesetTileW, y2 = tilesetTileH;
			int x3 =            0, y3 = tilesetTileH;
			
			if(diagonalFlip){
				CC_SWAP(x1, y1);
				CC_SWAP(x2, y2);
				CC_SWAP(x3, y3);
				
				horizontalFlip = !horizontalFlip;
				verticalFlip = !verticalFlip;
				CC_SWAP(horizontalFlip, verticalFlip);
			}
			
			// Calculate the texture coordinates (in points).
			uint32_t tileIndex = (gid & kCCFlippedMask) - tilesetFirstGid;
			int txmin = (tileIndex % tilesPerSheetRow) * (tilesetTileW + tilesetSpacing) + tilesetMargin;
			int tymin = (tileIndex / tilesPerSheetRow) * (tilesetTileH + tilesetSpacing) + tilesetMargin;
			int txmax = txmin + tilesetTileW;
			int tymax = tymin + tilesetTileH;
			
			if(horizontalFlip) CC_SWAP(txmin, txmax);
			if(verticalFlip  ) CC_SWAP(tymin, tymax);
			
			CCRenderBufferSetVertex(buffer, vertex_cursor + 0, (CCVertex){GLKVector4Make(x     , y     , 0, 1), GLKVector2Make(txmin*scaleW, tymax*scaleH), zero2, color});
			CCRenderBufferSetVertex(buffer, vertex_cursor + 1, (CCVertex){GLKVector4Make(x + x1, y + y1, 0, 1), GLKVector2Make(txmax*scaleW, tymax*scaleH), zero2, color});
			CCRenderBufferSetVertex(buffer, vertex_cursor + 2, (CCVertex){GLKVector4Make(x + x2, y + y2, 0, 1), GLKVector2Make(txmax*scaleW, tymin*scaleH), zero2, color});
			CCRenderBufferSetVertex(buffer, vertex_cursor + 3, (CCVertex){GLKVector4Make(x + x3, y + y3, 0, 1), GLKVector2Make(txmin*scaleW, tymin*scaleH), zero2, color});
			
			CCRenderBufferSetTriangle(buffer, triangle_cursor + 0, vertex_cursor + 0, vertex_cursor + 1, vertex_cursor + 2);
			CCRenderBufferSetTriangle(buffer, triangle_cursor + 1, vertex_cursor + 0, vertex_cursor + 2, vertex_cursor + 3);
			
			vertex_cursor += 4;
			triangle_cursor += 2;
		}
	}
	
	// Transform the vertexes
	for(int i=0; i<4*tileCount; i++) buffer.vertexes[i].position = GLKMatrix4MultiplyVector4(*transform, buffer.vertexes[i].position);
}

@end

