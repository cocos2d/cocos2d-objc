//
//  CCFontAtlas.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFontAtlas.h"

#import "CCFont.h"
#import "CCFontCoreGraphics.h"

@implementation CCFontLetterDefinition

@end

@interface CCFontAtlas ()
- (BOOL) renderCharacter:(unichar)theChar atX:(NSInteger)x atY:(NSInteger)y destination:(unsigned char*)destMemory destinationSize:(NSUInteger)destSize;
@end

@implementation CCFontAtlas
{
    CCFont* _font;
    
    NSMutableDictionary* _atlasTextures;
    NSMutableDictionary* _fontLetterDefinitions;
    // Dynamic GlyphCollection related stuff
    int _currentPage;
    unsigned char *_currentPageData;
    int _currentPageDataSize;
    float _currentPageOrigX;
    float _currentPageOrigY;
    float _currentPageLineHeight;
    float _letterPadding;
}

- (instancetype) initWithFont:(CCFont*)font
{
    if (self = [super init]) {
        _font = font;
        // TODO!!!
        _atlasTextures = [[NSMutableDictionary alloc] initWithCapacity:1];
        _fontLetterDefinitions = [[NSMutableDictionary alloc] initWithCapacity:80];
        
        if ([_font isKindOfClass:[CCFontCoreGraphics class]]) {
            CCFontCoreGraphics* fontCG = (CCFontCoreGraphics*)_font;
            if ([fontCG isDynamicGlyphCollection]) {
                _currentPageLineHeight = [_font fontMaxHeight];
                _commonLineHeight = _currentPageLineHeight * 0.8f;
                CCTexture* tex = [CCTexture alloc];
                _currentPage = 0;
                _currentPageOrigX = 0;
                _currentPageOrigY = 0;
                _letterPadding = 5;
                _currentPageDataSize = (1024 * 1024 * 4);
                
                _currentPageData = malloc(_currentPageDataSize);
                memset(_currentPageData, 0, _currentPageDataSize);
                [self addTexture:tex atSlot:0];
            }
        }
    }
    return self;
}


- (void) addFontLetterDefinition:(CCFontLetterDefinition*)letterDefinition
{
    [_fontLetterDefinitions setObject:letterDefinition forKey:@(letterDefinition.letteCharUTF16)];
}

- (CCFontLetterDefinition*) fontLetterDefinitionForCharacter:(unichar)theChar
{
    return [_fontLetterDefinitions objectForKey:@(theChar)];
}

- (BOOL) prepareLetterDefinitions:(NSString*)letters
{
    if(_currentPageData == NULL)
        return NO;
    
    CCFontCoreGraphics* fontCG = (CCFontCoreGraphics*)_font;
    
    NSMutableArray* fontDefs = [NSMutableArray arrayWithCapacity:16];
    for (int i = 0; i < [letters length]; i++) {
        unichar currentCharacter = [letters characterAtIndex:i];
        
        
        if (![_fontLetterDefinitions objectForKey:@(currentCharacter)]) {
            
            CGRect tempRect;

            CCFontLetterDefinition* tempDef = [CCFontLetterDefinition new];
            tempDef.offsetX = 0;
            tempDef.anchorX = 0.0f;
            tempDef.anchorY = 1.0f;

            if (![fontCG getBBOXForCharacter:currentCharacter rect:&tempRect]) {
                tempDef.validDefinition = NO;
                tempDef.letteCharUTF16   = currentCharacter;
                tempDef.commonLineHeight = 0;
                tempDef.width            = 0;
                tempDef.height           = 0;
                tempDef.U                = 0;
                tempDef.V                = 0;
                tempDef.offsetY          = 0;
                tempDef.textureID        = 0;
            } else {
                tempDef.validDefinition = YES;
                tempDef.letteCharUTF16   = currentCharacter;
                tempDef.width            = tempRect.size.width  + _letterPadding;
                tempDef.height           = _currentPageLineHeight - 1;
                tempDef.offsetY          = tempRect.origin.y;
                tempDef.commonLineHeight = _currentPageLineHeight;
            }
            
            [fontDefs addObject:tempDef];
        }
        
    }

    CGFloat scaleFactor = CC_CONTENT_SCALE_FACTOR();
    NSUInteger newLetterCount = [fontDefs count];
    CGFloat glyphWidth;
    for (NSUInteger i = 0; i < newLetterCount; ++i)
    {
        CCFontLetterDefinition* letterDef = [fontDefs objectAtIndex:i];
        
        if (letterDef.validDefinition)
        {
            _currentPageOrigX += _letterPadding;
            glyphWidth = letterDef.width - _letterPadding;
            
            if (_currentPageOrigX + glyphWidth > 1024)
            {
                _currentPageOrigY += _currentPageLineHeight;
                if(_currentPageOrigY >= 1024)
                {
                    CCTexture* atlasTexture = [_atlasTextures objectForKey:@(_currentPage)];
                    atlasTexture = [atlasTexture initWithData:_currentPageData pixelFormat:CCTexturePixelFormat_RGBA8888 pixelsWide:1024 pixelsHigh:1024 contentSize:CGSizeMake(1024, 1024)];
//                    _atlasTextures[_currentPage]->initWithData(_currentPageData, _currentPageDataSize, Texture2D::PixelFormat::RGBA8888, 1024, 1024, Size(1024, 1024) );
                    _currentPageOrigX = 0;
                    _currentPageOrigY = 0;
                    
                    free(_currentPageData);
                    _currentPageData = malloc(_currentPageDataSize);
                    if (_currentPageData == nil)
                        return NO;
                    memset(_currentPageData, 0, _currentPageDataSize);
                    _currentPage++;
                    
                    CCTexture* tex = [CCTexture alloc];
                    [self addTexture:tex atSlot:_currentPage];
                }
            }
            
            [self renderCharacter:letterDef.letteCharUTF16 atX:_currentPageOrigX atY:_currentPageOrigY destination:_currentPageData destinationSize:1024];
            
            
            
            letterDef.U                = _currentPageOrigX - 1;
            letterDef.V                = _currentPageOrigY;
            letterDef.textureID        = _currentPage;
            // take from pixels to points
            letterDef.width  =    letterDef.width  / scaleFactor;
            letterDef.height =    letterDef.height / scaleFactor;
            letterDef.U      =    letterDef.U      / scaleFactor;
            letterDef.V      =    letterDef.V      / scaleFactor;
            

        }
        else
            glyphWidth = 0;
        
        [self addFontLetterDefinition:letterDef];
        
        _currentPageOrigX += glyphWidth;
    }
    if (newLetterCount > 0) {
        CCTexture* atlasTexture = [_atlasTextures objectForKey:@(_currentPage)];
        atlasTexture = [atlasTexture initWithData:_currentPageData pixelFormat:CCTexturePixelFormat_RGBA8888 pixelsWide:1024 pixelsHigh:1024 contentSize:CGSizeMake(1024, 1024)];
    }
    return YES;
}


- (void) addTexture:(CCTexture*)texture atSlot:(NSInteger)slot
{
    NSAssert(texture != nil, @"Texture cannot be nil");
    [_atlasTextures setObject:texture forKey:@(slot)];
}

- (CCTexture*) textureAtSlot:(NSInteger)slot
{
    return [_atlasTextures objectForKey:@(slot)];
}


- (BOOL) renderCharacter:(unichar)theChar atX:(NSInteger)posX atY:(NSInteger)posY destination:(unsigned char*)destMemory destinationSize:(NSUInteger)destSize
{
    unsigned char *sourceBitmap = 0;
    NSUInteger sourceWidth  = 0;
    NSUInteger sourceHeight = 0;
    
    // get the glyph's bitmap
    sourceBitmap = [_font glyphBitmapWithCharacter:theChar outWidth:&sourceWidth outHeight:&sourceHeight];
    
    
    if (!sourceBitmap)
        return NO;
    
    int iX = posX;
    int iY = posY;
    
    for (int y = 0; y < sourceHeight; ++y)
    {
        int bitmap_y = y * sourceWidth;
        
        for (int x = 0; x < sourceWidth; ++x)
        {
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
