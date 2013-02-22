/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CCActionGrid.h"
#import "CCDirector.h"

#pragma mark -
#pragma mark GridAction

@implementation CCGridAction

@synthesize gridSize = _gridSize;

+(id) actionWithDuration:(ccTime)duration size:(CGSize)gridSize;
{
	return [[[self alloc] initWithDuration:duration size:gridSize] autorelease];
}

-(id) initWithDuration:(ccTime)duration size:(CGSize)gridSize;
{
	if ( (self = [super initWithDuration:duration]) )
	{
		_gridSize = gridSize;
	}

	return self;
}

-(void)startWithTarget:(id)target
{
	[super startWithTarget:target];

	CCGridBase *newgrid = [self grid];

	CCNode *t = (CCNode*) target;
	CCGridBase *targetGrid = [t grid];

	if ( targetGrid && targetGrid.reuseGrid > 0 )
	{
		if ( targetGrid.active && targetGrid.gridSize.width == _gridSize.width && targetGrid.gridSize.height == _gridSize.height && [targetGrid isKindOfClass:[newgrid class]] )
			[targetGrid reuse];
		else
			[NSException raise:@"GridBase" format:@"Cannot reuse grid"];
	}
	else
	{
		if ( targetGrid && targetGrid.active )
			targetGrid.active = NO;

		[t setGrid: newgrid];
		t.grid.active = YES;
	}
}

-(CCGridBase *)grid
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
	return nil;
}

- (CCActionInterval*) reverse
{
	return [CCReverseTime actionWithAction:self];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithDuration:_duration size:_gridSize];
	return copy;
}
@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Grid3DAction

@implementation CCGrid3DAction

-(CCGridBase *)grid
{
	return [CCGrid3D gridWithSize:_gridSize];
}

-(ccVertex3F)vertex:(CGPoint)pos
{
	CCGrid3D *g = (CCGrid3D *)[_target grid];
	return [g vertex:pos];
}

-(ccVertex3F)originalVertex:(CGPoint)pos
{
	CCGrid3D *g = (CCGrid3D *)[_target grid];
	return [g originalVertex:pos];
}

-(void)setVertex:(CGPoint)pos vertex:(ccVertex3F)vertex
{
	CCGrid3D *g = (CCGrid3D *)[_target grid];
	[g setVertex:pos vertex:vertex];
}
@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark TiledGrid3DAction

@implementation CCTiledGrid3DAction

-(CCGridBase *)grid
{
	return [CCTiledGrid3D gridWithSize:_gridSize];
}

-(ccQuad3)tile:(CGPoint)pos
{
	CCTiledGrid3D *g = (CCTiledGrid3D *)[_target grid];
	return [g tile:pos];
}

-(ccQuad3)originalTile:(CGPoint)pos
{
	CCTiledGrid3D *g = (CCTiledGrid3D *)[_target grid];
	return [g originalTile:pos];
}

-(void)setTile:(CGPoint)pos coords:(ccQuad3)coords
{
	CCTiledGrid3D *g = (CCTiledGrid3D *)[_target grid];
	[g setTile:pos coords:coords];
}

@end

////////////////////////////////////////////////////////////

@interface CCActionInterval (Amplitude)
-(void)setAmplitudeRate:(CGFloat)amp;
-(CGFloat)getAmplitudeRate;
@end

@implementation CCActionInterval (Amplitude)
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

@synthesize rate=_rate;

+(id)actionWithAction:(CCAction*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(CCAction *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		_rate = 1.0f;
		_other = (CCActionInterval*)[action retain];
	}

	return self;
}

-(void)dealloc
{
	[_other release];
	[super dealloc];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_other startWithTarget:_target];
}

-(void) update: (ccTime) time
{
	float f = time*2;

	if (f > 1)
	{
		f -= 1;
		f = 1 - f;
	}

	[_other setAmplitudeRate:powf(f, _rate)];
	[_other update:time];
}

- (CCActionInterval*) reverse
{
	return [CCAccelDeccelAmplitude actionWithAction:[_other reverse] duration:_duration];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark AccelAmplitude

@implementation CCAccelAmplitude

@synthesize rate=_rate;

+(id)actionWithAction:(CCAction*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(CCAction *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		_rate = 1.0f;
		_other = (CCActionInterval*)[action retain];
	}

	return self;
}

-(void)dealloc
{
	[_other release];
	[super dealloc];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_other startWithTarget:_target];
}

-(void) update: (ccTime) time
{
	[_other setAmplitudeRate:powf(time, _rate)];
	[_other update:time];
}

- (CCActionInterval*) reverse
{
	return [CCAccelAmplitude actionWithAction:[_other reverse] duration:self.duration];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark DeccelAmplitude

@implementation CCDeccelAmplitude

@synthesize rate=_rate;

+(id)actionWithAction:(CCAction*)action duration:(ccTime)d
{
	return [[[self alloc] initWithAction:action duration:d ] autorelease];
}

-(id)initWithAction:(CCAction *)action duration:(ccTime)d
{
	if ( (self = [super initWithDuration:d]) )
	{
		_rate = 1.0f;
		_other = (CCActionInterval*)[action retain];
	}

	return self;
}

-(void)dealloc
{
	[_other release];
	[super dealloc];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_other startWithTarget:_target];
}

-(void) update: (ccTime) time
{
	[_other setAmplitudeRate:powf((1-time), _rate)];
	[_other update:time];
}

- (CCActionInterval*) reverse
{
	return [CCDeccelAmplitude actionWithAction:[_other reverse] duration:self.duration];
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
		_times = times;

	return self;
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	CCNode *myTarget = (CCNode*) [self target];
	if ( myTarget.grid && myTarget.grid.active )
		myTarget.grid.reuseGrid += _times;
}

@end
