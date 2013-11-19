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

#import "CCFontDefinition.h"
#import "CCTextImage.h"
#import "CCFont_Internal.h"

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
        _letterPadding = 5.0f;
        font_ = CTFontCreateWithName((__bridge CFStringRef)(fontName), fontSize, NULL);
        _usedGlyphs = glyphs;
        _isDynamicGlyphCollection = glyphs == CCGlyphCollectionDynamic;
        fontName_ = fontName;
        fontSize_ = fontSize;
        
        [self setCurrentGlyphCollection:glyphs customGlyphs:customGlyphs];
    }
    return self;
}

- (CCFontAtlas*) makeFontAtlas
{
    if (_isDynamicGlyphCollection) {
        CCFontAtlas* atlas = [[CCFontAtlas alloc] initWithFont:self];
        return atlas;
    } else {
        CCFontDefinitionTTF* def = [[CCFontDefinitionTTF alloc] initWithFont:self];
        return [def makeFontAtlas];
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
    
    outRect->origin.x = 0.0f;
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
    CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
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
    
//    for (int j=0; j < h; ++j) {
//        for (int i=0; i < w; ++i)
//            putchar(" .:ioVM@"[data[j*w+i]>>5]);
//        putchar('\n');
//    }
    
    return [[NSMutableData dataWithBytesNoCopy:data length:w * h] mutableBytes];
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
    
    // receiver should free result
    return advances;
}

- (NSArray*) glyphDefintionsForText:(NSString *)text
{
    //
    if  (!text)
        return nil;
    
    NSUInteger numChar = [text length];
    if (!numChar)
        return nil;
    
    // allocate the needed Glyphs
    NSMutableArray* glyphs = [[NSMutableArray alloc] initWithCapacity:numChar];
    for (NSUInteger i = 0; i < numChar; i++) {
        [glyphs addObject:[CCGlyphDef new]];
    }
    
    if (!glyphs)
        return nil;
    
    // sore result as CCRect
    for (int c = 0; c < numChar; ++c) {
        unichar character = [text characterAtIndex:c];
        CGRect tempRect;
        if (![self getBBOXForCharacter:character rect:&tempRect]) {
            CCLOGWARN(@"Cannot find definition for glyph: %C in font: %@", character, fontName_);
        
            
            CCGlyphDef* glyph = [glyphs objectAtIndex:c];
            glyph.rect = CGRectZero;
            glyph.letter = character;
            glyph.valid = NO;
            glyph.padding = _letterPadding;
            
        } else {
            CCGlyphDef* glyph = [glyphs objectAtIndex:c];
            glyph.rect = tempRect;
            glyph.letter = character;
            glyph.valid = YES;
            glyph.padding = _letterPadding;
        }
    }
    
    // done
    return glyphs;
}


- (void) dealloc
{
    CFRelease(font_);
}
@end
