//
//  sprite.m
//  test-opengl
//
//  Created by Ricardo Quesada on 28/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Sprite.h"

// Sets up an array of values for the texture coordinates.
const GLshort spriteTexcoords[] = {

// XXX: find out why the texture is upside down
0, 1,
1, 1,

0, 0,
1, 0,
};

@implementation Sprite
// Sets up an array of values to use as the sprite vertices.

- (id) initFromFile: (NSString*) filename
{
	CGImageRef spriteImage;
	CGContextRef spriteContext;
	GLubyte *spriteData;
	
	if (![super init])
		return nil;

	
	// Creates a Core Graphics image from an image file
	spriteImage = [UIImage imageNamed: filename].CGImage;	

	if( ! spriteImage )
		return nil;

	// Get the width and height of the image
	width = CGImageGetWidth(spriteImage);
	height = CGImageGetHeight(spriteImage);

	// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
	// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.

	// Allocated memory needed for the bitmap context
	spriteData = (GLubyte *) malloc(width * height * 4);
	// Uses the bitmatp creation function provided by the Core Graphics framework. 
	spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
	// After you create the context, you can draw the sprite image to the context.
	CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
	// You don't need the context at this point, so you need to release it to avoid memory leaks.
	CGContextRelease(spriteContext);
		
	// Use OpenGL ES to generate a name for the texture.
	glGenTextures(1, &spriteTexture);
	// Bind the texture name. 
	glBindTexture(GL_TEXTURE_2D, spriteTexture);
	// Speidfy a 2D texture image, provideing the a pointer to the image data in memory
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
	// Release the image data
	free(spriteData);
		
	// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
	// Set a blending function to use
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// Enable blending
	glEnable(GL_BLEND);
	
	[self initVertices];
	[self initAnchors];
	return self;
}

- (void) initVertices
{
	for( int i=0; i< sizeof(spriteVertices) / sizeof(spriteVertices[0]);i++)
		spriteVertices[i] = 0.0f;
	
	spriteVertices[2] = width;
	spriteVertices[5] = height;
	spriteVertices[6] = width;
	spriteVertices[7] = height;

}

- (void) initAnchors
{
	transform_anchor_x = width / 2;
	transform_anchor_y = height / 2;
}

- (void) draw
{	
	// Sets up pointers and enables states needed for using vertex arrays and textures
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glEnable( GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, spriteTexture);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY | GL_TEXTURE_COORD_ARRAY);	
}

@end
