/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
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


#import "Platforms/CCGL.h"
#import "CCGrabber.h"
#import "ccMacros.h"
#import "CCTexture2D.h"
#import "Support/OpenGL_Internal.h"

@implementation CCGrabber

-(id) init
{
	if(( self = [super init] )) {
		// generate FBO
		ccglGenFramebuffers(1, &fbo);		
	}
	return self;
}
-(void)grab:(CCTexture2D*)texture
{
	glGetIntegerv(CC_GL_FRAMEBUFFER_BINDING, &oldFBO);
	
	// bind
	ccglBindFramebuffer(CC_GL_FRAMEBUFFER, fbo);

	// associate texture with FBO
	ccglFramebufferTexture2D(CC_GL_FRAMEBUFFER, CC_GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.name, 0);
	
	// check if it worked (probably worth doing :) )
	GLuint status = ccglCheckFramebufferStatus(CC_GL_FRAMEBUFFER);
	if (status != CC_GL_FRAMEBUFFER_COMPLETE)
	{
		[NSException raise:@"Frame Grabber" format:@"Could not attach texture to framebuffer"];
	}
	
	ccglBindFramebuffer(CC_GL_FRAMEBUFFER, oldFBO);
}

-(void)beforeRender:(CCTexture2D*)texture
{
	glGetIntegerv(CC_GL_FRAMEBUFFER_BINDING, &oldFBO);
	ccglBindFramebuffer(CC_GL_FRAMEBUFFER, fbo);

	// BUG XXX: doesn't work with RGB565.


	glClearColor(0,0,0,0);
	
	// BUG #631: To fix #631, uncomment the lines with #631
	// Warning: But it CCGrabber won't work with 2 effects at the same time
//	glClearColor(0.0f,0.0f,0.0f,1.0f);	// #631
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	
//	glColorMask(TRUE, TRUE, TRUE, FALSE);	// #631

}

-(void)afterRender:(CCTexture2D*)texture
{
 	ccglBindFramebuffer(CC_GL_FRAMEBUFFER, oldFBO);
//	glColorMask(TRUE, TRUE, TRUE, TRUE);	// #631
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	ccglDeleteFramebuffers(1, &fbo);
	[super dealloc];
}

@end
