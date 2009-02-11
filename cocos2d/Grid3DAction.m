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

#import "Grid3DAction.h"

@implementation Waves3D

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gridSize duration:d]) )
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
	
	for( i = 0; i < (grid.x+1); i++ )
	{
		for( j = 0; j < (grid.y+1); j++ )
		{
			ccVertex3D	v = [self getOriginalVertex:ccg(i,j)];
			v.z += (sinf((cpFloat)M_PI*time*waves*2 + (v.y+v.x) * .01f) * amplitude * amplitudeRate);
			[self setVertex:ccg(i,j) vertex:v];
		}
	}
}
@end

////////////////////////////////////////////////////////////

@implementation FlipX3D

-(id)initWithSize:(ccGrid)gridSize duration:(ccTime)d
{
	if ( gridSize.x != 1 || gridSize.y != 1 )
	{
		[NSException raise:@"FlipX3D" format:@"Grid size must be (1,1)"];
	}
	
	return [super initWithSize:gridSize duration:d];
}

-(void)update:(ccTime)time
{
	cpFloat angle = (cpFloat)M_PI * time; // 180 degrees
	cpFloat mz = sinf( angle );
	angle = angle / 2.0f;     // x calculates degrees from 0 to 90
	cpFloat mx = cosf( angle );
	
	ccVertex3D	v0, v1, v, diff;
	
	v0 = [self getOriginalVertex:ccg(1,1)];
	v1 = [self getOriginalVertex:ccg(0,0)];
	
	cpFloat	x0 = v0.x;
	cpFloat	x1 = v1.x;
	cpFloat x;
	ccGrid	a, b, c, d;
	
	if ( x0 > x1 )
	{
		// Normal Grid
		a = ccg(0,0);
		b = ccg(0,1);
		c = ccg(1,0);
		d = ccg(1,1);
		x = x0;
	}
	else
	{
		// Reversed Grid
		c = ccg(0,0);
		d = ccg(0,1);
		a = ccg(1,0);
		b = ccg(1,1);
		x = x1;
	}
	
	diff.x = ( x - x * mx );
	diff.z = fabsf( floorf( (x * mz) / 4.0f ) );
	
// bottom-left
	v = [self getOriginalVertex:a];
	v.x = diff.x;
	v.z += diff.z;
	[self setVertex:a vertex:v];
	
// upper-left
	v = [self getOriginalVertex:b];
	v.x = diff.x;
	v.z += diff.z;
	[self setVertex:b vertex:v];
	
// bottom-right
	v = [self getOriginalVertex:c];
	v.x -= diff.x;
	v.z -= diff.z;
	[self setVertex:c vertex:v];
	
// upper-right
	v = [self getOriginalVertex:d];
	v.x -= diff.x;
	v.z -= diff.z;
	[self setVertex:d vertex:v];
}

@end

////////////////////////////////////////////////////////////

@implementation FlipY3D

-(id)initWithSize:(ccGrid)gridSize duration:(ccTime)d
{
	if ( gridSize.x != 1 || gridSize.y != 1 )
	{
		[NSException raise:@"FlipX3D" format:@"Grid size must be (1,1)"];
	}
	
	return [super initWithSize:gridSize duration:d];
}

-(void)update:(ccTime)time
{
	cpFloat angle = (cpFloat)M_PI * time; // 180 degrees
	cpFloat mz = sinf( angle );
	angle = angle / 2.0f;     // x calculates degrees from 0 to 90
	cpFloat my = cosf( angle );
	
	ccVertex3D	v0, v1, v, diff;
	
	v0 = [self getOriginalVertex:ccg(1,1)];
	v1 = [self getOriginalVertex:ccg(0,0)];
	
	cpFloat	y0 = v0.y;
	cpFloat	y1 = v1.y;
	cpFloat y;
	ccGrid	a, b, c, d;
	
	if ( y0 > y1 )
	{
		// Normal Grid
		a = ccg(0,0);
		b = ccg(0,1);
		c = ccg(1,0);
		d = ccg(1,1);
		y = y0;
	}
	else
	{
		// Reversed Grid
		b = ccg(0,0);
		a = ccg(0,1);
		d = ccg(1,0);
		c = ccg(1,1);
		y = y1;
	}
	
	diff.y = y - y * my;
	diff.z = fabsf( floorf( (y * mz) / 4.0f ) );
	
	// bottom-left
	v = [self getOriginalVertex:a];
	v.y = diff.y;
	v.z += diff.z;
	[self setVertex:a vertex:v];
	
	// upper-left
	v = [self getOriginalVertex:b];
	v.y -= diff.y;
	v.z -= diff.z;
	[self setVertex:b vertex:v];
	
	// bottom-right
	v = [self getOriginalVertex:c];
	v.y = diff.y;
	v.z += diff.z;
	[self setVertex:c vertex:v];
	
	// upper-right
	v = [self getOriginalVertex:d];
	v.y -= diff.y;
	v.z -= diff.z;
	[self setVertex:d vertex:v];
}

@end

////////////////////////////////////////////////////////////

@implementation Lens3D

@synthesize lensEffect;
@synthesize position;

+(id)actionWithPosition:(cpVect)pos radius:(float)r grid:(ccGrid)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithPosition:pos radius:r grid:gridSize duration:d] autorelease];
}

-(id)initWithPosition:(cpVect)pos radius:(float)r grid:(ccGrid)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gridSize duration:d]) )
	{
		position = pos;
		radius = r;
		lensEffect = 0.7f;
		lastPosition = cpv(-1,-1);
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	if ( position.x != lastPosition.x || position.y != lastPosition.y )
	{
		int i, j;
		
		for( i = 0; i < grid.x+1; i++ )
		{
			for( j = 0; j < grid.y+1; j++ )
			{
				ccVertex3D	v = [self getOriginalVertex:ccg(i,j)];
				cpVect vect = cpvsub(position, cpv(v.x,v.y));
				cpFloat r = cpvlength(vect);
				
				if ( r < radius )
				{
					r = radius - r;
					cpFloat pre_log = r / radius;
					if ( pre_log == 0 ) pre_log = 0.001f;
					float l = logf(pre_log) * lensEffect;
					float new_r = expf( l ) * radius;
					
					if ( cpvlength(vect) > 0 )
					{
						vect = cpvnormalize(vect);
						cpVect new_vect = cpvmult(vect, new_r);
						v.z += cpvlength(new_vect) * lensEffect;
					}
				}
				
				[self setVertex:ccg(i,j) vertex:v];
			}
		}
		
		lastPosition = position;
	}
}

@end

////////////////////////////////////////////////////////////

@implementation Ripple3D

@synthesize position;
@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithPosition:(cpVect)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithPosition:pos radius:r waves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithPosition:(cpVect)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gridSize duration:d]) )
	{
		position = pos;
		radius = r;
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < (grid.x+1); i++ )
	{
		for( j = 0; j < (grid.y+1); j++ )
		{
			ccVertex3D	v = [self getOriginalVertex:ccg(i,j)];
			cpVect vect = cpvsub(position, cpv(v.x,v.y));
			cpFloat r = cpvlength(vect);
			
			if ( r < radius )
			{
				r = radius - r;
				cpFloat rate = powf( r / radius, 2);
				v.z += (sinf( time*(cpFloat)M_PI*waves*2 + r * 0.1f) * amplitude * amplitudeRate * rate );
			}
			
			[self setVertex:ccg(i,j) vertex:v];
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation Shaky3D

+(id)actionWithRange:(int)range grid:(ccGrid)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithRange:range grid:gridSize duration:d] autorelease];
}

-(id)initWithRange:(int)range grid:(ccGrid)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gridSize duration:d]) )
	{
		randrange = range;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < (grid.x+1); i++ )
	{
		for( j = 0; j < (grid.y+1); j++ )
		{
			ccVertex3D	v = [self getOriginalVertex:ccg(i,j)];
			v.x += ( rand() % (randrange*2) ) - randrange;
			v.y += ( rand() % (randrange*2) ) - randrange;
			v.z += ( rand() % (randrange*2) ) - randrange;
			
			[self setVertex:ccg(i,j) vertex:v];
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation Liquid

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gridSize duration:d]) )
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
	
	for( i = 1; i < grid.x; i++ )
	{
		for( j = 1; j < grid.y; j++ )
		{
			ccVertex3D	v = [self getOriginalVertex:ccg(i,j)];
			v.x = (v.x + (sinf(time*(cpFloat)M_PI*waves*2 + v.x * .01f) * amplitude * amplitudeRate));
			v.y = (v.y + (sinf(time*(cpFloat)M_PI*waves*2 + v.y * .01f) * amplitude * amplitudeRate));
			[self setVertex:ccg(i,j) vertex:v];
		}
	}
}	

@end

////////////////////////////////////////////////////////////

@implementation Waves

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(ccGrid)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithWaves:wav amplitude:amp horizontal:h vertical:v grid:gridSize duration:d] autorelease];
}

-(id)initWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(ccGrid)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gridSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0f;
		horizontal = h;
		vertical = v;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < (grid.x+1); i++ )
	{
		for( j = 0; j < (grid.y+1); j++ )
		{
			ccVertex3D	v = [self getOriginalVertex:ccg(i,j)];
			
			if ( vertical )
				v.x = (v.x + (sinf(time*(cpFloat)M_PI*waves*2 + v.y * .01f) * amplitude * amplitudeRate));
			
			if ( horizontal )
				v.y = (v.y + (sinf(time*(cpFloat)M_PI*waves*2 + v.x * .01f) * amplitude * amplitudeRate));
					
			[self setVertex:ccg(i,j) vertex:v];
		}
	}
}	

@end

////////////////////////////////////////////////////////////

@implementation Twirl

@synthesize position;
@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithPosition:(cpVect)pos twirls:(int)t amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithPosition:pos twirls:t amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithPosition:(cpVect)pos twirls:(int)t amplitude:(float)amp grid:(ccGrid)gridSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gridSize duration:d]) )
	{
		position = pos;
		twirls = t;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	cpVect		c = position;
	
	for( i = 0; i < (grid.x+1); i++ )
	{
		for( j = 0; j < (grid.y+1); j++ )
		{
			ccVertex3D	v = [self getOriginalVertex:ccg(i,j)];
			
			cpVect	avg = cpv(i-(grid.x/2.0f), j-(grid.y/2.0f));
			cpFloat r = cpvlength( avg );
			
			cpFloat amp = 0.1f * amplitude * amplitudeRate;
			cpFloat a = r * cosf( (cpFloat)M_PI/2.0f + time * (cpFloat)M_PI * twirls * 2 ) * amp;
			
			cpVect	d;
			
			d.x = sinf(a) * (v.y-c.y) + cosf(a) * (v.x-c.x);
			d.y = cosf(a) * (v.y-c.y) - sinf(a) * (v.x-c.x);
			
			v.x = c.x + d.x;
			v.y = c.y + d.y;
			
			[self setVertex:ccg(i,j) vertex:v];
		}
	}
}

@end
