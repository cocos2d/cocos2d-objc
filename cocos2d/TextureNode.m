/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

@synthesize opacity=opacity_;
@synthesize color=color_;
@synthesize blendFunc = blendFunc_;

- (id) init
{
	if( (self=[super init]) ) {
		opacity_ = 255;
		color_ = ccWHITE;
		anchorPoint_ = ccp(0.5f, 0.5f);
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
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
	if( ! [texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
	opacityModifyRGB_ = [texture hasPremultipliedAlpha];
}

-(Texture2D*) texture
{
	return texture_;
}

#pragma mark TextureNode - RGBA protocol
-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b
{
	[self setColor:ccc3(r,g,b)];
}

-(void) setOpacity:(GLubyte)opacity
{
	// special opacity for premultiplied textures
	opacity_ = opacity;
	if( opacityModifyRGB_ )
		color_.r = color_.g = color_.b = opacity_;
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
}
-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

#pragma mark TextureNode - draw
- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glEnable( GL_TEXTURE_2D);

	glColor4ub( color_.r, color_.g, color_.b, opacity_);

	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}

	[texture_ drawAtPoint: CGPointZero];
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);

	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);

	glDisable( GL_TEXTURE_2D);

	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}	
@end
