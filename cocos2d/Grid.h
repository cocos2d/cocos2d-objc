/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 On-Core
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <UIKit/UIKit.h>

#import "CocosNode.h"
#import "Camera.h"
#import "ccTypes.h"

@class Texture2D;
@class Grabber;

/** Base class for other
 */
@interface GridBase : NSObject
{
	BOOL		active;
	int			reuseGrid;
	ccGridSize	gridSize;
	Texture2D *	texture;
	CGPoint		step;
	Grabber *	grabber;
}

@property BOOL active;
@property int reuseGrid;
@property (readonly) ccGridSize gridSize;
@property CGPoint step;
@property (nonatomic, retain) Texture2D *texture;
@property (nonatomic, retain) Grabber *grabber;

-(id)initWithSize:(ccGridSize)gridSize;
-(void)beforeDraw;
-(void)afterDraw:(Camera*)camera;
-(void)blit;
-(void)reuse;

@end

////////////////////////////////////////////////////////////

/**
 Grid3D is a 3D grid implementation. Each vertex has 3 dimensions: x,y,z
 */
@interface Grid3D : GridBase
{
	GLvoid		*texCoordinates;
	GLvoid		*vertices;
	GLvoid		*originalVertices;
	GLushort	*indices;
}

/** creates a Grid3D (non-tiled) grid with a grid size */
+(id)gridWithSize:(ccGridSize)gridSize;
/** initizlies a Grid3D (non-tiled) grid with a grid size */
-(id)initWithSize:(ccGridSize)gridSize;

/** returns the vertex at a given position */
-(ccVertex3F)vertex:(ccGridSize)pos;
/** returns the original (non-transformed) vertex at a given position */
-(ccVertex3F)originalVertex:(ccGridSize)pos;
/** sets a new vertex at a given position */
-(void)setVertex:(ccGridSize)pos vertex:(ccVertex3F)vertex;

-(void)calculateVertexPoints;

@end

////////////////////////////////////////////////////////////

/**
 TiledGrid3D is a 3D grid implementation. It differs from Grid3D in that
 the tiles can be separated from the grid.
*/
@interface TiledGrid3D : GridBase
{
	GLvoid		*texCoordinates;
	GLvoid		*vertices;
	GLvoid		*originalVertices;
	GLushort	*indices;
}

/** creates a TiledGrid3D with a grid size */
+(id)gridWithSize:(ccGridSize)gridSize;
/** initializes a TiledGrid3D with a grid size */
-(id)initWithSize:(ccGridSize)gridSize;

/** returns the tile at the given position */
-(ccQuad3)tile:(ccGridSize)pos;
/** returns the original tile (untransformed) at the given position */
-(ccQuad3)originalTile:(ccGridSize)pos;
/** sets a new tile */
-(void)setTile:(ccGridSize)pos coords:(ccQuad3)coords;

-(void)calculateVertexPoints;

@end
