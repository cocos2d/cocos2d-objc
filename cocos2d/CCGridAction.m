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
#import "CCDirector.h"

#pragma mark -
#pragma mark GridAction

@implementation CCGridAction

@synthesize gridSize;

+(id) actionWithSize:(ccGridSize)size duration:(ccTime)d
{
	return [[[self alloc] initWithSize:size duration:d ] autorelease];
}

-(id) initWithSize:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		gridSize = gSize;
	}
	
	return self;
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	CCGridBase *newgrid = [self grid];
	
	CCNode *t = (CCNode*) target;
	CCGridBase *targetGrid = [t grid];
	
	if ( targetGrid && targetGrid.reuseGrid > 0 )
	{
		if ( targetGrid.active && targetGrid.gridSize.x == gridSize.x && targetGrid.gridSize.y == gridSize.y && [targetGrid isKindOfClass:[newgrid class]] )
		{
			[targetGrid reuse];
		}
		else
		{
			[NSException raise:@"GridBase" format:@"Cannot reuse grid"];
		}
	}
	else
	{
		if ( targetGrid && targetGrid.active )
			targetGrid.active = NO;
		t.grid = newgrid;
		t.grid.active = YES;
	}	
}

-(CCGridBase *)grid
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
	return nil;
}

- (CCIntervalAction*) reverse
{
	return [CCReverseTime actionWithAction:self];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithSize:gridSize duration:duration];
	return copy;
}
@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Grid3DAction

@implementation CCGrid3DAction

-(CCGridBase *)grid
{
	return [CCGrid3D gridWithSize:gridSize];
}

-(ccVertex3F)vertex:(ccGridSize)pos
{
	CCGrid3D *g = (CCGrid3D *)[target grid];
	return [g vertex:pos];
}

-(ccVertex3F)originalVertex:(ccGridSize)pos
{
	CCGrid3D *g = (CCGrid3D *)[target grid];
	return [g originalVertex:pos];
}

-(void)setVertex:(ccGridSize)pos vertex:(ccVertex3F)vertex
{
	CCGrid3D *g = (CCGrid3D *)[target grid];
	return [g setVertex:pos vertex:vertex];
}
@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark TiledGrid3DAction

@implementation CCTiledGrid3DAction

-(CCGridBase *)grid
{
	return [CCTiledGrid3D gridWithSize:gridSize];
}

-(ccQuad3)tile:(ccGridSize)pos
{
	CCTiledGrid3D *g = (CCTiledGrid3D *)[target grid];
	return [g tile:pos];
}

-(ccQuad3)originalTile:(ccGridSize)pos
{
	CCTiledGrid3D *g = (CCTiledGrid3D *)[target grid];
	return [g originalTile:pos];
}

-(void)setTile:(ccGridSize)pos coords:(ccQuad3)coords
{
	CCTiledGrid3D *g = (CCTiledGrid3D *)[target grid];
	[g setTile:pos coords:coords];
}

@end

////////////////////////////////////////////////////////////

@interface CCIntervalAction (Amplitude)
-(void)setAmplitudeRate:(CGFloat)amp;
-(CGFloat)getAmplitudeRate;
@end

@implementation CCIntervalAction (Amplitude)
-(void)setAmplitudeRate:(CGFloat)amp
{
	[NSException raise:@"IntervalAction (Amplitude)" format:@"Abstract class needs implementation"];
}

-(CGFloat)getAmplitudeRate
{
	[NSException raise:@"IntervalAction (Amplitude)" format:@"Abstract class needs implementation"];
	return 0;
}
@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark AccelDeccelAmplitude

@implementation CCAccelDeccelAmplitude

@synthesize rate;

+(id)actionWithAction:(CCAction*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(CCAction *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		rate = 1.0f;
		other = [action retain];
	}
	
	return self;
}

-(void)dealloc
{
	[other release];
	[super dealloc];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other startWithTarget:target];
}

-(void) update: (ccTime) time
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

- (CCIntervalAction*) reverse
{
	return [CCAccelDeccelAmplitude actionWithAction:[other reverse] duration:duration];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark AccelAmplitude

@implementation CCAccelAmplitude

@synthesize rate;

+(id)actionWithAction:(CCAction*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(CCAction *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		rate = 1.0f;
		other = [action retain];
	}
	
	return self;
}

-(void)dealloc
{
	[other release];
	[super dealloc];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other startWithTarget:target];
}

-(void) update: (ccTime) time
{
	[other setAmplitudeRate:powf(time, rate)];
	[other update:time];
}

- (CCIntervalAction*) reverse
{
	return [CCAccelAmplitude actionWithAction:[other reverse] duration:self.duration];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark DeccelAmplitude

@implementation CCDeccelAmplitude

@synthesize rate;

+(id)actionWithAction:(CCAction*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(CCAction *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		rate = 1.0f;
		other = [action retain];
	}
	
	return self;
}

-(void)dealloc
{
	[other release];
	[super dealloc];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other startWithTarget:target];
}

-(void) update: (ccTime) time
{
	[other setAmplitudeRate:powf((1-time), rate)];
	[other update:time];
}

- (CCIntervalAction*) reverse
{
	return [CCDeccelAmplitude actionWithAction:[other reverse] duration:self.duration];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark StopGrid

@implementation CCStopGrid

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	if ( [[self target] grid] && [[[self target] grid] active] ) {
		[[[self target] grid] setActive: NO];
		
//		[[self target] setGrid: nil];
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark ReuseGrid

@implementation CCReuseGrid

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

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	CCNode *myTarget = (CCNode*) [self target];
	if ( myTarget.grid && myTarget.grid.active )
		myTarget.grid.reuseGrid += t;
}

@end
