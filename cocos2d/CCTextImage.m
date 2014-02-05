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

- (NSUInteger) lineCount
{
    return [_lines count];
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
{
    NSMutableDictionary* _textGlyphs;
}

@synthesize pages = _fontPages;

- (instancetype) initWithString:(NSString*)text size:(CGSize)size font:(CCFont*)font
{
    return [self initWithString:text size:size font:font releaseData:YES];
}

- (instancetype) initWithString:(NSString*)text size:(CGSize)size font:(CCFont*)font releaseData:(BOOL)releaseData
{
    if (self = [super init]) {
        _textGlyphs = [[NSMutableDictionary alloc] initWithCapacity:[text length]];
        
        // carloX
        _font = font;
        
        // generate the glyphs for the requested text (glyphs are latter's bounding boxes)
        if (![self generateTextGlyphs:text])
            return nil;
        
        if (![text length])
            return nil;
        
        // create all the needed pages
        if (![self makePageDefinitionsWithText:text size:size lineHeight:[_font fontMaxHeight]])
            return nil;
        
        // actually create the needed images
        if (![self makeImageDataFromPages:_fontPages releaseData:releaseData])
            return nil;
    }
    return self;
}

- (BOOL) makePageDefinitionsWithText:(NSString*)text size:(CGSize)size lineHeight:(CGFloat)lineHeight
{
    int   delta             = 0;
    int   currentPage       = 0;
    float currentY          = 0.0;
    
    
    // create pages for the font
    _fontPages = [[CCTextFontPages alloc] init];
    if (!_fontPages)
        return NO;
    
    // create the first page (ther is going to be at least one page)
    CCTextPageDef* currentPageDef = [[CCTextPageDef alloc] initWithPageNumber:currentPage andSize:size];
    if (!currentPageDef)
        return NO;
    
    // add the current page
    [_fontPages addPage:currentPageDef];
    
    // work out creating pages
    
    do {
        
        // choose texture page
        if ((currentY + lineHeight) > size.height)
        {
            currentY     = 0;
            currentPage += 1;
            
            // create a new page and add
            currentPageDef = [[CCTextPageDef alloc] initWithPageNumber:currentPage andSize:size];
            if (!currentPageDef)
                return NO;
            
            [_fontPages addPage:currentPageDef];
        }
        
        // get the new fitting string
        CGSize tempSize = size;
        
        // figure out how many glyphs fit in this line
        CGFloat newLineSize    = 0;
        NSUInteger numFittingChar = [self numGlyphs:_textGlyphs forString:text fittingSize:tempSize newSize:&newLineSize];
        
        // crete the temporary new string
        NSString* tempString = [text substringToIndex:numFittingChar - 1];
        
        // create the new line and add to the current page
        CCTextLineDef* newLine = [[CCTextLineDef alloc] initWithRect:CGRectMake(0.0, currentY, newLineSize, lineHeight)];
        if (!newLine)
            return NO;
        
        // add all the glyphs to this line
        [self addGlyphsToLine:newLine glyphs:tempString];
        
        // add the line the to current page
        [currentPageDef addLine:newLine];
        
        
        // create the new string
        NSUInteger stringLength = [text length];
        delta = (stringLength - numFittingChar);
        
        // there is still some leftover, need to work on it
        if (delta) {
            // create the new string
            NSString* tempS = [text substringWithRange:NSMakeRange(numFittingChar, stringLength - numFittingChar - 1)];
            text = tempS;
        }
        
        // go to next line
        currentY += lineHeight;
        
    } while(delta);
    
    return true;

}

- (NSUInteger) numGlyphs:(NSDictionary*)glyphs forString:(NSString*)str fittingSize:(CGSize)constrainSize newSize:(CGFloat*)outNewSize
{
    if (!str)
        return 0;
    
    CGFloat widthWithBBX  =  0.0f;
    CGFloat lastWidth     =  0.0f;
    
    // get the string to UTF8
    NSUInteger numChar = [str length];
    
    for (NSUInteger c = 0; c < numChar; ++c) {
        unichar character = [str characterAtIndex:c];
        CCGlyphDef* glyph = [glyphs objectForKey:@(character)];
        
        widthWithBBX += glyph.rect.size.width + glyph.padding;
        
        if (widthWithBBX >= constrainSize.width) {
            if (outNewSize)
                *outNewSize = lastWidth;
            return c;
        }
        
        lastWidth = widthWithBBX;
    }
    if (outNewSize)
        *outNewSize = constrainSize.width;
    return numChar;
}

- (BOOL) addGlyphsToLine:(CCTextLineDef*)line glyphs:(NSString*)glyphs
{
    if (!_font)
        return NO;
    
    NSUInteger numLetters = [glyphs length];
    for (NSUInteger c = 0; c < numLetters; c++) {
        unichar character = [glyphs characterAtIndex:c];
        CCGlyphDef* glyph = [_textGlyphs objectForKey:@(character)];
        NSAssert1(glyph, @"There is no glyph '%C'", character);
        glyph.commonHeight = line.rect.size.height;
        [line addGlyph:glyph];
    }
    return YES;
}


- (BOOL) generateTextGlyphs:(NSString*)text
{
    if (!_font)
        return NO;
    
    NSArray* newGlyphs = [_font glyphDefintionsForText:text];
    if (!newGlyphs)
        return NO;
    
    [_textGlyphs removeAllObjects];
    
    for (NSUInteger c = 0; c < [text length]; c++) {
        CCGlyphDef* glyph = [newGlyphs objectAtIndex:c];
        unichar character = [glyph letter];
        [_textGlyphs setObject:glyph forKey:@(character)];
    }
    
    return YES;
}

- (BOOL) makeImageDataFromPages:(CCTextFontPages*)thePages releaseData:(BOOL)releaseData
{
    NSUInteger numPages = [thePages pageCount];
    if (!numPages)
        return NO;
    
    for (NSUInteger c = 0; c < numPages; ++c) {
        unsigned char *pageData = [self preparePageGlyphData:[thePages pageAtIndex:c]];
        
        if (pageData) {
            // set the page data
            [[thePages pageAtIndex:c] setPageData:pageData];
            
            // create page texture and relase RAW data
            [[thePages pageAtIndex:c] preparePageTextureWithReleaseData:releaseData];
        } else {
            return NO;
        }
    }
    
    return YES;
}


- (unsigned char*) preparePageGlyphData:(CCTextPageDef*)thePage
{
    return [self renderGlyphData:thePage];
}

- (unsigned char*) renderGlyphData:(CCTextPageDef*)thePage
{
    if (!thePage)
        return NULL;
    
    if (!_font)
        return NULL;
    
    if ([thePage lineCount] == 0)
        return NULL;
    
    NSUInteger pageWidth  = thePage.size.width;
    NSUInteger pageHeight = thePage.size.height;
    
    // prepare memory and clean to 0
    NSUInteger sizeInBytes     = (pageWidth * pageHeight * 4);
    unsigned char* data = malloc(sizeInBytes);
    
    if (!data)
        return NULL;
    
    memset(data, 0, sizeInBytes);
    
    NSUInteger numLines = [thePage lineCount];
    
    for (NSUInteger c = 0; c < numLines; ++c) {
        CCTextLineDef* currentLine = [thePage lineAtIndex:c];
        
        CGFloat origX         = [_font letterPadding];
        CGFloat origY         = currentLine.rect.origin.y;
        
        NSUInteger numGlyphToRender = [currentLine glyphCount];
        
        for (NSUInteger cglyph = 0; cglyph < numGlyphToRender; ++cglyph) {
            CCGlyphDef* currGlyph = [currentLine glyphAtIndex:cglyph];
            [self renderCharacter:currGlyph.letter atX:origX atY:origY destination:data destinationSize:pageWidth];
            origX += currGlyph.rect.size.width + _font.letterPadding;
        }
    }
    
    
    // we are done here
    return data;

}


- (BOOL) renderCharacter:(unichar)theChar atX:(NSInteger)posX atY:(NSInteger)posY destination:(unsigned char*)destMemory destinationSize:(NSUInteger)destSize
{
    if (!_font)
        return NO;
    
    unsigned char *sourceBitmap = 0;
    NSUInteger sourceWidth  = 0;
    NSUInteger sourceHeight = 0;
    
    // get the glyph's bitmap
    sourceBitmap = [_font glyphBitmapWithCharacter:theChar outWidth:&sourceWidth outHeight:&sourceHeight];
    
    if (!sourceBitmap)
        return NO;
    
    int iX = posX;
    int iY = posY;
    
    for (int y = 0; y < sourceHeight; ++y) {
        int bitmap_y = y * sourceWidth;
        
        for (int x = 0; x < sourceWidth; ++x) {
            unsigned char cTemp = sourceBitmap[bitmap_y + x];
            
            // the final pixel
            int iTemp = cTemp << 24 | cTemp << 16 | cTemp << 8 | cTemp;
            *(int*) &destMemory[(iX + ( iY * destSize ) ) * 4] = iTemp;
            
            iX += 1;
        }
        
        iX  = posX;
        iY += 1;
    }
    
    //everything good
    return YES;
}



@end
