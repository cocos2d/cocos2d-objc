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

#import "IntervalAction.h"
#import "InstantAction.h"
#import "Grid.h"

@class GridBase;

/** Base class for Grid actions */
@interface GridAction : IntervalAction
{
	ccGridSize gridSize;
}

@property ccGridSize gridSize;

/** creates the action with size and duration */
+(id) actionWithSize:(ccGridSize)size duration:(ccTime)d;
/** initializes the action with size and duration */
-(id) initWithSize:(ccGridSize)gridSize duration:(ccTime)d;
/** returns the grid */
-(GridBase *)grid;

@end

////////////////////////////////////////////////////////////

/** Base class for Grid3D actions.
 Grid3D actions can modify a non-tiled grid.
 */
@interface Grid3DAction : GridAction
{
	
}

/** returns the vertex than belongs to certain position in the grid */
-(ccVertex3F)vertex:(ccGridSize)pos;
/** returns the non-transformed vertex than belongs to certain position in the grid */
-(ccVertex3F)originalVertex:(ccGridSize)pos;
/** sets a new vertex to a certain position of the grid */
-(void)setVertex:(ccGridSize)pos vertex:(ccVertex3F)vertex;

@end

////////////////////////////////////////////////////////////

/** Base class for TiledGrid3D actions */
@interface TiledGrid3DAction : GridAction
{
	
}

/** returns the tile that belongs to a certain position of the grid */
-(ccQuad3)tile:(ccGridSize)pos;
/** returns the non-transformed tile that belongs to a certain position of the grid */
-(ccQuad3)originalTile:(ccGridSize)pos;
/** sets a new tile to a certain position of the grid */
-(void)setTile:(ccGridSize)pos coords:(ccQuad3)coords;

@end

////////////////////////////////////////////////////////////

/** AccelDeccelAmplitude action */
@interface AccelDeccelAmplitude : IntervalAction
{
	float			rate;
	IntervalAction *other;
}

/** amplitude rate */
@property float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(Action*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(Action*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** AccelAmplitude action */
@interface AccelAmplitude : IntervalAction
{
	float			rate;
	IntervalAction *other;
}

/** amplitude rate */
@property float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(Action*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(Action*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** DeccelAmplitude action */
@interface DeccelAmplitude : IntervalAction
{
	float			rate;
	IntervalAction *other;
}

/** amplitude rate */
@property float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(Action*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(Action*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** StopGrid action.
 Don't call this action if another grid action is active.
 Call if you want to remove the the grid effect. Example:
 [Sequence actions:[Lens ...], [StopGrid action], nil];
 */
@interface StopGrid : InstantAction
{
}
@end

////////////////////////////////////////////////////////////

/** ReuseGrid action */
@interface ReuseGrid : InstantAction
{
	int t;
}
/** creates an action with the number of times that the current grid will be reused */
+(id) actionWithTimes: (int) times;
/** initializes an action with the number of times that the current grid will be reused */
-(id) initWithTimes: (int) times;
@end
