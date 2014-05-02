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
-(CGPoint) calculateLayerOffset:(CGPoint)offset;

/* The layer recognizes some special properties, like cc_vertez */
-(void) parseInternalProperties;
@end

@implementation CCTiledMapLayer {
	// Number of rows and columns of tiles in the layer.
	int _mapRows, _mapColumns;
	
	// Size of a tile in points.
	int _tileWidth, _tileHeight;
	
	// Only used when vertexZ is used.
	float _vertexZvalue;
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

-(uint32_t) tileGIDAt:(CGPoint)pos
{
	return [self tileGIDAt:pos withFlags:NULL];
}

-(uint32_t) tileGIDAt:(CGPoint)pos withFlags:(ccTMXTileFlags*)flags
{
	NSAssert( pos.x < _mapColumns && pos.y < _mapRows && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( _tiles, @"TMXLayer: the tiles map has been released");

	NSInteger idx = (int)pos.x + (int)pos.y*_mapColumns;

	// Bits on the far end of the 32-bit global tile ID are used for tile flags

	uint32_t tile = _tiles[idx];
	
	// issue1264, flipped tiles can be changed dynamically
	if(flags){
		*flags = tile & kCCFlipedAll;
	}

	return ( tile & kCCFlippedMask);
}

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

	ccTMXTileFlags currentFlags = 0;
	uint32_t currentGID = [self tileGIDAt:pos withFlags:&currentFlags];
	
	if(currentGID != gid || currentFlags != flags){
		uint32_t gidAndFlags = gid | flags;
		
		int idx = (int)pos.x + (int)pos.y*_mapColumns;
		_tiles[idx] = gidAndFlags;
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
		NSUInteger idx = (int)pos.x + (int)pos.y * _mapColumns;
		_tiles[idx] = 0;
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

-(GLKMatrix4)tileToNodeTransform
{
	float w = _tileWidth;
	float h = _tileHeight;
	float offY = _mapRows*h;
	
	switch(_layerOrientation){
		case CCTiledMapOrientationOrtho:
			return GLKMatrix4Make(
				   w, 0.0f, 0.0f, 0.0f,
				0.0f,   -h, 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 0.0f,
				0.0f, offY, 0.0f, 1.0f
			);
		case CCTiledMapOrientationIso: {
			float offX = _mapColumns*w/2;
			return GLKMatrix4Make(
				 w/2, -h/2, 00.f, 0.0f,
				-w/2, -h/2, 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 0.0f,
				offX, offY, 0.0f, 1.0f
			);
		}
	}
}

-(CGPoint) positionAt:(CGPoint)pos
{
	GLKVector4 p = GLKMatrix4MultiplyVector4([self tileToNodeTransform], GLKVector4Make(floorf(pos.x), floorf(pos.y), 0.0f, 1.0f));
	return ccp(p.x, p.y);
}

-(CGPoint)tileCoordinateAt:(CGPoint)pos
{
	GLKMatrix4 nodeToTile = GLKMatrix4Invert([self tileToNodeTransform], NULL);
	GLKVector4 p = GLKMatrix4MultiplyVector4(nodeToTile, GLKVector4Make(pos.x, pos.y, 0.0f, 1.0f));
	return ccp(floorf(p.x), floorf(p.y));
}

static float
AutomaticVertexZ(int tileX, int tileY, int mapColumns, int mapRows, CCTiledMapOrientation orientation)
{
	switch(orientation) {
		case CCTiledMapOrientationIso: {
			NSUInteger maxVal = mapColumns + mapRows;
			return -(maxVal - (tileX + tileY));
		}
		
		case CCTiledMapOrientationOrtho: return -(mapRows - tileY);
		default: NSCAssert(NO, @"TMX invalid value");
	}
}

struct IntRect { int xmin, xmax, ymin, ymax; };

// Calculate the range of tiles visible on the screen.
-(struct IntRect)tileBoundsForClipTransform:(GLKMatrix4)tileToClip
{
	// Inverting the matrix lets you convert from clip coordinates to tile coordinates.
	bool isInvertible = YES;
	GLKMatrix4 clipToTile = GLKMatrix4Invert(tileToClip, &isInvertible);
	NSAssert(isInvertible, @"Attempted to draw a tilemap using a bad transform. (Scale is zero maybe?)");
	
	// TODO Needs to handle perspective? Will make it easy to generate *huge* ranges.
	
	// TODO Doesn't handle offsets.
	// Find the maximum amount a tile sprite can spill out of it's bounds.
	float oversize = MAX(_tileset.tileSize.width, _tileset.tileSize.height)/MIN(_tileWidth, _tileHeight) - 1.0f;
	
	// TODO This might be overly conservative for Isometric tilemaps.
	if(_layerOrientation == CCTiledMapOrientationIso){
		oversize = oversize*2 + 1;
	}
	
	// Clip coordinates just go from [-1, 1] so it's fairly easy to convert the bounds to tile coordinates.
	GLKVector4 tileSpaceCenter = GLKMatrix4GetColumn(clipToTile, 3);
	float tileSpaceHalfWidth = fmaxf(fabsf(clipToTile.m00 + clipToTile.m10), fabsf(clipToTile.m00 - clipToTile.m10)) + oversize;
	float tileSpaceHalfHeight = fmaxf(fabsf(clipToTile.m01 + clipToTile.m11), fabsf(clipToTile.m01 - clipToTile.m11)) + oversize;
	
	// Calculating visible tile bounds.
	return (struct IntRect){
		MAX(0, MIN(_mapColumns, floorf(tileSpaceCenter.x - tileSpaceHalfWidth))),
		MAX(0, MIN(_mapColumns, ceilf(tileSpaceCenter.x + tileSpaceHalfWidth))),
		MAX(0, MIN(_mapRows, floorf(tileSpaceCenter.y - tileSpaceHalfHeight))),
		MAX(0, MIN(_mapRows, ceilf(tileSpaceCenter.y + tileSpaceHalfHeight))),
	};
}

// Calculate the bounds of a tile on the screen. (Could be precalculated)
-(struct IntRect)tileBounds
{
	int w = _tileset.tileSize.width;
	int h = _tileset.tileSize.height;
	
	switch(_layerOrientation){
		case CCTiledMapOrientationOrtho: return (struct IntRect){0, w, 0, h};
		case CCTiledMapOrientationIso: return (struct IntRect){-w/2, w/2, 0, h};
	}
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	GLKMatrix4 tileToNode = [self tileToNodeTransform];
	struct IntRect tiles = [self tileBoundsForClipTransform:GLKMatrix4Multiply(*transform, tileToNode)];
	
	// Count the number of tiles to be drawn.
	int tileCount = 0;
	
	for(int tileY = tiles.ymin; tileY < tiles.ymax; tileY++){
		for(int tileX = tiles.xmin; tileX < tiles.xmax; tileX++){
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
	
	struct IntRect tileBounds = [self tileBounds];
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:tileCount*2 andVertexes:tileCount*4 withState:self.renderState globalSortOrder:0];
	int vertex_cursor = 0;
	int triangle_cursor = 0;
	
	for(int tileY = tiles.ymin; tileY < tiles.ymax; tileY++){
		for(int tileX = tiles.xmin; tileX < tiles.xmax; tileX++){
			int index = tileX + tileY*_mapColumns;
			uint32_t gidWithFlags = _tiles[index];
			
			uint32_t flags = gidWithFlags & kCCFlipedAll;
			uint32_t gid = gidWithFlags & kCCFlippedMask;
			GLKVector4 tileColor = color;
			
			// Call the animation block to substitute tile values.
			if(_animationBlock) _animationBlock(tileX, tileY, &gid, &flags, &tileColor);
			
			// Skip blank tiles.
			if(gid == 0) continue;
			
			// Need to normalize these before storing them to BOOLs to avoid truncation on the 32 bit ABI.
			BOOL diagonalFlip   = !!(flags & kCCTMXTileDiagonalFlag);
			BOOL horizontalFlip = !!(flags & kCCTMXTileHorizontalFlag);
			BOOL verticalFlip   = !!(flags & kCCTMXTileVerticalFlag);
			
			// Calculate the vertex positions (in points).
			GLKVector4 pos = GLKMatrix4MultiplyVector4(tileToNode, GLKVector4Make(tileX, tileY, 0.0f, 1.0f));
			pos.y -= _tileHeight;
			
			GLKVector2 v0 = GLKVector2Make(tileBounds.xmin, tileBounds.ymin);
			GLKVector2 v1 = GLKVector2Make(tileBounds.xmax, tileBounds.ymin);
			GLKVector2 v2 = GLKVector2Make(tileBounds.xmax, tileBounds.ymax);
			GLKVector2 v3 = GLKVector2Make(tileBounds.xmin, tileBounds.ymax);
			
			if(diagonalFlip){
				CC_SWAP(v0.x, v0.y);
				CC_SWAP(v1.x, v1.y);
				CC_SWAP(v2.x, v2.y);
				CC_SWAP(v3.x, v3.y);
				
				horizontalFlip = !horizontalFlip;
				verticalFlip = !verticalFlip;
				CC_SWAP(horizontalFlip, verticalFlip);
			}
			
			// Calculate the texture coordinates (in points).
			uint32_t tileIndex = gid - tilesetFirstGid;
			int txmin = (tileIndex%tilesPerSheetRow)*(tilesetTileW + tilesetSpacing) + tilesetMargin;
			int tymin = (tileIndex/tilesPerSheetRow)*(tilesetTileH + tilesetSpacing) + tilesetMargin;
			int txmax = txmin + tilesetTileW;
			int tymax = tymin + tilesetTileH;
			
			if(horizontalFlip) CC_SWAP(txmin, txmax);
			if(verticalFlip  ) CC_SWAP(tymin, tymax);
			
			// AutomaticZ
			float z = (_useAutomaticVertexZ ? AutomaticVertexZ(tileX, tileY, _mapColumns, _mapRows, _layerOrientation) : _vertexZvalue);
			
			// Fill in the buffers and increment the cursors.
			CCRenderBufferSetVertex(buffer, vertex_cursor + 0, (CCVertex){GLKVector4Make(pos.x + v0.x, pos.y + v0.y, z, 1), GLKVector2Make(txmin*scaleW, tymax*scaleH), zero2, tileColor});
			CCRenderBufferSetVertex(buffer, vertex_cursor + 1, (CCVertex){GLKVector4Make(pos.x + v1.x, pos.y + v1.y, z, 1), GLKVector2Make(txmax*scaleW, tymax*scaleH), zero2, tileColor});
			CCRenderBufferSetVertex(buffer, vertex_cursor + 2, (CCVertex){GLKVector4Make(pos.x + v2.x, pos.y + v2.y, z, 1), GLKVector2Make(txmax*scaleW, tymin*scaleH), zero2, tileColor});
			CCRenderBufferSetVertex(buffer, vertex_cursor + 3, (CCVertex){GLKVector4Make(pos.x + v3.x, pos.y + v3.y, z, 1), GLKVector2Make(txmin*scaleW, tymin*scaleH), zero2, tileColor});
			
			CCRenderBufferSetTriangle(buffer, triangle_cursor + 0, vertex_cursor + 0, vertex_cursor + 1, vertex_cursor + 2);
			CCRenderBufferSetTriangle(buffer, triangle_cursor + 1, vertex_cursor + 0, vertex_cursor + 2, vertex_cursor + 3);
			
			vertex_cursor += 4;
			triangle_cursor += 2;
		}
	}
	
	// Transform the vertexes in a loop to avoid invariance.
	for(int i=0; i<4*tileCount; i++) buffer.vertexes[i].position = GLKMatrix4MultiplyVector4(*transform, buffer.vertexes[i].position);
}

@end

