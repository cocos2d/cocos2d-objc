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

#import "ccMacros.h"
#import "Grid.h"
#import "Texture2D.h"
#import "Director.h"
#import "Grabber.h"

#import "Support/glu.h"

@implementation GridBase

@synthesize active;
@synthesize reuseGrid;
@synthesize texture;
@synthesize grabber;
@synthesize grid;
@synthesize step;

-(id)initWithSize:(cpVect)gridSize
{
	if ( (self = [super init] ) )
	{
		active = NO;
		reuseGrid = 0;
		grid = gridSize;
		
		CGSize	win = [[Director sharedDirector] winSize];
	
		if ( self.texture == nil )
		{
			Texture2DPixelFormat	format = [Director sharedDirector].pixelFormat == kRGB565 ? kTexture2DPixelFormat_RGB565 : kTexture2DPixelFormat_RGBA8888;
			
			void *data = malloc((int)(512 * 512 * 4));
			memset(data, 0, (int)(512 * 512 * 4));
			
			texture = [[Texture2D alloc] initWithData:data pixelFormat:format pixelsWide:512 pixelsHigh:512 contentSize:win];
			free( data );
		}
		
		grabber = [[Grabber alloc] init];
		[grabber grab:self.texture];

		step.x = win.width / grid.x;
		step.y = win.height / grid.y;
	}
	
	return self;
}
- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Dimensions = %ix%i>", [self class], self, (int)grid.x, (int)grid.y];
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);

	[texture release];
	[grabber release];
	[super dealloc];
}


// This routine can be merged with Director
-(void)applyLandscape
{
	BOOL	landscape = [Director sharedDirector].landscape;
	
	if( landscape ) {
		glTranslatef(160,240,0);
		
#if LANDSCAPE_LEFT
		glRotatef(-90,0,0,1);
		glTranslatef(-240,-160,0);
#else		
		// rotate left
		glRotatef(90,0,0,1);
		glTranslatef(-240,-160,0);
#endif // LANDSCAPE_LEFT
	}
}

-(void)set2DProjection
{
	CGSize	winSize = [[Director sharedDirector] winSize];
	
	glLoadIdentity();
	glViewport(0, 0, winSize.width, winSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, winSize.width, 0, winSize.height, -100, 100);
	glMatrixMode(GL_MODELVIEW);
}

// This routine can be merged with Director
-(void)set3DProjection
{
	CGSize	winSize = [[Director sharedDirector] displaySize];
	
	glViewport(0, 0, winSize.width, winSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60, (GLfloat)winSize.width/winSize.height, 0.5f, 1500.0f);
	
	glMatrixMode(GL_MODELVIEW);	
	glLoadIdentity();
	gluLookAt( winSize.width/2, winSize.height/2, [Camera getZEye],
			  winSize.width/2, winSize.height/2, 0,
			  0.0f, 1.0f, 0.0f
			  );
}

-(void)beforeDraw
{
	[self set2DProjection];
	[grabber beforeRender:self.texture];
}

-(void)afterDraw:(Camera *)camera
{
	[grabber afterRender:self.texture];
	
	[self set3DProjection];
	[self applyLandscape];

	BOOL cDirty = camera.dirty;
	camera.dirty = YES;
	[camera locate];
	camera.dirty = cDirty;
		
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, self.texture.name);
	
	[self blit];
	
	glDisable(GL_TEXTURE_2D);
}

-(void)blit
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

-(void)reuse
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

@end

////////////////////////////////////////////////////////////

@implementation Grid3D

+(id)gridWithSize:(cpVect)gridSize
{
	return [[[Grid3D alloc] initWithSize:gridSize] autorelease];
}

-(id)initWithSize:(cpVect)gridSize
{
	if ( (self = [super initWithSize:gridSize] ) )
	{
		[self calculate_vertex_points];
	}
	
	return self;
}

-(void)dealloc
{
	free(texCoordinates);
	free(vertices);
	free(indices);
	free(originalVertices);
	[super dealloc];
}

-(void)blit
{
	int n = grid.x * grid.y;
	
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);
	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

-(void)calculate_vertex_points
{
	float width = (float)self.texture.pixelsWide;
	float height = (float)self.texture.pixelsHigh;
	
	int x, y, i;
	
	vertices = malloc((grid.x+1)*(grid.y+1)*sizeof(ccVertex3D));
	originalVertices = malloc((grid.x+1)*(grid.y+1)*sizeof(ccVertex3D));
	texCoordinates = malloc((grid.x+1)*(grid.y+1)*sizeof(cpVect));
	indices = malloc(grid.x*grid.y*sizeof(GLushort)*6);
	
	float *vertArray = (float*)vertices;
	float *texArray = (float*)texCoordinates;
	GLushort *idxArray = (GLushort *)indices;
	
	for( y = 0; y < (grid.y+1); y++ )
	{
		for( x = 0; x < (grid.x+1); x++ )
		{
			int idx = (y * (grid.x+1)) + x;
			
			vertArray[idx*3] = -1;
			vertArray[idx*3+1] = -1;
			vertArray[idx*3+2] = -1;
			texArray[idx*2] = -1;
			texArray[idx*2+1] = -1;
		}
	}
	
	for( x = 0; x < grid.x; x++ )
	{
		for( y = 0; y < grid.y; y++ )
		{
			int idx = (y * grid.x) + x;
			
			float x1 = x * step.x;
			float x2 = x1 + step.x;
			float y1 = y * step.y;
			float y2 = y1 + step.y;
			
			GLushort a = x * (grid.y+1) + y;
			GLushort b = (x+1) * (grid.y+1) + y;
			GLushort c = (x+1) * (grid.y+1) + (y+1);
			GLushort d = x * (grid.y+1) + (y+1);
			
			GLushort	tempidx[6] = { a, b, d, b, c, d };
			
			memcpy(&idxArray[6*idx], tempidx, 6*sizeof(GLushort));
			
			int l1[4] = { a*3, b*3, c*3, d*3 };
			ccVertex3D	e = {x1,y1,0};
			ccVertex3D	f = {x2,y1,0};
			ccVertex3D	g = {x2,y2,0};
			ccVertex3D	h = {x1,y2,0};
			
			ccVertex3D l2[4] = { e, f, g, h };
			
			int tex1[4] = { a*2, b*2, c*2, d*2 };
			cpVect tex2[4] = { cpv(x1,y1), cpv(x2,y1), cpv(x2,y2), cpv(x1,y2) };
			
			for( i = 0; i < 4; i++ )
			{
				vertArray[ l1[i] ] = l2[i].x;
				vertArray[ l1[i] + 1 ] = l2[i].y;
				vertArray[ l1[i] + 2 ] = l2[i].z;
				
				texArray[ tex1[i] ] = tex2[i].x / width;
				texArray[ tex1[i] + 1 ] = tex2[i].y / height;
			}
		}
	}
	
	memcpy(originalVertices, vertices, (grid.x+1)*(grid.y+1)*sizeof(ccVertex3D));
}

-(ccVertex3D)getVertex:(cpVect)pos
{
	int	index = (pos.x * (grid.y+1) + pos.y) * 3;
	float *vertArray = (float *)vertices;
	
	ccVertex3D	vert = { vertArray[index], vertArray[index+1], vertArray[index+2] };
	
	return vert;
}

-(ccVertex3D)getOriginalVertex:(cpVect)pos
{
	int	index = (pos.x * (grid.y+1) + pos.y) * 3;
	float *vertArray = (float *)originalVertices;
	
	ccVertex3D	vert = { vertArray[index], vertArray[index+1], vertArray[index+2] };
	
	return vert;
}

-(void)setVertex:(cpVect)pos vertex:(ccVertex3D)vertex
{
	int	index = (pos.x * (grid.y+1) + pos.y) * 3;
	float *vertArray = (float *)vertices;
	vertArray[index] = vertex.x;
	vertArray[index+1] = vertex.y;
	vertArray[index+2] = vertex.z;
}

-(void)reuse
{
	if ( reuseGrid > 0 )
	{
		memcpy(originalVertices, vertices, (grid.x+1)*(grid.y+1)*sizeof(ccVertex3D));
		reuseGrid--;
	}
}

@end

////////////////////////////////////////////////////////////

@implementation TiledGrid3D

+(id)gridWithSize:(cpVect)gridSize
{
	return [[[TiledGrid3D alloc] initWithSize:gridSize] autorelease];
}

-(id)initWithSize:(cpVect)gridSize
{
	if ( (self = [super initWithSize:gridSize] ) )
	{
		[self calculate_vertex_points];
	}
	
	return self;
}

-(void)dealloc
{
	free(texCoordinates);
	free(vertices);
	free(indices);
	free(originalVertices);
	[super dealloc];
}

-(void)blit
{
	int n = grid.x * grid.y;
	
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);
	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

-(void)calculate_vertex_points
{
	float width = (float)self.texture.pixelsWide;
	float height = (float)self.texture.pixelsHigh;
	
	int numQuads = grid.x * grid.y;
	
	vertices = malloc(numQuads*12*sizeof(GLfloat));
	originalVertices = malloc(numQuads*12*sizeof(GLfloat));
	texCoordinates = malloc(numQuads*8*sizeof(GLfloat));
	indices = malloc(numQuads*6*sizeof(GLushort));
	
	float *vertArray = (float*)vertices;
	float *texArray = (float*)texCoordinates;
	GLushort *idxArray = (GLushort *)indices;
	
	int x, y;
	
	for( x = 0; x < grid.x; x++ )
	{
		for( y = 0; y < grid.y; y++ )
		{
			float x1 = x * step.x;
			float x2 = x1 + step.x;
			float y1 = y * step.y;
			float y2 = y1 + step.y;
			
			*vertArray++ = x1;
			*vertArray++ = y1;
			*vertArray++ = 0;
			*vertArray++ = x2;
			*vertArray++ = y1;
			*vertArray++ = 0;
			*vertArray++ = x1;
			*vertArray++ = y2;
			*vertArray++ = 0;
			*vertArray++ = x2;
			*vertArray++ = y2;
			*vertArray++ = 0;
			
			*texArray++ = x1 / width;
			*texArray++ = y1 / height;
			*texArray++ = x2 / width;
			*texArray++ = y1 / height;
			*texArray++ = x1 / width;
			*texArray++ = y2 / height;
			*texArray++ = x2 / width;
			*texArray++ = y2 / height;
		}
	}
	
	for( x = 0; x < numQuads; x++)
	{
		idxArray[x*6+0] = x*4+0;
		idxArray[x*6+1] = x*4+1;
		idxArray[x*6+2] = x*4+2;
		
		idxArray[x*6+3] = x*4+1;
		idxArray[x*6+4] = x*4+2;
		idxArray[x*6+5] = x*4+3;
	}
	
	memcpy(originalVertices, vertices, numQuads*12*sizeof(GLfloat));
}

-(void)setTile:(cpVect)pos coords:(ccQuad3)coords
{
	int idx = (grid.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)vertices;
	memcpy(&vertArray[idx], &coords, sizeof(ccQuad3));
}

-(ccQuad3)getOriginalTile:(cpVect)pos
{
	int idx = (grid.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)originalVertices;
	
	ccQuad3 ret;
	memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));
	
	return ret;
}

-(ccQuad3)getTile:(cpVect)pos
{
	int idx = (grid.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)vertices;
	
	ccQuad3 ret;
	memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));
	
	return ret;
}

-(void)reuse
{
	if ( reuseGrid > 0 )
	{
		int numQuads = grid.x * grid.y;
		
		memcpy(originalVertices, vertices, numQuads*12*sizeof(GLfloat));
		reuseGrid--;
	}
}

@end
