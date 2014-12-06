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


#import "CCImage.h"

#import "CCDeviceInfo.h"
#import "ccUtils.h"

#import "CCFile_Private.h"


NSString * const CCImageFlipVertical = @"CCImageFlipVertical";
NSString * const CCImageFlipHorizontal = @"CCImageFlipHorizontal";
NSString * const CCImageRescaleFactor = @"CCImageRescaleFactor";
NSString * const CCImageExpandToPOT = @"CCImageExpandToPOT";
NSString * const CCImagePremultiply = @"CCImagePremultiply";


@implementation CCImage {
    // Options the image was loaded with.
    NSDictionary *_options;
}

-(instancetype)initWithPixelSize:(CGSize)pixelSize contentScale:(CGFloat)contentScale pixelData:(NSData *)pixelData;
{
    if((self = [super init])){
        _pixelSize = pixelSize;
        
        _contentScale = contentScale;
        _contentSize = CC_SIZE_SCALE(pixelSize, 1.0/contentScale);
        
        // TODO?
        _options = nil;
        
        _premultipliedAlpha = YES;
        _flippedVertically = NO;
        _flippedHorizontally = NO;
        
        _pixelData = [pixelData copy];
    }
    
    return self;
}

static CGAffineTransform
DrawingTransform(CGSize pixelSize, CGSize imageSize, NSDictionary *options)
{
    // TODO handling flipping here.
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, pixelSize.height - imageSize.height);
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	transform = CGAffineTransformTranslate(transform, 0, -imageSize.height);
    
    return transform;
}

-(instancetype)initWithCGImage:(CGImageRef)image contentScale:(CGFloat)contentScale options:(NSDictionary *)options
{
	CCDeviceInfo *conf = [CCDeviceInfo sharedDeviceInfo];
    
    if(![options[CCImagePremultiply] boolValue]){
        CCLOGWARN(@"CCImagePremultiply: NO not supported for the core graphics loader.");
    }
    
    // Original size of the image.
    CGSize imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    // Size of the bitmap in pixels including POT padding.
    CGSize pixelSize = imageSize;
	if(![conf supportsNPOT] || [options[CCImageExpandToPOT] boolValue]){
		pixelSize.width = CCNextPOT(pixelSize.width);
		pixelSize.height = CCNextPOT(pixelSize.height);
	}

    NSUInteger maxTextureSize = [conf maxTextureSize];
    if(pixelSize.width > maxTextureSize || pixelSize.height > maxTextureSize){
        CCLOGWARN(@"cocos2d: Error: Image (%d x %d) is bigger than the maximum supported texture size %d",
            (int)pixelSize.width, (int)pixelSize.height, (int)maxTextureSize
        );
        
        return nil;
    }
    
    NSUInteger bytes = pixelSize.width*pixelSize.height*4;
    void *data = malloc(bytes);
    
    // Set up the CGContext to render the image to a bitmap.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo info = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(data, pixelSize.width, pixelSize.height, 8, pixelSize.width*4, colorSpace, info);
    
    // Render the image into the context.
	CGContextClearRect(context, (CGRect){CGPointZero, pixelSize});
    CGContextConcatCTM(context, DrawingTransform(pixelSize, imageSize, options));
	CGContextDrawImage(context, (CGRect){CGPointZero, imageSize}, image);
    
    CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	
    // Create a NSData object to wrap the pixel data.
    NSData *pixelData = [NSData dataWithBytesNoCopy:data length:bytes];
    
    if((self = [self initWithPixelSize:pixelSize contentScale:contentScale pixelData:pixelData])){
        _options = [options copy];
        
        _flippedVertically = [options[CCImageFlipVertical] boolValue];
        _flippedHorizontally = [options[CCImageFlipHorizontal] boolValue];
        _premultipliedAlpha = YES;
    }
    
    return self;
}

-(instancetype)initWithCoreGraphics:(CCFile *)file options:(NSDictionary *)options;
{
    CGImageSourceRef source = [file createCGImageSource];
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    
    self = [self initWithCGImage:image contentScale:file.contentScale options:options];
    CGImageRelease(image);
    
    return self;
}

static NSDictionary *
NormalizeOptions(NSDictionary *options)
{
    NSDictionary *defaults = @{
        CCImageFlipVertical: @(NO),
        CCImageFlipHorizontal: @(NO),
        CCImageRescaleFactor: @(1.0),
        CCImageExpandToPOT: @(NO),
        CCImagePremultiply: @(YES)
    };
    
    if(options){
        // Merge the default values with the user values.
        NSMutableDictionary *opts = [defaults mutableCopy];
        [opts addEntriesFromDictionary:options];
        
        return opts;
    } else {
        return defaults;
    }
}

-(instancetype)initWithCCFile:(CCFile *)file options:(NSDictionary *)options;
{
    if(YES){
        return [self initWithCoreGraphics:file options:options];
    } else {
        // TODO Add a libpng based loader.
        // TODO Add pdf loading because it would be really easy?
    }
}

#warning TODO
-(id)initWithCoder:(NSCoder *)coder
{
    return nil;
}

-(void)encodeWithCoder:(NSCoder *)coder
{

}

@end
