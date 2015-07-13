/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 * Copyright (c) 2013-2014 Cocos2D Authors
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
#import "CCShader.h"
#import "CCConfiguration.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"

#import "CCTexture_Private.h"
#import "CCDirector_Private.h"
#import "CCNode_Private.h"
#import "CCRenderer_Private.h"
#import "CCRenderTexture_Private.h"
#import "CCRenderDispatch.h"
#import "CCMetalSupport_Private.h"

#if __CC_PLATFORM_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif




@implementation CCRenderTextureSprite

-(CCRenderState *)renderState
{
	if(_renderState == nil){
		// Allowing the uniforms to be copied speeds up the rendering by making the render state immutable.
		// Copy the uniforms if custom uniforms are not being used.
		BOOL copyUniforms = self.hasDefaultShaderUniforms;
		
		// Create an uncached renderstate so the texture can be released before the renderstate cache is flushed.
		_renderState = [CCRenderState renderStateWithBlendMode:_blendMode shader:_shader shaderUniforms:self.shaderUniforms copyUniforms:copyUniforms];
	}
	
	return _renderState;
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];
    
	for (CCNode *p = _renderTexture; p != nil; p = p.parent)
    {
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
    }
	return t;
}

@end


@implementation CCRenderTexture

+(instancetype)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat) format depthStencilFormat:(GLuint)depthStencilFormat
{
  return [[self alloc] initWithWidth:w height:h pixelFormat:format depthStencilFormat:depthStencilFormat];
}

// issue #994
+(instancetype)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format
{
	return [[self alloc] initWithWidth:w height:h pixelFormat:format];
}

+(instancetype)renderTextureWithWidth:(int)w height:(int)h
{
	return [[self alloc] initWithWidth:w height:h pixelFormat:CCTexturePixelFormat_RGBA8888 depthStencilFormat:0];
}

-(id)initWithWidth:(int)w height:(int)h
{
	return [self initWithWidth:w height:h pixelFormat:CCTexturePixelFormat_RGBA8888];
}

- (id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format
{
  return [self initWithWidth:w height:h pixelFormat:format depthStencilFormat:0];
}

-(id)initWithWidth:(int)width height:(int)height pixelFormat:(CCTexturePixelFormat) format depthStencilFormat:(GLuint)depthStencilFormat
{
	if((self = [super init])){
#if __CC_METAL_SUPPORTED_AND_ENABLED
		if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
			NSAssert(format == CCTexturePixelFormat_RGBA8888, @"Only RGBA8 pixel formats are supported for Metal render textures. (The internally created texture is actually BRGA8)");
			format = CCTexturePixelFormat_BGRA8888;
		} else
#endif
		{
			NSAssert(format != CCTexturePixelFormat_A8, @"only RGB and RGBA formats are valid for a render texture");
		}

		CCDirector *director = [CCDirector sharedDirector];

		// XXX multithread
		if( [director runningThread] != [NSThread currentThread] )
			CCLOGWARN(@"cocos2d: WARNING. CCRenderTexture is running on its own thread. Make sure that an OpenGL context is being used on this thread!");

		_contentScale = [CCDirector sharedDirector].contentScaleFactor;
		[self setContentSize:CGSizeMake(width, height)];
		_pixelFormat = format;
		_depthStencilFormat = depthStencilFormat;

		self.projection = GLKMatrix4MakeOrtho(0.0f, width, 0.0f, height, -1024.0f, 1024.0f);
		
		CCRenderTextureSprite *rtSprite = [CCRenderTextureSprite spriteWithTexture:[CCTexture none]];
		rtSprite.renderTexture = self;
		_sprite = rtSprite;

		// Diabled by default.
		_autoDraw = NO;
	}
	
	return self;
}


-(id)init
{
    return [self initWithWidth:0 height:0 pixelFormat:CCTexturePixelFormat_RGBA8888];
}

-(void)create
{
    CGSize pixelSize = CGSizeMake(_contentSize.width * _contentScale, _contentSize.height * _contentScale);
    [self createTextureAndFboWithPixelSize:pixelSize];
}

-(void)createTextureAndFboWithPixelSize:(CGSize)pixelSize
{
	CCGL_DEBUG_PUSH_GROUP_MARKER("CCRenderTexture: Create");
	
	// textures must be power of two
	NSUInteger powW;
	NSUInteger powH;

	if( [[CCConfiguration sharedConfiguration] supportsNPOT] ) {
		powW = pixelSize.width;
		powH = pixelSize.height;
	} else {
		powW = CCNextPOT(pixelSize.width);
		powH = CCNextPOT(pixelSize.height);
	}
    
	void *data = calloc(powW*powH, 4);
	CCTexture *texture = [[CCTexture alloc] initWithData:data pixelFormat:_pixelFormat pixelsWide:powW pixelsHigh:powH contentSizeInPixels:pixelSize contentScale:_contentScale];
	self.texture = texture;
	free(data);
	
	// Render textures are nearest filtered for legacy reasons.
	self.texture.antialiased = NO;
	
	_framebuffer = [[CCFrameBufferObjectClass alloc] initWithTexture:texture depthStencilFormat:_depthStencilFormat];
	
    // XXX Thayer says: I think this is incorrect for any situations where the content
    // size type isn't (points, points). The call to setTextureRect below eventually arrives
    // at some code that assumes the supplied size is in points so, if the size is not in points,
    // things break.
	[self assignSpriteTexture];
	[_sprite setTextureRect:CGRectMake(0, 0, _contentSize.width, _contentSize.height)];
}

-(void)assignSpriteTexture
{
    _sprite.texture = self.texture;
}

-(void)setContentScale:(float)contentScale
{
	if(_contentScale != contentScale){
		_contentScale = contentScale;
		
		[self destroy];
	}
}

-(void)destroy
{
	_framebuffer = nil;
	self.texture = nil;
}

-(void)dealloc
{
	[self destroy];
}

-(CCTexture *)texture
{
    if (super.texture == nil)
    {
        [self create];
    }
    
    return super.texture;
}

static GLKMatrix4
FlipY(GLKMatrix4 projection)
{
	return GLKMatrix4Multiply(GLKMatrix4MakeScale(1.0, -1.0, 1.0), projection);
}

// Metal texture coordinates are inverted compared to GL so the projection must be flipped.
-(GLKMatrix4)projection
{
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		return FlipY(_projection);
	} else
#endif
	{
		return _projection;
	}
}

-(void)setProjection:(GLKMatrix4)projection
{
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		_projection = FlipY(projection);
	} else
#endif
	{
		_projection = projection;
	}
}

-(CCRenderer *)begin
{
	// CCTexture *texture = self.texture;
	if(self.texture == nil){
		[self create];
		// texture = self.texture;
	}
	
	CCRenderer *renderer = [[CCDirector sharedDirector] rendererFromPool];
	[renderer prepareWithProjection:&_projection framebuffer:_framebuffer];
	
	_previousRenderer = [CCRenderer currentRenderer];
	[CCRenderer bindRenderer:renderer];
	
	return renderer;
}

-(CCRenderer *)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue stencil:(int)stencilValue flags:(GLbitfield)flags
{
	CCRenderer *renderer = [self begin];
	[renderer enqueueClear:flags color:GLKVector4Make(r, g, b, a) depth:depthValue stencil:stencilValue globalSortOrder:NSIntegerMin];
	
	return renderer;
}

-(CCRenderer *)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a
{
	return [self beginWithClear:r g:g b:b a:a depth:0 stencil:0 flags:GL_COLOR_BUFFER_BIT];
}

-(CCRenderer *)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue
{
	return [self beginWithClear:r g:g b:b a:a depth:depthValue stencil:0 flags:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
}

-(CCRenderer *)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue stencil:(int)stencilValue
{
	return [self beginWithClear:r g:g b:b a:a depth:depthValue stencil:stencilValue flags:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT];
}

-(void)end
{
	CCRenderer *renderer = [CCRenderer currentRenderer];
	
	__unsafe_unretained CCDirector *director = [CCDirector sharedDirector];
	CCRenderDispatch(renderer.threadsafe, ^{
		[director addFrameCompletionHandler:^{
			// Return the renderer to the pool when the frame completes.
			[director poolRenderer:renderer];
		}];
		
		[renderer flush];
	});
	
	[CCRenderer bindRenderer:_previousRenderer];
}

-(void)clear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self beginWithClear:r g:g b:b a:a];
	[self end];
}

- (void)clearDepth:(float)depthValue
{
	CCRenderer *renderer = [self begin];
		[renderer enqueueClear:GL_DEPTH_BUFFER_BIT color:GLKVector4Make(0, 0, 0, 0) depth:depthValue stencil:0 globalSortOrder:NSIntegerMin];
	[self end];
}

- (void)clearStencil:(int)stencilValue
{
	CCRenderer *renderer = [self begin];
		[renderer enqueueClear:GL_STENCIL_BUFFER_BIT color:GLKVector4Make(0, 0, 0, 0) depth:0.0 stencil:stencilValue globalSortOrder:NSIntegerMin];
	[self end];
}

#pragma mark RenderTexture - "auto" update

- (void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	// override visit.
	// Don't call visit on its children
	if(!_visible) return;
	
	if(_autoDraw){
		if(_contentSizeChanged){
			[self destroy];
			_contentSizeChanged = NO;
		}
		
		CCRenderer *rtRenderer = [self begin];
		NSAssert(renderer == renderer, @"CCRenderTexture error!");
		
		[rtRenderer enqueueClear:_clearFlags color:_clearColor depth:_clearDepth stencil:_clearStencil globalSortOrder:NSIntegerMin];
		
		//! make sure all children are drawn
		[self sortAllChildren];
		
		for(CCNode *child in _children){
			[child visit:rtRenderer parentTransform:&_projection];
		}
		
		[self end];
		
		GLKMatrix4 transform = [self transform:parentTransform];
		[self draw:renderer transform:&transform];
	} else {
		// Render normally, v3.0 and earlier skipped this.
		[super visit:renderer parentTransform:parentTransform];
	}
	
	_orderOfArrival = 0;
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	NSAssert(_sprite.zOrder == 0, @"Changing the sprite's zOrder is not supported.");
	
	// Force the sprite to render itself.
	[_sprite visit:renderer parentTransform:transform];
}

#pragma mark RenderTexture - Save Image

-(CGImageRef) newCGImage
{
	// TODO need to find out why getting pixels from a Metal texture doesn't seem to work.
	// Workaround - use pixel buffers and a copy encoder?
	NSAssert([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIGL, @"[CCRenderTexture -newCGImage] is only supported for GL.");
	
	NSAssert(_pixelFormat == CCTexturePixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	CGSize s = [self.texture contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	int bitsPerComponent = 8;
	int bitsPerPixel = 4 * 8;
	int bytesPerPixel = bitsPerPixel / 8;
	int bytesPerRow = bytesPerPixel * tx;
	NSInteger myDataLength = bytesPerRow * ty;
	
	GLubyte *buffer	= calloc(myDataLength,1);
	GLubyte *pixels	= calloc(myDataLength,1);
	
	
	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getCGImageFromBuffer: not enough memory");
		free(buffer);
		free(pixels);
		return nil;
	}
	
    CCRenderer *renderer = [self begin];
    [renderer enqueueBlock:^{
        glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, buffer);
    } globalSortOrder:NSIntegerMax debugLabel:@"CCRenderTexture reading pixels for new image" threadSafe:NO];
    [self end];
	
	// make data provider with data.
	// TODO find out why iref can't be used as the return value.
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
	
	CGContextRelease(context);
	CGImageRelease(iref);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	
	free(pixels);
	free(buffer);
	
	return image;
}

-(BOOL) saveToFile:(NSString*)name
{
	return [self saveToFile:name format:CCRenderTextureImageFormatJPEG];
}

-(BOOL)saveToFile:(NSString*)fileName format:(CCRenderTextureImageFormat)format
{
	NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];

    return [self saveToFilePath:fullPath format:format];
}

- (BOOL)saveToFilePath:(NSString *)filePath
{
    return [self saveToFilePath:filePath format:CCRenderTextureImageFormatJPEG];
}

- (BOOL)saveToFilePath:(NSString *)filePath format:(CCRenderTextureImageFormat)format
{
    BOOL success = NO;

   	CGImageRef imageRef = [self newCGImage];

   	if( ! imageRef ) {
   		CCLOG(@"cocos2d: Error: Cannot create CGImage ref from texture");
   		return NO;
   	}

#if __CC_PLATFORM_IOS
   	CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
   	UIImage* image	= [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
   	NSData *imageData = nil;

   	if( format == CCRenderTextureImageFormatPNG )
   		imageData = UIImagePNGRepresentation( image );

   	else if( format == CCRenderTextureImageFormatJPEG )
   		imageData = UIImageJPEGRepresentation(image, 0.9f);

   	else
   		NSAssert(NO, @"Unsupported format");

   	success = [imageData writeToFile:filePath atomically:YES];

#elif __CC_PLATFORM_MAC
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];

    CGImageDestinationRef dest = nil;

    if( format == CCRenderTextureImageFormatPNG )
        dest = 	CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);

    else if( format == CCRenderTextureImageFormatJPEG )
        dest = 	CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);

    else
        NSAssert(NO, @"Unsupported format");

    if (!dest)
    {
        CCLOG(@"cocos2d: ERROR: Failed to create image destination with file path:%@", filePath);
        CGImageRelease(imageRef);
        return NO;
    }

    CGImageDestinationAddImage(dest, imageRef, nil);

    success = CGImageDestinationFinalize(dest);

    CFRelease(dest);
#endif

    CGImageRelease(imageRef);

    if( ! success )
        CCLOG(@"cocos2d: ERROR: Failed to save file:%@ to disk", filePath);

    return success;
}


#if __CC_PLATFORM_IOS

-(UIImage *) getUIImage
{
	CGImageRef imageRef = [self newCGImage];
	
	CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
	UIImage* image	= [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    
	CGImageRelease( imageRef );
    
	return image;
}
#endif // __CC_PLATFORM_IOS

- (CCColor*) clearColor
{
    return [CCColor colorWithGLKVector4:_clearColor];
}

- (void) setClearColor:(CCColor *)clearColor
{
    _clearColor = clearColor.glkVector4;
}

#pragma RenderTexture - Override

-(void) setContentSize:(CGSize)size
{
    // TODO: Fix CCRenderTexture so that it correctly handles this
	// NSAssert(NO, @"You cannot change the content size of an already created CCRenderTexture. Recreate it");
    [super setContentSize:size];
    
    // XXX Thayer says: I'm pretty sure this is broken since the supplied content size could
    // be normalized, in points, in UI points, etc. We should get the size in points then convert
    // to pixels and use that to make the ortho matrix.
	self.projection = GLKMatrix4MakeOrtho(0.0f, size.width, 0.0f, size.height, -1024.0f, 1024.0f);
    _contentSizeChanged = YES;
}

@end

