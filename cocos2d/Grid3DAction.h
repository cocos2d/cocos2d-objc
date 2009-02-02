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

@interface Waves3D : Grid3DAction
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

@interface FlipX3D : Grid3DAction
{
}

@end

////////////////////////////////////////////////////////////

@interface FlipY3D : Grid3DAction
{
}

@end

////////////////////////////////////////////////////////////

@interface Lens3D : Grid3DAction
{
	cpVect	position;
	float	radius;
	float	lensEffect;
	cpVect	lastPosition;
}

// Defaults to 0.7 - 0 means no effect, 1 is very strong effect
@property float lensEffect;
@property cpVect position;

+(id)actionWithPosition:(cpVect)pos radius:(float)r grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithPosition:(cpVect)pos radius:(float)r grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface Ripple3D : Grid3DAction
{
	cpVect	position;
	float	radius;
	int		waves;
	float	amplitude;
	float	amplitudeRate;
}

@property cpVect position;
@property float amplitude;
@property float amplitudeRate;

+(id)actionWithPosition:(cpVect)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithPosition:(cpVect)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface Shaky3D : Grid3DAction
{
	int randrange;
}

+(id)actionWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithRange:(int)range grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface Liquid : Grid3DAction
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

@interface Waves : Grid3DAction
{
	int		waves;
	float	amplitude;
	float	amplitudeRate;
	BOOL	vertical;
	BOOL	horizontal;
}

@property float amplitude;
@property float amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(cpVect)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

@interface Twirl : Grid3DAction
{
	cpVect	position;
	int		twirls;
	float	amplitude;
	float	amplitudeRate;
}

@property cpVect position;
@property float amplitude;
@property float amplitudeRate;

+(id)actionWithPosition:(cpVect)pos twirls:(int)t amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;
-(id)initWithPosition:(cpVect)pos twirls:(int)t amplitude:(float)amp grid:(cpVect)gridSize duration:(ccTime)d;

@end
