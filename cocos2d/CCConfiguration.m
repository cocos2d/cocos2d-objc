/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <OpenGLES/ES1/gl.h>

#import "CCBlockSupport.h"
#import "CCConfiguration.h"
#import "ccMacros.h"
#import "ccConfig.h"

@implementation CCConfiguration

@synthesize loadingBundle=loadingBundle_;
@synthesize maxTextureSize=maxTextureSize_;
@synthesize supportsPVRTC=supportsPVRTC_;
@synthesize maxModelviewStackDepth=maxModelviewStackDepth_;
@synthesize supportsNPOT=supportsNPOT_;
@synthesize supportsBGRA8888=supportsBGRA8888_;

//
// singleton stuff
//
static CCConfiguration *_sharedConfiguration = nil;

static char * glExtensions;

+ (CCConfiguration *)sharedConfiguration
{
	if (!_sharedConfiguration)
		_sharedConfiguration = [[self alloc] init];

	return _sharedConfiguration;
}

+(id)alloc
{
	NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

-(id) init
{
	if( (self=[super init])) {
		
		loadingBundle_ = [NSBundle mainBundle];

		CCLOG(@"cocos2d: GL_VENDOR:   %s", glGetString(GL_VENDOR) );
		CCLOG(@"cocos2d: GL_RENDERER: %s", glGetString ( GL_RENDERER   ) );
		CCLOG(@"cocos2d: GL_VERSION:  %s", glGetString ( GL_VERSION    ) );
		
		glExtensions = (char*) glGetString(GL_EXTENSIONS);
		
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize_);
		glGetIntegerv(GL_MAX_MODELVIEW_STACK_DEPTH, &maxModelviewStackDepth_);
		
		supportsPVRTC_ = [self checkForGLExtension:@"GL_IMG_texture_compression_pvrtc"];
		supportsNPOT_ = [self checkForGLExtension:@"GL_APPLE_texture_2D_limited_npot"];
		supportsBGRA8888_ = [self checkForGLExtension:@"GL_IMG_texture_format_BGRA8888"];
						 
		CCLOG(@"cocos2d: GL_MAX_TEXTURE_SIZE: %d", maxTextureSize_);
		CCLOG(@"cocos2d: GL_MAX_MODELVIEW_STACK_DEPTH: %d",maxModelviewStackDepth_);
		CCLOG(@"cocos2d: GL supports PVRTC: %s", (supportsPVRTC_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports BGRA8888 textures: %s", (supportsBGRA8888_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports NPOT textures: %s", (supportsNPOT_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: compiled with NPOT support: %s",
#if CC_TEXTURE_NPOT_SUPPORT
				"YES"
#else
				"NO"
#endif
			  );
		CCLOG(@"cocos2d: compiled with VBO support in TextureAtlas : %s",
#if CC_TEXTURE_ATLAS_USES_VBO
			  "YES"
#else
			  "NO"
#endif
			  );

		CCLOG(@"cocos2d: compiled with Affine Matrix transformation in CCNode : %s",
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
			  "YES"
#else
			  "NO"
#endif
			  );
		
	}
	
	return self;
}

- (BOOL) checkForGLExtension:(NSString *)searchName
{
	// For best results, extensionsNames should be stored in your renderer so that it does not
	// need to be recreated on each invocation.
    NSString *extensionsString = [NSString stringWithCString:glExtensions encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}
@end
