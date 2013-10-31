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

#import <Foundation/Foundation.h> //	for NSObject

#import "ccTypes.h"
#import "ccMacros.h"

#import "Platforms/CCGL.h" // OpenGL stuff
#import "Platforms/CCNS.h" // Next-Step stuff

@class CCSpriteFrame;

//CONSTANTS:

/** @typedef CCTexture2DPixelFormat
 Possible texture pixel formats
 */
typedef NS_ENUM(NSUInteger, CCTexturePixelFormat) {
	//! 32-bit texture: RGBA8888
	CCTexturePixelFormat_RGBA8888,
	//! 32-bit texture without Alpha channel. Don't use it.
	CCTexturePixelFormat_RGB888,
	//! 16-bit texture without Alpha channel
	CCTexturePixelFormat_RGB565,
	//! 8-bit textures used as masks
	CCTexturePixelFormat_A8,
	//! 8-bit intensity texture
	CCTexturePixelFormat_I8,
	//! 16-bit textures used as masks
	CCTexturePixelFormat_AI88,
	//! 16-bit textures: RGBA4444
	CCTexturePixelFormat_RGBA4444,
	//! 16-bit textures: RGB5A1
	CCTexturePixelFormat_RGB5A1,
	//! 4-bit PVRTC-compressed texture: PVRTC4
	CCTexturePixelFormat_PVRTC4,
	//! 2-bit PVRTC-compressed texture: PVRTC2
	CCTexturePixelFormat_PVRTC2,

	//! Default texture format: RGBA8888
	CCTexturePixelFormat_Default = CCTexturePixelFormat_RGBA8888,
};


@class CCGLProgram;

/** CCTexture2D class.
 * This class allows to easily create OpenGL 2D textures from images, text or raw data.
 * The created CCTexture2D object will always have power-of-two dimensions.
 * Depending on how you create the CCTexture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
 * Be aware that the content of the generated textures will be upside-down!
 */
@interface CCTexture : NSObject
{
	GLuint						_name;
	CGSize						_size;
	NSUInteger					_width,
								_height;
	CCTexturePixelFormat		_format;
	GLfloat						_maxS,
								_maxT;
	BOOL						_premultipliedAlpha;
	BOOL						_hasMipmaps;
    
    BOOL                        _antialiased;

	CCResolutionType			_resolutionType;

	// needed for drawAtRect, drawInPoint
	CCGLProgram					*_shaderProgram;

}
+ (id) textureWithFile:(NSString*)file;

/** Initializes with a texture2d with data */
- (id) initWithData:(const void*)data pixelFormat:(CCTexturePixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size;

/** pixel format of the texture */
@property(nonatomic,readonly) CCTexturePixelFormat pixelFormat;
/** width in pixels */
@property(nonatomic,readonly) NSUInteger pixelWidth;
/** hight in pixels */
@property(nonatomic,readonly) NSUInteger pixelHeight;

/** returns content size of the texture in pixels */
@property(nonatomic,readonly, nonatomic) CGSize contentSizeInPixels;

/** whether or not the texture has their Alpha premultiplied */
@property(nonatomic,readonly,getter=hasPremultipliedAlpha) BOOL premultipliedAlpha;

@property(nonatomic,assign,getter=isAntialiased) BOOL antialiased;

/** shader program used by drawAtPoint and drawInRect */
@property(nonatomic,readwrite,strong) CCGLProgram *shaderProgram;

/** Returns the resolution type of the texture.
 Is it a RetinaDisplay texture, an iPad texture, a Mac, a Mac RetinaDisplay or an standard texture ?

 Should be a readonly property. It is readwrite as a hack.

 @since v1.1
 */
@property (nonatomic, readwrite) CCResolutionType resolutionType;


/** returns the content size of the texture in points */
-(CGSize) contentSize;


/**
 *  Creates a sprite frame from the texture.
 *
 *  @return A new sprite frame.
 *  @since v3.0
 */
-(CCSpriteFrame*) createSpriteFrame;


@end

/**
Extensions to make it easy to create a CCTexture2D object from an image file.
Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface CCTexture (Image)
/** Initializes a texture from a CGImage object */
- (id) initWithCGImage:(CGImageRef)cgImage resolutionType:(CCResolutionType)resolution;
@end


@interface CCTexture (PixelFormat)
/** sets the default pixel format for CGImages that contains alpha channel.
 If the CGImage contains alpha channel, then the options are:
	- generate 32-bit textures: kCCTexture2DPixelFormat_RGBA8888 (default one)
	- generate 16-bit textures: kCCTexture2DPixelFormat_RGBA4444
	- generate 16-bit textures: kCCTexture2DPixelFormat_RGB5A1
	- generate 24-bit textures: kCCTexture2DPixelFormat_RGB888 (no alpha)
	- generate 16-bit textures: kCCTexture2DPixelFormat_RGB565 (no alpha)
	- generate 8-bit textures: kCCTexture2DPixelFormat_A8 (only use it if you use just 1 color)

 How does it work ?
   - If the image is an RGBA (with Alpha) then the default pixel format will be used (it can be a 8-bit, 16-bit or 32-bit texture)
   - If the image is an RGB (without Alpha) then: If the default pixel format is RGBA8888 then a RGBA8888 (32-bit) will be used. Otherwise a RGB565 (16-bit texture) will be used.

 This parameter is not valid for PVR / PVR.CCZ images.

 @since v0.8
 */
+(void) setDefaultAlphaPixelFormat:(CCTexturePixelFormat)format;

/** returns the alpha pixel format
 @since v0.8
 */
+(CCTexturePixelFormat) defaultAlphaPixelFormat;

/** returns the bits-per-pixel of the in-memory OpenGL texture
 @since v1.0
 */
-(NSUInteger) bitsPerPixelForFormat;

/** returns the pixel format in a NSString.
 @since v2.0
 */
-(NSString*) stringForFormat;


/** Helper functions that returns bits per pixels for a given format.
 @since v2.0
 */
+(NSUInteger) bitsPerPixelForFormat:(CCTexturePixelFormat)format;

@end





