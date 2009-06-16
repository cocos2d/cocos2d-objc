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

#import "GridAction.h"

/** Waves3D action */
@interface Waves3D : Grid3DAction
{
	int waves;
	float amplitude;
	float amplitudeRate;
}

@property float amplitude;
@property float amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** FlipX3D action */
@interface FlipX3D : Grid3DAction
{
}

/** creates the action with duration */
+(id) actionWithDuration:(ccTime)d;
/** initizlies the action with duration */
-(id) initWithDuration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** FlipY3D action */
@interface FlipY3D : FlipX3D
{
}

@end

////////////////////////////////////////////////////////////

/** Lens3D action */
@interface Lens3D : Grid3DAction
{
	CGPoint	position;
	float	radius;
	float	lensEffect;
	CGPoint	lastPosition;
}

/** lens effect. Defaults to 0.7 - 0 means no effect, 1 is very strong effect */
@property float lensEffect;
/** lens center position */
@property CGPoint position;

/** creates the action with center position, radius, a grid size and duration */
+(id)actionWithPosition:(CGPoint)pos radius:(float)r grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with center position, radius, a grid size and duration */
-(id)initWithPosition:(CGPoint)pos radius:(float)r grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** Ripple3D action */
@interface Ripple3D : Grid3DAction
{
	CGPoint	position;
	float	radius;
	int		waves;
	float	amplitude;
	float	amplitudeRate;
}

/** center position */
@property CGPoint position;
/** amplitude */
@property float amplitude;
/** amplitude rate */
@property float amplitudeRate;

/** creates the action with radius, number of waves, amplitude, a grid size and duration */
+(id)actionWithPosition:(CGPoint)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with radius, number of waves, amplitude, a grid size and duration */
-(id)initWithPosition:(CGPoint)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** Shaky3D action */
@interface Shaky3D : Grid3DAction
{
	int randrange;
	BOOL	shakeZ;
}

/** creates the action with a range, shake Z vertices, a grid and duration */
+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with a range, shake Z vertices, a grid and duration */
-(id)initWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** Liquid action */
@interface Liquid : Grid3DAction
{
	int waves;
	float amplitude;
	float amplitudeRate;
	
}

/** amplitude */
@property float amplitude;
/** amplitude rate */
@property float amplitudeRate;

/** creates the action with amplitude, a grid and duration */
+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with amplitude, a grid and duration */
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** Waves action */
@interface Waves : Grid3DAction
{
	int		waves;
	float	amplitude;
	float	amplitudeRate;
	BOOL	vertical;
	BOOL	horizontal;
}

/** amplitude */
@property float amplitude;
/** amplitude rate */
@property float amplitudeRate;

/** initializes the action with amplitude, horizontal sin, vertical sin, a grid and duration */
+(id)actionWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(ccGridSize)gridSize duration:(ccTime)d;
/** creates the action with amplitude, horizontal sin, vertical sin, a grid and duration */
-(id)initWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** Twirl action */
@interface Twirl : Grid3DAction
{
	CGPoint	position;
	int		twirls;
	float	amplitude;
	float	amplitudeRate;
}

/** twirl center */
@property CGPoint position;
/** amplitude */
@property float amplitude;
/** amplitude rate */
@property float amplitudeRate;

/** creates the action with center position, number of twirls, amplitude, a grid size and duration */
+(id)actionWithPosition:(CGPoint)pos twirls:(int)t amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with center position, number of twirls, amplitude, a grid size and duration */
-(id)initWithPosition:(CGPoint)pos twirls:(int)t amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end
