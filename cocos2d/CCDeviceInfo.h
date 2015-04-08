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

#import <Foundation/Foundation.h>
#import "CCGL.h"

#if __CC_PLATFORM_ANDROID

#import <AndroidKit/AndroidDisplayMetrics.h>
#endif


/**
 CCConfiguration contains some openGL variables
  */
@interface CCDeviceInfo : NSObject

/** returns a shared instance of the CCConfiguration */
+(CCDeviceInfo *)sharedDeviceInfo;

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

/** dumps in the console the CCConfiguration information.
 */
-(void)dumpInfo;

@end
