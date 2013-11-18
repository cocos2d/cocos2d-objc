//
//  CCFontFNT.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 14.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFontFNT.h"

#import "CCTextureCache.h"

#import "CCLabelBMFont_Private.h"

#import "CCFontAtlas.h"

@implementation CCFontFNT
{
    CCBMFontConfiguration* _configuration;
}


+ (instancetype) fontWithFNTFilePath:(NSString*)fntFilePath
{
    return [[self alloc] initWithFNTFilePath:fntFilePath];
}

- (instancetype) initWithFNTFilePath:(NSString*)fntFilePath
{
    if (self = [super init]) {
        _configuration = FNTConfigLoadFile(fntFilePath);
        if (!_configuration) {
            return nil;
        }
        
        CCTexture* tex = [[CCTextureCache sharedTextureCache] addImage:[_configuration atlasName]];
        if (!tex) {
            return nil;
        }
        
    }
    return self;
}

- (CGSize*) getAdvancesForText:(NSString *)text
{
    if (!text)
        return 0;

    if (![text length])
        return 0;
    
    CGSize* sizes = calloc([text length], sizeof(CGSize));
    if (!sizes)
        return 0;
    
    for (int c = 0; c < [text length]; ++c)
    {
        CGFloat advance = 0;
        CGFloat kerning = 0;
        
        advance = [self advanceForChar:[text characterAtIndex:c]];
        
        if (c < ([text length]-1))
            kerning = [self horizontalKerningForFirstChar:[text characterAtIndex:c] andSecondChar:[text characterAtIndex:c + 1]];
        
        sizes[c].width = (advance + kerning);
    }
    
    return sizes;
}

- (CGFloat) advanceForChar:(unichar)theChar
{
    tCCFontDefHashElement *element = NULL;
    
    // unichar is a short, and an int is needed on HASH_FIND_INT
    unsigned int key = theChar;
    HASH_FIND_INT(_configuration->_fontDefDictionary, &key, element);
    if (! element)
        return -1;
    
    return element->fontDef.xAdvance;
}

- (CGFloat) horizontalKerningForFirstChar:(unichar)firstChar andSecondChar:(unichar)secondChar
{
    CGFloat ret = 0;
    unsigned int key = (firstChar << 16) | (secondChar & 0xffff);
    
    if (_configuration->_kerningDictionary)
    {
        tCCKerningHashElement *element = NULL;
        HASH_FIND_INT(_configuration->_kerningDictionary, &key, element);
        
        if (element)
            ret = element->amount;
    }
    
    return ret;

}

- (CGRect) rectForCharacterInternal:(unichar)theChar
{
    CGRect retRect;
    tCCFontDefHashElement *element = NULL;
    unsigned int key = theChar;
    
    HASH_FIND_INT(_configuration->_fontDefDictionary, &key, element);
    
    if (element)
    {
        retRect = element->fontDef.rect;
    }
    
    return retRect;
}

- (CGRect) rectForCharacter:(unichar)theChar
{
    return [self rectForCharacterInternal:theChar];
}

- (CCFontAtlas*) makeFontAtlas
{
    CCFontAtlas* tempAtlas = [[CCFontAtlas alloc] initWithFont:self];
    if (!tempAtlas)
        return nil;
    
    // check that everything is fine with the BMFontCofniguration
    if (!_configuration->_fontDefDictionary)
        return nil;
    
    if (!_configuration.characterSet)
        return nil;
    
    if (_configuration->_commonHeight == 0)
        return nil;
    
    // commone height
    [tempAtlas setCommonLineHeight:_configuration->_commonHeight];
    
    
    ccBMFontDef fontDef;
    tCCFontDefHashElement *currentElement, *tmp;
    
    // Purge uniform hash
    HASH_ITER(hh, _configuration->_fontDefDictionary, currentElement, tmp)
    {
        
        CCFontLetterDefinition* tempDefinition;
        
        fontDef = currentElement->fontDef;
        CGRect tempRect;
        
        tempRect = fontDef.rect;
        tempRect = CC_RECT_PIXELS_TO_POINTS(tempRect);
        
        tempDefinition.letteCharUTF16 = fontDef.charID;
        
        tempDefinition.offsetX  = fontDef.xOffset;
        tempDefinition.offsetY  = fontDef.yOffset;
        
        tempDefinition.U        = tempRect.origin.x;
        tempDefinition.V        = tempRect.origin.y;
        
        tempDefinition.width    = tempRect.size.width;
        tempDefinition.height   = tempRect.size.height;
        
        //carloX: only one texture supported FOR NOW
        tempDefinition.textureID = 0;
        
        tempDefinition.anchorX = 0.5f;
        tempDefinition.anchorY = 0.5f;
        tempDefinition.validDefinition = true;
        // add the new definition
        [tempAtlas addFontLetterDefinition:tempDefinition];
    }
    
    // add the texture (only one texture for now)
    CCTexture* tempTexture = [[CCTextureCache sharedTextureCache] addImage:_configuration.atlasName];
    if (!tempTexture)
        return nil;
    
    // add the texture
    [tempAtlas addTexture:tempTexture atSlot:0];
    
    // done
    return tempAtlas;
}

@end
