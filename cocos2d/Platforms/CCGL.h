/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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
 */

//
// Common layer for OpenGL stuff
//

#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGL.h>
#import "iOS/glu.h"
#import "iOS/EAGLView.h"

#elif __MAC_OS_X_VERSION_MIN_REQUIRED
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <Cocoa/Cocoa.h>	// needed for NSOpenGLView
#import "Mac/MacGLView.h"
#endif


#if __IPHONE_OS_VERSION_MIN_REQUIRED
#define CC_GLVIEW					EAGLView
#define CC_GL_GENERATE_MIPMAP		glGenerateMipmapOES
#define CC_GL_ORTHO					glOrthof
#define	CC_GL_CLEAR_DEPTH			glClearDepthf

#elif __MAC_OS_X_VERSION_MIN_REQUIRED
#define CC_GLVIEW					MacGLView
#define CC_GL_GENERATE_MIPMAP		glGenerateMipmap
#define CC_GL_ORTHO					glOrtho
#define	CC_GL_CLEAR_DEPTH			glClearDepth

#endif