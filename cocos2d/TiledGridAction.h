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

/** ShakyTiles3D action */
@interface ShakyTiles3D : TiledGrid3DAction
{
	int randrange;
}

+(id)actionWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** ShatteredTiles3D action */
@interface ShatteredTiles3D : TiledGrid3DAction
{
	int randrange;
	BOOL once;
}

+(id)actionWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** ShuffleTiles action */
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

/** FadeOutTRTiles action */
@interface FadeOutTRTiles : TiledGrid3DAction
{
}
@end

////////////////////////////////////////////////////////////

/** FadeOutBLTiles action */
@interface FadeOutBLTiles : FadeOutTRTiles
{
}
@end

////////////////////////////////////////////////////////////

/** FadeOutUpTiles action */
@interface FadeOutUpTiles : FadeOutTRTiles
{
}
@end

////////////////////////////////////////////////////////////

/** FadeOutDownTiles action */
@interface FadeOutDownTiles : FadeOutUpTiles
{
}
@end

////////////////////////////////////////////////////////////

/** TurnOffTiles action */
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

/** WavesTiles3D action */
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

/** JumpTiles3D action */
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

/** SplitRows action */
@interface SplitRows : TiledGrid3DAction
{
}

+(id)actionWithRows:(int)r duration:(ccTime)d;
-(id)initWithRows:(int)r duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** SplitCols action */
@interface SplitCols : TiledGrid3DAction
{
}

+(id)actionWithCols:(int)c duration:(ccTime)d;
-(id)initWithCols:(int)c duration:(ccTime)d;

@end
