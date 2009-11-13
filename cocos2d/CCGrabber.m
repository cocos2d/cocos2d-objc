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

#import "CCGrabber.h"
#import "ccMacros.h"
#import "CCTexture2D.h"
#import "Support/OpenGL_Internal.h"

@implementation CCGrabber

-(id) init
{
	if(( self = [super init] )) {
		// generate FBO
		glGenFramebuffersOES(1, &fbo);		
	}
	return self;
}
-(void)grab:(CCTexture2D*)texture
{
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	
	// bind
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

-(void)beforeRender:(CCTexture2D*)texture
{
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
	
	// BUG XXX: doesn't work with RGB565.
	glClearColor(0.0f,0.0f,0.0f,0.0f);

	glClear(GL_COLOR_BUFFER_BIT);
}

-(void)afterRender:(CCTexture2D*)texture
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	glDeleteFramebuffersOES(1, &fbo);
	[super dealloc];
}

@end
