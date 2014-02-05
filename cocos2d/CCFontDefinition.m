//
//  CCFontDefinition.m
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 18.11.13.
//
//

#import "CCFontDefinition.h"

#import "CCFont.h"
#import "CCTextImage.h"
#import "CCFontAtlas.h"

@implementation CCFontDefinitionTTF
{
    CCTextImage* _textImages;
    CGFloat _commonLineHeight;
    
    NSMutableDictionary* _fontLettersDefinitionUTF16;
    
}

- (instancetype) initWithFont:(CCFont*)font andTextureSize:(NSUInteger)textureSize
{
    if (self = [super init]) {
        if (textureSize == 0)
            textureSize = 1024;
        
        
        
        NSString* glyph = [font currentGlyphCollection];
        if (!glyph)
            return nil;
        
        _fontLettersDefinitionUTF16 = [[NSMutableDictionary alloc] initWithCapacity:[glyph length]];
        if (!_fontLettersDefinitionUTF16)
            return nil;
        
        _textImages = [[CCTextImage alloc] initWithString:glyph size:CGSizeMake(textureSize, textureSize) font:font releaseData:YES];
        if (!_textImages)
            return nil;
        
        
        
        // prepare the new letter definition
        if (![self prepareLetterDefinitions:_textImages.pages]) {
            return nil;
        }
    }
    return self;
}

- (instancetype) initWithFont:(CCFont*)font
{
    return [self initWithFont:font andTextureSize:0];
}

- (BOOL) prepareLetterDefinitions:(CCTextFontPages*)pageDefs
{
    // get all the pages
    CCTextFontPages *pages = pageDefs;
    if (!pages)
        return NO;
    
    CGFloat maxLineHeight = -1;
    
    // loops all the pages
    for (int cPages = 0; cPages < [pages pageCount]; ++cPages)
    {
        // loops all the lines in this page
        for (int cLines = 0; cLines< [[pages pageAtIndex:cPages] lineCount]; ++cLines)
        {
            float posXUV = 0.0;
            float posYUV = [[pages pageAtIndex:cPages] lineAtIndex:cLines].rect.origin.y;
            
            int   charsCounter = 0;
            
            for (int c = 0; c < [[[pages pageAtIndex:cPages] lineAtIndex:cLines] glyphCount]; ++c)
            {
                // the current glyph
                CCGlyphDef* currentGlyph =  [[[pages pageAtIndex:cPages] lineAtIndex:cLines] glyphAtIndex:c];
                
                // letter width
                float letterWidth  = currentGlyph.rect.size.width;
                
                // letter height
                float letterHeight = [[pages pageAtIndex:cPages] lineAtIndex:cLines].rect.size.height;
                
                // add this letter definition
                CCFontLetterDefinition* tempDef = [CCFontLetterDefinition new];
                
                
                // carloX little hack (this should be done outside the loop)
                if (posXUV == 0.0)
                    posXUV = [currentGlyph padding];
                
                tempDef.validDefinition  =  [currentGlyph isValid];
                
                if (tempDef.validDefinition)
                {
                    tempDef.letteCharUTF16   = [currentGlyph letter];
                    tempDef.width            = letterWidth  + [currentGlyph padding];
                    tempDef.height           = (letterHeight - 1);
                    tempDef.U                = (posXUV       - 1);
                    tempDef.V                = posYUV;
                    tempDef.offsetX          = currentGlyph.rect.origin.x;
                    tempDef.offsetY          = currentGlyph.rect.origin.y;
                    tempDef.textureID        = cPages;
                    tempDef.commonLineHeight = [currentGlyph commonHeight];
                    
                    // take from pixels to points
                    tempDef.width  =    tempDef.width  / CC_CONTENT_SCALE_FACTOR();
                    tempDef.height =    tempDef.height / CC_CONTENT_SCALE_FACTOR();
                    tempDef.U      =    tempDef.U      / CC_CONTENT_SCALE_FACTOR();
                    tempDef.V      =    tempDef.V      / CC_CONTENT_SCALE_FACTOR();
                    
                    if (tempDef.commonLineHeight>maxLineHeight)
                        maxLineHeight = tempDef.commonLineHeight;
                }
                else
                {
                    tempDef.letteCharUTF16   = currentGlyph.letter;
                    tempDef.commonLineHeight = 0;
                    tempDef.width            = 0;
                    tempDef.height           = 0;
                    tempDef.U                = 0;
                    tempDef.V                = 0;
                    tempDef.offsetX          = 0;
                    tempDef.offsetY          = 0;
                    tempDef.textureID        = 0;
                }
                
                
                // add this definition
                [self addFontLetterDefinition:tempDef];
                
                // move bounding box to the next letter
                posXUV += letterWidth + currentGlyph.padding;
                
                // next char in the string
                ++charsCounter;
            }
        }
    }
    
    // store the common line height
    _commonLineHeight = maxLineHeight;
    
    //
    return YES;
}

- (void) addFontLetterDefinition:(CCFontLetterDefinition*)letterDefinition
{
    if (![_fontLettersDefinitionUTF16 objectForKey:@(letterDefinition.letteCharUTF16)])
        [_fontLettersDefinitionUTF16 setObject:letterDefinition forKey:@(letterDefinition.letteCharUTF16)];
}

- (CCFontAtlas*) makeFontAtlas
{
    CCTextFontPages* pages = [_textImages pages];
    NSUInteger numTextures = [pages pageCount];
    if (numTextures == 0)
        return nil;
    
    
    CCFontAtlas* atlas = [[CCFontAtlas alloc] initWithFont:_textImages.font];
    if (!atlas)
        return nil;
    
    
    for (NSUInteger c = 0; c < numTextures; ++c) {
        CCTextFontPages* pPages = [_textImages pages];
        [atlas addTexture:[[pPages pageAtIndex:c] pageTexture] atSlot:c];
    }
    
    // set the common line height
    [atlas setCommonLineHeight:_commonLineHeight * 0.8];
    
    for (NSNumber* character in [_fontLettersDefinitionUTF16 keyEnumerator]) {
        CCFontLetterDefinition* def = [_fontLettersDefinitionUTF16 objectForKey:character];
        if (def.validDefinition) {
            def.offsetX = 0.0f;
            def.anchorX = 0.0f;
            def.anchorY = 1.0f;
            [atlas addFontLetterDefinition:def];
        }
    }
    
    // done here
    return atlas;
}

@end
