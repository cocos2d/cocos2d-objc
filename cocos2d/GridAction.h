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

#import "IntervalAction.h"
#import "InstantAction.h"
#import "Grid.h"

@class GridBase;

/** Base class for Grid actions */
@interface GridAction : IntervalAction
{
	ccGrid grid;
	ccGrid size;
}

@property ccGrid size;

/** creates the action with size and duration */
+(id) actionWithSize:(ccGrid)size duration:(ccTime)d;
/** initializes the action with size and duration */
-(id) initWithSize:(ccGrid)gridSize duration:(ccTime)d;
/** returns the grid */
-(GridBase *)getGrid;

@end

////////////////////////////////////////////////////////////

/** Base class for Grid3D actions */
@interface Grid3DAction : GridAction
{
	
}

-(GridBase *)getGrid;
-(ccVertex3D)getVertex:(ccGrid)pos;
-(ccVertex3D)getOriginalVertex:(ccGrid)pos;
-(void)setVertex:(ccGrid)pos vertex:(ccVertex3D)vertex;

@end

////////////////////////////////////////////////////////////

/** Base class for TiledGrid3D actions */
@interface TiledGrid3DAction : GridAction
{
	
}

-(GridBase *)getGrid;
-(ccQuad3)getTile:(ccGrid)pos;
-(ccQuad3)getOriginalTile:(ccGrid)pos;
-(void)setTile:(ccGrid)pos coords:(ccQuad3)coords;

@end

////////////////////////////////////////////////////////////

/** AccelDeccelAmplitude action */
@interface AccelDeccelAmplitude : IntervalAction
{
	float			rate;
	IntervalAction *other;
}

@property float rate;

+(id)actionWithAction:(Action*)action duration:(ccTime)d;
-(id)initWithAction:(Action*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** AccelAmplitude action */
@interface AccelAmplitude : IntervalAction
{
	float			rate;
	IntervalAction *other;
}

@property float rate;

+(id)actionWithAction:(Action*)action duration:(ccTime)d;
-(id)initWithAction:(Action*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** DeccelAmplitude action */
@interface DeccelAmplitude : IntervalAction
{
	float			rate;
	IntervalAction *other;
}

@property float rate;

+(id)actionWithAction:(Action*)action duration:(ccTime)d;
-(id)initWithAction:(Action*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** StopGrid action */
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
/** creates a Place action with a position */
+(id) actionWithTimes: (int) times;
/** Initializes a Place action with a position */
-(id) initWithTimes: (int) times;
@end
