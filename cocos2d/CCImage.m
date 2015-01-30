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


#import "CCImage_Private.h"

#import "CCDeviceInfo.h"
#import "CCColor.h"
#import "ccUtils.h"

#import "CCFile_Private.h"


NSString * const CCImageOptionFlipVertical = @"CCImageOptionFlipVertical";
NSString * const CCImageOptionFlipHorizontal = @"CCImageOptionFlipHorizontal";
NSString * const CCImageOptionRescaleFactor = @"CCImageOptionRescaleFactor";
NSString * const CCImageOptionExpandToPOT = @"CCImageOptionExpandToPOT";
NSString * const CCImageOptionPremultiply = @"CCImageOptionPremultiply";


@implementation CCImage {
    // Options the image was loaded with.
    NSDictionary *_options;
}

NSDictionary *DEFAULT_OPTIONS = nil;

+(void)initialize
{
    DEFAULT_OPTIONS = @{
        CCImageOptionFlipVertical: @(NO),
        CCImageOptionFlipHorizontal: @(NO),
        CCImageOptionRescaleFactor: @(1.0),
        CCImageOptionExpandToPOT: @(NO),
        CCImageOptionPremultiply: @(YES)
    };
}

static NSDictionary *
NormalizeOptions(NSDictionary *options)
{
    if(options == nil || options == DEFAULT_OPTIONS){
        return DEFAULT_OPTIONS;
    } else {
        // Merge the default values with the user values.
        NSMutableDictionary *opts = [DEFAULT_OPTIONS mutableCopy];
        [opts addEntriesFromDictionary:options];
        
        return opts;
    }
}

-(instancetype)initWithPixelSize:(CGSize)pixelSize contentScale:(CGFloat)contentScale pixelData:(NSMutableData *)pixelData options:(NSDictionary *)options;
{
    if((self = [super init])){
        _sizeInPixels.width = floor(pixelSize.width);
        _sizeInPixels.height = floor(pixelSize.height);
        
        _contentScale = contentScale;
        _contentSize = CC_SIZE_SCALE(pixelSize, 1.0/contentScale);
        
        _options = NormalizeOptions(options);
        
        _pixelData = pixelData;
    }
    
    return self;
}

-(instancetype)initWithPixelSize:(CGSize)pixelSize contentScale:(CGFloat)contentScale pixelData:(NSMutableData *)pixelData;
{
    return [self initWithPixelSize:pixelSize contentScale:contentScale pixelData:pixelData options:DEFAULT_OPTIONS];
}

-(instancetype)initWithPixelSize:(CGSize)pixelSize contentScale:(CGFloat)contentScale clearColor:(CCColor *)color options:(NSDictionary *)options
{
    NSUInteger bytes = pixelSize.width*pixelSize.height*4;
    NSMutableData *pixelData = [NSMutableData dataWithLength:bytes];
    
    // Convert to a RGBA8 color
    GLKVector4 color4f = color.glkVector4;
    uint8_t color4b[] = {255*color4f.r, 255*color4f.g, 255*color4f.b, 255*color4f.a};
    
    // Set the initial fill color.
    memset_pattern4(pixelData.mutableBytes, color4b, bytes);
    
    return [self initWithPixelSize:pixelSize contentScale:contentScale pixelData:pixelData options:options];
}

-(instancetype)initWithCGImage:(CGImageRef)image contentScale:(CGFloat)contentScale options:(NSDictionary *)options
{
    // Make the options are filled in and that it's not nil.
    options = NormalizeOptions(options);
    
    if(![options[CCImageOptionPremultiply] boolValue]){
        CCLOGWARN(@"CCImagePremultiply: NO ignored by the CoreGraphics loader.");
    }
    
    CGFloat rescaleFactor = [options[CCImageOptionRescaleFactor] doubleValue];
    contentScale *= rescaleFactor;
    
    // Original size of the image in pixels after rescaling.
    CGSize originalSizeInPixels = CC_SIZE_SCALE(CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image)), rescaleFactor);
    
    // Size of the bitmap in pixels including POT padding.
    CGSize sizeInPixels = originalSizeInPixels;
	if(![[CCDeviceInfo sharedDeviceInfo] supportsNPOT] || [options[CCImageOptionExpandToPOT] boolValue]){
		sizeInPixels.width = CCNextPOT(sizeInPixels.width);
		sizeInPixels.height = CCNextPOT(sizeInPixels.height);
	}
    
    if((self = [self initWithPixelSize:sizeInPixels contentScale:contentScale clearColor:[CCColor clearColor] options:options])){
        _contentSize = CC_SIZE_SCALE(originalSizeInPixels, 1.0/contentScale);
        
        CGContextRef context = [self createCGContext];
        CGContextDrawImage(context, (CGRect){CGPointZero, _contentSize}, image);
        CGContextRelease(context);
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

-(instancetype)initWithCCFile:(CCFile *)file options:(NSDictionary *)options;
{
    NSAssert(file, @"file is nil.");
    
    if(YES){
        return [self initWithCoreGraphics:file options:options];
    } else {
        // TODO Add a libpng based loader.
        // TODO Add pdf loading because it would be really easy?
    }
}

// TODO
-(id)initWithCoder:(NSCoder *)coder
{
    return nil;
}

-(void)encodeWithCoder:(NSCoder *)coder
{

}

#pragma mark CGContext creation.

-(CGAffineTransform)loadingTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if(![_options[CCImageOptionFlipVertical] boolValue]){
        transform = CGAffineTransformConcat(transform, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, _sizeInPixels.height));
    }
    
    if([_options[CCImageOptionFlipHorizontal] boolValue]){
        transform = CGAffineTransformConcat(transform, CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, _sizeInPixels.width, 0.0));
    }
    
    return CGAffineTransformScale(transform, _contentScale, _contentScale);
}

// Create a CGContext that is set up to use points for the drawing coordinates.
-(CGContextRef)createCGContext
{
    NSAssert(self.pixelData, @"Cannot render into a CCImage with a nil pixelData.");
    
    CGSize size = self.sizeInPixels;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo info = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(self.pixelData.mutableBytes, size.width, size.height, 8, size.width*4, colorSpace, info);
    
    CGContextConcatCTM(context, [self loadingTransform]);
    
    CGColorSpaceRelease(colorSpace);
    return context;
}

@end
