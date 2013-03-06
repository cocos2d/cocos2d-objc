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


#import "CCActionTiledGrid.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

typedef struct
{
	CGPoint	position;
	CGPoint	startPosition;
	CGSize	delta;
} Tile;

#pragma mark -
#pragma mark ShakyTiles3D

@implementation CCShakyTiles3D

+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shakeZ:(BOOL)shakeZ
{
	return [[[self alloc] initWithDuration:duration size:gridSize range:range shakeZ:shakeZ] autorelease];
}

-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shakeZ:(BOOL)shakeZ
{
	if ( (self = [super initWithDuration:duration size:gridSize]) )
	{
		_randrange = range;
		_shakeZ = shakeZ;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone:zone] initWithDuration:_duration size:_gridSize range:_randrange shakeZ:_shakeZ];
}


-(void)update:(ccTime)time
{
	int i, j;

	for( i = 0; i < _gridSize.width; i++ )
	{
		for( j = 0; j < _gridSize.height; j++ )
		{
			ccQuad3 coords = [self originalTile:ccp(i,j)];

			// X
			coords.bl.x += ( rand() % (_randrange*2) ) - _randrange;
			coords.br.x += ( rand() % (_randrange*2) ) - _randrange;
			coords.tl.x += ( rand() % (_randrange*2) ) - _randrange;
			coords.tr.x += ( rand() % (_randrange*2) ) - _randrange;

			// Y
			coords.bl.y += ( rand() % (_randrange*2) ) - _randrange;
			coords.br.y += ( rand() % (_randrange*2) ) - _randrange;
			coords.tl.y += ( rand() % (_randrange*2) ) - _randrange;
			coords.tr.y += ( rand() % (_randrange*2) ) - _randrange;

			if( _shakeZ ) {
				coords.bl.z += ( rand() % (_randrange*2) ) - _randrange;
				coords.br.z += ( rand() % (_randrange*2) ) - _randrange;
				coords.tl.z += ( rand() % (_randrange*2) ) - _randrange;
				coords.tr.z += ( rand() % (_randrange*2) ) - _randrange;
			}

			[self setTile:ccp(i,j) coords:coords];
		}
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCShatteredTiles3D

@implementation CCShatteredTiles3D

+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shatterZ:(BOOL)shatterZ
{
	return [[[self alloc] initWithDuration:duration size:gridSize range:range shatterZ:shatterZ] autorelease];
}

-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shatterZ:(BOOL)shatterZ

{
	if ( (self = [super initWithDuration:duration size:gridSize]) )
	{
		_once = NO;
		_randrange = range;
		_shatterZ = shatterZ;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone:zone] initWithDuration:_duration size:_gridSize range:_randrange shatterZ:_shatterZ];
}


-(void)update:(ccTime)time
{
	int i, j;

	if ( _once == NO )
	{
		for( i = 0; i < _gridSize.width; i++ )
		{
			for( j = 0; j < _gridSize.height; j++ )
			{
				ccQuad3 coords = [self originalTile:ccp(i,j)];

				// X
				coords.bl.x += ( rand() % (_randrange*2) ) - _randrange;
				coords.br.x += ( rand() % (_randrange*2) ) - _randrange;
				coords.tl.x += ( rand() % (_randrange*2) ) - _randrange;
				coords.tr.x += ( rand() % (_randrange*2) ) - _randrange;

				// Y
				coords.bl.y += ( rand() % (_randrange*2) ) - _randrange;
				coords.br.y += ( rand() % (_randrange*2) ) - _randrange;
				coords.tl.y += ( rand() % (_randrange*2) ) - _randrange;
				coords.tr.y += ( rand() % (_randrange*2) ) - _randrange;

				if( _shatterZ ) {
					coords.bl.z += ( rand() % (_randrange*2) ) - _randrange;
					coords.br.z += ( rand() % (_randrange*2) ) - _randrange;
					coords.tl.z += ( rand() % (_randrange*2) ) - _randrange;
					coords.tr.z += ( rand() % (_randrange*2) ) - _randrange;
				}

				[self setTile:ccp(i,j) coords:coords];
			}
		}

		_once = YES;
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCShuffleTiles

@implementation CCShuffleTiles

+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed
{
	return [[[self alloc] initWithDuration:duration size:gridSize seed:seed] autorelease];
}

-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed
{
	if ( (self = [super initWithDuration:duration size:gridSize]) )
	{
		_seed = seed;
		_tilesOrder = nil;
		_tiles = nil;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone:zone] initWithDuration:_duration size:_gridSize seed:_seed];
}


-(void)dealloc
{
	if(_tilesOrder)
		free(_tilesOrder);
	if(_tiles)
		free(_tiles);
	[super dealloc];
}

-(void)shuffle:(NSUInteger*)array count:(NSUInteger)len
{
	NSInteger i;
	for( i = len - 1; i >= 0; i-- )
	{
		NSInteger j = rand() % (i+1);
		NSUInteger v = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(CGSize)getDelta:(CGSize)pos
{
	CGPoint	pos2;

	NSUInteger idx = pos.width * _gridSize.height + pos.height;

	pos2.x = _tilesOrder[idx] / (NSUInteger)_gridSize.height;
	pos2.y = _tilesOrder[idx] % (NSUInteger)_gridSize.height;

	return CGSizeMake(pos2.x - pos.width, pos2.y - pos.height);
}

-(void)placeTile:(CGPoint)pos tile:(Tile)t
{
	ccQuad3	coords = [self originalTile:pos];

	CGPoint step = [[_target grid] step];
	coords.bl.x += (int)(t.position.x * step.x);
	coords.bl.y += (int)(t.position.y * step.y);

	coords.br.x += (int)(t.position.x * step.x);
	coords.br.y += (int)(t.position.y * step.y);

	coords.tl.x += (int)(t.position.x * step.x);
	coords.tl.y += (int)(t.position.y * step.y);

	coords.tr.x += (int)(t.position.x * step.x);
	coords.tr.y += (int)(t.position.y * step.y);

	[self setTile:pos coords:coords];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	if ( _seed != -1 )
		srand(_seed);

	_tilesCount = _gridSize.width * _gridSize.height;
	_tilesOrder = (NSUInteger*)malloc(_tilesCount*sizeof(NSUInteger));
	int i, j;

	for( i = 0; i < _tilesCount; i++ )
		_tilesOrder[i] = i;

	[self shuffle:_tilesOrder count:_tilesCount];

	_tiles = malloc(_tilesCount*sizeof(Tile));
	Tile *tileArray = (Tile*)_tiles;

	for( i = 0; i < _gridSize.width; i++ )
	{
		for( j = 0; j < _gridSize.height; j++ )
		{
			tileArray->position = ccp(i,j);
			tileArray->startPosition = ccp(i,j);
			tileArray->delta = [self getDelta:CGSizeMake(i,j)];
			tileArray++;
		}
	}
}

-(void)update:(ccTime)time
{
	int i, j;

	Tile *tileArray = (Tile*)_tiles;

	for( i = 0; i < _gridSize.width; i++ )
	{
		for( j = 0; j < _gridSize.height; j++ )
		{
			tileArray->position = ccpMult( ccp(tileArray->delta.width, tileArray->delta.height), time);
			[self placeTile:ccp(i,j) tile:*tileArray];
			tileArray++;
		}
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCFadeOutTRTiles

@implementation CCFadeOutTRTiles

-(float)testFunc:(CGSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult( ccp(_gridSize.width,_gridSize.height), time);
	if ( (n.x+n.y) == 0.0f )
		return 1.0f;

	return powf( (pos.width+pos.height) / (n.x+n.y), 6 );
}

-(void)turnOnTile:(CGPoint)pos
{
	[self setTile:pos coords:[self originalTile:pos]];
}

-(void)turnOffTile:(CGPoint)pos
{
	ccQuad3	coords;
	bzero(&coords, sizeof(ccQuad3));
	[self setTile:pos coords:coords];
}

-(void)transformTile:(CGPoint)pos distance:(float)distance
{
	ccQuad3	coords = [self originalTile:pos];
	CGPoint	step = [[_target grid] step];

	coords.bl.x += (step.x / 2) * (1.0f - distance);
	coords.bl.y += (step.y / 2) * (1.0f - distance);

	coords.br.x -= (step.x / 2) * (1.0f - distance);
	coords.br.y += (step.y / 2) * (1.0f - distance);

	coords.tl.x += (step.x / 2) * (1.0f - distance);
	coords.tl.y -= (step.y / 2) * (1.0f - distance);

	coords.tr.x -= (step.x / 2) * (1.0f - distance);
	coords.tr.y -= (step.y / 2) * (1.0f - distance);

	[self setTile:pos coords:coords];
}

-(void)update:(ccTime)time
{
	int i, j;

	for( i = 0; i < _gridSize.width; i++ )
	{
		for( j = 0; j < _gridSize.height; j++ )
		{
			float distance = [self testFunc:CGSizeMake(i,j) time:time];
			if ( distance == 0 )
				[self turnOffTile:ccp(i,j)];
			else if ( distance < 1 )
				[self transformTile:ccp(i,j) distance:distance];
			else
				[self turnOnTile:ccp(i,j)];
		}
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCFadeOutBLTiles

@implementation CCFadeOutBLTiles

-(float)testFunc:(CGSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(_gridSize.width, _gridSize.height), (1.0f-time));
	if ( (pos.width+pos.height) == 0 )
		return 1.0f;

	return powf( (n.x+n.y) / (pos.width+pos.height), 6 );
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCFadeOutUpTiles

@implementation CCFadeOutUpTiles

-(float)testFunc:(CGSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(_gridSize.width, _gridSize.height), time);
	if ( n.y == 0 )
		return 1.0f;

	return powf( pos.height / n.y, 6 );
}

-(void)transformTile:(CGPoint)pos distance:(float)distance
{
	ccQuad3	coords = [self originalTile:pos];
	CGPoint step = [[_target grid] step];

	coords.bl.y += (step.y / 2) * (1.0f - distance);
	coords.br.y += (step.y / 2) * (1.0f - distance);
	coords.tl.y -= (step.y / 2) * (1.0f - distance);
	coords.tr.y -= (step.y / 2) * (1.0f - distance);

	[self setTile:pos coords:coords];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCFadeOutDownTiles

@implementation CCFadeOutDownTiles

-(float)testFunc:(CGSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(_gridSize.width,_gridSize.height), (1.0f - time));
	if ( pos.height == 0 )
		return 1.0f;

	return powf( n.y / pos.height, 6 );
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark TurnOffTiles

@implementation CCTurnOffTiles

+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed
{
	return [[[self alloc] initWithDuration:duration size:gridSize seed:seed] autorelease];
}

-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed
{
	if ( (self = [super initWithDuration:duration size:gridSize]) )
	{
		_seed = seed;
		_tilesOrder = nil;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone:zone] initWithDuration:_duration size:_gridSize seed:_seed];
}

-(void)dealloc
{
	if(_tilesOrder)
		free(_tilesOrder);
	[super dealloc];
}

-(void)shuffle:(NSUInteger*)array count:(NSUInteger)len
{
	NSInteger i;
	for( i = len - 1; i >= 0; i-- )
	{
		NSUInteger j = rand() % (i+1);
		NSUInteger v = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(void)turnOnTile:(CGPoint)pos
{
	[self setTile:pos coords:[self originalTile:pos]];
}

-(void)turnOffTile:(CGPoint)pos
{
	ccQuad3	coords;

	bzero(&coords, sizeof(ccQuad3));
	[self setTile:pos coords:coords];
}

-(void)startWithTarget:(id)aTarget
{
	NSUInteger i;

	[super startWithTarget:aTarget];

	if ( _seed != -1 )
		srand(_seed);

	_tilesCount = _gridSize.width * _gridSize.height;
	_tilesOrder = (NSUInteger*)malloc(_tilesCount*sizeof(NSUInteger));

	for( i = 0; i < _tilesCount; i++ )
		_tilesOrder[i] = i;

	[self shuffle:_tilesOrder count:_tilesCount];
}

-(void)update:(ccTime)time
{
	NSUInteger i, l, t;

	l = (NSUInteger)(time * (float)_tilesCount);

	for( i = 0; i < _tilesCount; i++ )
	{
		t = _tilesOrder[i];
		CGPoint tilePos = ccp( (NSUInteger)(t / _gridSize.height),
							  t % (NSUInteger)_gridSize.height );

		if ( i < l )
			[self turnOffTile:tilePos];
		else
			[self turnOnTile:tilePos];
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCWavesTiles3D

@implementation CCWavesTiles3D

@synthesize amplitude = _amplitude;
@synthesize amplitudeRate = _amplitudeRate;

+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize waves:(NSUInteger)wav amplitude:(float)amp
{
	return [[[self alloc] initWithDuration:duration size:gridSize waves:wav amplitude:amp] autorelease];
}

-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize waves:(NSUInteger)wav amplitude:(float)amp
{
	if ( (self = [super initWithDuration:duration size:gridSize]) )
	{
		_waves = wav;
		_amplitude = amp;
		_amplitudeRate = 1.0f;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithDuration:_duration size:_gridSize waves:_waves amplitude:_amplitude];
	return copy;
}


-(void)update:(ccTime)time
{
	int i, j;

	for( i = 0; i < _gridSize.width; i++ )
	{
		for( j = 0; j < _gridSize.height; j++ )
		{
			ccQuad3 coords = [self originalTile:ccp(i,j)];

			coords.bl.z = (sinf(time*(CGFloat)M_PI*_waves*2 + (coords.bl.y+coords.bl.x) * .01f) * _amplitude * _amplitudeRate );
			coords.br.z	= coords.bl.z;
			coords.tl.z = coords.bl.z;
			coords.tr.z = coords.bl.z;

			[self setTile:ccp(i,j) coords:coords];
		}
	}
}
@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCJumpTiles3D

@implementation CCJumpTiles3D

@synthesize amplitude = _amplitude;
@synthesize amplitudeRate = _amplitudeRate;

+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize jumps:(NSUInteger)numberOfJumps amplitude:(float)amplitude
{
	return [[[self alloc] initWithDuration:duration size:gridSize jumps:numberOfJumps amplitude:amplitude] autorelease];
}

-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize jumps:(NSUInteger)numberOfJumps amplitude:(float)amplitude
{
	if ( (self = [super initWithDuration:duration size:gridSize]) )
	{
		_jumps = numberOfJumps;
		_amplitude = amplitude;
		_amplitudeRate = 1.0f;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithDuration:_duration size:_gridSize jumps:_jumps amplitude:_amplitude];
	return copy;
}


-(void)update:(ccTime)time
{
	int i, j;

	float sinz =  (sinf((CGFloat)M_PI*time*_jumps*2) * _amplitude * _amplitudeRate );
	float sinz2 = (sinf((CGFloat)M_PI*(time*_jumps*2 + 1)) * _amplitude * _amplitudeRate );

	for( i = 0; i < _gridSize.width; i++ )
	{
		for( j = 0; j < _gridSize.height; j++ )
		{
			ccQuad3 coords = [self originalTile:ccp(i,j)];

			if ( ((i+j) % 2) == 0 )
			{
				coords.bl.z += sinz;
				coords.br.z += sinz;
				coords.tl.z += sinz;
				coords.tr.z += sinz;
			}
			else
			{
				coords.bl.z += sinz2;
				coords.br.z += sinz2;
				coords.tl.z += sinz2;
				coords.tr.z += sinz2;
			}

			[self setTile:ccp(i,j) coords:coords];
		}
	}
}
@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark SplitRows

@implementation CCSplitRows

+(id)actionWithDuration:(ccTime)duration rows:(NSUInteger)rows
{
	return [[[self alloc] initWithDuration:duration rows:rows] autorelease];
}

-(id)initWithDuration:(ccTime)duration rows:(NSUInteger)rows
{
	if( (self=[super initWithDuration:duration size:CGSizeMake(1,rows)]) )
		_rows = rows;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone:zone] initWithDuration:_duration rows:_rows];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_winSize = [[CCDirector sharedDirector] winSizeInPixels];
}

-(void)update:(ccTime)time
{
	NSUInteger j;

	for( j = 0; j < _gridSize.height; j++ )
	{
		ccQuad3 coords = [self originalTile:ccp(0,j)];
		float	direction = 1;

		if ( (j % 2 ) == 0 )
			direction = -1;

		coords.bl.x += direction * _winSize.width * time;
		coords.br.x += direction * _winSize.width * time;
		coords.tl.x += direction * _winSize.width * time;
		coords.tr.x += direction * _winSize.width * time;

		[self setTile:ccp(0,j) coords:coords];
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCSplitCols

@implementation CCSplitCols

+(id)actionWithDuration:(ccTime)duration cols:(NSUInteger)cols
{
	return [[[self alloc] initWithDuration:duration cols:cols] autorelease];
}

-(id)initWithDuration:(ccTime)duration cols:(NSUInteger)cols
{
	if( (self=[super initWithDuration:duration size:CGSizeMake(cols,1)]) )
		_cols = cols;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone:zone] initWithDuration:_duration cols:_cols];
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_winSize = [[CCDirector sharedDirector] winSizeInPixels];
}

-(void)update:(ccTime)time
{
	NSUInteger i;

	for( i = 0; i < _gridSize.width; i++ )
	{
		ccQuad3 coords = [self originalTile:ccp(i,0)];
		float	direction = 1;

		if ( (i % 2 ) == 0 )
			direction = -1;

		coords.bl.y += direction * _winSize.height * time;
		coords.br.y += direction * _winSize.height * time;
		coords.tl.y += direction * _winSize.height * time;
		coords.tr.y += direction * _winSize.height * time;

		[self setTile:ccp(i,0) coords:coords];
	}
}

@end
