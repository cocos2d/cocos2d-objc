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


extern NSString * const CCImageFlipVertical;
extern NSString * const CCImageFlipHorizontal;
extern NSString * const CCImageRescaleFactor;
extern NSString * const CCImageExpandToPOT;
extern NSString * const CCImagePremultiply;


@interface CCImage : NSObject<NSCoding>

// Designated initializer for 32 bit RGBA bitmaps.
// Should accept a nil ‘pixelData’ argument to support empty bitmaps (or textures).
-(instancetype)initWithPixelSize:(CGSize)pixelSize contentScale:(CGFloat)contentScale pixelData:(NSData *)pixelData;

// Designated initializer.
-(instancetype)initWithCGImage:(CGImageRef)image contentScale:(CGFloat)contentScale options:(NSDictionary *)options;

// Load an image based on a CCFileUtils file object.
// Image format should be automatically detected,
// content scale calculated by CCFileUtils, etc.
// 'options' would include flags could include things such as flipping,
// scaling, expand to POT size, or pre-multiplying the alpha.
-(instancetype)initWithCCFile:(CCFile *)file options:(NSDictionary *)options;

// Will probably add more convenience initializers if they come up. (suggestions?)

// Size of the bitmap in pixels.
@property(nonatomic, readonly) CGSize pixelSize;

// Content scale of the bitmap.
@property(nonatomic, readonly) CGFloat contentScale;

// Content size of the contents.
// Not required to match pixelSize/contentScale if, for example, loading a non-POT sized image into a POT sized one.
@property(nonatomic, assign) CGSize contentSize;

// Bitmap data pointer.
@property(nonatomic, readonly) NSData *pixelData;

// Whether the bitmap should be interpreted as being flipped vertically or not.
@property(nonatomic, assign) BOOL flippedVertically;

// Whether the bitmap should be interpreted as being flipped horizontally or not.
@property(nonatomic, assign) BOOL flippedHorizontally;

// Whether the bitmap should be interpreted as having premultiplied alpha or not.
@property(nonatomic, assign) BOOL premultipliedAlpha;

// TODO Other thoughts:
// * Method to create a CGImage from the CCBitmap?
// * Method to capture the screen as a CCBitmap?

@end
