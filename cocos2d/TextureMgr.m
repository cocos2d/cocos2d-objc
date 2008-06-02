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

#import "Texture2D.h"
#import "TextureMgr.h"

@implementation TextureMgr
//
// singleton stuff
//
static TextureMgr *sharedTextureMgr;

+ (TextureMgr *)sharedTextureMgr
{
	@synchronized(self)
	{
		if (!sharedTextureMgr)
			[[TextureMgr alloc] init];
		
		return sharedTextureMgr;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized(self)
	{
		NSAssert(sharedTextureMgr == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedTextureMgr = [super alloc];
		return sharedTextureMgr;
	}
	// to avoid compiler warning
	return nil;
}

-(id) init
{
	if( ! [super init])
		return nil;
	
	textures = [NSMutableDictionary dictionaryWithCapacity: 10];
	return self;
}

-(Texture2D*) addImage: (NSString*) fileimage
{
	Texture2D * tex;
	
	if( (tex=[textures objectForKey: fileimage] ) ) {
		return	[tex retain];
	}
	
	tex = [[Texture2D alloc] initWithImagePath: fileimage];
	[textures setObject: tex forKey:fileimage];
	
	return tex;
}
@end