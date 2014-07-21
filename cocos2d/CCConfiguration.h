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

#import "Platforms/CCGL.h"

/** OS version definitions. Includes both iOS and Mac OS versions
 */
typedef NS_ENUM(NSUInteger, CCSystemVersion){
	CCSystemVersion_iOS_4_0   = 0x04000000,
	CCSystemVersion_iOS_4_0_1 = 0x04000100,
	CCSystemVersion_iOS_4_1   = 0x04010000,
	CCSystemVersion_iOS_4_2   = 0x04020000,
	CCSystemVersion_iOS_4_2_1 = 0x04020100,
	CCSystemVersion_iOS_4_3   = 0x04030000,
	CCSystemVersion_iOS_4_3_1 = 0x04030100,
	CCSystemVersion_iOS_4_3_2 = 0x04030200,
	CCSystemVersion_iOS_4_3_3 = 0x04030300,
	CCSystemVersion_iOS_4_3_4 = 0x04030400,
	CCSystemVersion_iOS_4_3_5 = 0x04030500,
	CCSystemVersion_iOS_5_0   = 0x05000000,
	CCSystemVersion_iOS_5_0_1 = 0x05000100,
	CCSystemVersion_iOS_5_1_0 = 0x05010000,
	CCSystemVersion_iOS_6_0  = 0x06000000,
	CCSystemVersion_iOS_7_0  = 0x06000000,
	
	CCSystemVersion_Mac_10_6  = 0x0a060000,
	CCSystemVersion_Mac_10_7  = 0x0a070000,
	CCSystemVersion_Mac_10_8  = 0x0a080000,
	CCSystemVersion_Mac_10_9  = 0x0a080000,
};

typedef NS_ENUM(NSUInteger, CCDevice) {
	CCDeviceiPhone,
	CCDeviceiPhoneRetinaDisplay,
	CCDeviceiPhone5,
	CCDeviceiPhone5RetinaDisplay,
	CCDeviceiPad,
	CCDeviceiPadRetinaDisplay,

	CCDeviceMac,
	CCDeviceMacRetinaDisplay,
};

/**
 CCConfiguration contains some openGL variables
  */
@interface CCConfiguration : NSObject {

	BOOL			_openGLInitialized;
	
	GLint			_maxTextureSize;
	BOOL			_supportsPVRTC;
	BOOL			_supportsBGRA8888;
	BOOL			_supportsDiscardFramebuffer;
	BOOL			_supportsShareableVAO;
	GLint			_maxSamplesAllowed;
	GLint			_maxTextureUnits;

	unsigned int	_OSVersion;
}

/** OpenGL Max texture size. */
@property (nonatomic, readonly) GLint maxTextureSize;

/** returns the maximum texture units
 */
@property (nonatomic, readonly) GLint maxTextureUnits;

/** Whether or not PVR Texture Compressed is supported */
@property (nonatomic, readonly) BOOL supportsPVRTC;

/** Whether or not BGRA8888 textures are supported.

 */
@property (nonatomic, readonly) BOOL supportsBGRA8888;

/** Whether or not glDiscardFramebufferEXT is supported

 */
@property (nonatomic, readonly) BOOL supportsDiscardFramebuffer;

/** Whether or not shareable VAOs are supported.
 */
@property (nonatomic, readonly) BOOL supportsShareableVAO;

/** returns the OS version.
	- On iOS devices it returns the firmware version.
	- On Mac returns the OS version

 */
@property (nonatomic, readonly) unsigned int OSVersion;


/** returns a shared instance of the CCConfiguration */
+(CCConfiguration *) sharedConfiguration;

/** returns whether or not an OpenGL is supported */
- (BOOL) checkForGLExtension:(NSString *)searchName;

/** returns the current device */
-(NSInteger) runningDevice;

/** dumps in the console the CCConfiguration information.
 */
-(void) dumpInfo;

@end
