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
	GLuint fbo;
	GLint oldFBO;
	CCTexture2D* texture;
	CCSprite* sprite;
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


