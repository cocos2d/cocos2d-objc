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

#import "CCRenderTexture.h"
#import "cocos2d.h"
#include "glu.h"

@implementation CCRenderTexture

@synthesize sprite;

+(id)renderTextureWithWidth:(int)w height:(int)h
{
	return [[[self alloc] initWithWidth:w height:h] autorelease];
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
		texture = [[[CCTexture2D alloc] initWithData:data pixelFormat:format pixelsWide:pow pixelsHigh:pow contentSize:CGSizeMake(w, h)] autorelease];
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
		sprite = [CCSprite spriteWithTexture:texture];
		[sprite setScaleY:-1];
		[self addChild:sprite];
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
	}
	return self;
}

-(void)dealloc
{
//	[self removeAllChildrenWithCleanup:YES];
	glDeleteFramebuffersOES(1, &fbo);
	[super dealloc];
}

-(void)begin
{
	// Save the current matrix
	glPushMatrix();

	// Calculate the adjustment ratios based on the old and new projections
	CGRect frame = [[[CCDirector sharedDirector] openGLView] frame];
	float widthRatio = frame.size.width / texture.contentSize.width;
	float heightRatio = frame.size.height / texture.contentSize.height;

	// Adjust the orthographic propjection and viewport
	glOrthof((float)-1.0 / widthRatio,  (float)1.0 / widthRatio, (float)-1.0 / heightRatio, (float)1.0 / heightRatio, -1,1);
	glViewport(0, 0, texture.contentSize.width, texture.contentSize.height);

	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);//Will direct drawing to the frame buffer created above
	glDisable(GL_DITHER);
}

-(void)end
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
	// Restore the original matrix and viewport
	glPopMatrix();
	CGRect frame = [[[CCDirector sharedDirector] openGLView] frame];
	glViewport(0, 0, frame.size.width, frame.size.height);
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

-(BOOL)saveBuffer:(NSString*)name
{
	return [self saveBuffer:name format:kImageFormatJPG];
}

-(BOOL)saveBuffer:(NSString*)fileName format:(int)format
{
	UIImage *myImage				= [self getUIImageFromBuffer];
  
	NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *fullPath				= [documentsDirectory stringByAppendingPathComponent:fileName];
  
	NSData *data;
  
	if (format == kImageFormatPNG)
		data = UIImagePNGRepresentation(myImage);
	else
		data = UIImageJPEGRepresentation(myImage, 1.0f);
  
	return [data writeToFile:fullPath atomically:YES];
}

/* get buffer as UIImage */
-(UIImage *)getUIImageFromBuffer
{
	int tx = texture.contentSize.width;
	int ty = texture.contentSize.height;
  
	int bitsPerComponent			= 8;
	int bitsPerPixel				= 32;
	int bytesPerPixel				= (bitsPerComponent * 4)/8;
	int bytesPerRow					= bytesPerPixel * tx;
	NSInteger myDataLength			= bytesPerRow * ty;
  
	unsigned char buffer[myDataLength];
  
	[self begin];
	glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, &buffer);
	[self end];
	/*
	 CGImageCreate(size_t width, size_t height,
	 size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow,
	 CGColorSpaceRef space, CGBitmapInfo bitmapInfo, CGDataProviderRef provider,
	 const CGFloat decode[], bool shouldInterpolate,
	 CGColorRenderingIntent intent)
	 */
	// make data provider with data.
  
	CGBitmapInfo bitmapInfo			= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
	CGDataProviderRef provider		= CGDataProviderCreateWithData(NULL, buffer, myDataLength, NULL);
	CGColorSpaceRef colorSpaceRef	= CGColorSpaceCreateDeviceRGB();
	CGImageRef iref					= CGImageCreate(tx, ty,
                                          bitsPerComponent, bitsPerPixel, bytesPerRow,
                                          colorSpaceRef, bitmapInfo, provider,
                                          NULL, false,
                                          kCGRenderingIntentDefault);
	/* Create a bitmap context. The context draws into a bitmap which is `width'
	 pixels wide and `height' pixels high. The number of components for each
	 pixel is specified by `colorspace', which may also specify a destination
	 color profile. The number of bits for each component of a pixel is
	 specified by `bitsPerComponent'. The number of bytes per pixel is equal
	 to `(bitsPerComponent * number of components + 7)/8'. Each row of the
	 bitmap consists of `bytesPerRow' bytes, which must be at least `width *
	 bytes per pixel' bytes; in addition, `bytesPerRow' must be an integer
	 multiple of the number of bytes per pixel. `data' points a block of
	 memory at least `bytesPerRow * height' bytes. `bitmapInfo' specifies
	 whether the bitmap should contain an alpha channel and how it's to be
	 generated, along with whether the components are floating-point or
	 integer.
   
	 CGContextRef CGBitmapContextCreate(void *data, size_t width,
	 size_t height, size_t bitsPerComponent, size_t bytesPerRow,
	 CGColorSpaceRef colorspace, CGBitmapInfo bitmapInfo)
	 */
	uint32_t* pixels				= (uint32_t *)malloc(myDataLength);
	CGContextRef context			= CGBitmapContextCreate(pixels, tx,
                                                    ty, CGImageGetBitsPerComponent(iref), CGImageGetBytesPerRow(iref),
                                                    CGImageGetColorSpace(iref), bitmapInfo);
	CGContextTranslateCTM(context, 0.0f, ty);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, tx, ty), iref);   
	CGImageRef outputRef			= CGBitmapContextCreateImage(context);
	UIImage* image					= [[UIImage alloc] initWithCGImage:outputRef];
  
	free(pixels);
	CGImageRelease(iref);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	CGImageRelease(outputRef);
  
	return [image autorelease];
}
@end
