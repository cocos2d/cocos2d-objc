//
//  CCFont.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFont.h"

#import "CCFont_Internal.h"

#import "CCFontCoreGraphics.h"




@implementation CCFont
{
    CCGlyphCollection _usedGlyphs;
    NSString* _customGlyphs;
}

+ (instancetype) fontWithTTFFilePath:(NSString*)fontPath size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    return [CCFontCoreGraphics fontWithTTFFilePath:fontPath size:fontSize glyphs:glyphs customGlyphs:customGlyphs];
}

- (CCFontAtlas*) makeFontAtlas
{
    NSAssert(NO, @"Override me!");
    return nil;
}

- (CGSize*) getAdvancesForText:(NSString*)text outLength:(int*)length
{
    NSAssert(NO, @"Override me!");
    return nil;
}

- (NSString*) currentGlyphCollection
{
    if (_customGlyphs) {
        return _customGlyphs;
    } else {
        return [self glyphCollection:_usedGlyphs];
    }
}


- (unsigned char*) glyphBitmapWithCharacter:(unichar)theChar outWidth:(NSUInteger*)width outHeight:(NSUInteger*)height
{
    return NULL;
}

- (NSArray*) glyphDefintionsForText:(NSString*)text
{
    return nil;
}

- (CGRect) rectForCharacter:(unichar)theChar
{
    return CGRectZero;
}

static NSString* _glyphASCII = @"\"!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþ ";

static NSString*  _glyphNEHE =  @"!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ";


- (NSString*) glyphCollection:(CCGlyphCollection)glyphs
{
    switch (glyphs) {
        case CCGlyphCollectionNeHe:
            return _glyphNEHE;
            break;
        case CCGlyphCollectionASCII:
            return _glyphASCII;
            break;
        default:
            return nil;
            break;
    }
}


- (void) setCurrentGlyphCollection:(CCGlyphCollection)glyphs
{
    [self setCurrentGlyphCollection:glyphs customGlyphs:nil];
}

- (void) setCurrentGlyphCollection:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    switch (glyphs)
    {
        case CCGlyphCollectionNeHe:
            _customGlyphs = nil;
            break;
            
        case CCGlyphCollectionASCII:
            _customGlyphs = nil;
            break;
            
        default:
            if (customGlyphs) {
                _customGlyphs = customGlyphs;
            }
            
            break;
    }

}


@end
