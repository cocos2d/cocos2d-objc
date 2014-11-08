/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#if __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>		// Needed for UIDevice
#elif __CC_PLATFORM_ANDROID
#import <BridgeKitV3/BridgeKit.h> // Needed for AndroidBuild
#endif

#import "Platforms/CCGL.h"
#import "CCConfiguration.h"
#import "ccMacros.h"
#import "ccConfig.h"
#import "cocos2d.h"
#import "CCRenderDispatch.h"

Class CCGraphicsBufferClass;
Class CCGraphicsBufferBindingsClass;
Class CCRenderStateClass;
Class CCRenderCommandDrawClass;
Class CCFrameBufferObjectClass;

NSString* const CCSetupPixelFormat = @"CCSetupPixelFormat";
NSString* const CCSetupScreenMode = @"CCSetupScreenMode";
NSString* const CCSetupScreenOrientation = @"CCSetupScreenOrientation";
NSString* const CCSetupAnimationInterval = @"CCSetupAnimationInterval";
NSString* const CCSetupFixedUpdateInterval = @"CCSetupFixedUpdateInterval";
NSString* const CCSetupShowDebugStats = @"CCSetupShowDebugStats";
NSString* const CCSetupTabletScale2X = @"CCSetupTabletScale2X";

NSString* const CCSetupDepthFormat = @"CCSetupDepthFormat";
NSString* const CCSetupPreserveBackbuffer = @"CCSetupPreserveBackbuffer";
NSString* const CCSetupMultiSampling = @"CCSetupMultiSampling";
NSString* const CCSetupNumberOfSamples = @"CCSetupNumberOfSamples";

NSString* const CCScreenOrientationLandscape = @"CCScreenOrientationLandscape";
NSString* const CCScreenOrientationPortrait = @"CCScreenOrientationPortrait";
NSString* const CCScreenOrientationAll = @"CCScreenOrientationAll";

NSString* const CCScreenModeFlexible = @"CCScreenModeFlexible";
NSString* const CCScreenModeFixed = @"CCScreenModeFixed";


@interface CCConfiguration ()
-(void) getOpenGLvariables;
@end

@implementation CCConfiguration

@synthesize maxTextureSize = _maxTextureSize, maxTextureUnits=_maxTextureUnits;
@synthesize supportsPVRTC = _supportsPVRTC;
@synthesize supportsNPOT = _supportsNPOT;
@synthesize supportsBGRA8888 = _supportsBGRA8888;
@synthesize supportsDiscardFramebuffer = _supportsDiscardFramebuffer;
@synthesize supportsShareableVAO = _supportsShareableVAO;
@synthesize OSVersion = _OSVersion;

//
// singleton stuff
//
static CCConfiguration *_sharedConfiguration = nil;

static char * glExtensions;

+ (CCConfiguration *)sharedConfiguration
{
	if (!_sharedConfiguration){
		_sharedConfiguration = [[self alloc] init];
	}

	return _sharedConfiguration;
}

+(id)alloc
{
	NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}


#if __CC_PLATFORM_IOS
#elif __CC_PLATFORM_MAC
- (NSString*)getMacVersion
{
    return([[NSProcessInfo processInfo] operatingSystemVersionString]);
}
#endif // __CC_PLATFORM_MAC

-(id) init
{
	if( (self=[super init])) {

		// Obtain iOS version
		_OSVersion = 0;
#if __CC_PLATFORM_IOS
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif __CC_PLATFORM_MAC
		NSString *OSVer = [self getMacVersion];
#elif __CC_PLATFORM_ANDROID
        NSString *OSVer = @"?";//[AndroidBuild DISPLAY];
#endif
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];
		int idx = 0x01000000;
		for( NSString *str in arr ) {
			int value = [str intValue];
			_OSVersion += value * idx;
			idx = idx >> 8;
		}
	}

	return self;
}

-(CCGraphicsAPI)graphicsAPI
{
	if(_graphicsAPI == CCGraphicsAPIInvalid){
#if __CC_METAL_SUPPORTED_AND_ENABLED
		if(NSProtocolFromString(@"MTLDevice") && !getenv("CC_FORCE_GL")){
			CCGraphicsBufferClass = NSClassFromString(@"CCGraphicsBufferMetal");
			CCGraphicsBufferBindingsClass = NSClassFromString(@"CCGraphicsBufferBindingsMetal");
			CCRenderStateClass = NSClassFromString(@"CCRenderStateMetal");
			CCRenderCommandDrawClass = NSClassFromString(@"CCRenderCommandDrawMetal");
			CCFrameBufferObjectClass = NSClassFromString(@"CCFrameBufferObjectMetal");
			
			_graphicsAPI = CCGraphicsAPIMetal;
		} else
#endif
		{
			CCGraphicsBufferClass = NSClassFromString(@"CCGraphicsBufferGLBasic");
			CCGraphicsBufferBindingsClass = NSClassFromString(@"CCGraphicsBufferBindingsGL");
			CCRenderStateClass = NSClassFromString(@"CCRenderStateGL");
			CCRenderCommandDrawClass = NSClassFromString(@"CCRenderCommandDrawGL");
			CCFrameBufferObjectClass = NSClassFromString(@"CCFrameBufferObjectGL");
			
			_graphicsAPI = CCGraphicsAPIGL;
		}
		
		NSAssert(CCGraphicsBufferClass, @"CCGraphicsBufferClass not configured.");
		NSAssert(CCGraphicsBufferBindingsClass, @"CCGraphicsBufferBindingsClass not configured.");
		NSAssert(CCRenderStateClass, @"CCRenderStateClass not configured.");
		NSAssert(CCRenderCommandDrawClass, @"CCRenderCommandDrawClass not configured.");
		NSAssert(CCFrameBufferObjectClass, @"CCFrameBufferObjectClass not configured.");
	}
	
	return _graphicsAPI;
}

- (BOOL) checkForGLExtension:(NSString *)searchName
{
	// For best results, extensionsNames should be stored in your renderer so that it does not
	// need to be recreated on each invocation.
    NSString *extensionsString = [NSString stringWithCString:glExtensions encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}

// XXX: Optimization: This should be called only once
-(NSInteger) runningDevice
{
	// TODO: This method really needs to go very away in v4
	
#if __CC_PLATFORM_ANDROID
    
    AndroidDisplayMetrics *metrics = [[AndroidDisplayMetrics alloc] init];
    [[CCActivity currentActivity].windowManager.defaultDisplay getMetrics:metrics];
    double yInches= metrics.heightPixels/metrics.ydpi;
    double xInches= metrics.widthPixels/metrics.xdpi;
    double diagonalInches = sqrt(xInches*xInches + yInches*yInches);
    if (diagonalInches<=CC_MINIMUM_TABLET_SCREEN_DIAGONAL){

        
        if([CCDirector sharedDirector].contentScaleFactor > 1.0)
        {
            return CCDeviceiPhoneRetinaDisplay;
        }
        else
        {
            return CCDeviceiPhone;
        }
    } else {
        if([CCDirector sharedDirector].contentScaleFactor > 1.0)
        {
            return CCDeviceiPadRetinaDisplay;
        }
        else
        {
            return CCDeviceiPad;
        }

    }
#elif __CC_PLATFORM_IOS
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		return ([UIScreen mainScreen].scale == 2) ? CCDeviceiPadRetinaDisplay : CCDeviceiPad;
	}
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		CGSize preferredSize = [[UIScreen mainScreen] preferredMode].size;
		
		if(preferredSize.height == 960){
			return ([UIScreen mainScreen].scale == 2 ? CCDeviceiPhoneRetinaDisplay : CCDeviceiPhone);
		} else if(preferredSize.height == 1136){
			return CCDeviceiPhone5RetinaDisplay;
		} else {
			return ([UIScreen mainScreen].scale == 2 ? CCDeviceiPhone6 : CCDeviceiPhone6Plus);
		}
	}
	
#elif __CC_PLATFORM_MAC
	
	// XXX: Add here support for Mac Retina Display
	return CCDeviceMac;
	
#endif // __CC_PLATFORM_MAC
	
	// This is what it used to do before, but it seems quite wrong...
	return -1;
}

#pragma mark OpenGL getters

-(void) getOpenGLvariables
{
	if( ! _openGLInitialized ) {
		CCRenderDispatch(NO, ^{
			glExtensions = (char*) glGetString(GL_EXTENSIONS);

			NSAssert( glExtensions, @"OpenGL not initialized!");

#if __CC_PLATFORM_IOS
			if( _OSVersion >= CCSystemVersion_iOS_4_0 )
				glGetIntegerv(GL_MAX_SAMPLES_APPLE, &_maxSamplesAllowed);
			else
				_maxSamplesAllowed = 0;
#elif __CC_PLATFORM_MAC
			glGetIntegerv(GL_MAX_SAMPLES, &_maxSamplesAllowed);
#endif

			glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_maxTextureSize);
			glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &_maxTextureUnits );

#if __CC_PLATFORM_IOS
		_supportsNPOT = YES;
        _supportsPackedDepthStencil = YES;
#elif __CC_PLATFORM_MAC
		_supportsNPOT = [self checkForGLExtension:@"GL_ARB_texture_non_power_of_two"];
        _supportsPackedDepthStencil = YES;
#elif __CC_PLATFORM_ANDROID
        // source: http://www.khronos.org/registry/gles/
        _supportsNPOT = [self checkForGLExtension:@"GL_OES_texture_npot"] || [self checkForGLExtension:@"GL_NV_texture_npot_2D_mipmap"];
        _supportsPackedDepthStencil = [self checkForGLExtension:@"GL_OES_packed_depth_stencil"];
#endif
		_supportsPVRTC = [self checkForGLExtension:@"GL_IMG_texture_compression_pvrtc"];

		// It seems that somewhere between firmware iOS 3.0 and 4.2 Apple renamed
		// GL_IMG_... to GL_APPLE.... So we should check both names
#if __CC_PLATFORM_IOS
		BOOL bgra8a = [self checkForGLExtension:@"GL_IMG_texture_format_BGRA8888"];
		BOOL bgra8b = [self checkForGLExtension:@"GL_APPLE_texture_format_BGRA8888"];
		_supportsBGRA8888 = bgra8a | bgra8b;
#elif __CC_PLATFORM_MAC
		_supportsBGRA8888 = [self checkForGLExtension:@"GL_EXT_bgra"];
#endif
			_supportsDiscardFramebuffer = [self checkForGLExtension:@"GL_EXT_discard_framebuffer"];

			_supportsShareableVAO = [self checkForGLExtension:@"GL_APPLE_vertex_array_object"];
			
			// Check if unsynchronized buffers are supported.
			if(
				[self checkForGLExtension:@"GL_OES_mapbuffer"] &&
				[self checkForGLExtension:@"GL_EXT_map_buffer_range"]
			){
				CCGraphicsBufferClass = NSClassFromString(@"CCGraphicsBufferGLUnsynchronized");
			}
			
			_openGLInitialized = YES;
		});
	}
}

/// Cache the current device configuration if it hasn't already been done.
/// The naming here is admittedly terrible and generic but I couldn't think of something better.
-(void)configure
{
	if(!_configured){
		switch(self.graphicsAPI){
			case CCGraphicsAPIGL:
				[self getOpenGLvariables];
				break;
			case CCGraphicsAPIMetal:
				// TODO Hard coding these for now... Does the Metal API even expose any queries for limits?
				_maxTextureSize = 4096;
				_supportsPVRTC = YES;
				_supportsNPOT = YES;
				_supportsBGRA8888 = YES;
				_supportsDiscardFramebuffer = NO;
				_supportsShareableVAO = NO;
				_maxSamplesAllowed = 4;
				_maxTextureUnits = 10;
				_supportsPackedDepthStencil = YES;
				break;
			default: NSAssert(NO, @"Internal Error: Graphics API not set up?");
		}
		
		_configured = YES;
	}
}

-(GLint) maxTextureSize
{
	[self configure];
	return _maxTextureSize;
}

-(GLint) maxTextureUnits
{
	[self configure];
	return _maxTextureUnits;
}

-(BOOL) supportsNPOT
{
	[self configure];
	return _supportsNPOT;
}

-(BOOL) supportsPVRTC
{
	[self configure];
	return _supportsPVRTC;
}

-(BOOL) supportsPackedDepthStencil
{
	[self configure];
	return _supportsPackedDepthStencil;
}

-(BOOL) supportsBGRA8888
{
	[self configure];
	return _supportsBGRA8888;
}

-(BOOL) supportsDiscardFramebuffer
{
	[self configure];
	return _supportsDiscardFramebuffer;
}

-(BOOL) supportsShareableVAO
{
	[self configure];
	return _supportsShareableVAO;
}


#pragma mark Helper

-(void) dumpInfo
{
#if DEBUG
	printf("cocos2d: %s\n", [cocos2dVersion() UTF8String] );

#if __CC_PLATFORM_IOS
	NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif __CC_PLATFORM_ANDROID
    NSString *OSVer = @"?";//[AndroidBuild DISPLAY];
#else //__CC_PLATFORM_MAC
	NSString *OSVer = [self getMacVersion];
#endif

#if __CC_PLATFORM_MAC
	printf("cocos2d: Director's thread: %s\n",
#if (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_MAIN_THREAD)
		  "Main thread"
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_OWN_THREAD)
		  "Own thread"
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_DISPLAY_LINK_THREAD)
		  "DisplayLink thread"
#endif //
		  );
#endif // Mac
	
	printf("cocos2d: compiled with Profiling Support: %s\n",
#if CC_ENABLE_PROFILERS
		  "YES - *** Disable it when you finish profiling ***"
#else
		  "NO"
#endif
		  );

	printf("cocos2d: OS version: %s (0x%08x)\n", [OSVer UTF8String], _OSVersion);
	printf("cocos2d: %ld bit runtime\n", 8*sizeof(long));	
	printf("cocos2d: Multi-threaded rendering: %d\n", CC_RENDER_DISPATCH_ENABLED);
	
	if(_graphicsAPI == CCGraphicsAPIGL){
		printf("cocos2d: OpenGL Rendering enabled.");
		
		CCRenderDispatch(NO, ^{
			printf("cocos2d: GL_VENDOR:   %s\n", glGetString(GL_VENDOR) );
			printf("cocos2d: GL_RENDERER: %s\n", glGetString ( GL_RENDERER   ) );
			printf("cocos2d: GL_VERSION:  %s\n", glGetString ( GL_VERSION    ) );
		});
		
		printf("cocos2d: GL_MAX_TEXTURE_SIZE: %d\n", _maxTextureSize);
		printf("cocos2d: GL_MAX_TEXTURE_UNITS: %d\n", _maxTextureUnits);
		printf("cocos2d: GL_MAX_SAMPLES: %d\n", _maxSamplesAllowed);
		printf("cocos2d: GL supports PVRTC: %s\n", (_supportsPVRTC ? "YES" : "NO") );
		printf("cocos2d: GL supports BGRA8888 textures: %s\n", (_supportsBGRA8888 ? "YES" : "NO") );
		printf("cocos2d: GL supports NPOT textures: %s\n", (_supportsNPOT ? "YES" : "NO") );
		printf("cocos2d: GL supports discard_framebuffer: %s\n", (_supportsDiscardFramebuffer ? "YES" : "NO") );
		printf("cocos2d: GL supports shareable VAO: %s\n", (_supportsShareableVAO ? "YES" : "NO") );
	} else if(_graphicsAPI == CCGraphicsAPIMetal){
		printf("cocos2d: Metal Rendering enabled.");
	}
	
	printf("cocos2d: CCGraphicsBufferClass: %s\n", NSStringFromClass(CCGraphicsBufferClass).UTF8String);
	printf("cocos2d: CCGraphicsBufferBindingsClass: %s\n", NSStringFromClass(CCGraphicsBufferBindingsClass).UTF8String);
	printf("cocos2d: CCRenderCommandDrawClass: %s\n", NSStringFromClass(CCRenderCommandDrawClass).UTF8String);
#endif // DEBUG
}
@end
