/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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
 */

#import <Availability.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>		// Needed for UIDevice
#endif

#import "Platforms/CCGL.h"
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
@synthesize supportsDiscardFramebuffer=supportsDiscardFramebuffer_;
@synthesize OSVersion=OSVersion_;

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


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
- (NSString*)getMacVersion
{
    SInt32 versionMajor, versionMinor, versionBugFix;
	Gestalt(gestaltSystemVersionMajor, &versionMajor);
	Gestalt(gestaltSystemVersionMinor, &versionMinor);
	Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
	
	return [NSString stringWithFormat:@"%d.%d.%d", versionMajor, versionMinor, versionBugFix];
}
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

-(id) init
{
	if( (self=[super init])) {
		
		loadingBundle_ = [NSBundle mainBundle];
		
		// Obtain iOS version
		OSVersion_ = 0;
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		NSString *OSVer = [self getMacVersion];
#endif
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];		
		int idx=0x01000000;
		for( NSString *str in arr ) {
			int value = [str intValue];
			OSVersion_ += value * idx;
			idx = idx >> 8;
		}
		CCLOG(@"cocos2d: OS version: %@ (0x%08x)", OSVer, OSVersion_);
		
		CCLOG(@"cocos2d: GL_VENDOR:   %s", glGetString(GL_VENDOR) );
		CCLOG(@"cocos2d: GL_RENDERER: %s", glGetString ( GL_RENDERER   ) );
		CCLOG(@"cocos2d: GL_VERSION:  %s", glGetString ( GL_VERSION    ) );
		
		glExtensions = (char*) glGetString(GL_EXTENSIONS);
		
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize_);
		glGetIntegerv(GL_MAX_MODELVIEW_STACK_DEPTH, &maxModelviewStackDepth_);
		
		supportsPVRTC_ = [self checkForGLExtension:@"GL_IMG_texture_compression_pvrtc"];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		supportsNPOT_ = [self checkForGLExtension:@"GL_APPLE_texture_2D_limited_npot"];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		supportsNPOT_ = [self checkForGLExtension:@"GL_ARB_texture_non_power_of_two"];
#endif
		supportsBGRA8888_ = [self checkForGLExtension:@"GL_IMG_texture_format_BGRA8888"];
		supportsDiscardFramebuffer_ = [self checkForGLExtension:@"GL_EXT_discard_framebuffer"];

		CCLOG(@"cocos2d: GL_MAX_TEXTURE_SIZE: %d", maxTextureSize_);
		CCLOG(@"cocos2d: GL_MAX_MODELVIEW_STACK_DEPTH: %d",maxModelviewStackDepth_);
		CCLOG(@"cocos2d: GL supports PVRTC: %s", (supportsPVRTC_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports BGRA8888 textures: %s", (supportsBGRA8888_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports NPOT textures: %s", (supportsNPOT_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports discard_framebuffer: %s", (supportsDiscardFramebuffer_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: compiled with NPOT support: %s",
#if CC_TEXTURE_NPOT_SUPPORT
				"YES"
#else
				"NO"
#endif
			  );
		CCLOG(@"cocos2d: compiled with VBO support in TextureAtlas : %s",
#if CC_USES_VBO
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
		
		CCLOG(@"cocos2d: compiled with Profiling Support: %s",
#if CC_ENABLE_PROFILERS

			  "YES - *** Disable it when you finish profiling ***"
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
