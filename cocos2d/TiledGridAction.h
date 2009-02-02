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

#import "GridAction.h"

@interface ShakyTiles3D : TiledGrid3DAction
{
	int randrange;
}

+(id)actionWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface ShatteredTiles3D : TiledGrid3DAction
{
	int randrange;
	BOOL once;
}

+(id)actionWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface ShuffleTiles : TiledGrid3DAction
{
	int	seed;
	int tilesCount;
	int *tilesOrder;
	void *tiles;
}

+(id)actionWithSeed:(int)s grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithSeed:(int)s grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface FadeOutTRTiles : TiledGrid3DAction
{
}
@end

////////////////////////////////////////////////////////////

@interface FadeOutBLTiles : FadeOutTRTiles
{
}
@end

////////////////////////////////////////////////////////////

@interface FadeOutUpTiles : FadeOutTRTiles
{
}
@end

////////////////////////////////////////////////////////////

@interface FadeOutDownTiles : FadeOutUpTiles
{
}
@end

////////////////////////////////////////////////////////////

@interface TurnOffTiles : TiledGrid3DAction
{
	int	seed;
	int tilesCount;
	int *tilesOrder;
}

+(id)actionWithSeed:(int)s grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithSeed:(int)s grid:(cpVect)gridSize duration:(ccTime)d;
@end

////////////////////////////////////////////////////////////

@interface WavesTiles3D : TiledGrid3DAction
{
	int waves;
	float amplitude;
	float amplitudeRate;
}

@property float amplitude;
@property float amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface JumpTiles3D : TiledGrid3DAction
{
	int jumps;
	float amplitude;
	float amplitudeRate;
}

@property float amplitude;
@property float amplitudeRate;

+(id)actionWithJumps:(int)j amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithJumps:(int)j amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface SplitRows : TiledGrid3DAction
{
}

+(id)actionWithRows:(int)r duration:(ccTime)d;
-(id)initWithRows:(int)r duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface SplitCols : TiledGrid3DAction
{
}

+(id)actionWithCols:(int)c duration:(ccTime)d;
-(id)initWithCols:(int)c duration:(ccTime)d;

@end
