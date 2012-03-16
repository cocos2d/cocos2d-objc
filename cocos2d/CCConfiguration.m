/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

#import "ccMacros.h"

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>		// Needed for UIDevice
#endif

#import "Platforms/CCGL.h"
#import "CCConfiguration.h"
#import "ccMacros.h"
#import "ccConfig.h"
#import "Support/OpenGL_Internal.h"

@implementation CCConfiguration

@synthesize maxTextureSize = maxTextureSize_, maxTextureUnits=maxTextureUnits_;
@synthesize supportsPVRTC = supportsPVRTC_;
@synthesize maxModelviewStackDepth = maxModelviewStackDepth_;
@synthesize supportsNPOT = supportsNPOT_;
@synthesize supportsBGRA8888 = supportsBGRA8888_;
@synthesize supportsDiscardFramebuffer = supportsDiscardFramebuffer_;
@synthesize OSVersion = OSVersion_;

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


#ifdef __CC_PLATFORM_IOS
#elif defined(__CC_PLATFORM_MAC)
- (NSString*)getMacVersion
{
    SInt32 versionMajor, versionMinor, versionBugFix;
	Gestalt(gestaltSystemVersionMajor, &versionMajor);
	Gestalt(gestaltSystemVersionMinor, &versionMinor);
	Gestalt(gestaltSystemVersionBugFix, &versionBugFix);

	return [NSString stringWithFormat:@"%d.%d.%d", versionMajor, versionMinor, versionBugFix];
}
#endif // __CC_PLATFORM_MAC

-(id) init
{
	if( (self=[super init])) {

		// Obtain iOS version
		OSVersion_ = 0;
#ifdef __CC_PLATFORM_IOS
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif defined(__CC_PLATFORM_MAC)
		NSString *OSVer = [self getMacVersion];
#endif
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];
		int idx = 0x01000000;
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
		glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &maxTextureUnits_ );

#ifdef __CC_PLATFORM_IOS
		if( OSVersion_ >= kCCiOSVersion_4_0 )
			glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamplesAllowed_);
		else
			maxSamplesAllowed_ = 0;
#elif defined(__CC_PLATFORM_MAC)
		glGetIntegerv(GL_MAX_SAMPLES, &maxSamplesAllowed_);
#endif

		supportsPVRTC_ = [self checkForGLExtension:@"GL_IMG_texture_compression_pvrtc"];
#ifdef __CC_PLATFORM_IOS
		supportsNPOT_ = YES;
#elif defined(__CC_PLATFORM_MAC)
		supportsNPOT_ = [self checkForGLExtension:@"GL_ARB_texture_non_power_of_two"];
#endif
		// It seems that somewhere between firmware iOS 3.0 and 4.2 Apple renamed
		// GL_IMG_... to GL_APPLE.... So we should check both names

#ifdef __CC_PLATFORM_IOS
		BOOL bgra8a = [self checkForGLExtension:@"GL_IMG_texture_format_BGRA8888"];
		BOOL bgra8b = [self checkForGLExtension:@"GL_APPLE_texture_format_BGRA8888"];
		supportsBGRA8888_ = bgra8a | bgra8b;
#elif defined(__CC_PLATFORM_MAC)
		supportsBGRA8888_ = [self checkForGLExtension:@"GL_EXT_bgra"];
#endif

		supportsDiscardFramebuffer_ = [self checkForGLExtension:@"GL_EXT_discard_framebuffer"];

		CCLOG(@"cocos2d: GL_MAX_TEXTURE_SIZE: %d", maxTextureSize_);
		CCLOG(@"cocos2d: GL_MAX_TEXTURE_UNITS: %d", maxTextureUnits_);
		CCLOG(@"cocos2d: GL_MAX_SAMPLES: %d", maxSamplesAllowed_);
		CCLOG(@"cocos2d: GL supports PVRTC: %s", (supportsPVRTC_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports BGRA8888 textures: %s", (supportsBGRA8888_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports NPOT textures: %s", (supportsNPOT_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports discard_framebuffer: %s", (supportsDiscardFramebuffer_ ? "YES" : "NO") );

#ifdef __CC_PLATFORM_MAC
		CCLOG(@"cocos2d: Director's thread: %@",
#if (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_MAIN_THREAD)
			  @"Main thread"
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_OWN_THREAD)
			  @"Own thread"	
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_DISPLAY_LINK_THREAD)
			  @"DisplayLink thread"
#endif //
			  );
#endif // Mac

		CCLOG(@"cocos2d: compiled with Profiling Support: %s",
#if CC_ENABLE_PROFILERS

			  "YES - *** Disable it when you finish profiling ***"
#else
			  "NO"
#endif
			  );

	}

#if CC_ENABLE_GL_STATE_CACHE == 0
	printf("\n");
	NSLog(@"cocos2d: **** WARNING **** CC_ENABLE_GL_STATE_CACHE is disabled. To improve performance, enable it by editing ccConfig.h");
	printf("\n");
#endif

	CHECK_GL_ERROR_DEBUG();

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
