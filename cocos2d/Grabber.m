/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

#import "Grabber.h"
#import "Texture2D.h"
#import "OpenGL_Internal.h"
#import "ccMacros.h"

@implementation Grabber

-(void)grab:(Texture2D*)texture
{
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	
	// generate FBO
	glGenFramebuffersOES(1, &fbo);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);

	// associate texture with FBO
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture.name, 0);
	
	// check if it worked (probably worth doing :) )
	GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
	if (status != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		[NSException raise:@"Frame Grabber" format:@"Could not attach texture to framebuffer"];
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
}

-(void)beforeRender:(Texture2D*)texture
{
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
	glClear(GL_COLOR_BUFFER_BIT);
}

-(void)afterRender:(Texture2D*)texture
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);
	[super dealloc];
}

@end
