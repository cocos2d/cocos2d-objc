/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

@class Texture2D;
@class Grabber;

@interface GridBase : NSObject
{
	BOOL		active;
	int			reuseGrid;
	cpVect		grid;
	Texture2D *	texture;
	cpVect		step;
	Grabber *	grabber;
}

@property BOOL active;
@property int reuseGrid;
@property cpVect grid;
@property cpVect step;
@property (nonatomic, retain) Texture2D *texture;
@property (nonatomic, retain) Grabber *grabber;

-(id)initWithSize:(cpVect)gridSize;
-(void)beforeDraw;
-(void)afterDraw:(Camera*)camera;
-(void)blit;
-(void)reuse;

@end

////////////////////////////////////////////////////////////

/*
 'Grid3D' is a 3D grid implementation. Each vertex has 3 dimensions: x,y,z
*/

typedef struct
{
	float x;
	float y;
	float z;
} ccVertex3D;

@interface Grid3D : GridBase
{
	GLvoid		*texCoordinates;
	GLvoid		*vertices;
	GLvoid		*originalVertices;
	GLushort	*indices;
}

+(id)gridWithSize:(cpVect)gridSize;
-(id)initWithSize:(cpVect)gridSize;

-(ccVertex3D)getVertex:(cpVect)pos;
-(ccVertex3D)getOriginalVertex:(cpVect)pos;
-(void)setVertex:(cpVect)pos vertex:(ccVertex3D)vertex;

-(void)calculate_vertex_points;

@end

////////////////////////////////////////////////////////////

/*
 'TiledGrid3D' is a 3D grid implementation. It differs from `Grid3D` in that
 the tiles can be separated from the grid. 
*/

@interface TiledGrid3D : GridBase
{
	GLvoid		*texCoordinates;
	GLvoid		*vertices;
	GLvoid		*originalVertices;
	GLushort	*indices;
}

+(id)gridWithSize:(cpVect)gridSize;
-(id)initWithSize:(cpVect)gridSize;

-(ccQuad3)getTile:(cpVect)pos;
-(ccQuad3)getOriginalTile:(cpVect)pos;
-(void)setTile:(cpVect)pos coords:(ccQuad3)coords;

-(void)calculate_vertex_points;

@end
