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

+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(CGSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithRange:range shakeZ:shakeZ grid:gridSize duration:d] autorelease];
}

-(id)initWithRange:(int)range shakeZ:(BOOL)sz grid:(CGSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		randrange = range;
		shakeZ = sz;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithRange:randrange shakeZ:shakeZ grid:gridSize_ duration:duration_];
	return copy;
}


-(void)update:(ccTime)time
{
	int i, j;

	for( i = 0; i < gridSize_.width; i++ )
	{
		for( j = 0; j < gridSize_.height; j++ )
		{
			ccQuad3 coords = [self originalTile:ccp(i,j)];

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

			[self setTile:ccp(i,j) coords:coords];
		}
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCShatteredTiles3D

@implementation CCShatteredTiles3D

+(id)actionWithRange:(int)range shatterZ:(BOOL)sz grid:(CGSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithRange:range shatterZ:sz grid:gridSize duration:d] autorelease];
}

-(id)initWithRange:(int)range shatterZ:(BOOL)sz grid:(CGSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		once = NO;
		randrange = range;
		shatterZ = sz;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithRange:randrange shatterZ:shatterZ grid:gridSize_ duration:duration_];
	return copy;
}


-(void)update:(ccTime)time
{
	int i, j;

	if ( once == NO )
	{
		for( i = 0; i < gridSize_.width; i++ )
		{
			for( j = 0; j < gridSize_.height; j++ )
			{
				ccQuad3 coords = [self originalTile:ccp(i,j)];

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

				[self setTile:ccp(i,j) coords:coords];
			}
		}

		once = YES;
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCShuffleTiles

@implementation CCShuffleTiles

+(id)actionWithSeed:(int)s grid:(CGSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithSeed:s grid:gridSize duration:d] autorelease];
}

-(id)initWithSeed:(int)s grid:(CGSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		seed = s;
		tilesOrder = nil;
		tiles = nil;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithSeed:seed grid:gridSize_ duration:duration_];
	return copy;
}


-(void)dealloc
{
	if ( tilesOrder ) free(tilesOrder);
	if ( tiles ) free(tiles);
	[super dealloc];
}

-(void)shuffle:(int*)array count:(NSUInteger)len
{
	NSInteger i;
	for( i = len - 1; i >= 0; i-- )
	{
		NSInteger j = rand() % (i+1);
		int v = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(CGSize)getDelta:(CGSize)pos
{
	CGPoint	pos2;

	NSInteger idx = pos.width * gridSize_.height + pos.height;

	pos2.x = tilesOrder[idx] / (int)gridSize_.height;
	pos2.y = tilesOrder[idx] % (int)gridSize_.height;

	return CGSizeMake(pos2.x - pos.width, pos2.y - pos.height);
}

-(void)placeTile:(CGPoint)pos tile:(Tile)t
{
	ccQuad3	coords = [self originalTile:pos];

	CGPoint step = [[target_ grid] step];
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

	if ( seed != -1 )
		srand(seed);

	tilesCount = gridSize_.width * gridSize_.height;
	tilesOrder = (int*)malloc(tilesCount*sizeof(int));
	int i, j;

	for( i = 0; i < tilesCount; i++ )
		tilesOrder[i] = i;

	[self shuffle:tilesOrder count:tilesCount];

	tiles = malloc(tilesCount*sizeof(Tile));
	Tile *tileArray = (Tile*)tiles;

	for( i = 0; i < gridSize_.width; i++ )
	{
		for( j = 0; j < gridSize_.height; j++ )
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

	Tile *tileArray = (Tile*)tiles;

	for( i = 0; i < gridSize_.width; i++ )
	{
		for( j = 0; j < gridSize_.height; j++ )
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
	CGPoint	n = ccpMult( ccp(gridSize_.width,gridSize_.height), time);
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
	CGPoint	step = [[target_ grid] step];

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

	for( i = 0; i < gridSize_.width; i++ )
	{
		for( j = 0; j < gridSize_.height; j++ )
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
	CGPoint	n = ccpMult(ccp(gridSize_.width, gridSize_.height), (1.0f-time));
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
	CGPoint	n = ccpMult(ccp(gridSize_.width, gridSize_.height), time);
	if ( n.y == 0 )
		return 1.0f;

	return powf( pos.height / n.y, 6 );
}

-(void)transformTile:(CGPoint)pos distance:(float)distance
{
	ccQuad3	coords = [self originalTile:pos];
	CGPoint step = [[target_ grid] step];

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
	CGPoint	n = ccpMult(ccp(gridSize_.width,gridSize_.height), (1.0f - time));
	if ( pos.height == 0 )
		return 1.0f;

	return powf( n.y / pos.height, 6 );
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark TurnOffTiles

@implementation CCTurnOffTiles

+(id)actionWithSeed:(int)s grid:(CGSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithSeed:s grid:gridSize duration:d] autorelease];
}

-(id)initWithSeed:(int)s grid:(CGSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		seed = s;
		tilesOrder = nil;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithSeed:seed grid:gridSize_ duration:duration_];
	return copy;
}

-(void)dealloc
{
	if ( tilesOrder ) free(tilesOrder);
	[super dealloc];
}

-(void)shuffle:(int*)array count:(NSUInteger)len
{
	NSInteger i;
	for( i = len - 1; i >= 0; i-- )
	{
		NSInteger j = rand() % (i+1);
		int v = array[i];
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
	int i;

	[super startWithTarget:aTarget];

	if ( seed != -1 )
		srand(seed);

	tilesCount = gridSize_.width * gridSize_.height;
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
		CGPoint tilePos = ccp( (NSUInteger)(t / gridSize_.height),
							  t % (NSUInteger)gridSize_.height );

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

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithWaves:waves amplitude:amplitude grid:gridSize_ duration:duration_];
	return copy;
}


-(void)update:(ccTime)time
{
	int i, j;

	for( i = 0; i < gridSize_.width; i++ )
	{
		for( j = 0; j < gridSize_.height; j++ )
		{
			ccQuad3 coords = [self originalTile:ccp(i,j)];

			coords.bl.z = (sinf(time*(CGFloat)M_PI*waves*2 + (coords.bl.y+coords.bl.x) * .01f) * amplitude * amplitudeRate );
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

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithJumps:(int)j amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithJumps:j amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithJumps:(int)j amplitude:(float)amp grid:(CGSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		jumps = j;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithJumps:jumps amplitude:amplitude grid:gridSize_ duration:duration_];
	return copy;
}


-(void)update:(ccTime)time
{
	int i, j;

	float sinz =  (sinf((CGFloat)M_PI*time*jumps*2) * amplitude * amplitudeRate );
	float sinz2 = (sinf((CGFloat)M_PI*(time*jumps*2 + 1)) * amplitude * amplitudeRate );

	for( i = 0; i < gridSize_.width; i++ )
	{
		for( j = 0; j < gridSize_.height; j++ )
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

+(id)actionWithRows:(int)r duration:(ccTime)d
{
	return [[[self alloc] initWithRows:r duration:d] autorelease];
}

-(id)initWithRows:(int)r duration:(ccTime)d
{
	rows = r;
	return [super initWithSize:CGSizeMake(1,r) duration:d];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithRows:rows duration:duration_];
	return copy;
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	winSize = [[CCDirector sharedDirector] winSizeInPixels];
}

-(void)update:(ccTime)time
{
	int j;

	for( j = 0; j < gridSize_.height; j++ )
	{
		ccQuad3 coords = [self originalTile:ccp(0,j)];
		float	direction = 1;

		if ( (j % 2 ) == 0 )
			direction = -1;

		coords.bl.x += direction * winSize.width * time;
		coords.br.x += direction * winSize.width * time;
		coords.tl.x += direction * winSize.width * time;
		coords.tr.x += direction * winSize.width * time;

		[self setTile:ccp(0,j) coords:coords];
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCSplitCols

@implementation CCSplitCols

+(id)actionWithCols:(int)c duration:(ccTime)d
{
	return [[[self alloc] initWithCols:c duration:d] autorelease];
}

-(id)initWithCols:(int)c duration:(ccTime)d
{
	cols = c;
	return [super initWithSize:CGSizeMake(c,1) duration:d];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCGridAction *copy = [[[self class] allocWithZone:zone] initWithCols:cols duration:duration_];
	return copy;
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	winSize = [[CCDirector sharedDirector] winSizeInPixels];
}

-(void)update:(ccTime)time
{
	int i;

	for( i = 0; i < gridSize_.width; i++ )
	{
		ccQuad3 coords = [self originalTile:ccp(i,0)];
		float	direction = 1;

		if ( (i % 2 ) == 0 )
			direction = -1;

		coords.bl.y += direction * winSize.height * time;
		coords.br.y += direction * winSize.height * time;
		coords.tl.y += direction * winSize.height * time;
		coords.tr.y += direction * winSize.height * time;

		[self setTile:ccp(i,0) coords:coords];
	}
}

@end
