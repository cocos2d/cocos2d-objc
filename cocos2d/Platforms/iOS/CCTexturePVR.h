/*

File: PVRTexture.h
Abstract: The PVRTexture class is responsible for loading .pvr files.

Version: 1.0

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
#import <OpenGLES/ES1/glext.h>

#import "CCTextureCache.h"
#import "CCTexture2D.h"

#pragma mark -
#pragma mark CCTextureCache PVR extension

@interface CCTextureCache (PVR)

/** Returns a Texture2D object given an PVRTC RAW filename
 * If the file image was not previously loaded, it will create a new CCTexture2D
 *  object and it will return it. Otherwise it will return a reference of a previosly loaded image
 *
 * It can only load square images: width == height, and it must be a power of 2 (128,256,512...)
 * bpp can only be 2 or 4. 2 means more compression but lower quality.
 * hasAlpha: whether or not the image contains alpha channel
 *
 * IMPORTANT: This method is only defined on iOS. It is not supported on the Mac version.
 */
-(CCTexture2D*) addPVRTCImage:(NSString*)fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w;

/** Returns a Texture2D object given an PVRTC filename
 * If the file image was not previously loaded, it will create a new CCTexture2D
 *  object and it will return it. Otherwise it will return a reference of a previosly loaded image
 *
 * IMPORTANT: This method is only defined on iOS. It is not supported on the Mac version.
 *
 */
-(CCTexture2D*) addPVRTCImage:(NSString*) filename;

@end


#pragma mark -
#pragma mark CCTexture2D PVR extension

/**
 Extensions to make it easy to create a CCTexture2D object from a PVRTC file
 Note that the generated textures don't have their alpha premultiplied - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
 */
@interface CCTexture2D (PVR)
/** Initializes a texture from a PVR Texture Compressed (PVRTC) buffer
 *
 * IMPORTANT: This method is only defined on iOS. It is not supported on the Mac version.
 */
-(id) initWithPVRTCData: (const void*)data level:(int)level bpp:(int)bpp hasAlpha:(BOOL)hasAlpha length:(int)length;
/** Initializes a texture from a PVR file.
 
 Supported PVR formats:
 - BGRA 8888
 - RGBA 8888
 - RGBA 4444
 - RGBA 5551
 - RBG 565
 - A 8
 - I 8
 - AI 8
 - PVRTC 2BPP
 - PVRTC 4BPP
 
 By default PVR images are treated as if they alpha channel is NOT premultiplied. You can override this behavior with this class method:
 - PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied;
 
 IMPORTANT: This method is only defined on iOS. It is not supported on the Mac version.
 
 */
-(id) initWithPVRFile: (NSString*) file;

/** treats (or not) PVR files as if they have alpha premultiplied.
 Since it is impossible to know at runtime if the PVR images have the alpha channel premultiplied, it is
 possible load them as if they have (or not) the alpha channel premultiplied.
 
 By default it is disabled by default.
 
 @since v0.99.5
 */
+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied;
@end

#pragma mark -
#pragma mark CCTexturePVR

@interface CCTexturePVR : NSObject
{
	NSMutableArray *imageData_;
	
	int		tableFormatIndex_;
	uint32_t width_, height_;
	GLuint	name_;
	BOOL hasAlpha_;
	
	// cocos2d integration
	BOOL retainName_;
}

- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithContentsOfURL:(NSURL *)url;
+ (id)pvrTextureWithContentsOfFile:(NSString *)path;
+ (id)pvrTextureWithContentsOfURL:(NSURL *)url;

@property (nonatomic,readonly) GLuint name;
@property (nonatomic,readonly) uint32_t width;
@property (nonatomic,readonly) uint32_t height;
@property (nonatomic,readonly) BOOL hasAlpha;

// cocos2d integration
@property (nonatomic,readwrite) BOOL retainName;

@end


