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

#import <Availability.h>
#import "CCRenderTexture.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"

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
		
		w *= CC_CONTENT_SCALE_FACTOR();
		h *= CC_CONTENT_SCALE_FACTOR();

		glGetIntegerv(CC_GL_FRAMEBUFFER_BINDING, &oldFBO_);
		
		// textures must be power of two
		NSUInteger powW = ccNextPOT(w);
		NSUInteger powH = ccNextPOT(h);
		
		void *data = malloc((int)(powW * powH * 4));
		memset(data, 0, (int)(powW * powH * 4));
		pixelFormat_=format; 
		
		texture_ = [[CCTexture2D alloc] initWithData:data pixelFormat:pixelFormat_ pixelsWide:powW pixelsHigh:powH contentSize:CGSizeMake(w, h)];
		free( data );
    
		// generate FBO
		ccglGenFramebuffers(1, &fbo_);
		ccglBindFramebuffer(CC_GL_FRAMEBUFFER, fbo_);
    
		// associate texture with FBO
		ccglFramebufferTexture2D(CC_GL_FRAMEBUFFER, CC_GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture_.name, 0);
    
		// check if it worked (probably worth doing :) )
		GLuint status = ccglCheckFramebufferStatus(CC_GL_FRAMEBUFFER);
		if (status != CC_GL_FRAMEBUFFER_COMPLETE)
		{
			[NSException raise:@"Render Texture" format:@"Could not attach texture to framebuffer"];
		}
		[texture_ setAliasTexParameters];
		
		sprite_ = [CCSprite spriteWithTexture:texture_];
		
		[texture_ release];
		[sprite_ setScaleY:-1];
		[self addChild:sprite_];

		// issue #937
		[sprite_ setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];

		ccglBindFramebuffer(CC_GL_FRAMEBUFFER, oldFBO_);
	}
	return self;
}

-(void)dealloc
{
//	[self removeAllChildrenWithCleanup:YES];
	ccglDeleteFramebuffers(1, &fbo_);
	[super dealloc];
}

-(void)begin
{
	// Save the current matrix
	glPushMatrix();
	
	CGSize texSize = [texture_ contentSizeInPixels];
	
	
	// Calculate the adjustment ratios based on the old and new projections
	CGSize size = [[CCDirector sharedDirector] displaySizeInPixels];
	float widthRatio = size.width / texSize.width;
	float heightRatio = size.height / texSize.height;
	
	
	// Adjust the orthographic propjection and viewport
	ccglOrtho((float)-1.0 / widthRatio,  (float)1.0 / widthRatio, (float)-1.0 / heightRatio, (float)1.0 / heightRatio, -1,1);
	glViewport(0, 0, texSize.width, texSize.height);
	
	
	glGetIntegerv(CC_GL_FRAMEBUFFER_BINDING, &oldFBO_);
	ccglBindFramebuffer(CC_GL_FRAMEBUFFER, fbo_);//Will direct drawing to the frame buffer created above
	
	// Issue #1145
	// There is no need to enable the default GL states here
	// but since CCRenderTexture is mostly used outside the "render" loop
	// these states needs to be enabled.
	// Since this bug was discovered in API-freeze (very close of 1.0 release)
	// This bug won't be fixed to prevent incompatibilities with code.
	// 
	// If you understand the above mentioned message, then you can comment the following line
	// and enable the gl states manually, in case you need them.
	CC_ENABLE_DEFAULT_GL_STATES();
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
	ccglBindFramebuffer(CC_GL_FRAMEBUFFER, oldFBO_);
	// Restore the original matrix and viewport
	glPopMatrix();
	CGSize size = [[CCDirector sharedDirector] displaySizeInPixels];
	glViewport(0, 0, size.width, size.height);
}

-(void)clear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self beginWithClear:r g:g b:b a:a];
	[self end];
}

#pragma mark RenderTexture - Save Image

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(BOOL)saveBuffer:(NSString*)name
{
	return [self saveBuffer:name format:kCCImageFormatJPG];
}

-(BOOL)saveBuffer:(NSString*)fileName format:(int)format
{
    NSString *fullPath = [CCFileUtils fullPathFromRelativePath:fileName];
	
	NSData *data = [self getUIImageAsDataFromBuffer:format];
	
	return [data writeToFile:fullPath atomically:YES];
}

/* get buffer as UIImage */
-(UIImage *)getUIImageFromBuffer
{
    NSAssert(pixelFormat_ == kCCTexture2DPixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	CGSize s = [texture_ contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	int bitsPerComponent			= 8;
    int bitsPerPixel                = 4 * 8;
    int bytesPerPixel               = bitsPerPixel / 8;
	int bytesPerRow					= bytesPerPixel * tx;
	NSInteger myDataLength			= bytesPerRow * ty;
	
	GLubyte *buffer	= malloc(sizeof(GLubyte)*myDataLength);
	GLubyte *pixels	= malloc(sizeof(GLubyte)*myDataLength);
	
	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getUIImageFromBuffer: not enough memory");
        free(buffer);
		free(pixels);
		return nil;
	}
	
	[self begin];
        glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, buffer);
	[self end];
	
	// flip image
    int x,y;
	
	for(y = 0; y <ty; y++) {
		for(x = 0; x <tx * 4; x++) {
			pixels[((ty - 1 - y) * tx * 4 + x)] = buffer[(y * 4 * tx + x)];
		}
	}
    
	CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
    CGDataProviderRef provider		= CGDataProviderCreateWithData(NULL, pixels, myDataLength, NULL);
    CGColorSpaceRef colorSpaceRef	= CGColorSpaceCreateDeviceRGB();
    CGImageRef iref					= CGImageCreate(tx, ty,
                                                    bitsPerComponent, bitsPerPixel, bytesPerRow,
                                                    colorSpaceRef, bitmapInfo, provider,
                                                    NULL, false,
                                                    kCGRenderingIntentDefault);
    CGContextRef context = CGBitmapContextCreate(pixels, tx, ty, CGImageGetBitsPerComponent(iref),
                                                 CGImageGetBytesPerRow(iref), CGImageGetColorSpace(iref),
                                                 bitmapInfo);
  

    CGContextDrawImage(context, CGRectMake(0, 0, tx, ty), iref); 
    //make copy so pixels can be freed        
    CGImageRef outputRef = CGBitmapContextCreateImage(context);
  
    
    UIImage* image = [[UIImage alloc] initWithCGImage:outputRef];
        
    CGImageRelease(iref);	
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    CGImageRelease(outputRef);
    
    free(pixels);
    free(buffer);
    
	return [image autorelease];
}

-(NSData*)getUIImageAsDataFromBuffer:(int) format
{
	NSAssert(pixelFormat_ == kCCTexture2DPixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	CGSize s = [texture_ contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	int bitsPerComponent=8;			
	int bitsPerPixel=32;				
	
	int bytesPerRow					= (bitsPerPixel/8) * tx;
	NSInteger myDataLength			= bytesPerRow * ty;
	
	GLubyte *buffer	= malloc(sizeof(GLubyte)*myDataLength);
	GLubyte *pixels	= malloc(sizeof(GLubyte)*myDataLength);
	
	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getUIImageFromBuffer: not enough memory");
		free(buffer);
		free(pixels);
		return nil;
	}
	
	[self begin];
	glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, buffer);
	[self end];
	
	int x,y;
	
	for(y = 0; y <ty; y++) {
		for(x = 0; x <tx * 4; x++) {
			pixels[((ty - 1 - y) * tx * 4 + x)] = buffer[(y * 4 * tx + x)];
		}
	}
	
	NSData* data;
	
	if (format == kCCImageFormatRawData)
	{
		free(buffer);
		//data frees buffer when it is deallocated
		data = [NSData dataWithBytesNoCopy:pixels length:myDataLength];
		
	} else {
		
		/*
		 CGImageCreate(size_t width, size_t height,
		 size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow,
		 CGColorSpaceRef space, CGBitmapInfo bitmapInfo, CGDataProviderRef provider,
		 const CGFloat decode[], bool shouldInterpolate,
		 CGColorRenderingIntent intent)
		 */
		// make data provider with data.
		CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
		CGDataProviderRef provider		= CGDataProviderCreateWithData(NULL, pixels, myDataLength, NULL);
		CGColorSpaceRef colorSpaceRef	= CGColorSpaceCreateDeviceRGB();
		CGImageRef iref					= CGImageCreate(tx, ty,
														bitsPerComponent, bitsPerPixel, bytesPerRow,
														colorSpaceRef, bitmapInfo, provider,
														NULL, false,
														kCGRenderingIntentDefault);
		
		UIImage* image					= [[UIImage alloc] initWithCGImage:iref];
		
		CGImageRelease(iref);	
		CGColorSpaceRelease(colorSpaceRef);
		CGDataProviderRelease(provider);
		
		if (format == kCCImageFormatPNG)
			data = UIImagePNGRepresentation(image);
		else
			data = UIImageJPEGRepresentation(image, 1.0f);
		
		[image release];
		
		free(pixels);
		free(buffer);
	}
	
	return data;
}

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
@end
