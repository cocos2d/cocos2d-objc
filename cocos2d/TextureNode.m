/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "TextureMgr.h"
#import "TextureNode.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

@implementation TextureNode

@synthesize opacity=opacity_, r=r_, g=g_, b=b_;

- (id) init
{
	if( (self=[super init]) ) {
		opacity_ = r_ = g_ = b_ = 255;
		anchorPoint_ = ccp(0.5f, 0.5f);
	}
	
	return self;
}

-(void) dealloc
{
	[texture_ release];
	[super dealloc];
}

-(void) setTexture:(Texture2D*) texture
{
	[texture_ release];
	texture_ = [texture retain];
	[self setContentSize: texture.contentSize];
}

-(Texture2D*) texture
{
	return texture_;
}

#pragma mark TextureNode - RGBA protocol
-(void) setRGB: (GLubyte) rr :(GLubyte) gg :(GLubyte)bb
{
	r_=rr;
	g_=gg;
	b_=bb;
}

-(void) setOpacity:(GLubyte)opacity
{
	// special opacity for premultiplied textures
	opacity_ = opacity;
	if( [texture_ hasPremultipliedAlpha] )
		r_ = g_ = b_ = opacity_;	
}

- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glEnable( GL_TEXTURE_2D);

	glColor4ub( r_, g_, b_, opacity_);
	
	BOOL preMulti = [texture_ hasPremultipliedAlpha];
	if( !preMulti )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
	[texture_ drawAtPoint: CGPointZero];
	
	if( !preMulti )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);

	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);

	glDisable( GL_TEXTURE_2D);

	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}	
@end
