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

@interface GridAction : IntervalAction
{
	cpVect grid;
	cpVect size;
}

@property cpVect size;

/** creates the action */
+(id) actionWithSize:(cpVect)size duration:(ccTime)d;
-(id) initWithSize:(cpVect)gridSize duration:(ccTime)d;

-(GridBase *)getGrid;

@end

////////////////////////////////////////////////////////////

@interface Grid3DAction : GridAction
{
	
}

-(GridBase *)getGrid;
-(ccVertex3D)getVertex:(cpVect)pos;
-(ccVertex3D)getOriginalVertex:(cpVect)pos;
-(void)setVertex:(cpVect)pos vertex:(ccVertex3D)vertex;

@end

////////////////////////////////////////////////////////////

@interface TiledGrid3DAction : GridAction
{
	
}

-(GridBase *)getGrid;
-(ccQuad3)getTile:(cpVect)pos;
-(ccQuad3)getOriginalTile:(cpVect)pos;
-(void)setTile:(cpVect)pos coords:(ccQuad3)coords;

@end

////////////////////////////////////////////////////////////

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

@interface StopGrid : InstantAction
{
}
@end

////////////////////////////////////////////////////////////

@interface ReuseGrid : InstantAction
{
	int t;
}
/** creates a Place action with a position */
+(id) actionWithTimes: (int) times;
/** Initializes a Place action with a position */
-(id) initWithTimes: (int) times;
@end
