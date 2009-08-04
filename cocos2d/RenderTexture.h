//
//  RenderTexture.h
//
//  Created by Jason Booth on 2/3/09.
//  Copyright 2009 Jason Booth. All rights reserved.
//
// RenderTexture is a generic rendering target. To render things into it,
// simply construct a render target, call begin on it, call visit on any cocos
// scenes or objects to render them, and call end. For convienience, render texture
// adds a sprite as it's display child with the results, so you can simply add
// the render texture to your scene and treat it like any other CocosNode.
// 
// There are also functions for saving the render texture to disk in PNG or JPG format.

#import <Foundation/Foundation.h>
#import "CocosNode.h"
#import "Sprite.h"
#import "OpenGL_Internal.h"

enum  
{
  kJPG = 0,
  kPNG = 1
};

@interface RenderTexture : CocosNode 
{
  GLuint fbo;
  GLint oldFBO;
  Texture2D* texture;
  Sprite* sprite;
}

@property (readwrite, assign) Sprite* sprite;

+(id)renderTextureWithWidth:(int)width height:(int)height;
-(id)initWithWidth:(int)width height:(int)height;
-(void)begin;
-(void)end;
-(void)saveBuffer:(NSString*)name;
-(void)saveBuffer:(NSString*)name format:(int)format;
-(void)clear:(float)r g:(float)g b:(float)b a:(float)a;
@end
