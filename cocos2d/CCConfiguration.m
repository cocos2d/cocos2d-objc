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

#import "CCConfiguration.h"
#import "ccMacros.h"


@implementation CCConfiguration

@synthesize loadingBundle=loadingBundle_;
@synthesize maxTextureSize=maxTextureSize_;
@synthesize supportsPVRTC=supportsPVRTC_;
@synthesize maxModelviewStackDepth=maxModelviewStackDepth_;

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
		
		CCLOG(@"cocos2d: GL_MAX_TEXTURE_SIZE: %d", maxTextureSize_);
		CCLOG(@"cocos2d: Supports PVRTC: %s", (supportsPVRTC_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL_MAX_MODELVIEW_STACK_DEPTH: %d",maxModelviewStackDepth_);
		
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
