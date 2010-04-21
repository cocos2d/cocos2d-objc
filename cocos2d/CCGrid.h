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

#import "CCNode.h"
#import "CCCamera.h"
#import "ccTypes.h"

@class CCTexture2D;
@class CCGrabber;

/** Base class for other
 */
@interface CCGridBase : NSObject
{
	BOOL		active_;
	int			reuseGrid_;
	ccGridSize	gridSize_;
	CCTexture2D *texture_;
	CGPoint		step_;
	CCGrabber	*grabber_;
	BOOL		isTextureFlipped_;
}

/** wheter or not the grid is active */
@property (nonatomic,readwrite) BOOL active;
/** number of times that the grid will be reused */
@property (nonatomic,readwrite) int reuseGrid;
/** size of the grid */
@property (nonatomic,readonly) ccGridSize gridSize;
/** pixels between the grids */
@property (nonatomic,readwrite) CGPoint step;
/** texture used */
@property (nonatomic, retain) CCTexture2D *texture;
/** grabber used */
@property (nonatomic, retain) CCGrabber *grabber;
/** is texture flipped */
@property (nonatomic, readwrite) BOOL isTextureFlipped;

+(id) gridWithSize:(ccGridSize)gridSize texture:(CCTexture2D*)texture flippedTexture:(BOOL)flipped;
+(id) gridWithSize:(ccGridSize)gridSize;

-(id) initWithSize:(ccGridSize)gridSize texture:(CCTexture2D*)texture flippedTexture:(BOOL)flipped;
-(id)initWithSize:(ccGridSize)gridSize;
-(void)beforeDraw;
-(void)afterDraw:(CCNode*)target;
-(void)blit;
-(void)reuse;

-(void)calculateVertexPoints;

@end

////////////////////////////////////////////////////////////

/**
 CCGrid3D is a 3D grid implementation. Each vertex has 3 dimensions: x,y,z
 */
@interface CCGrid3D : CCGridBase
{
	GLvoid		*texCoordinates;
	GLvoid		*vertices;
	GLvoid		*originalVertices;
	GLushort	*indices;
}

/** returns the vertex at a given position */
-(ccVertex3F)vertex:(ccGridSize)pos;
/** returns the original (non-transformed) vertex at a given position */
-(ccVertex3F)originalVertex:(ccGridSize)pos;
/** sets a new vertex at a given position */
-(void)setVertex:(ccGridSize)pos vertex:(ccVertex3F)vertex;

@end

////////////////////////////////////////////////////////////

/**
 CCTiledGrid3D is a 3D grid implementation. It differs from Grid3D in that
 the tiles can be separated from the grid.
*/
@interface CCTiledGrid3D : CCGridBase
{
	GLvoid		*texCoordinates;
	GLvoid		*vertices;
	GLvoid		*originalVertices;
	GLushort	*indices;
}

/** returns the tile at the given position */
-(ccQuad3)tile:(ccGridSize)pos;
/** returns the original tile (untransformed) at the given position */
-(ccQuad3)originalTile:(ccGridSize)pos;
/** sets a new tile */
-(void)setTile:(ccGridSize)pos coords:(ccQuad3)coords;

@end
