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

#import <Foundation/Foundation.h>

#import "ccMacros.h"
#import "CCNode.h"
#import "CCSprite.h"
#import "CCTexture.h"

#if __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif // iPHone

/**
 *  Image format when saving render textures
 */
typedef NS_ENUM(NSInteger, CCRenderTextureImageFormat)
{
	/** Image will be saved as JPEG */
	CCRenderTextureImageFormatJPEG = 0,
	/** Image will be saved as PNG */
	CCRenderTextureImageFormatPNG = 1,
};


/**
 CCRenderTexture is a generic rendering target. To render things into it,
 simply construct a render target, call begin on it, call visit on any cocos2d
 scenes or objects to render them, and call end. For convenience, render texture
 adds a sprite as its display child with the results, so you can simply add
 the render texture to your scene and treat it like any other CCNode.
 There are also functions for saving the render texture to disk in PNG or JPG format.

 */
@interface CCRenderTexture : CCNode

/** The CCSprite that is used for rendering.
	A subtle change introduced in v3.1.1 is that this sprite is rendered explicitly and is not a child of the render texture.
*/
@property (nonatomic,readwrite, strong) CCSprite* sprite;

/** Valid flags: GL_COLOR_BUFFER_BIT, GL_DEPTH_BUFFER_BIT, GL_STENCIL_BUFFER_BIT. They can be OR'ed. Valid when "autoDraw is YES. */
@property (nonatomic, readwrite) GLbitfield clearFlags;
/** Clear color value. Valid only when "autoDraw" is YES. */
@property (nonatomic, strong) CCColor* clearColor;
/** Value for clearDepth. Valid only when autoDraw is YES. */
@property (nonatomic, readwrite) GLclampf clearDepth;
/** Value for clear Stencil. Valid only when autoDraw is YES */
@property (nonatomic, readwrite) GLint clearStencil;
/** When enabled, it will render its children into the texture automatically. Disabled by default for compatiblity reasons.
 Will be enabled in the future.
 */
@property (nonatomic, readwrite) BOOL autoDraw;

@property (nonatomic, readwrite) GLKMatrix4 projection;
@property (nonatomic, readwrite) float contentScale;
@property (nonatomic, readonly) CCTexture *texture;

// ---------------------------------------------------------------------
/**
 *  @name Create CCRenderTexture.
 */

/**
 *  initializes a RenderTexture object with width and height in Points and a pixel format( only RGB and RGBA formats are valid ) and depthStencil format
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param format             Pixel format of render target.
 *  @param depthStencilFormat Stencil format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
+(id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat) format depthStencilFormat:(GLuint)depthStencilFormat;

/**
 *  Creates a RenderTexture object with width and height in Points and a pixel format, only RGB and RGBA formats are valid
 *
 *  @param w      Width of render target.
 *  @param h      Height of render target.
 *  @param format Pixel format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
+(id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat) format;

/**
 *  Creates a RenderTexture object with width and height in Points, pixel format is RGBA8888
 *
 *  @param w Width of render target.
 *  @param h Height of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
+(id)renderTextureWithWidth:(int)w height:(int)h;

/**
 *  Initializes a RenderTexture object with width and height in Points and a pixel format, only RGB and RGBA formats are valid
 *
 *  @param w      Width of render target.
 *  @param h      Height of render target.
 *  @param format Pixel format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
-(id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat) format;

/**
 *  Initializes a RenderTexture object with width and height in Points and a pixel format( only RGB and RGBA formats are valid ) and depthStencil format
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param format             Pixel format of render target.
 *  @param depthStencilFormat Stencil format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
- (id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format depthStencilFormat:(GLuint)depthStencilFormat;


- (id)init;

/** 
 *  Starts rendering to the texture whitout clearing the texture first. 
 */
-(CCRenderer *)begin;

/**
 *  starts rendering to the texture while clearing the texture first.
 *  This is more efficient then calling -clear first and then -begin.
 *
 *  @param r Red color.
 *  @param g Green color.
 *  @param b Blue color.
 *  @param a Alpha.
 */
-(CCRenderer *)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a;

/**
 *  starts rendering to the texture while clearing the texture first.
 *  This is more efficient then calling -clear first and then -begin.
 *
 *  @param r Red color.
 *  @param g Green color.
 *  @param b Blue color.
 *  @param a Alpha.
 *  @param depthValue Depth value.
 */
- (CCRenderer *)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue;

/**
 *  starts rendering to the texture while clearing the texture first.
 *  This is more efficient then calling -clear first and then -begin.
 *
 *  @param r Red color.
 *  @param g Green color.
 *  @param b Blue color.
 *  @param a Alpha.
 *  @param depthValue Depth value.
 *  @param stencilValue Stencil value.
 */
- (CCRenderer *)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue stencil:(int)stencilValue;

/** 
 *  Ends grabbing 
 */
-(void)end;

/**
 *  Clears the texture with a color
 *
 *  @param r Red color.
 *  @param g Green color.
 *  @param b Blue color.
 *  @param a Alpha.
 */
-(void)clear:(float)r g:(float)g b:(float)b a:(float)a;

/**
 *  Clears the texture with a specified depth value.
 *
 *  @param depthValue Depth value.
 */
- (void)clearDepth:(float)depthValue;

/**
 *  Clears the texture with a specified stencil value.
 *
 *  @param stencilValue Stencil value.
 */
- (void)clearStencil:(int)stencilValue;

/* 
 *  Creates a new CGImage from with the texture's data.
 *  Caller is responsible for releasing it by calling CGImageRelease().
 */
-(CGImageRef) newCGImage;

/**
 *  Saves the texture into a file using JPEG format. The file will be saved in the Documents folder.
 *
 *  @param name Filename to save image to.
 *
 *  @return YES if the operation is successful.
 */
-(BOOL)saveToFile:(NSString*)name;

/**
 *  Saves the texture into a file. The format could be JPG or PNG. The file will be saved in the Documents folder.
 *
 *  @param name   Filename to save image to.
 *  @param format File format.
 *
 *  @return YES if the operation is successful.
 */
-(BOOL)saveToFile:(NSString*)name format:(CCRenderTextureImageFormat)format;

#if __CC_PLATFORM_IOS
/**
 *  Saves the texture into a file using JPEG format.
 *
 *  @param filePath File path to save image to.
 *
 *  @return YES if the operation was successful.
 */
-(BOOL)saveToFilePath:(NSString*)filePath;

/**
 *  Saves the texture into a file. The format could be JPG or PNG.
 *
 *  @param filePath   File path to save image to.
 *  @param format File format.
 *
 *  @return YES if the operation was successful.
 */
-(BOOL)saveToFilePath:(NSString*)filePath format:(CCRenderTextureImageFormat)format;

/**
 *  Returns an autoreleased UIImage from the texture 
 */
-(UIImage *) getUIImage;

#endif // __CC_PLATFORM_IOS

@end

