//
//  CCTextImage.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 14.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCTextImage.h"

@implementation CCGlyphDef

- (instancetype) init
{
    if (self = [super init]) {
        _valid = NO;
    }
    return self;
}

- (instancetype) initWithLetter:(unichar)letter andRect:(CGRect)rect
{
    if (self = [super init]) {
        _letter = letter;
        _rect = rect;
    }
    return self;
}


@end

@implementation CCTextLineDef
{
    CGRect _rect;
    NSMutableArray* _glyphs;
}

- (instancetype) initWithRect:(CGRect)rect
{
    if (self = [super init]) {
        _glyphs = [[NSMutableArray alloc] initWithCapacity:8];
        _rect = rect;
    }
    return self;
}

- (void) addGlyph:(CCGlyphDef*)glyph
{
    [_glyphs addObject:glyph];
}

- (NSUInteger) glyphCount
{
    return [_glyphs count];
}

- (CCGlyphDef*) glyphAtIndex:(NSUInteger)idx
{
    NSAssert(idx < [_glyphs count], @"Index out of bounds");
    return [_glyphs objectAtIndex:idx];
}


@end

@implementation CCTextPageDef
{
    NSMutableArray* _lines;
}

@synthesize pageTexture = _pageTexture;

- (instancetype) initWithPageNumber:(NSUInteger)pageNumber andSize:(CGSize)size
{
    if (self = [super init]) {
        _lines = [[NSMutableArray alloc] initWithCapacity:8];
        _pageNumber = pageNumber;
        _size = size;
        
    }
    return self;
}

- (void) addLine:(CCTextLineDef*)line
{
    [_lines addObject:line];
}

- (CCTextLineDef*) lineAtIndex:(NSUInteger)idx
{
    NSAssert(idx < [_lines count], @"Index out of bounds");
    return [_lines objectAtIndex:idx];
}

- (BOOL) generatePageTexture:(BOOL)releasePageData
{
    if (!_pageData)
        return NO;

    
    if((_size.width <= 0) || (_size.height <= 0))
        return NO;
    

    NSUInteger pixelWidth = _size.width;
    NSUInteger pixelHeight = _size.height;
    
    _pageTexture = [[CCTexture alloc] initWithData:_pageData pixelFormat:CCTexturePixelFormat_RGBA8888 pixelsWide:pixelWidth pixelsHigh:pixelHeight contentSize:_size];

    if (!_pageTexture)
        return NO;
    
    // release the page data if requested
    if (releasePageData) {
        free(_pageData);
        _pageData = NULL;
    }
    
    return _pageTexture != nil;
}

- (void) preparePageTextureWithReleaseData:(BOOL)releaseData
{
    [self generatePageTexture:releaseData];
}

- (void) preparePageTexture
{
    [self generatePageTexture:YES];
}

- (CCTexture*) pageTexture
{
    if (_pageTexture == nil) {
        [self generatePageTexture:NO];
    }
    return _pageTexture;
}

@end

@implementation CCTextFontPages
{
    NSMutableArray* _pages;
}

- (instancetype) init
{
    if (self = [super init]) {
        _pages = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return self;
}

- (void) addPage:(CCTextPageDef*)page
{
    [_pages addObject:page];
}

- (CCTextPageDef*) pageAtIndex:(NSUInteger)idx
{
    NSAssert(idx < [_pages count], @"Index out of bounds");
    return [_pages objectAtIndex:idx];
}

- (NSUInteger) pageCount
{
    return [_pages count];
}

@end

@implementation CCTextImage

- (instancetype) initWithString:(NSString*)text size:(CGSize)size font:(CCFont*)font
{
    return [self initWithString:text size:size font:font releaseData:YES];
}

- (instancetype) initWithString:(NSString*)text size:(CGSize)size font:(CCFont*)font releaseData:(BOOL)releaseData
{
    if (self = [super init]) {
        _font = font;
    }
    return self;
}


@end
