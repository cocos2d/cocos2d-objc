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

File: Texture2D.h
Abstract: Creates OpenGL 2D textures from images or text.

Version: 1.6

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

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

//CONSTANTS:

/** @typedef CCTexture2DPixelFormat
 Possible texture pixel formats
 */
typedef enum {
	kCCTexture2DPixelFormat_Automatic = 0,
	//! 32-bit texture: RGBA8888
	kCCTexture2DPixelFormat_RGBA8888,
	//! 16-bit texture: used with images that have alpha pre-multiplied
	kCCTexture2DPixelFormat_RGB565,
	//! 8-bit textures used as masks
	kCCTexture2DPixelFormat_A8,
	//! 16-bit textures: RGBA4444
	kCCTexture2DPixelFormat_RGBA4444,
	//! 16-bit textures: RGB5A1
	kCCTexture2DPixelFormat_RGB5A1,	

	//! Default texture format: RGBA8888
	kCCTexture2DPixelFormat_Default = kCCTexture2DPixelFormat_RGBA8888,

	// backward compatibility stuff
	kTexture2DPixelFormat_Automatic = kCCTexture2DPixelFormat_Automatic,
	kTexture2DPixelFormat_RGBA8888 = kCCTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGB565 = kCCTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_A8 = kCCTexture2DPixelFormat_A8,
	kTexture2DPixelFormat_RGBA4444 = kCCTexture2DPixelFormat_RGBA4444,
	kTexture2DPixelFormat_RGB5A1 = kCCTexture2DPixelFormat_RGB5A1,
	kTexture2DPixelFormat_Default = kCCTexture2DPixelFormat_Default
	
} CCTexture2DPixelFormat;

//CLASS INTERFACES:

/** CCTexture2D class.
 * This class allows to easily create OpenGL 2D textures from images, text or raw data.
 * The created CCTexture2D object will always have power-of-two dimensions. 
 * Depending on how you create the CCTexture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
 * Be aware that the content of the generated textures will be upside-down!
 */
@interface CCTexture2D : NSObject
{
	GLuint						_name;
	CGSize						_size;
	NSUInteger					_width,
								_height;
	CCTexture2DPixelFormat		_format;
	GLfloat						_maxS,
								_maxT;
	BOOL						_hasPremultipliedAlpha;
}
/** Intializes with a texture2d with data */
- (id) initWithData:(const void*)data pixelFormat:(CCTexture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size;

/** pixel format of the texture */
@property(nonatomic,readonly) CCTexture2DPixelFormat pixelFormat;
/** width in pixels */
@property(nonatomic,readonly) NSUInteger pixelsWide;
/** hight in pixels */
@property(nonatomic,readonly) NSUInteger pixelsHigh;

/** texture name */
@property(nonatomic,readonly) GLuint name;

/** content size */
@property(nonatomic,readonly, nonatomic) CGSize contentSize;
/** texture max S */
@property(nonatomic,readwrite) GLfloat maxS;
/** texture max T */
@property(nonatomic,readwrite) GLfloat maxT;
/** whether or not the texture has their Alpha premultiplied */
@property(nonatomic,readonly) BOOL hasPremultipliedAlpha;
@end

/**
Drawing extensions to make it easy to draw basic quads using a CCTexture2D object.
These functions require GL_TEXTURE_2D and both GL_VERTEX_ARRAY and GL_TEXTURE_COORD_ARRAY client states to be enabled.
*/
@interface CCTexture2D (Drawing)
/** draws a texture at a given point */
- (void) drawAtPoint:(CGPoint)point;
/** draws a texture inside a rect */
- (void) drawInRect:(CGRect)rect;
@end

/**
Extensions to make it easy to create a CCTexture2D object from an image file.
Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface CCTexture2D (Image)
/** Initializes a texture from a UIImage object */
- (id) initWithImage:(UIImage *)uiImage;
@end

/**
Extensions to make it easy to create a CCTexture2D object from a string of text.
Note that the generated textures are of type A8 - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface CCTexture2D (Text)
/** Initializes a texture from a string with dimensions, alignment, font name and font size */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** Initializes a texture from a string with font name and font size */
- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
@end

/**
 Extensions to make it easy to create a CCTexture2D object from a PVRTC file
 Note that the generated textures don't have their alpha premultiplied - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
 */
@interface CCTexture2D (PVRTC)
/** Initializes a texture from a PVRTC buffer */
-(id) initWithPVRTCData: (const void*)data level:(int)level bpp:(int)bpp hasAlpha:(BOOL)hasAlpha length:(int)length;
/** Initializes a texture from a PVRTC file */
-(id) initWithPVRTCFile: (NSString*) file;
@end

/**
 Extension to set the Min / Mag filter
 */
typedef struct _ccTexParams {
	GLuint	minFilter;
	GLuint	magFilter;
	GLuint	wrapS;
	GLuint	wrapT;
} ccTexParams;

@interface CCTexture2D (GLFilter)
/** sets the min filter, mag filter, wrap s and wrap t texture parameters.
 If the texture size is NPOT (non power of 2), then in can only use GL_CLAMP_TO_EDGE in GL_TEXTURE_WRAP_{S,T}.
 @since v0.8
 */
-(void) setTexParameters: (ccTexParams*) texParams;

/** sets antialias texture parameters:
  - GL_TEXTURE_MIN_FILTER = GL_LINEAR
  - GL_TEXTURE_MAG_FILTER = GL_LINEAR

 @since v0.8
 */
- (void) setAntiAliasTexParameters;

/** sets alias texture parameters:
  - GL_TEXTURE_MIN_FILTER = GL_NEAREST
  - GL_TEXTURE_MAG_FILTER = GL_NEAREST
 
 @since v0.8
 */
- (void) setAliasTexParameters;


/** Generates mipmap images for the texture.
 It only works if the texture size is POT (power of 2).
 @since v0.99.0
 */
-(void) generateMipmap;


@end

@interface CCTexture2D (PixelFormat)
/** sets the default pixel format for UIImages that contains alpha channel.
 If the UIImage contains alpha channel, then the options are:
	- generate 32-bit textures: kCCTexture2DPixelFormat_RGBA8888 (default one)
	- generate 16-bit textures: kCCTexture2DPixelFormat_RGBA4444
	- generate 16-bit textures: kCCTexture2DPixelFormat_RGB5A1
	- generate 16-bit textures: kCCTexture2DPixelFormat_RGB565
	- generate 8-bit textures: kCCTexture2DPixelFormat_A8 (only use it if you use just 1 color)

 How does it work ?
   - If the image is an RGBA (with Alpha) then the default pixel format will be used (it can be a 8-bit, 16-bit or 32-bit texture)
   - If the image is an RGB (without Alpha) then an RGB565 texture will be used (16-bit texture)
 
 @since v0.8
 */
+(void) setDefaultAlphaPixelFormat:(CCTexture2DPixelFormat)format;

/** returns the alpha pixel format
 @since v0.8
 */
+(CCTexture2DPixelFormat) defaultAlphaPixelFormat;
@end



