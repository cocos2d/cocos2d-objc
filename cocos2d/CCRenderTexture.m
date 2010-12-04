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

@interface CCRenderTexture (private)

- (void) saveGLstate;
- (void) restoreGLstate;
@end

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
	// issue #878 save opengl state
	[self saveGLstate];

	CC_DISABLE_DEFAULT_GL_STATES();
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
	
	CC_ENABLE_DEFAULT_GL_STATES();	
}

-(void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a
{
	// issue #878 save opengl state
	[self saveGLstate];
	
	CC_DISABLE_DEFAULT_GL_STATES();
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
	
	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	CC_ENABLE_DEFAULT_GL_STATES();
}

-(void)end
{
	ccglBindFramebuffer(CC_GL_FRAMEBUFFER, oldFBO_);
	// Restore the original matrix and viewport
	glPopMatrix();
	CGSize size = [[CCDirector sharedDirector] displaySizeInPixels];
	glViewport(0, 0, size.width, size.height);
	[self restoreGLstate];

}

-(void)clear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self begin];
	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	[self end];
}

-(void) saveGLstate
{
	glGetFloatv(GL_COLOR_CLEAR_VALUE,clearColor_); 
}

- (void) restoreGLstate
{
	glClearColor(clearColor_[0], clearColor_[1], clearColor_[2], clearColor_[3]);
}

#pragma mark RenderTexture - Save Image

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(BOOL)saveBuffer:(NSString*)name
{
	return [self saveBuffer:name format:kCCImageFormatJPG];
}

-(BOOL)saveBuffer:(NSString*)fileName format:(int)format
{
	NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *fullPath				= [documentsDirectory stringByAppendingPathComponent:fileName];
	
	NSData *data = [self getUIImageAsDataFromBuffer:format];
	
	return [data writeToFile:fullPath atomically:YES];
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
