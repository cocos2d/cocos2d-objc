//
//  sprite.m
//  test-opengl
//
//  Created by Ricardo Quesada on 28/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "TextureMgr.h"
#import "Sprite.h"

@implementation Sprite
// Sets up an array of values to use as the sprite vertices.

+ (id) spriteFromFile: (NSString*) filename
{
	return [[[self alloc] initFromFile:filename] autorelease];
}

- (id) initFromFile: (NSString*) filename
{
	if (![super init])
		return nil;

	texture = [[TextureMgr sharedTextureMgr] addImage: filename];
	
	[self initAnchors];
	return self;
}

- (void) initAnchors
{
//	CGSize size = [texture contentSize];
//	transform_anchor_x = size.width  / 2;
//	transform_anchor_y = size.height / 2;
}

- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glEnable( GL_TEXTURE_2D);

	[texture drawAtPoint: CGPointZero];

	glDisable( GL_TEXTURE_2D);

	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

@end
