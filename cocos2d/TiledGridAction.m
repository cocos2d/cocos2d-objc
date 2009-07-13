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

#import "TiledGridAction.h"
#import "Director.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

typedef struct
{
	CGPoint	position;
	CGPoint	startPosition;
	ccGridSize	delta;
} Tile;


@implementation ShakyTiles3D

+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithRange:range shakeZ:shakeZ grid:gridSize duration:d] autorelease];
}

-(id)initWithRange:(int)range shakeZ:(BOOL)sz grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		randrange = range;
		shakeZ = sz;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			ccQuad3 coords = [self originalTile:ccg(i,j)];

			// X
			coords.bl.x += ( rand() % (randrange*2) ) - randrange;
			coords.br.x += ( rand() % (randrange*2) ) - randrange;
			coords.tl.x += ( rand() % (randrange*2) ) - randrange;
			coords.tr.x += ( rand() % (randrange*2) ) - randrange;

			// Y
			coords.bl.y += ( rand() % (randrange*2) ) - randrange;
			coords.br.y += ( rand() % (randrange*2) ) - randrange;
			coords.tl.y += ( rand() % (randrange*2) ) - randrange;
			coords.tr.y += ( rand() % (randrange*2) ) - randrange;

			if( shakeZ ) {
				coords.bl.z += ( rand() % (randrange*2) ) - randrange;
				coords.br.z += ( rand() % (randrange*2) ) - randrange;
				coords.tl.z += ( rand() % (randrange*2) ) - randrange;
				coords.tr.z += ( rand() % (randrange*2) ) - randrange;
			}
						
			[self setTile:ccg(i,j) coords:coords];
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation ShatteredTiles3D

+(id)actionWithRange:(int)range shatterZ:(BOOL)sz grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithRange:range shatterZ:sz grid:gridSize duration:d] autorelease];
}

-(id)initWithRange:(int)range shatterZ:(BOOL)sz grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		once = NO;
		randrange = range;
		shatterZ = sz;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	if ( once == NO )
	{
		for( i = 0; i < gridSize.x; i++ )
		{
			for( j = 0; j < gridSize.y; j++ )
			{
				ccQuad3 coords = [self originalTile:ccg(i,j)];
				
				// X
				coords.bl.x += ( rand() % (randrange*2) ) - randrange;
				coords.br.x += ( rand() % (randrange*2) ) - randrange;
				coords.tl.x += ( rand() % (randrange*2) ) - randrange;
				coords.tr.x += ( rand() % (randrange*2) ) - randrange;
				
				// Y
				coords.bl.y += ( rand() % (randrange*2) ) - randrange;
				coords.br.y += ( rand() % (randrange*2) ) - randrange;
				coords.tl.y += ( rand() % (randrange*2) ) - randrange;
				coords.tr.y += ( rand() % (randrange*2) ) - randrange;

				if( shatterZ ) {
					coords.bl.z += ( rand() % (randrange*2) ) - randrange;
					coords.br.z += ( rand() % (randrange*2) ) - randrange;				
					coords.tl.z += ( rand() % (randrange*2) ) - randrange;
					coords.tr.z += ( rand() % (randrange*2) ) - randrange;
				}
				
				[self setTile:ccg(i,j) coords:coords];
			}
		}
		
		once = YES;
	}
}

@end

////////////////////////////////////////////////////////////

@implementation ShuffleTiles

+(id)actionWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithSeed:s grid:gridSize duration:d] autorelease];
}

-(id)initWithSeed:(int)s grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		seed = s;
		tilesOrder = nil;
		tiles = nil;
	}
	
	return self;
}

-(void)dealloc
{
	if ( tilesOrder ) free(tilesOrder);
	if ( tiles ) free(tiles);
	[super dealloc];
}

-(void)shuffle:(int*)array count:(int)len
{
	int i;
	for( i = len - 1; i >= 0; i-- )
	{
		int j = rand() % (i+1);
		int v = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(ccGridSize)getDelta:(ccGridSize)pos
{
	CGPoint	pos2;
	
	int idx = pos.x * gridSize.y + pos.y;
	
	pos2.x = tilesOrder[idx] / (int)gridSize.y;
	pos2.y = tilesOrder[idx] % (int)gridSize.y;
	
	return ccg(pos2.x - pos.x, pos2.y - pos.y);
}

-(void)placeTile:(ccGridSize)pos tile:(Tile)t
{
	ccQuad3	coords = [self originalTile:pos];
	
	CGPoint step = [[target grid] step];
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

-(void)start
{
	[super start];
	
	if ( seed != -1 )
		srand(seed);
	
	tilesCount = gridSize.x * gridSize.y;
	tilesOrder = (int*)malloc(tilesCount*sizeof(int));
	int i, j;
	
	for( i = 0; i < tilesCount; i++ )
		tilesOrder[i] = i;
	
	[self shuffle:tilesOrder count:tilesCount];
	
	tiles = malloc(tilesCount*sizeof(Tile));
	Tile *tileArray = (Tile*)tiles;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			tileArray->position = ccp(i,j);
			tileArray->startPosition = ccp(i,j);
			tileArray->delta = [self getDelta:ccg(i,j)];
			tileArray++;
		}
	}
}

-(void)update:(ccTime)time
{
	int i, j;
	
	Tile *tileArray = (Tile*)tiles;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			tileArray->position = ccpMult( ccp(tileArray->delta.x, tileArray->delta.y), time);
			[self placeTile:ccg(i,j) tile:*tileArray];
			tileArray++;
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutTRTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult( ccp(gridSize.x,gridSize.y), time);
	if ( (n.x+n.y) == 0.0f )
		return 1.0f;
	return powf( (pos.x+pos.y) / (n.x+n.y), 6 );
}

-(void)turnOnTile:(ccGridSize)pos
{
	[self setTile:pos coords:[self originalTile:pos]];
}

-(void)turnOffTile:(ccGridSize)pos
{
	ccQuad3	coords;	
	bzero(&coords, sizeof(ccQuad3));
	[self setTile:pos coords:coords];
}

-(void)transformTile:(ccGridSize)pos distance:(float)distance
{
	ccQuad3	coords = [self originalTile:pos];
	CGPoint	step = [[target grid] step];
	
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
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			float distance = [self testFunc:ccg(i,j) time:time];
			if ( distance == 0 )
				[self turnOffTile:ccg(i,j)];
			else if ( distance < 1 )
				[self transformTile:ccg(i,j) distance:distance];
			else
				[self turnOnTile:ccg(i,j)];
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutBLTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(gridSize.x, gridSize.y), (1.0f-time));
	
	if ( (pos.x+pos.y) == 0 )
		return 1.0f;
	return powf( (n.x+n.y) / (pos.x+pos.y), 6 );
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutUpTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(gridSize.x, gridSize.y), time);
	if ( n.y == 0 )
		return 1.0f;
	return powf( pos.y / n.y, 6 );
}

-(void)transformTile:(ccGridSize)pos distance:(float)distance
{
	ccQuad3	coords = [self originalTile:pos];
	CGPoint step = [[target grid] step];
	
	coords.bl.y += (step.y / 2) * (1.0f - distance);
	coords.br.y += (step.y / 2) * (1.0f - distance);
	coords.tl.y -= (step.y / 2) * (1.0f - distance);
	coords.tr.y -= (step.y / 2) * (1.0f - distance);
	
	[self setTile:pos coords:coords];
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutDownTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(gridSize.x,gridSize.y), (1.0f - time));
	if ( pos.y == 0 )
		return 1.0f;
	return powf( n.y / pos.y, 6 );
}

@end

////////////////////////////////////////////////////////////

@implementation TurnOffTiles

+(id)actionWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithSeed:s grid:gridSize duration:d] autorelease];
}

-(id)initWithSeed:(int)s grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		seed = s;
		tilesOrder = nil;
	}
	
	return self;
}

-(void)dealloc
{
	if ( tilesOrder ) free(tilesOrder);
	[super dealloc];
}

-(void)shuffle:(int*)array count:(int)len
{
	int i;
	for( i = len - 1; i >= 0; i-- )
	{
		int j = rand() % (i+1);
		int v = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(void)turnOnTile:(ccGridSize)pos
{
	[self setTile:pos coords:[self originalTile:pos]];
}

-(void)turnOffTile:(ccGridSize)pos
{
	ccQuad3	coords;
	
	bzero(&coords, sizeof(ccQuad3));
	[self setTile:pos coords:coords];
}

-(void)start
{
	int i;
	
	[super start];
	
	if ( seed != -1 )
		srand(seed);
	
	tilesCount = gridSize.x * gridSize.y;
	tilesOrder = (int*)malloc(tilesCount*sizeof(int));

	for( i = 0; i < tilesCount; i++ )
		tilesOrder[i] = i;
	
	[self shuffle:tilesOrder count:tilesCount];
}

-(void)update:(ccTime)time
{
	int i, l, t;
	
	l = (int)(time * (float)tilesCount);
	
	for( i = 0; i < tilesCount; i++ )
	{
		t = tilesOrder[i];
		ccGridSize tilePos = ccg( t / gridSize.y, t % gridSize.y );
		
		if ( i < l )
			[self turnOffTile:tilePos];
		else
			[self turnOnTile:tilePos];
	}
}

@end

////////////////////////////////////////////////////////////

@implementation WavesTiles3D

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			ccQuad3 coords = [self originalTile:ccg(i,j)];
			
			coords.bl.z = (sinf(time*(CGFloat)M_PI*waves*2 + (coords.bl.y+coords.bl.x) * .01f) * amplitude * amplitudeRate );
			coords.br.z	= coords.bl.z;
			coords.tl.z = coords.bl.z;
			coords.tr.z = coords.bl.z;
			
			[self setTile:ccg(i,j) coords:coords];
		}
	}
}
@end

////////////////////////////////////////////////////////////

@implementation JumpTiles3D

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithJumps:(int)j amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithJumps:j amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithJumps:(int)j amplitude:(float)amp grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		jumps = j;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	float sinz =  (sinf((CGFloat)M_PI*time*jumps*2) * amplitude * amplitudeRate );
	float sinz2 = (sinf((CGFloat)M_PI*(time*jumps*2 + 1)) * amplitude * amplitudeRate );
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			ccQuad3 coords = [self originalTile:ccg(i,j)];
			
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
			
			[self setTile:ccg(i,j) coords:coords];
		}
	}
}
@end

////////////////////////////////////////////////////////////

@implementation SplitRows

+(id)actionWithRows:(int)r duration:(ccTime)d
{
	return [[[self alloc] initWithRows:r duration:d] autorelease];
}

-(id)initWithRows:(int)r duration:(ccTime)d
{
	return [super initWithSize:ccg(1,r) duration:d];
}

-(void)start
{
	[super start];
	winSize = [[Director sharedDirector] winSize];
}

-(void)update:(ccTime)time
{
	int j;
	
	for( j = 0; j < gridSize.y; j++ )
	{
		ccQuad3 coords = [self originalTile:ccg(0,j)];
		float	direction = 1;
		
		if ( (j % 2 ) == 0 )
			direction = -1;
		
		coords.bl.x += direction * winSize.width * time;
		coords.br.x += direction * winSize.width * time;
		coords.tl.x += direction * winSize.width * time;
		coords.tr.x += direction * winSize.width * time;
		
		[self setTile:ccg(0,j) coords:coords];
	}
}

@end

////////////////////////////////////////////////////////////

@implementation SplitCols

+(id)actionWithCols:(int)c duration:(ccTime)d
{
	return [[[self alloc] initWithCols:c duration:d] autorelease];
}

-(id)initWithCols:(int)c duration:(ccTime)d
{
	return [super initWithSize:ccg(c,1) duration:d];
}

-(void)start
{
	[super start];
	winSize = [[Director sharedDirector] winSize];
}

-(void)update:(ccTime)time
{
	int i;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		ccQuad3 coords = [self originalTile:ccg(i,0)];
		float	direction = 1;
		
		if ( (i % 2 ) == 0 )
			direction = -1;
		
		coords.bl.y += direction * winSize.height * time;
		coords.br.y += direction * winSize.height * time;
		coords.tl.y += direction * winSize.height * time;
		coords.tr.y += direction * winSize.height * time;
		
		[self setTile:ccg(i,0) coords:coords];
	}
}

@end
