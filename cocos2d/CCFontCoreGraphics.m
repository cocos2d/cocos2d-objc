//
//  CCFontCoreGraphics.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFontCoreGraphics.h"

#import <CoreText/CoreText.h>

#import "CCFontAtlas.h"

@implementation CCFontCoreGraphics
{
    CTFontRef font_;
    NSString* fontName_;
    CGFloat fontSize_;
}



+ (instancetype) fontWithFontName:(NSString*)fontName size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    return [[self alloc] initWithFontName:fontName size:fontSize glyphs:glyphs customGlyphs:customGlyphs];
}

- (instancetype) initWithFontName:(NSString*)fontName size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    if (self = [super init]) {
        font_ = CTFontCreateWithName((__bridge CFStringRef)(fontName), fontSize, NULL);
        _isDynamicGlyphCollection = glyphs == CCGlyphCollectionDynamic;
        fontName_ = fontName;
        fontSize_ = fontSize;
    }
    return self;
}

- (CCFontAtlas*) makeFontAtlas
{
    if (_isDynamicGlyphCollection) {
        CCFontAtlas* atlas = [[CCFontAtlas alloc] initWithFont:self];
        return atlas;
    } else {
        return nil;
//    
//        FontDefinitionTTF *def = FontDefinitionTTF::create(this);
//        
//        if (!def)
//            return nullptr;
//        
//        FontAtlas *atlas = def->createFontAtlas();
//        
//        return atlas;
    }
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
    
    CGSize translation;
    
    CTFontGetVerticalTranslationsForGlyphs(font_, &glyph, &translation, 1);
    CTFontGetBoundingRectsForGlyphs(font_, kCTFontOrientationDefault, &glyph, outRect, 1);
    
    outRect->origin.x = 0;
    outRect->origin.y = translation.height;
    
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
    
    if (!context) {
        free(data);
        return NULL;
    }
    
    CGContextSetGrayFillColor(context, 1.0f, 1.0f);

    UIGraphicsPushContext(context);
    
    CGPoint p = ccp(-bounds.origin.x, -bounds.origin.y);
    CTFontDrawGlyphs(font_, &glyph, &p, 1, context);
    
    UIGraphicsPopContext();
    
    for (int j=0; j < h; ++j) {
        for (int i=0; i < w; ++i)
            putchar(" .:ioVM@"[data[j*w+i]>>5]);
        putchar('\n');
    }
    return data;
}

- (CGFloat) fontMaxHeight
{
    return CTFontGetBoundingBox(font_).size.height;
}

- (CGSize*) getAdvancesForText:(NSString *)text
{
    CGSize* advances = calloc([text length], sizeof(CGSize));
    CGGlyph* glyphs = calloc([text length], sizeof(CGGlyph));
    unichar* chars = calloc([text length], sizeof(unichar));
    [text getCharacters:chars];
    
    if (!CTFontGetGlyphsForCharacters(font_, chars, glyphs, [text length])) {
        NSAssert(NO, @"Cannot get glyphs for characters");
        return NULL;
    }

    CTFontGetAdvancesForGlyphs(font_, kCTFontDefaultOrientation, glyphs, advances, [text length]);
    free(glyphs);
    free(chars);
    
    return (CGSize*)[[NSData dataWithBytesNoCopy:advances length:[text length] * sizeof(CGSize)] bytes];
}

- (void) dealloc
{
    CFRelease(font_);
}
@end
