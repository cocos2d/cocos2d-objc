/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

void CGAffineToGL(const CGAffineTransform *t, GLfloat *m);
void GLToCGAffine(const GLfloat *m, CGAffineTransform *t);
