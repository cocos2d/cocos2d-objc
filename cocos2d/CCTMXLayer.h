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


#import "CCAtlasNode.h"
#import "CCSpriteBatchNode.h"


@class CCTMXMapInfo;
@class CCTMXLayerInfo;
@class CCTMXTilesetInfo;

/** CCTMXLayer represents the TMX layer.
 
 It is a subclass of CCSpriteSheet. By default the tiles are rendered using a CCTextureAtlas.
 If you mofify a tile on runtime, then, that tile will become a CCSprite, otherwise no CCSprite objects are created.
 The benefits of using CCSprite objects as tiles are:
 - tiles (CCSprite) can be rotated/scaled/moved with a nice API
 
 If the layer contains a property named "cc_vertexz" with an integer (in can be positive or negative),
 then all the tiles belonging to the layer will use that value as their OpenGL vertex Z for depth.

 On the other hand, if the "cc_vertexz" property has the "automatic" value, then the tiles will use an automatic vertex Z value.
 Also before drawing the tiles, GL_ALPHA_TEST will be enabled, and disabled after drawing them. The used alpha func will be:

    glAlphaFunc( GL_GREATER, value )
 
 "value" by default is 0, but you can change it from Tiled by adding the "cc_alpha_func" property to the layer.
 The value 0 should work for most cases, but if you have tiles that are semi-transparent, then you might want to use a differnt
 value, like 0.5.
 
 For further information, please see the programming guide:
 
	http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:tiled_maps
 
 @since v0.8.1
 */
@interface CCTMXLayer : CCSpriteBatchNode
{
	CCTMXTilesetInfo	*tileset_;
	NSString			*layerName_;
	CGSize				layerSize_;
	CGSize				mapTileSize_;
	uint32_t			*tiles_;			// GID are 32 bit
	NSUInteger			layerOrientation_;
	NSMutableArray		*properties_;
	
	unsigned char		opacity_; // TMX Layer supports opacity
	
	NSUInteger			minGID_;
	NSUInteger			maxGID_;
	
	// Only used when vertexZ is used
	NSInteger			vertexZvalue_;
	BOOL				useAutomaticVertexZ_;
	float				alphaFuncValue_;
	
	// used for optimization
	CCSprite		*reusedTile_;
	ccCArray		*atlasIndexArray_;
}
/** name of the layer */
@property (nonatomic,readwrite,retain) NSString *layerName;
/** size of the layer in tiles */
@property (nonatomic,readwrite) CGSize layerSize;
/** size of the map's tile (could be differnt from the tile's size) */
@property (nonatomic,readwrite) CGSize mapTileSize;
/** pointer to the map of tiles */
@property (nonatomic,readwrite) uint32_t *tiles;
/** Tilset information for the layer */
@property (nonatomic,readwrite,retain) CCTMXTilesetInfo *tileset;
/** Layer orientation, which is the same as the map orientation */
@property (nonatomic,readwrite) NSUInteger layerOrientation;
/** properties from the layer. They can be added using Tiled */
@property (nonatomic,readwrite,retain) NSMutableArray *properties;

/** creates a CCTMXLayer with an tileset info, a layer info and a map info */
+(id) layerWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo;
/** initializes a CCTMXLayer with a tileset info, a layer info and a map info */
-(id) initWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo;

/** dealloc the map that contains the tile position from memory.
 Unless you want to know at runtime the tiles positions, you can safely call this method.
 If you are going to call [layer tileGIDAt:] then, don't release the map
 */
-(void) releaseMap;

/** returns the tile (CCSprite) at a given a tile coordinate.
 The returned CCSprite will be already added to the CCTMXLayer. Don't add it again.
 The CCSprite can be treated like any other CCSprite: rotated, scaled, translated, opacity, color, etc.
 You can remove either by calling:
	- [layer removeChild:sprite cleanup:cleanup];
	- or [layer removeTileAt:ccp(x,y)];
 */
-(CCSprite*) tileAt:(CGPoint)tileCoordinate;

/** returns the tile gid at a given tile coordinate.
 if it returns 0, it means that the tile is empty.
 This method requires the the tile map has not been previously released (eg. don't call [layer releaseMap])
 */
-(uint32_t) tileGIDAt:(CGPoint)tileCoordinate;

/** sets the tile gid (gid = tile global id) at a given tile coordinate.
 The Tile GID can be obtained by using the method "tileGIDAt" or by using the TMX editor -> Tileset Mgr +1.
 If a tile is already placed at that position, then it will be removed.
 */
-(void) setTileGID:(uint32_t)gid at:(CGPoint)tileCoordinate;

/** removes a tile at given tile coordinate */
-(void) removeTileAt:(CGPoint)tileCoordinate;

/** returns the position in pixels of a given tile coordinate */
-(CGPoint) positionAt:(CGPoint)tileCoordinate;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;

/** Creates the tiles */
-(void) setupTiles;

/** CCTMXLayer doesn't support adding a CCSprite manually.
 @warning addchild:z:tag: is not supported on CCTMXLayer. Instead of setTileGID:at:/tileAt:
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z tag:(NSInteger)tag;
@end
