/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
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

#import "CCRenderTexture.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "CCConfiguration.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"

#if __CC_PLATFORM_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

// extern
#import "kazmath/GL/matrix.h"

@implementation CCRenderTexture

@synthesize sprite=sprite_;

// issue #994
+(id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexture2DPixelFormat) format
{
	return [[[self alloc] initWithWidth:w height:h pixelFormat:format] autorelease];
}

+(id)renderTextureWithWidth:(int)w height:(int)h
{
	return [[[self alloc] initWithWidth:w height:h pixelFormat:kCCTexture2DPixelFormat_RGBA8888] autorelease];
}

-(id)initWithWidth:(int)w height:(int)h
{
	return [self initWithWidth:w height:h pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
}

-(id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexture2DPixelFormat) format
{
	if ((self = [super init]))
	{
		NSAssert(format != kCCTexture2DPixelFormat_A8,@"only RGB and RGBA formats are valid for a render texture");

		CCDirector *director = [CCDirector sharedDirector];

		// XXX multithread
		if( [director runningThread] != [NSThread currentThread] )
			CCLOG(@"cocos2d: WARNING. CCRenderTexture is running on its own thread. Make sure that an OpenGL context is being used on this thread!");

		
		w *= CC_CONTENT_SCALE_FACTOR();
		h *= CC_CONTENT_SCALE_FACTOR();

		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO_);

		// textures must be power of two
		NSUInteger powW;
		NSUInteger powH;

		if( [[CCConfiguration sharedConfiguration] supportsNPOT] ) {
			powW = w;
			powH = h;
		} else {
			powW = ccNextPOT(w);
			powH = ccNextPOT(h);
		}

		void *data = malloc((int)(powW * powH * 4));
		memset(data, 0, (int)(powW * powH * 4));
		pixelFormat_=format;

		texture_ = [[CCTexture2D alloc] initWithData:data pixelFormat:pixelFormat_ pixelsWide:powW pixelsHigh:powH contentSize:CGSizeMake(w, h)];
		free( data );

		// generate FBO
		glGenFramebuffers(1, &fbo_);
		glBindFramebuffer(GL_FRAMEBUFFER, fbo_);

		// associate texture with FBO
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture_.name, 0);

		// check if it worked (probably worth doing :) )
		NSAssert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Could not attach texture to framebuffer");

		[texture_ setAliasTexParameters];

		sprite_ = [CCSprite spriteWithTexture:texture_];

		[texture_ release];
		[sprite_ setScaleY:-1];
		[self addChild:sprite_];

		// issue #937
		[sprite_ setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];

		glBindFramebuffer(GL_FRAMEBUFFER, oldFBO_);
	}
	return self;
}

-(void)dealloc
{
	glDeleteFramebuffers(1, &fbo_);

	[super dealloc];
}

-(void)begin
{
	CCDirector *director = [CCDirector sharedDirector];
	
	// Save the current matrix
	kmGLPushMatrix();

	CGSize texSize = [texture_ contentSizeInPixels];


	// Calculate the adjustment ratios based on the old and new projections
	CGSize size = [director winSizeInPixels];
	float widthRatio = size.width / texSize.width;
	float heightRatio = size.height / texSize.height;


	// Adjust the orthographic projection and viewport
	glViewport(0, 0, texSize.width * CC_CONTENT_SCALE_FACTOR(), texSize.height * CC_CONTENT_SCALE_FACTOR() );

	// special viewport for 3d projection + retina display
	if ( director.projection == kCCDirectorProjection3D && CC_CONTENT_SCALE_FACTOR() != 1 )
		glViewport(-texSize.width/2, -texSize.height/2, texSize.width * CC_CONTENT_SCALE_FACTOR(), texSize.height * CC_CONTENT_SCALE_FACTOR() );

	kmMat4 orthoMatrix;
	kmMat4OrthographicProjection(&orthoMatrix, (float)-1.0 / widthRatio,  (float)1.0 / widthRatio,
								 (float)-1.0 / heightRatio, (float)1.0 / heightRatio, -1,1 );
	kmGLMultMatrix(&orthoMatrix);

	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO_);
	glBindFramebuffer(GL_FRAMEBUFFER, fbo_);
}

-(void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self begin];

	// save clear color
	GLfloat	clearColor[4];
	glGetFloatv(GL_COLOR_CLEAR_VALUE,clearColor);

	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// restore clear color
	glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);
}

-(void)end
{
	CCDirector *director = [CCDirector sharedDirector];
	
	glBindFramebuffer(GL_FRAMEBUFFER, oldFBO_);

	kmGLPopMatrix();

	CGSize size = [director winSizeInPixels];

	// restore viewport
	glViewport(0, 0, size.width * CC_CONTENT_SCALE_FACTOR(), size.height * CC_CONTENT_SCALE_FACTOR() );

	// special viewport for 3d projection + retina display
	if ( director.projection == kCCDirectorProjection3D && CC_CONTENT_SCALE_FACTOR() != 1 )
		glViewport(-size.width/2, -size.height/2, size.width * CC_CONTENT_SCALE_FACTOR(), size.height * CC_CONTENT_SCALE_FACTOR() );
	
	[director setProjection:director.projection];	
}

-(void)clear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self beginWithClear:r g:g b:b a:a];
	[self end];
}

#pragma mark RenderTexture - Save Image

-(CGImageRef) newCGImage
{
    NSAssert(pixelFormat_ == kCCTexture2DPixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	
	CGSize s = [texture_ contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	int bitsPerComponent			= 8;
	int bitsPerPixel				= 32;
	int bytesPerPixel				= (bitsPerComponent * 4)/8;
	int bytesPerRow					= bytesPerPixel * tx;
	NSInteger myDataLength			= bytesPerRow * ty;
	
	GLubyte *buffer	= calloc(myDataLength,1);
	GLubyte *pixels	= calloc(myDataLength,1);
	
	
	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getCGImageFromBuffer: not enough memory");
		free(buffer);
		free(pixels);
		return nil;
	}
	
	[self begin];
	

	glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, buffer);

	[self end];
	
	// make data provider with data.
	
	CGBitmapInfo bitmapInfo	= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, NULL);
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref	= CGImageCreate(tx, ty,
									bitsPerComponent, bitsPerPixel, bytesPerRow,
									colorSpaceRef, bitmapInfo, provider,
									NULL, false,
									kCGRenderingIntentDefault);
	
	CGContextRef context = CGBitmapContextCreate(pixels, tx,
												 ty, CGImageGetBitsPerComponent(iref),
												 CGImageGetBytesPerRow(iref), CGImageGetColorSpace(iref),
												 bitmapInfo);
	
	// vertically flipped
	if( YES ) {
		CGContextTranslateCTM(context, 0.0f, ty);
		CGContextScaleCTM(context, 1.0f, -1.0f);
	}
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, tx, ty), iref);
	CGImageRef image = CGBitmapContextCreateImage(context);
	
	CGImageRelease(iref);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	
	free(pixels);
	free(buffer);
	
	return image;
}

-(BOOL) saveToFile:(NSString*)name
{
	return [self saveToFile:name format:kCCImageFormatJPEG];
}

-(BOOL)saveToFile:(NSString*)fileName format:(tCCImageFormat)format
{
	BOOL success;
	
	NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
	
	CGImageRef imageRef = [self newCGImage];

	if( ! imageRef ) {
		CCLOG(@"cocos2d: Error: Cannot create CGImage ref from texture");
		return NO;
	}
	
#if __CC_PLATFORM_IOS
	
	UIImage* image	= [[UIImage alloc] initWithCGImage:imageRef scale:CC_CONTENT_SCALE_FACTOR() orientation:UIImageOrientationUp];
	NSData *imageData;

	if( format == kCCImageFormatPNG )
		imageData = UIImagePNGRepresentation( image );

	else if( format == kCCImageFormatJPEG )
		imageData = UIImageJPEGRepresentation(image, 0.9f);

	else
		NSAssert(NO, @"Unsupported format");
	
	[image release];

	success = [imageData writeToFile:fullPath atomically:YES];

	
#elif __CC_PLATFORM_MAC
	
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:fullPath];
	
	CGImageDestinationRef dest;

	if( format == kCCImageFormatPNG )
		dest = 	CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);

	else if( format == kCCImageFormatJPEG )
		dest = 	CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);

	else
		NSAssert(NO, @"Unsupported format");

	CGImageDestinationAddImage(dest, imageRef, nil);
		
	success = CGImageDestinationFinalize(dest);

	CFRelease(dest);
#endif

	CGImageRelease(imageRef);
	
	if( ! success )
		CCLOG(@"cocos2d: ERROR: Failed to save file:%@ to disk",fullPath);

	return success;
}


#if __CC_PLATFORM_IOS

-(UIImage *) getUIImage
{
	CGImageRef imageRef = [self newCGImage];
	
	UIImage* image	= [[UIImage alloc] initWithCGImage:imageRef scale:CC_CONTENT_SCALE_FACTOR() orientation:UIImageOrientationUp];

	CGImageRelease( imageRef );

	return [image autorelease];
}
#endif // __CC_PLATFORM_IOS
@end
