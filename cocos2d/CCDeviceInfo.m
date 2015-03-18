/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
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

#import "cocos2d.h"

#if __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#elif __CC_PLATFORM_ANDROID
#import <AndroidKit/AndroidWindowManager.h>
#import <AndroidKit/AndroidDisplay.h>
#endif

#import "CCSetup_Private.h"


@implementation CCDeviceInfo

static CCDeviceInfo *_sharedConfiguration = nil;

static NSSet *GL_EXTENSIONS_SET = nil;

+ (CCDeviceInfo *)sharedDeviceInfo
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

-(void)getGLInfo
{
    CCRenderDispatch(NO, ^{
        const char *extensions = (const char *)glGetString(GL_EXTENSIONS);
        NSAssert(extensions, @"OpenGL not initialized!");
        
        GL_EXTENSIONS_SET = [NSSet setWithArray:[[NSString stringWithCString:extensions encoding:NSASCIIStringEncoding] componentsSeparatedByString:@" "]];
        
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_maxTextureSize);
        
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
        _supportsNPOT = YES;
        _supportsPackedDepthStencil = YES;
#elif __CC_PLATFORM_ANDROID
        // While the GL ES 2 spec requires NPOT support, many Android devices don't support it.
        // Bummer. The best we can do is to check for full NPOT texture support instead.
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
        
        // Check if unsynchronized buffers are supported.
        if([self checkForGLExtension:@"GL_OES_mapbuffer"] && [self checkForGLExtension:@"GL_EXT_map_buffer_range"]){
            CCGraphicsBufferClass = NSClassFromString(@"CCGraphicsBufferGLUnsynchronized");
        }
    });
}

-(void)getMetalInfo
{
    // Metal's limits are hardcoded in a PDF file supplied by Apple...
    // This list will be correct for the foreseeable future, but it should really be updated once Apple
    // fixes their API.
    _maxTextureSize = 4096;
    _supportsPVRTC = YES;
    _supportsNPOT = YES;
    _supportsBGRA8888 = YES;
    _supportsDiscardFramebuffer = NO;
    _supportsPackedDepthStencil = YES;
}

-(instancetype)init
{
    if((self=[super init])){
        switch([CCSetup sharedSetup].graphicsAPI){
            case CCGraphicsAPIGL: [self getGLInfo]; break;
            case CCGraphicsAPIMetal: [self getMetalInfo]; break;
            default: NSAssert(NO, @"Error: Graphics API has not set up?");
        }
    }
    
//#if __CC_PLATFORM_IOS
//        _OSVersion = [[UIDevice currentDevice] systemVersion];
//#elif __CC_PLATFORM_MAC
//        _OSVersion = [self getMacVersion];
//#elif __CC_PLATFORM_ANDROID
//        _OSVersion = @"?";//[AndroidBuild DISPLAY];
//#endif
    
    return self;
}

- (BOOL) checkForGLExtension:(NSString *)searchName
{
    return [GL_EXTENSIONS_SET containsObject: searchName];
}

#pragma mark OpenGL getters

-(void) dumpInfo
{
#if DEBUG
	printf("Cocos2D: %s\n", [cocos2dVersion() UTF8String] );

#if __CC_PLATFORM_IOS
	NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif __CC_PLATFORM_ANDROID
    NSString *OSVer = @"?";//[AndroidBuild DISPLAY];
#else //__CC_PLATFORM_MAC
	NSString *OSVer = [[NSProcessInfo processInfo] operatingSystemVersionString];
#endif

	printf("Cocos2D: platform is %ld bit\n", 8*sizeof(long));
    
    static const BOOL multiThreadedRendering = CC_RENDER_DISPATCH_ENABLED;
	printf("Cocos2D: Multi-threaded rendering: %s\n", multiThreadedRendering ? "YES" : "NO");
	
	if([CCSetup sharedSetup].graphicsAPI == CCGraphicsAPIGL){
		printf("Cocos2D: OpenGL Rendering enabled.");
		
		CCRenderDispatch(NO, ^{
			printf("Cocos2D: GL_VENDOR:    %s\n", glGetString(GL_VENDOR) );
			printf("Cocos2D: GL_RENDERER:  %s\n", glGetString ( GL_RENDERER   ) );
			printf("Cocos2D: GL_VERSION:   %s\n", glGetString ( GL_VERSION    ) );
			printf("Cocos2D: GLSL_VERSION: %s\n", glGetString ( GL_SHADING_LANGUAGE_VERSION ) );
		});
		
		printf("Cocos2D: GL_MAX_TEXTURE_SIZE: %d\n", _maxTextureSize);
		printf("Cocos2D: GL supports PVRTC: %s\n", (_supportsPVRTC ? "YES" : "NO") );
		printf("Cocos2D: GL supports NPOT textures: %s\n", (_supportsNPOT ? "YES" : "NO") );
	} else if([CCSetup sharedSetup].graphicsAPI == CCGraphicsAPIMetal){
		printf("Cocos2D: Metal Rendering enabled.");
	}
	
	printf("Cocos2D: CCGraphicsBufferClass: %s\n", NSStringFromClass(CCGraphicsBufferClass).UTF8String);
#endif // DEBUG
}
@end
