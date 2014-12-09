/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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


#import <CoreGraphics/CGImage.h>

#import "ccTypes.h"


@class CCFile;


/**
 How much to rescale the image while loading it.
 
 The default value is 1.0.
 
 @warning Some image loaders may only support inverse powers of two (1/2, 1/4, etc)

 @since 4.0
 */
extern NSString * const CCImageOptionRescaleFactor;

/**
 Should the image dimensions be expanded to a power of two while loading?
 
 The default value is `NO`.

 @since 4.0
 */
extern NSString * const CCImageOptionExpandToPOT;

/**
 Should the image alpha be premultiplied while loading?
 
 The default value is YES.
 
 @warning Some image loaders only support pre-multiplied alpha.

 @since 4.0
 */
extern NSString * const CCImageOptionPremultiply;

/**
 Low level image handling class for RGBA8 bitmaps.
 */
@interface CCImage : NSObject<NSCoding>

/**
 Initialize a new image with raw pixel data. All default options are applied to the image.
 
 TODO Should this initializer support an options dictionary?
 TODO Should `pixelData` be allowed to be `nil`?

 @param pixelSize    Size of the image in pixels.
 @param contentScale Content scale of the image.
 @param pixelData    A pointer to raw, tightly packed, RGBA8 pixel data.

 @return An image object that wraps the given pixel data.

 @since 4.0
 */
-(instancetype)initWithPixelSize:(CGSize)pixelSize contentScale:(CGFloat)contentScale pixelData:(NSMutableData *)pixelData;

/**
 Initialize a new image from a CGImageRef.

 @param image        The CGImage to use as the image's content.
 @param contentScale The content scale the CGImage should be interpreted as.
 @param options      A dictionary of NSImageOption* key and NSNumbers for values.
 May be `nil`. Any keys not included will be filled with default values.

 @return An image with the CGImage loaded into it.

 @since 4.0
 */
-(instancetype)initWithCGImage:(CGImageRef)image contentScale:(CGFloat)contentScale options:(NSDictionary *)options;

/**
 Initialize an image based on a CCFileUtils file object.

 @param file    The CCFile to load the image data from.
 @param options A dictionary of NSImageOption* key and NSNumbers for values.
 May be `nil`. Any keys not included will be filled with default values.

 @return An image loaded from the file.

 @since 4.0
 */
-(instancetype)initWithCCFile:(CCFile *)file options:(NSDictionary *)options;

/**
 Size of the image's bitmap in pixels.

 @since 4.0
 */
@property(nonatomic, readonly) CGSize sizeInPixels;

/**
 Bitmap data pointer. The format will always be RGBA8.

 @since 4.0
 */
@property(nonatomic, readonly) NSMutableData *pixelData;

/**
 Content scale of the bitmap

 @since 4.0
 */
@property(nonatomic, readonly) CGFloat contentScale;

/**
 User assignable content size of the image in points.
 
 This value may not equal pixelSize/contentScale if the image is padded.
 It defaults to the original size of the image in points.

 @since 4.0
 */
@property(nonatomic, assign) CGSize contentSize;


// TODO Other thoughts:
// * Method to create a CGImage from the CCImage?
// * Method to capture the screen as a CCImage?

@end
