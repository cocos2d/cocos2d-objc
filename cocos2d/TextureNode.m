/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "TextureMgr.h"
#import "TextureNode.h"

@implementation TextureNode

@synthesize texture, opacity, r, g, b;

- (id) init
{
	if( ! (self=[super init]) )
		return nil;
	
	opacity = 255;
	r = g = b = 255;
	
	return self;
}

-(void) dealloc
{
	// texture is retained and release by super
	[super dealloc];
}

-(void) setRGB: (GLubyte) rr :(GLubyte) gg :(GLubyte)bb
{
	r=rr;
	g=gg;
	b=bb;
}

- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glEnable( GL_TEXTURE_2D);

	glColor4ub( r, g, b, opacity);
	
	[texture drawAtPoint: CGPointZero];

	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);

	glDisable( GL_TEXTURE_2D);

	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

-(CGSize) contentSize
{
	return [texture contentSize];
}
	
@end
