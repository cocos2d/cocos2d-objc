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
#import "Director.h"

@implementation GridAction

@synthesize size;

+(id) actionWithSize:(cpVect)size duration:(ccTime)d
{
	return [[[self alloc] initWithSize:size duration:d ] autorelease];
}

-(id) initWithSize:(cpVect)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		grid = gridSize;
	}
	
	return self;
}

-(void)start
{
	[super start];

	GridBase *newgrid = [self getGrid];
	
	if ( target.grid && target.grid.reuseGrid > 0 )
	{
		if ( target.grid.active && target.grid.grid.x == grid.x && target.grid.grid.y == grid.y && [target.grid isKindOfClass:[newgrid class]] )
		{
			[target.grid reuse];
		}
		else
		{
			[NSException raise:@"GridBase" format:@"Cannot reuse grid"];
		}
	}
	else
	{
		if ( target.grid && target.grid.active )
			target.grid.active = NO;
		target.grid = newgrid;
		target.grid.active = YES;
	}
	
	CGSize	win = [[Director sharedDirector] winSize];
	
	size.x = win.width;
	size.y = win.height;
}

-(GridBase *)getGrid
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
	return nil;
}

- (IntervalAction*) reverse
{
	return [ReverseTime actionWithAction:self];
}
@end

////////////////////////////////////////////////////////////

@implementation Grid3DAction

-(GridBase *)getGrid
{
	return [Grid3D gridWithSize:grid];
}

-(ccVertex3D)getVertex:(cpVect)pos
{
	Grid3D *g = (Grid3D *)target.grid;
	return [g getVertex:pos];
}

-(ccVertex3D)getOriginalVertex:(cpVect)pos
{
	Grid3D *g = (Grid3D *)target.grid;
	return [g getOriginalVertex:pos];
}

-(void)setVertex:(cpVect)pos vertex:(ccVertex3D)vertex
{
	Grid3D *g = (Grid3D *)target.grid;
	return [g setVertex:pos vertex:vertex];
}

@end

////////////////////////////////////////////////////////////

@implementation TiledGrid3DAction

-(GridBase *)getGrid
{
	return [TiledGrid3D gridWithSize:grid];
}

-(ccQuad3)getTile:(cpVect)pos
{
	TiledGrid3D *g = (TiledGrid3D *)target.grid;
	return [g getTile:pos];
}

-(ccQuad3)getOriginalTile:(cpVect)pos
{
	TiledGrid3D *g = (TiledGrid3D *)target.grid;
	return [g getOriginalTile:pos];
}

-(void)setTile:(cpVect)pos coords:(ccQuad3)coords
{
	TiledGrid3D *g = (TiledGrid3D *)target.grid;
	[g setTile:pos coords:coords];
}

@end

////////////////////////////////////////////////////////////

@interface IntervalAction (Amplitude)
-(void)setAmplitudeRate:(cpFloat)amp;
-(cpFloat)getAmplitudeRate;
@end

@implementation IntervalAction (Amplitude)
-(void)setAmplitudeRate:(cpFloat)amp
{
	[NSException raise:@"IntervalAction (Amplitude)" format:@"Abstract class needs implementation"];
}

-(cpFloat)getAmplitudeRate
{
	[NSException raise:@"IntervalAction (Amplitude)" format:@"Abstract class needs implementation"];
	return 0;
}
@end

////////////////////////////////////////////////////////////

@implementation AccelDeccelAmplitude

@synthesize rate;

+(id)actionWithAction:(Action*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(Action *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		rate = 1.0;
		other = [action retain];
	}
	
	return self;
}

-(void)dealloc
{
	[other release];
	[super dealloc];
}

-(void)start
{
	[super start];
	other.target = self.target;
	[other start];
}

-(void) update: (ccTime) time;
{
	float f = time*2;
	
	if (f > 1)
	{
		f -= 1;
		f = 1 - f;
	}
	
	[other setAmplitudeRate:powf(f, rate)];
	[other update:time];
}

- (IntervalAction*) reverse
{
	return [AccelDeccelAmplitude actionWithAction:[other reverse] duration:self.duration];
}

@end

////////////////////////////////////////////////////////////

@implementation AccelAmplitude

@synthesize rate;

+(id)actionWithAction:(Action*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(Action *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		rate = 1.0;
		other = [action retain];
	}
	
	return self;
}

-(void)dealloc
{
	[other release];
	[super dealloc];
}

-(void)start
{
	[super start];
	other.target = self.target;
	[other start];
}

-(void) update: (ccTime) time;
{
	[other setAmplitudeRate:powf(time, rate)];
	[other update:time];
}

- (IntervalAction*) reverse
{
	return [AccelAmplitude actionWithAction:[other reverse] duration:self.duration];
}

@end

////////////////////////////////////////////////////////////

@implementation DeccelAmplitude

@synthesize rate;

+(id)actionWithAction:(Action*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(Action *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		rate = 1.0;
		other = [action retain];
	}
	
	return self;
}

-(void)dealloc
{
	[other release];
	[super dealloc];
}

-(void)start
{
	[super start];
	other.target = self.target;
	[other start];
}

-(void) update: (ccTime) time;
{
	[other setAmplitudeRate:powf((1-time), rate)];
	[other update:time];
}

- (IntervalAction*) reverse
{
	return [DeccelAmplitude actionWithAction:[other reverse] duration:self.duration];
}

@end

////////////////////////////////////////////////////////////

@implementation StopGrid

-(void)start
{
	[super start];

	if ( self.target.grid && self.target.grid.active )
		self.target.grid.active = NO;
}

@end

////////////////////////////////////////////////////////////

@implementation ReuseGrid

+(id)actionWithTimes:(int)times
{
	return [[[self alloc] initWithTimes:times ] autorelease];
}

-(id)initWithTimes:(int)times
{
	if ( (self = [super init]) )
	{
		t = times;
	}
	
	return self;
}

-(void)start
{
	[super start];

	if ( self.target.grid && self.target.grid.active )
		self.target.grid.reuseGrid += t;
}

@end
