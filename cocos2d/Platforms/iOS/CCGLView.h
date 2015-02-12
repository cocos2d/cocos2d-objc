/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: CCGLView.h
Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
UIView subclass.

Version: 1.3

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#if __CC_PLATFORM_IOS

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "CCDirectorView.h"


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
@interface CCGLView : UIView <CCDirectorView>

/** @name Creating a CCGLView */

/** creates an initializes an CCGLView with a frame and 0-bit depth buffer, and a RGB565 color buffer.
 @param frame The frame of the view. */
+ (id) viewWithFrame:(CGRect)frame;
/** creates an initializes an CCGLView with a frame, a color buffer format, and 0-bit depth buffer.
  @param frame The frame of the view.
  @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha). */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format;
/** creates an initializes an CCGLView with a frame, a color buffer format, and a depth buffer.
 @param frame The frame of the view.
 @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha).
 @param depth The size and format of the depth buffer, use 0 to disable depth buffer. Otherwise use `GL_DEPTH24_STENCIL8_OES` or `GL_DEPTH_COMPONENT24_OES`. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth;
/** creates an initializes an CCGLView with a frame, a color buffer format, a depth buffer format, a sharegroup, and multisamping.
 @param frame The frame of the view.
 @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha).
 @param depth The size and format of the depth buffer, use 0 to disable depth buffer. Otherwise use `GL_DEPTH24_STENCIL8_OES` or `GL_DEPTH_COMPONENT24_OES`.
 @param retained Whether to clear the backbuffer before drawing to it. YES = don't clear, NO = clear.
 @param sharegroup An OpenGL sharegroup or nil.
 @param multisampling Whether to enable multisampling (AA).
 @param samples The number of samples used in multisampling, from 0 (no AA) to `glGetIntegerv(GL_MAX_SAMPLES_APPLE)`. Only takes effect if the preceding multisampling parameters is set to `YES`. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)multisampling numberOfSamples:(unsigned int)samples;

/** Initializes an CCGLView with a frame and 0-bit depth buffer, and a RGB565 color buffer
 @param frame The frame of the view. */
- (id) initWithFrame:(CGRect)frame; //These also set the current context
/** Initializes an CCGLView with a frame, a color buffer format, and 0-bit depth buffer
 @param frame The frame of the view.
 @param format The pixel format of the render buffer, either: `kEAGLColorFormatRGBA8` (24-bit colors, 8-bit alpha) or `kEAGLColorFormatRGB565` (16-bit colors, no alpha). */
- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format;
/** Initializes an CCGLView with a frame, a color buffer format, a depth buffer format, a sharegroup and multisampling support
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
