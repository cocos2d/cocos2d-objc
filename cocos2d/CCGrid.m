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


#import "ccMacros.h"
#import "CCGrid.h"
#import "CCTexture2D.h"
#import "CCDirector.h"
#import "CCGrabber.h"

#import "Support/glu.h"
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark CCGridBase

@implementation CCGridBase

@synthesize reuseGrid=reuseGrid_;
@synthesize texture=texture_;
@synthesize grabber=grabber_;
@synthesize gridSize=gridSize_;
@synthesize step=step_;

+(id) gridWithSize:(ccGridSize)gridSize texture:(CCTexture2D*)texture flippedTexture:(BOOL)flipped
{
	return [[[self alloc] initWithSize:gridSize texture:texture flippedTexture:flipped] autorelease];
}

+(id) gridWithSize:(ccGridSize)gridSize
{
	return [[[self alloc] initWithSize:gridSize] autorelease];
}

-(id) initWithSize:(ccGridSize)gridSize texture:(CCTexture2D*)texture flippedTexture:(BOOL)flipped
{
	if( (self=[super init]) ) {
		
		active_ = NO;
		reuseGrid_ = 0;
		gridSize_ = gridSize;

		self.texture = texture;
		isTextureFlipped_ = flipped;
		
		CGSize texSize = [texture_ contentSize];
		step_.x = texSize.width / gridSize_.x;
		step_.y = texSize.height / gridSize_.y;
		
		grabber_ = [[CCGrabber alloc] init];
		[grabber_ grab:texture_];
		
		[self calculateVertexPoints];
	}
	return self;
}

-(id)initWithSize:(ccGridSize)gSize
{
	CCDirector *director = [CCDirector sharedDirector];
	CGSize s = [director winSize];
	int textureSize = 8;
	while (textureSize < s.width || textureSize < s.height)
		textureSize *= 2;
	
	EAGLView *glview = [[CCDirector sharedDirector] openGLView];
	NSString *pixelFormat = [glview pixelFormat];

	CCTexture2DPixelFormat format = [pixelFormat isEqualToString: kEAGLColorFormatRGB565] ? kCCTexture2DPixelFormat_RGB565 : kCCTexture2DPixelFormat_RGBA8888;
	
	void *data = malloc((int)(textureSize * textureSize * 4));
	if( ! data ) {
		CCLOG(@"cocos2d: CCGrid: not enough memory");
		[self release];
		return nil;
	}
	memset(data, 0, (int)(textureSize * textureSize * 4));
	
	CCTexture2D *texture = [[[CCTexture2D alloc] initWithData:data pixelFormat:format pixelsWide:textureSize pixelsHigh:textureSize contentSize:s] autorelease];
	free( data );

	if ( (self = [self initWithSize:gSize texture:texture flippedTexture:NO] ) )
	{
		// do something
	}
	
	return self;
}
- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Dimensions = %ix%i>", [self class], self, gridSize_.x, gridSize_.y];
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	[self setActive: NO];

	[texture_ release];
	[grabber_ release];
	[super dealloc];
}

// properties
-(BOOL) active
{
	return active_;
}

-(void) setActive:(BOOL)active
{
	active_ = active;
	if( ! active ) {
		CCDirector *director = [CCDirector sharedDirector];
		ccDirectorProjection proj = [director projection];
		[director setProjection:proj];
	}
}

-(BOOL) isTextureFlipped
{
	return isTextureFlipped_;
}

-(void) setIsTextureFlipped:(BOOL)flipped
{
	if( isTextureFlipped_ != flipped ) {
		isTextureFlipped_ = flipped;
		[self calculateVertexPoints];
	}
}

// This routine can be merged with Director
-(void)applyLandscape
{
	CCDirector *director = [CCDirector sharedDirector];
	
	CGSize winSize = [director displaySize];
	float w = winSize.width / 2;
	float h = winSize.height / 2;

	ccDeviceOrientation orientation  = [director deviceOrientation];

	switch (orientation) {
		case CCDeviceOrientationLandscapeLeft:
			glTranslatef(w,h,0);
			glRotatef(-90,0,0,1);
			glTranslatef(-h,-w,0);
			break;
		case CCDeviceOrientationLandscapeRight:
			glTranslatef(w,h,0);
			glRotatef(90,0,0,1);
			glTranslatef(-h,-w,0);
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			glTranslatef(w,h,0);
			glRotatef(180,0,0,1);
			glTranslatef(-w,-h,0);
			break;
		default:
			break;
	}
}

-(void)set2DProjection
{
	CGSize	winSize = [[CCDirector sharedDirector] winSize];
	
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
	CGSize	winSize = [[CCDirector sharedDirector] displaySize];
	
	glViewport(0, 0, winSize.width, winSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60, (GLfloat)winSize.width/winSize.height, 0.5f, 1500.0f);
	
	glMatrixMode(GL_MODELVIEW);	
	glLoadIdentity();
	gluLookAt( winSize.width/2, winSize.height/2, [[CCDirector sharedDirector] getZEye],
			  winSize.width/2, winSize.height/2, 0,
			  0.0f, 1.0f, 0.0f
			  );
}

-(void)beforeDraw
{
	[self set2DProjection];
	[grabber_ beforeRender:texture_];
}

-(void)afterDraw:(CCNode *)target
{
	[grabber_ afterRender:texture_];
	
	[self set3DProjection];
	[self applyLandscape];

	if( target.camera.dirty ) {

		CGPoint offset = [target anchorPointInPixels];

		//
		// XXX: Camera should be applied in the AnchorPoint
		//
		glTranslatef(offset.x, offset.y, 0);
		[target.camera locate];
		glTranslatef(-offset.x, -offset.y, 0);
	}
		
	glBindTexture(GL_TEXTURE_2D, texture_.name);

	[self blit];
}

-(void)blit
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

-(void)reuse
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

-(void)calculateVertexPoints
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCGrid3D
@implementation CCGrid3D

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
	int n = gridSize_.x * gridSize_.y;
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	glDisableClientState(GL_COLOR_ARRAY);	
	
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);
	
	// restore GL default state
	glEnableClientState(GL_COLOR_ARRAY);
}

-(void)calculateVertexPoints
{
	float width = (float)texture_.pixelsWide;
	float height = (float)texture_.pixelsHigh;
	float imageH = texture_.contentSize.height;
	
	int x, y, i;
	
	vertices = malloc((gridSize_.x+1)*(gridSize_.y+1)*sizeof(ccVertex3F));
	originalVertices = malloc((gridSize_.x+1)*(gridSize_.y+1)*sizeof(ccVertex3F));
	texCoordinates = malloc((gridSize_.x+1)*(gridSize_.y+1)*sizeof(CGPoint));
	indices = malloc(gridSize_.x*gridSize_.y*sizeof(GLushort)*6);
	
	float *vertArray = (float*)vertices;
	float *texArray = (float*)texCoordinates;
	GLushort *idxArray = (GLushort *)indices;
	
	for( x = 0; x < gridSize_.x; x++ )
	{
		for( y = 0; y < gridSize_.y; y++ )
		{
			int idx = (y * gridSize_.x) + x;
			
			float x1 = x * step_.x;
			float x2 = x1 + step_.x;
			float y1 = y * step_.y;
			float y2 = y1 + step_.y;
			
			GLushort a = x * (gridSize_.y+1) + y;
			GLushort b = (x+1) * (gridSize_.y+1) + y;
			GLushort c = (x+1) * (gridSize_.y+1) + (y+1);
			GLushort d = x * (gridSize_.y+1) + (y+1);
			
			GLushort	tempidx[6] = { a, b, d, b, c, d };
			
			memcpy(&idxArray[6*idx], tempidx, 6*sizeof(GLushort));
			
			int l1[4] = { a*3, b*3, c*3, d*3 };
			ccVertex3F	e = {x1,y1,0};
			ccVertex3F	f = {x2,y1,0};
			ccVertex3F	g = {x2,y2,0};
			ccVertex3F	h = {x1,y2,0};
			
			ccVertex3F l2[4] = { e, f, g, h };
			
			int tex1[4] = { a*2, b*2, c*2, d*2 };
			CGPoint tex2[4] = { ccp(x1,y1), ccp(x2,y1), ccp(x2,y2), ccp(x1,y2) };
			
			for( i = 0; i < 4; i++ )
			{
				vertArray[ l1[i] ] = l2[i].x;
				vertArray[ l1[i] + 1 ] = l2[i].y;
				vertArray[ l1[i] + 2 ] = l2[i].z;
				
				texArray[ tex1[i] ] = tex2[i].x / width;
				if( isTextureFlipped_ )
					texArray[ tex1[i] + 1 ] = (imageH - tex2[i].y) / height;
				else
					texArray[ tex1[i] + 1 ] = tex2[i].y / height;
			}
		}
	}
	
	memcpy(originalVertices, vertices, (gridSize_.x+1)*(gridSize_.y+1)*sizeof(ccVertex3F));
}

-(ccVertex3F)vertex:(ccGridSize)pos
{
	int	index = (pos.x * (gridSize_.y+1) + pos.y) * 3;
	float *vertArray = (float *)vertices;
	
	ccVertex3F	vert = { vertArray[index], vertArray[index+1], vertArray[index+2] };
	
	return vert;
}

-(ccVertex3F)originalVertex:(ccGridSize)pos
{
	int	index = (pos.x * (gridSize_.y+1) + pos.y) * 3;
	float *vertArray = (float *)originalVertices;
	
	ccVertex3F	vert = { vertArray[index], vertArray[index+1], vertArray[index+2] };
	
	return vert;
}

-(void)setVertex:(ccGridSize)pos vertex:(ccVertex3F)vertex
{
	int	index = (pos.x * (gridSize_.y+1) + pos.y) * 3;
	float *vertArray = (float *)vertices;
	vertArray[index] = vertex.x;
	vertArray[index+1] = vertex.y;
	vertArray[index+2] = vertex.z;
}

-(void)reuse
{
	if ( reuseGrid_ > 0 )
	{
		memcpy(originalVertices, vertices, (gridSize_.x+1)*(gridSize_.y+1)*sizeof(ccVertex3F));
		reuseGrid_--;
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCTiledGrid3D

@implementation CCTiledGrid3D

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
	int n = gridSize_.x * gridSize_.y;
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	glDisableClientState(GL_COLOR_ARRAY);	
	
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);

	// restore default GL state
	glEnableClientState(GL_COLOR_ARRAY);
}

-(void)calculateVertexPoints
{
	float width = (float)texture_.pixelsWide;
	float height = (float)texture_.pixelsHigh;
	float imageH = texture_.contentSize.height;
	
	int numQuads = gridSize_.x * gridSize_.y;
	
	vertices = malloc(numQuads*12*sizeof(GLfloat));
	originalVertices = malloc(numQuads*12*sizeof(GLfloat));
	texCoordinates = malloc(numQuads*8*sizeof(GLfloat));
	indices = malloc(numQuads*6*sizeof(GLushort));
	
	float *vertArray = (float*)vertices;
	float *texArray = (float*)texCoordinates;
	GLushort *idxArray = (GLushort *)indices;
	
	int x, y;
	
	for( x = 0; x < gridSize_.x; x++ )
	{
		for( y = 0; y < gridSize_.y; y++ )
		{
			float x1 = x * step_.x;
			float x2 = x1 + step_.x;
			float y1 = y * step_.y;
			float y2 = y1 + step_.y;
			
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
			
			float newY1 = y1;
			float newY2 = y2;
			
			if( isTextureFlipped_ ) {
				newY1 = imageH - y1;
				newY2 = imageH - y2;
			}

			*texArray++ = x1 / width;
			*texArray++ = newY1 / height;
			*texArray++ = x2 / width;
			*texArray++ = newY1 / height;
			*texArray++ = x1 / width;
			*texArray++ = newY2 / height;
			*texArray++ = x2 / width;
			*texArray++ = newY2 / height;
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

-(void)setTile:(ccGridSize)pos coords:(ccQuad3)coords
{
	int idx = (gridSize_.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)vertices;
	memcpy(&vertArray[idx], &coords, sizeof(ccQuad3));
}

-(ccQuad3)originalTile:(ccGridSize)pos
{
	int idx = (gridSize_.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)originalVertices;
	
	ccQuad3 ret;
	memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));
	
	return ret;
}

-(ccQuad3)tile:(ccGridSize)pos
{
	int idx = (gridSize_.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)vertices;
	
	ccQuad3 ret;
	memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));
	
	return ret;
}

-(void)reuse
{
	if ( reuseGrid_ > 0 )
	{
		int numQuads = gridSize_.x * gridSize_.y;
		
		memcpy(originalVertices, vertices, numQuads*12*sizeof(GLfloat));
		reuseGrid_--;
	}
}

@end
