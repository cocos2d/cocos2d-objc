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

#import "CCIntervalAction.h"
#import "CCInstantAction.h"
#import "CCGrid.h"

@class CCGridBase;

/** Base class for Grid actions */
@interface CCGridAction : CCIntervalAction
{
	ccGridSize gridSize;
}

/** size of the grid */
@property (nonatomic,readwrite) ccGridSize gridSize;

/** creates the action with size and duration */
+(id) actionWithSize:(ccGridSize)size duration:(ccTime)d;
/** initializes the action with size and duration */
-(id) initWithSize:(ccGridSize)gridSize duration:(ccTime)d;
/** returns the grid */
-(CCGridBase *)grid;

@end

////////////////////////////////////////////////////////////

/** Base class for CCGrid3D actions.
 Grid3D actions can modify a non-tiled grid.
 */
@interface CCGrid3DAction : CCGridAction
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

/** Base class for CCTiledGrid3D actions */
@interface CCTiledGrid3DAction : CCGridAction
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

/** CCAccelDeccelAmplitude action */
@interface CCAccelDeccelAmplitude : CCIntervalAction
{
	float			rate;
	CCIntervalAction *other;
}

/** amplitude rate */
@property (nonatomic,readwrite) float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(CCAction*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(CCAction*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCAccelAmplitude action */
@interface CCAccelAmplitude : CCIntervalAction
{
	float			rate;
	CCIntervalAction *other;
}

/** amplitude rate */
@property (nonatomic,readwrite) float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(CCAction*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(CCAction*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCDeccelAmplitude action */
@interface CCDeccelAmplitude : CCIntervalAction
{
	float			rate;
	CCIntervalAction *other;
}

/** amplitude rate */
@property (nonatomic,readwrite) float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(CCAction*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(CCAction*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCStopGrid action.
 Don't call this action if another grid action is active.
 Call if you want to remove the the grid effect. Example:
 [Sequence actions:[Lens ...], [StopGrid action], nil];
 */
@interface CCStopGrid : CCInstantAction
{
}
@end

////////////////////////////////////////////////////////////

/** CCReuseGrid action */
@interface CCReuseGrid : CCInstantAction
{
	int t;
}
/** creates an action with the number of times that the current grid will be reused */
+(id) actionWithTimes: (int) times;
/** initializes an action with the number of times that the current grid will be reused */
-(id) initWithTimes: (int) times;
@end
