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

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "CCSprite.h"
#import "Support/OpenGL_Internal.h"

#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#endif // iPHone

enum  
{
	kCCImageFormatJPG = 0,
	kCCImageFormatPNG = 1,
	kCCImageFormatRawData =2
};


/**
 CCRenderTexture is a generic rendering target. To render things into it,
 simply construct a render target, call begin on it, call visit on any cocos
 scenes or objects to render them, and call end. For convienience, render texture
 adds a sprite as it's display child with the results, so you can simply add
 the render texture to your scene and treat it like any other CocosNode.
 There are also functions for saving the render texture to disk in PNG or JPG format.
 
 @since v0.8.1
 */
@interface CCRenderTexture : CCNode 
{
	GLuint				fbo_;
	GLint				oldFBO_;
	CCTexture2D*		texture_;
	CCSprite*			sprite_;
	
	GLenum				pixelFormat_;
}

/** The CCSprite being used.
 The sprite, by default, will use the following blending function: GL_ONE, GL_ONE_MINUS_SRC_ALPHA.
 The blending function can be changed in runtime by calling:
	- [[renderTexture sprite] setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
*/
@property (nonatomic,readwrite, assign) CCSprite* sprite;

/** creates a RenderTexture object with width and height in Points and a pixel format, only RGB and RGBA formats are valid */
+(id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexture2DPixelFormat) format;

/** creates a RenderTexture object with width and height in Points, pixel format is RGBA8888 */
+(id)renderTextureWithWidth:(int)w height:(int)h;

/** initializes a RenderTexture object with width and height in Points and a pixel format, only RGB and RGBA formats are valid */
-(id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexture2DPixelFormat) format;

/** starts grabbing */
-(void)begin;

/** starts rendering to the texture while clearing the texture first.
 This is more efficient then calling -clear first and then -begin */
-(void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a;

/** ends grabbing */
-(void)end;

/** clears the texture with a color */
-(void)clear:(float)r g:(float)g b:(float)b a:(float)a;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** saves the texture into a file */
-(BOOL)saveBuffer:(NSString*)name;
/** saves the texture into a file. The format can be JPG or PNG */
-(BOOL)saveBuffer:(NSString*)name format:(int)format;
/* get buffer as UIImage, can only save a render buffer which has a RGBA8888 pixel format */
-(NSData*)getUIImageAsDataFromBuffer:(int) format;
/* get buffer as UIImage */
-(UIImage *)getUIImageFromBuffer;

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED

@end


