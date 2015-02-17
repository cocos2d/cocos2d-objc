/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2015 Cocos2D Authors
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
 *
 */

#import "ccMacros.h"
#if __CC_PLATFORM_IOS

#import <UIKit/UIView.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "CCView.h"


//CLASSES:

@class CCGLView;

//CLASS INTERFACE:

/** CCGLView Class.
 This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 The view content is basically an EAGL surface you render your OpenGL scene into.

 This class is normally set up for you in the AppDelegate instance of the Cocos2D project template, but you may need to create it yourself
 in mixed UIKit / Cocos2D apps or tweak some of its parameters, for instance to enable the framebuffer's alpha channel in order to see views 
 underneath the CCGLView.
 
 @note Setting the view non-opaque will only work if the pixelFormat is also set to `kEAGLColorFormatRGBA8` upon initialization.
 @note This documentation is for the iOS version of the class. OS X and Android use specific variants of CCGLView which 
 inherit from other base classes (ie NSOpenGLView on OS X).

 Parameters:

 - `viewWithFrame`: size of the OpenGL view. For full screen use `_window.bounds`.
 - `pixelFormat`: Format of the render buffer. Use `kEAGLColorFormatRGBA8` for better color precision (eg: gradients) at the 
 expense of doubling memory usage and performance. 
    - Possible values: `kEAGLColorFormatRGBA8`, `kEAGLColorFormatRGB565`
 - `depthFormat`: Use stencil if you plan to use CCClippingNode. Use depth if you plan to use 3D effects.
	- Possible values: `0`, `GL_DEPTH_COMPONENT24_OES`, `GL_DEPTH24_STENCIL8_OES`
 - `sharegroup`: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads.
 - `multiSampling`: Whether or not to enable multisampling.
 - `numberOfSamples`: Only valid if multisampling is enabled
	- Possible values: any integer in the range `0` (off) to `glGetIntegerv(GL_MAX_SAMPLES_APPLE)` where the latter is device-dependent.
 */
@interface CCViewiOSGL : UIView <CCView>

/** @name Creating a CCViewiOSGL */

/** creates an initializes an CCViewiOSGL with a frame and 0-bit depth buffer, and a RGB565 color buffer.
 @param frame The frame of the view. */
+ (id) viewWithFrame:(CGRect)frame;
/** creates an initializes an CCViewiOSGL with a frame, a color buffer format, and 0-bit depth buffer.
  @param frame The frame of the view.
  @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha). */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format;
/** creates an initializes an CCViewiOSGL with a frame, a color buffer format, and a depth buffer.
 @param frame The frame of the view.
 @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha).
 @param depth The size and format of the depth buffer, use 0 to disable depth buffer. Otherwise use `GL_DEPTH24_STENCIL8_OES` or `GL_DEPTH_COMPONENT24_OES`. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth;
/** creates an initializes an CCViewiOSGL with a frame, a color buffer format, a depth buffer format, a sharegroup, and multisamping.
 @param frame The frame of the view.
 @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha).
 @param depth The size and format of the depth buffer, use 0 to disable depth buffer. Otherwise use `GL_DEPTH24_STENCIL8_OES` or `GL_DEPTH_COMPONENT24_OES`.
 @param retained Whether to clear the backbuffer before drawing to it. YES = don't clear, NO = clear.
 @param sharegroup An OpenGL sharegroup or nil.
 @param multisampling Whether to enable multisampling (AA).
 @param samples The number of samples used in multisampling, from 0 (no AA) to `glGetIntegerv(GL_MAX_SAMPLES_APPLE)`. Only takes effect if the preceding multisampling parameters is set to `YES`. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)multisampling numberOfSamples:(unsigned int)samples;

/** Initializes an CCViewiOSGL with a frame and 0-bit depth buffer, and a RGB565 color buffer
 @param frame The frame of the view. */
- (id) initWithFrame:(CGRect)frame; //These also set the current context
/** Initializes an CCViewiOSGL with a frame, a color buffer format, and 0-bit depth buffer
 @param frame The frame of the view.
 @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha). */
- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format;
/** Initializes an CCViewiOSGL with a frame, a color buffer format, a depth buffer format, a sharegroup and multisampling support
 @param frame The frame of the view.
 @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha).
 @param depth The size and format of the depth buffer, use 0 to disable depth buffer. Otherwise use `GL_DEPTH24_STENCIL8_OES` or `GL_DEPTH_COMPONENT24_OES`.
 @param retained Whether to clear the backbuffer before drawing to it. YES = don't clear, NO = clear.
 @param sharegroup An OpenGL sharegroup or nil.
 @param sampling Whether to enable multisampling (AA).
 @param nSamples The number of samples used in multisampling, from 0 (no AA) to `glGetIntegerv(GL_MAX_SAMPLES_APPLE)`. Only takes effect if the preceding multisampling parameters is set to `YES`. */
- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)sampling numberOfSamples:(unsigned int)nSamples;

/** @name Framebuffer Information */

/** pixel format: it could be RGBA8 (32-bit) or RGB565 (16-bit) */
@property(nonatomic,readonly) NSString* pixelFormat;
/** depth format of the render buffer: 0, 16 or 24 bits*/
@property(nonatomic,readonly) GLuint depthFormat;

/** returns surface size in pixels */
@property(nonatomic,readonly) CGSize surfaceSize;

/** OpenGL context */
@property(nonatomic,readonly) EAGLContext *context;

/** Whether multisampling is enabled. */
@property(nonatomic,readwrite) BOOL multiSampling;

@property(nonatomic, readonly) GLuint fbo;

@end

#endif // __CC_PLATFORM_IOS
