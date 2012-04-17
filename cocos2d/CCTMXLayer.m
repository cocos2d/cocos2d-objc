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

#import "CCTMXLayer.h"
#import "CCTMXTiledMap.h"
#import "CCTMXXMLParser.h"
#import "CCSprite.h"
#import "CCSpriteBatchNode.h"
#import "CCTextureCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "Support/CGPointExtension.h"


#pragma mark -
#pragma mark CCTMXLayer

int compareInts (const void * a, const void * b);


@interface CCTMXLayer ()
-(CGPoint) positionForIsoAt:(CGPoint)pos;
-(CGPoint) positionForOrthoAt:(CGPoint)pos;
-(CGPoint) positionForHexAt:(CGPoint)pos;

-(CGPoint) calculateLayerOffset:(CGPoint)offset;

/* optimization methos */
-(CCSprite*) appendTileForGID:(uint32_t)gid at:(CGPoint)pos;
-(CCSprite*) insertTileForGID:(uint32_t)gid at:(CGPoint)pos;
-(CCSprite*) updateTileForGID:(uint32_t)gid at:(CGPoint)pos;

/* The layer recognizes some special properties, like cc_vertez */
-(void) parseInternalProperties;
- (void) setupTileSprite:(CCSprite*) sprite position:(CGPoint)pos withGID:(uint32_t)gid;

-(NSInteger) vertexZForPos:(CGPoint)pos;

// index
-(NSUInteger) atlasIndexForExistantZ:(NSUInteger)z;
-(NSUInteger) atlasIndexForNewZ:(NSUInteger)z;
@end

@implementation CCTMXLayer
@synthesize layerSize = layerSize_, layerName = layerName_, tiles = tiles_;
@synthesize tileset = tileset_;
@synthesize layerOrientation = layerOrientation_;
@synthesize mapTileSize = mapTileSize_;
@synthesize properties = properties_;

#pragma mark CCTMXLayer - init & alloc & dealloc

+(id) layerWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo
{
	return [[[self alloc] initWithTilesetInfo:tilesetInfo layerInfo:layerInfo mapInfo:mapInfo] autorelease];
}

-(id) initWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo
{
	// XXX: is 35% a good estimate ?
	CGSize size = layerInfo.layerSize;
	float totalNumberOfTiles = size.width * size.height;
	float capacity = totalNumberOfTiles * 0.35f + 1; // 35 percent is occupied ?

	CCTexture2D *tex = nil;
	if( tilesetInfo )
		tex = [[CCTextureCache sharedTextureCache] addImage:tilesetInfo.sourceImage];

	if((self = [super initWithTexture:tex capacity:capacity])) {

		// layerInfo
		self.layerName = layerInfo.name;
		layerSize_ = size;
		tiles_ = layerInfo.tiles;
		minGID_ = layerInfo.minGID;
		maxGID_ = layerInfo.maxGID;
		opacity_ = layerInfo.opacity;
		self.properties = [NSMutableDictionary dictionaryWithDictionary:layerInfo.properties];

		// tilesetInfo
		self.tileset = tilesetInfo;

		// mapInfo
		mapTileSize_ = mapInfo.tileSize;
		layerOrientation_ = mapInfo.orientation;

		// offset (after layer orientation is set);
		CGPoint offset = [self calculateLayerOffset:layerInfo.offset];
		[self setPosition:CC_POINT_PIXELS_TO_POINTS(offset)];

		atlasIndexArray_ = ccCArrayNew(totalNumberOfTiles);

		[self setContentSize:CC_SIZE_PIXELS_TO_POINTS(CGSizeMake( layerSize_.width * mapTileSize_.width, layerSize_.height * mapTileSize_.height ))];

		useAutomaticVertexZ_= NO;
		vertexZvalue_ = 0;
	}

	return self;
}

- (void) dealloc
{
	[layerName_ release];
	[tileset_ release];
	[reusedTile_ release];
	[properties_ release];

	if( atlasIndexArray_ ) {
		ccCArrayFree(atlasIndexArray_);
		atlasIndexArray_ = NULL;
	}

	if( tiles_ ) {
		free(tiles_);
		tiles_ = NULL;
	}

	[super dealloc];
}

-(void) releaseMap
{
	if( tiles_) {
		free( tiles_);
		tiles_ = NULL;
	}

	if( atlasIndexArray_ ) {
		ccCArrayFree(atlasIndexArray_);
		atlasIndexArray_ = NULL;
	}
}

#pragma mark CCTMXLayer - setup Tiles

-(CCSprite*) reusedTileWithRect:(CGRect)rect
{	
	if( ! reusedTile_ ) {
		reusedTile_ = [[CCSprite alloc] initWithTexture:textureAtlas_.texture rect:rect rotated:NO];
		[reusedTile_ setBatchNode:self];
	}
	else
	{
		// XXX: should not be re-init. Potential memeory leak. Not following best practices
		// XXX: it shall call directory  [setRect:rect]
		[reusedTile_ initWithTexture:textureAtlas_.texture rect:rect rotated:NO];
		
		// Since initWithTexture resets the batchNode, we need to re add it.
		// but should be removed once initWithTexture is not called again
		[reusedTile_ setBatchNode:self];
	}

	return reusedTile_;
}

-(void) setupTiles
{
	// Optimization: quick hack that sets the image size on the tileset
	tileset_.imageSize = [textureAtlas_.texture contentSizeInPixels];

	// By default all the tiles are aliased
	// pros:
	//  - easier to render
	// cons:
	//  - difficult to scale / rotate / etc.
	[textureAtlas_.texture setAliasTexParameters];

	// Parse cocos2d properties
	[self parseInternalProperties];

	for( NSUInteger y = 0; y < layerSize_.height; y++ ) {
		for( NSUInteger x = 0; x < layerSize_.width; x++ ) {

			NSUInteger pos = x + layerSize_.width * y;
			uint32_t gid = tiles_[ pos ];

			// gid are stored in little endian.
			// if host is big endian, then swap
			gid = CFSwapInt32LittleToHost( gid );

			// XXX: gid == 0 --> empty tile
			if( gid != 0 ) {
				[self appendTileForGID:gid at:ccp(x,y)];

				// Optimization: update min and max GID rendered by the layer
				minGID_ = MIN(gid, minGID_);
				maxGID_ = MAX(gid, maxGID_);
//				minGID_ = MIN((gid & kFlippedMask), minGID_);
//				maxGID_ = MAX((gid & kFlippedMask), maxGID_);
			}
		}
	}

	NSAssert( maxGID_ >= tileset_.firstGid &&
			 minGID_ >= tileset_.firstGid, @"TMX: Only 1 tilset per layer is supported");
}

#pragma mark CCTMXLayer - Properties

-(id) propertyNamed:(NSString *)propertyName
{
	return [properties_ valueForKey:propertyName];
}

-(void) parseInternalProperties
{
	// if cc_vertex=automatic, then tiles will be rendered using vertexz

	NSString *vertexz = [self propertyNamed:@"cc_vertexz"];
	if( vertexz ) {

		// If "automatic" is on, then parse the "cc_alpha_func" too
		if( [vertexz isEqualToString:@"automatic"] ) {
			useAutomaticVertexZ_ = YES;

			NSString *alphaFuncVal = [self propertyNamed:@"cc_alpha_func"];
			float alphaFuncValue = [alphaFuncVal floatValue];

			self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColorAlphaTest];

			GLint alphaValueLocation = glGetUniformLocation(self.shaderProgram->program_, kCCUniformAlphaTestValue);

			// NOTE: alpha test shader is hard-coded to use the equivalent of a glAlphaFunc(GL_GREATER) comparison
			[self.shaderProgram setUniformLocation:alphaValueLocation withF1:alphaFuncValue];
		}
		else
			vertexZvalue_ = [vertexz intValue];
	}
}

#pragma mark CCTMXLayer - obtaining tiles/gids

-(CCSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");

	CCSprite *tile = nil;
	uint32_t gid = [self tileGIDAt:pos];

	// if GID == 0, then no tile is present
	if( gid ) {
		int z = pos.x + pos.y * layerSize_.width;
		tile = (CCSprite*) [self getChildByTag:z];

		// tile not created yet. create it
		if( ! tile ) {
			CGRect rect = [tileset_ rectForGID:gid];
			rect = CC_RECT_PIXELS_TO_POINTS(rect);
			tile = [[CCSprite alloc] initWithTexture:self.texture rect:rect];
			[tile setBatchNode:self];

            CGPoint p = [self positionAt:pos];
            [tile setPosition:p];
			[tile setVertexZ: [self vertexZForPos:pos]];
			tile.anchorPoint = CGPointZero;
			[tile setOpacity:opacity_];

			NSUInteger indexForZ = [self atlasIndexForExistantZ:z];
			[self addSpriteWithoutQuad:tile z:indexForZ tag:z];
			[tile release];
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
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");

	NSInteger idx = pos.x + pos.y * layerSize_.width;

	// Bits on the far end of the 32-bit global tile ID are used for tile flags

	uint32_t tile = tiles_[idx];
	
	// issue1264, flipped tiles can be changed dynamically
	if (flags)
		*flags = tile & kCCFlipedAll;

	return ( tile & kCCFlippedMask);
}

#pragma mark CCTMXLayer - adding helper methods

- (void) setupTileSprite:(CCSprite*) sprite position:(CGPoint)pos withGID:(uint32_t)gid
{
	[sprite setPosition: [self positionAt:pos]];
	[sprite setVertexZ: [self vertexZForPos:pos]];
	sprite.anchorPoint = CGPointZero;
	[sprite setOpacity:opacity_];
	
	//issue 1264, flip can be undone as well
	sprite.flipX = NO;
	sprite.flipY = NO;
	sprite.rotation = 0;
	sprite.anchorPoint = ccp(0,0);
	
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

-(CCSprite*) insertTileForGID:(uint32_t)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	rect = CC_RECT_PIXELS_TO_POINTS(rect);

	NSInteger z = pos.x + pos.y * layerSize_.width;

	CCSprite *tile = [self reusedTileWithRect:rect];

	[self setupTileSprite:tile position:pos withGID:gid];

	// get atlas index
	NSUInteger indexForZ = [self atlasIndexForNewZ:z];

	// Optimization: add the quad without adding a child
	[self addQuadFromSprite:tile quadIndex:indexForZ];

	// insert it into the local atlasindex array
	ccCArrayInsertValueAtIndex(atlasIndexArray_, (void*)z, indexForZ);

	// update possible children
	CCSprite *sprite;
	CCARRAY_FOREACH(children_, sprite) {
		NSUInteger ai = [sprite atlasIndex];
		if( ai >= indexForZ)
			[sprite setAtlasIndex: ai+1];
	}

	tiles_[z] = gid;

	return tile;
}

-(CCSprite*) updateTileForGID:(uint32_t)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	rect = CC_RECT_PIXELS_TO_POINTS(rect);

	int z = pos.x + pos.y * layerSize_.width;

	CCSprite *tile = [self reusedTileWithRect:rect];

	[self setupTileSprite:tile position:pos withGID:gid];
	
	// get atlas index
	NSUInteger indexForZ = [self atlasIndexForExistantZ:z];

	[tile setAtlasIndex:indexForZ];
	[tile setDirty:YES];
	[tile updateTransform];
	tiles_[z] = gid;

	return tile;
}


// used only when parsing the map. useless after the map was parsed
// since lot's of assumptions are no longer true
-(CCSprite*) appendTileForGID:(uint32_t)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	rect = CC_RECT_PIXELS_TO_POINTS(rect);

	NSInteger z = pos.x + pos.y * layerSize_.width;

	CCSprite *tile = [self reusedTileWithRect:rect];

	[self setupTileSprite:tile position:pos withGID:gid];

	// optimization:
	// The difference between appendTileForGID and insertTileforGID is that append is faster, since
	// it appends the tile at the end of the texture atlas
	NSUInteger indexForZ = atlasIndexArray_->num;


	// don't add it using the "standard" way.
	[self addQuadFromSprite:tile quadIndex:indexForZ];


	// append should be after addQuadFromSprite since it modifies the quantity values
	ccCArrayInsertValueAtIndex(atlasIndexArray_, (void*)z, indexForZ);

	return tile;
}

#pragma mark CCTMXLayer - atlasIndex and Z

int compareInts (const void * a, const void * b)
{
	return ( *(int*)a - *(int*)b );
}

-(NSUInteger) atlasIndexForExistantZ:(NSUInteger)z
{
	NSInteger key = z;
	NSInteger *item = bsearch((void*)&key, (void*)&atlasIndexArray_->arr[0], atlasIndexArray_->num, sizeof(void*), compareInts);

	NSAssert( item, @"TMX atlas index not found. Shall not happen");

	NSUInteger index = ((NSInteger)item - (NSInteger)atlasIndexArray_->arr) / sizeof(void*);
	return index;
}

-(NSUInteger)atlasIndexForNewZ:(NSUInteger)z
{
	// XXX: This can be improved with a sort of binary search
	NSUInteger i = 0;
	for(i = 0; i< atlasIndexArray_->num; i++) {
		NSUInteger val = (NSUInteger) atlasIndexArray_->arr[i];
		if( z < val )
			break;
	}
	return i;
}

#pragma mark CCTMXLayer - adding / remove tiles
-(void) setTileGID:(uint32_t)gid at:(CGPoint)pos
{
	[self setTileGID:gid at:pos withFlags:NO];	
}

-(void) setTileGID:(uint32_t)gid at:(CGPoint)pos withFlags:(ccTMXTileFlags)flags
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");
	NSAssert( gid == 0 || gid >= tileset_.firstGid, @"TMXLayer: invalid gid" );

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
			[self insertTileForGID:gidAndFlags at:pos];

		// modifying an existing tile with a non-empty tile
		else {

			NSUInteger z = pos.x + pos.y * layerSize_.width;
			CCSprite *sprite = (CCSprite*)[self getChildByTag:z];
			if( sprite ) {
				CGRect rect = [tileset_ rectForGID:gid];
				rect = CC_RECT_PIXELS_TO_POINTS(rect);

				[sprite setTextureRect:rect rotated:NO untrimmedSize:rect.size];

				if (flags) 
					[self setupTileSprite:sprite position:[sprite position] withGID:gidAndFlags];

				tiles_[z] = gidAndFlags;
			} else
				[self updateTileForGID:gidAndFlags at:pos];
		}
	}
}

-(void) addChild: (CCNode*)node z:(NSInteger)z tag:(NSInteger)tag
{
	NSAssert(NO, @"addChild: is not supported on CCTMXLayer. Instead use setTileGID:at:/tileAt:");
}

-(void) removeChild:(CCSprite*)sprite cleanup:(BOOL)cleanup
{
	// allows removing nil objects
	if( ! sprite )
		return;

	NSAssert( [children_ containsObject:sprite], @"Tile does not belong to TMXLayer");

	NSUInteger atlasIndex = [sprite atlasIndex];
	NSUInteger zz = (NSUInteger) atlasIndexArray_->arr[atlasIndex];
	tiles_[zz] = 0;
	ccCArrayRemoveValueAtIndex(atlasIndexArray_, atlasIndex);
	[super removeChild:sprite cleanup:cleanup];
}

-(void) removeTileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");

	uint32_t gid = [self tileGIDAt:pos];

	if( gid ) {

		NSUInteger z = pos.x + pos.y * layerSize_.width;
		NSUInteger atlasIndex = [self atlasIndexForExistantZ:z];

		// remove tile from GID map
		tiles_[z] = 0;

		// remove tile from atlas position array
		ccCArrayRemoveValueAtIndex(atlasIndexArray_, atlasIndex);

		// remove it from sprites and/or texture atlas
		id sprite = [self getChildByTag:z];
		if( sprite )
			[super removeChild:sprite cleanup:YES];
		else {
			[textureAtlas_ removeQuadAtIndex:atlasIndex];

			// update possible children
			CCARRAY_FOREACH(children_, sprite) {
				NSUInteger ai = [sprite atlasIndex];
				if( ai >= atlasIndex) {
					[sprite setAtlasIndex: ai-1];
				}
			}
		}
	}
}

#pragma mark CCTMXLayer - obtaining positions, offset

-(CGPoint) calculateLayerOffset:(CGPoint)pos
{
	CGPoint ret = CGPointZero;
	switch( layerOrientation_ ) {
		case CCTMXOrientationOrtho:
			ret = ccp( pos.x * mapTileSize_.width, -pos.y *mapTileSize_.height);
			break;
		case CCTMXOrientationIso:
			ret = ccp( (mapTileSize_.width /2) * (pos.x - pos.y),
					  (mapTileSize_.height /2 ) * (-pos.x - pos.y) );
			break;
		case CCTMXOrientationHex:
			NSAssert(CGPointEqualToPoint(pos, CGPointZero), @"offset for hexagonal map not implemented yet");
			break;
	}
	return ret;
}

-(CGPoint) positionAt:(CGPoint)pos
{
	CGPoint ret = CGPointZero;
	switch( layerOrientation_ ) {
		case CCTMXOrientationOrtho:
			ret = [self positionForOrthoAt:pos];
			break;
		case CCTMXOrientationIso:
			ret = [self positionForIsoAt:pos];
			break;
		case CCTMXOrientationHex:
			ret = [self positionForHexAt:pos];
			break;
	}

	ret = CC_POINT_PIXELS_TO_POINTS( ret );
	return ret;
}

-(CGPoint) positionForOrthoAt:(CGPoint)pos
{
	CGPoint xy = {
		pos.x * mapTileSize_.width,
		(layerSize_.height - pos.y - 1) * mapTileSize_.height,
	};
	return xy;
}

-(CGPoint) positionForIsoAt:(CGPoint)pos
{
	CGPoint xy = {
		mapTileSize_.width /2 * ( layerSize_.width + pos.x - pos.y - 1),
		mapTileSize_.height /2 * (( layerSize_.height * 2 - pos.x - pos.y) - 2),
	};
	return xy;
}

-(CGPoint) positionForHexAt:(CGPoint)pos
{
	float diffY = 0;
	if( (int)pos.x % 2 == 1 )
		diffY = -mapTileSize_.height/2 ;

	CGPoint xy = {
		pos.x * mapTileSize_.width*3/4,
		(layerSize_.height - pos.y - 1) * mapTileSize_.height + diffY
	};
	return xy;
}

-(NSInteger) vertexZForPos:(CGPoint)pos
{
	NSInteger ret = 0;
	NSUInteger maxVal = 0;
	if( useAutomaticVertexZ_ ) {
		switch( layerOrientation_ ) {
			case CCTMXOrientationIso:
				maxVal = layerSize_.width + layerSize_.height;
				ret = -(maxVal - (pos.x + pos.y));
				break;
			case CCTMXOrientationOrtho:
				ret = -(layerSize_.height-pos.y);
				break;
			case CCTMXOrientationHex:
				NSAssert(NO,@"TMX Hexa zOrder not supported");
				break;
			default:
				NSAssert(NO,@"TMX invalid value");
				break;
		}
	} else
		ret = vertexZvalue_;

	return ret;
}

@end

