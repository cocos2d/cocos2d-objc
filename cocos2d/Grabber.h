/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 On-Core
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>

@class Texture2D;

/** FBO class that grabs the the contents of the screen */
@interface Grabber : NSObject
{
	GLuint	fbo;
	GLint	oldFBO;
}

-(void)grab:(Texture2D*)texture;
-(void)beforeRender:(Texture2D*)texture;
-(void)afterRender:(Texture2D*)texture;

@end
