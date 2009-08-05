/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "RenderTexture.h"
#import "cocos2d.h"
#include "glu.h"

@implementation RenderTexture

@synthesize sprite;

+(id)renderTextureWithWidth:(int)w height:(int)h
{
  self = [[[RenderTexture alloc] initWithWidth:w height:h] autorelease];
  return self;
}

-(id)initWithWidth:(int)w height:(int)h
{
	self = [super init];
	if (self)
	{
		glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
		Texture2DPixelFormat format = kTexture2DPixelFormat_RGBA8888;  
		// textures must be power of two squared
		int pow = 8;
		while (pow < w || pow < h) pow*=2;

		void *data = malloc((int)(pow * pow * 4));
		memset(data, 0, (int)(pow * pow * 4));
		texture = [[[Texture2D alloc] initWithData:data pixelFormat:format pixelsWide:pow pixelsHigh:pow contentSize:CGSizeMake(w, h)] autorelease];
		free( data );

		// generate FBO
		glGenFramebuffersOES(1, &fbo);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);

		// associate texture with FBO
		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture.name, 0);

		// check if it worked (probably worth doing :) )
		GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
		if (status != GL_FRAMEBUFFER_COMPLETE_OES)
		{
		  [NSException raise:@"Render Texture" format:@"Could not attach texture to framebuffer"];
		}
		sprite = [Sprite spriteWithTexture:texture];
		[sprite setScaleY:-1];
		[self addChild:sprite];
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
	}
	return self;
}

-(void)dealloc
{
	[self removeAllChildrenWithCleanup:YES];
	glDeleteFramebuffersOES(1, &fbo);
	[super dealloc];
}

-(void)begin
{
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);//Will direct drawing to the frame buffer created above
	glDisable(GL_DITHER);
}

-(void)clear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self begin];
	glColorMask(TRUE, TRUE, TRUE, TRUE);
	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glColorMask(TRUE, TRUE, TRUE, FALSE);
	[self end];
}

-(void)end
{	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
}

-(void)saveBuffer:(NSString*)name
{
	[self saveBuffer:name format:kJPG];
}

-(void)saveBuffer:(NSString*)name format:(int)format
{
	int tx = texture.contentSize.width;
	int ty = texture.contentSize.height;
	NSInteger myDataLength = tx * ty * 4;

	// allocate array and read pixels into it.
	GLubyte *buffer = (GLubyte *) malloc(myDataLength);
	[self begin];


	glReadPixels(0, 0, tx, ty, GL_RGBA, GL_UNSIGNED_BYTE, buffer);

	// gl renders "upside down" so swap top to bottom into new array.
	// there's gotta be a better way, but this works.
	GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
	for(int y = 0; y < ty; y++)
	{
		for(int x = 0; x < tx * 4; x++)
		{
			buffer2[(ty-1 - y) * tx * 4 + x] = buffer[y * 4 * tx + x];
		}
	}
	free(buffer);
	// make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);

	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * tx;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

	// make the cgimage
	CGImageRef imageRef = CGImageCreate(tx, ty, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);

	// then make the uiimage from that
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSData *data;
	if (format == kPNG)
		data = UIImagePNGRepresentation(myImage);
	else
		data = UIImageJPEGRepresentation(myImage, 1.0f);
  
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:name];
	[fileManager createFileAtPath:fullPath contents:data attributes:nil];
	CGImageRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	free(buffer2);
	[self end];
}
@end
