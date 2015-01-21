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

#import <Foundation/Foundation.h>
#import "CCGL.h"

#if __CC_PLATFORM_ANDROID

#import <AndroidKit/AndroidDisplayMetrics.h>
#endif


#define CC_MINIMUM_TABLET_SCREEN_DIAGONAL 6.0
extern Class CCTextureClass;
extern Class CCGraphicsBufferClass;
extern Class CCGraphicsBufferBindingsClass;
extern Class CCRenderStateClass;
extern Class CCRenderCommandDrawClass;
extern Class CCFrameBufferObjectClass;

extern NSString* const CCSetupPixelFormat;
extern NSString* const CCSetupScreenMode;
extern NSString* const CCSetupScreenOrientation;
extern NSString* const CCSetupAnimationInterval;
extern NSString* const CCSetupFixedUpdateInterval;
extern NSString* const CCSetupShowDebugStats;
extern NSString* const CCSetupTabletScale2X;

extern NSString* const CCSetupDepthFormat;
extern NSString* const CCSetupPreserveBackbuffer;
extern NSString* const CCSetupMultiSampling;
extern NSString* const CCSetupNumberOfSamples;
extern NSString* const CCScreenModeFixedDimensions;

// Landscape screen orientation. Used with CCSetupScreenOrientation.
extern NSString* const CCScreenOrientationLandscape;

// Portrait screen orientation.  Used with CCSetupScreenOrientation.
extern NSString* const CCScreenOrientationPortrait;

// Support all screen orientations.  Used with CCSetupScreenOrientation.
extern NSString* const CCScreenOrientationAll;


// The flexible screen mode is Cocos2d's default. It will give you an area that can vary slightly in size. In landscape mode the height will be 320 points for mobiles and 384 points for tablets. The width of the area can vary from 480 to 568 points.
extern NSString* const CCScreenModeFlexible;

// The fixed screen mode will setup the working area to be 568 x 384 points. Depending on the device, the outer edges may be cropped. The safe area, that will be displayed on all sorts of devices, is 480 x 320 points and placed in the center of the working area.
extern NSString* const CCScreenModeFixed;

// The desired default window size for mac
extern NSString* const CCMacDefaultWindowSize;


typedef NS_ENUM(NSUInteger, CCDevice) {
	CCDeviceiPhone,
	CCDeviceiPhoneRetinaDisplay,
	CCDeviceiPhone5,
	CCDeviceiPhone5RetinaDisplay,
	CCDeviceiPhone6,
	CCDeviceiPhone6Plus,
	CCDeviceiPad,
	CCDeviceiPadRetinaDisplay,

	CCDeviceMac,
	CCDeviceMacRetinaDisplay,
};

typedef NS_ENUM(NSUInteger, CCGraphicsAPI) {
	CCGraphicsAPIInvalid = 0,
	CCGraphicsAPIGL,
	CCGraphicsAPIMetal,
};

/**
 CCConfiguration contains some openGL variables
  */
@interface CCDeviceInfo : NSObject

/** returns a shared instance of the CCConfiguration */
+(CCDeviceInfo *)sharedDeviceInfo;

///** Which graphics API Cococs2D is using. */
+(CCGraphicsAPI)graphicsAPI;

/** Which graphics API Cococs2D is using. */
@property (nonatomic, readonly) CCGraphicsAPI graphicsAPI;

/** OpenGL Max texture size. */
@property (nonatomic, readonly) GLint maxTextureSize;

/** Whether or not the GPU supports NPOT (Non Power Of Two) textures.
 All iOS/OSX devices support NPOT textures.
 */
@property (nonatomic, readonly) BOOL supportsNPOT;

/** Whether or not the GPU supports a combined depthc/stencil buffer.
 All iOS/OSX devices support GL_DEPTH24_STENCIL8_OES.
 */
@property (nonatomic, readonly) BOOL supportsPackedDepthStencil;

/** Whether or not PVR Texture Compressed is supported */
@property (nonatomic, readonly) BOOL supportsPVRTC;

/** Whether or not BGRA8888 textures are supported.
 */
@property (nonatomic, readonly) BOOL supportsBGRA8888;

/** Whether or not glDiscardFramebufferEXT is supported
 */
@property (nonatomic, readonly) BOOL supportsDiscardFramebuffer;

/** returns whether or not an OpenGL is supported */
- (BOOL) checkForGLExtension:(NSString *)searchName;

///** returns the current device */
//-(NSInteger)runningDevice;

// TODO Temporary
+(NSInteger)runningDevice;

/** dumps in the console the CCConfiguration information.
 */
-(void)dumpInfo;

@end
