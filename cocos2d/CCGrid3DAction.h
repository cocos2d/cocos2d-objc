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

#import "CCGridAction.h"

/** CCWaves3D action */
@interface CCWaves3D : CCGrid3DAction
{
	int waves;
	float amplitude;
	float amplitudeRate;
}

/** amplitude of the wave */
@property (nonatomic,readwrite) float amplitude;
/** amplitude rate of the wave */
@property (nonatomic,readwrite) float amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCFlipX3D action */
@interface CCFlipX3D : CCGrid3DAction
{
}

/** creates the action with duration */
+(id) actionWithDuration:(ccTime)d;
/** initizlies the action with duration */
-(id) initWithDuration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCFlipY3D action */
@interface CCFlipY3D : CCFlipX3D
{
}

@end

////////////////////////////////////////////////////////////

/** CCLens3D action */
@interface CCLens3D : CCGrid3DAction
{
	CGPoint	position;
	float	radius;
	float	lensEffect;
	CGPoint	lastPosition;
}

/** lens effect. Defaults to 0.7 - 0 means no effect, 1 is very strong effect */
@property (nonatomic,readwrite) float lensEffect;
/** lens center position */
@property (nonatomic,readwrite) CGPoint position;

/** creates the action with center position, radius, a grid size and duration */
+(id)actionWithPosition:(CGPoint)pos radius:(float)r grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with center position, radius, a grid size and duration */
-(id)initWithPosition:(CGPoint)pos radius:(float)r grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCRipple3D action */
@interface CCRipple3D : CCGrid3DAction
{
	CGPoint	position;
	float	radius;
	int		waves;
	float	amplitude;
	float	amplitudeRate;
}

/** center position */
@property (nonatomic,readwrite) CGPoint position;
/** amplitude */
@property (nonatomic,readwrite) float amplitude;
/** amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** creates the action with radius, number of waves, amplitude, a grid size and duration */
+(id)actionWithPosition:(CGPoint)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with radius, number of waves, amplitude, a grid size and duration */
-(id)initWithPosition:(CGPoint)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCShaky3D action */
@interface CCShaky3D : CCGrid3DAction
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

/** CCLiquid action */
@interface CCLiquid : CCGrid3DAction
{
	int waves;
	float amplitude;
	float amplitudeRate;
	
}

/** amplitude */
@property (nonatomic,readwrite) float amplitude;
/** amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** creates the action with amplitude, a grid and duration */
+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with amplitude, a grid and duration */
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCWaves action */
@interface CCWaves : CCGrid3DAction
{
	int		waves;
	float	amplitude;
	float	amplitudeRate;
	BOOL	vertical;
	BOOL	horizontal;
}

/** amplitude */
@property (nonatomic,readwrite) float amplitude;
/** amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** initializes the action with amplitude, horizontal sin, vertical sin, a grid and duration */
+(id)actionWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(ccGridSize)gridSize duration:(ccTime)d;
/** creates the action with amplitude, horizontal sin, vertical sin, a grid and duration */
-(id)initWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCTwirl action */
@interface CCTwirl : CCGrid3DAction
{
	CGPoint	position;
	int		twirls;
	float	amplitude;
	float	amplitudeRate;
}

/** twirl center */
@property (nonatomic,readwrite) CGPoint position;
/** amplitude */
@property (nonatomic,readwrite) float amplitude;
/** amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** creates the action with center position, number of twirls, amplitude, a grid size and duration */
+(id)actionWithPosition:(CGPoint)pos twirls:(int)t amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with center position, number of twirls, amplitude, a grid size and duration */
-(id)initWithPosition:(CGPoint)pos twirls:(int)t amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end
