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


enum  
{
	kImageFormatJPG = 0,
	kImageFormatPNG = 1
};


/**
 RenderTexture is a generic rendering target. To render things into it,
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
}

/** sprite being used */
@property (nonatomic,readwrite, assign) CCSprite* sprite;

/** creates a RenderTexture object with width and height */
+(id)renderTextureWithWidth:(int)width height:(int)height;
/** initializes a RenderTexture object with width and height */
-(id)initWithWidth:(int)width height:(int)height;
-(void)begin;
-(void)end;
/* get buffer as UIImage */
-(UIImage *)getUIImageFromBuffer;
/** saves the texture into a file */
-(BOOL)saveBuffer:(NSString*)name;
/** saves the texture into a file. The format can be JPG or PNG */
-(BOOL)saveBuffer:(NSString*)name format:(int)format;
/** clears the texture with a color */
-(void)clear:(float)r g:(float)g b:(float)b a:(float)a;
@end


