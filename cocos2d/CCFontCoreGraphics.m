//
//  CCFontCoreGraphics.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFontCoreGraphics.h"

#import <CoreText/CoreText.h>

@implementation CCFontCoreGraphics
{
    CTFontRef font_;
    NSString* fontName_;
    CGFloat fontSize_;
}


- (instancetype) initWithFontName:(NSString*)fontName size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    if (self = [super init]) {
        font_ = CTFontCreateWithName((__bridge CFStringRef)(fontName), fontSize, NULL);
        fontName_ = fontName;
        fontSize_ = fontSize;
    }
    return self;
}

- (CGFloat) advanceForChar:(unichar)theChar
{
    CGGlyph glyph;
    if (!CTFontGetGlyphsForCharacters(font_, &theChar, &glyph, 1)) {
        NSAssert1(NO, @"Cannot get glyph for character: %c", theChar);
        return 0.0f;
    }
    
    return CTFontGetAdvancesForGlyphs(font_, kCTFontOrientationDefault, &glyph, NULL, 1);
}


- (BOOL) getBBOXForCharacter:(unichar)theChar rect:(CGRect*)outRect
{
    CGGlyph glyph;
    if (!CTFontGetGlyphsForCharacters(font_, &theChar, &glyph, 1)) {
        NSAssert1(NO, @"Cannot get glyph for character: %c", theChar);
        return NO;
    }
    
    if (!outRect) {
        NSAssert(NO, @"Out rect parameter is nil");
        return NO;
    }
    
    CTFontGetBoundingRectsForGlyphs(font_, kCTFontOrientationDefault, &glyph, outRect, 1);
    
    return YES;
}

- (unsigned char*) glyphBitmapWithCharacter:(unichar)theChar outWidth:(NSUInteger*)width outHeight:(NSUInteger*)height
{
    CGGlyph glyph;
    if (!CTFontGetGlyphsForCharacters(font_, &theChar, &glyph, 1)) {
        NSAssert1(NO, @"Cannot get glyph for character: %c", theChar);
        return NULL;
    }
    
    CGRect bounds = CTFontGetBoundingRectsForGlyphs(font_, kCTFontOrientationDefault, &glyph, NULL, 1);
    
    NSUInteger w = ceilf(bounds.size.width);
    NSUInteger h = ceilf(bounds.size.height);
    
    unsigned char* data = malloc(w * h);
    memset(data, 0, w * h);
    
    *width = w;
    *height = h;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (!context)
    {
        free(data);
        return NULL;
    }
    
    CGContextSetGrayFillColor(context, 1.0f, 1.0f);

    UIGraphicsPushContext(context);
    
    
    CGPoint p = {0, 0};
    
    CTFontDrawGlyphs(font_, &glyph, &p, 1, context);
   // [str drawInRect:CGRectMake(0, 0, s.width, s.height) withFont:f];
    CGContextShowGlyphsAtPoint(context, 0, 0, &glyph, 1);
    
    //CGContextShowGlyphs(context, &glyph, 1);
    
    UIGraphicsPopContext();
    
    for (int j=0; j < h; ++j) {
        for (int i=0; i < w; ++i)
            putchar(" .:ioVM@"[data[j*w+i]>>5]);
        putchar('\n');
    }
    return data;
}

- (void) dealloc
{
    CFRelease(font_);
}
@end
