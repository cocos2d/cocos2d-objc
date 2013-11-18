//
//  CCFontDefinition.m
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 18.11.13.
//
//

#import "CCFontDefinition.h"

#import "CCFont.h"

@implementation CCFontDefinitionTTF

- (instancetype) initWithFont:(CCFont*)font andTextureSize:(NSUInteger)textureSize
{
    if (self = [super init]) {
        if (textureSize == 0)
            textureSize = 1024;
        
    
        
        NSString* glyph = [font currentGlyphCollection];
        if (!glyph)
            return nil;
        
//        if (ret->initDefinition(font, glyph, textureSize))
//        {
//            ret->autorelease();
//            return ret;
//        }
//        else
//        {
//            delete ret;
//            return 0;
//        }

    }
    return self;
}

- (instancetype) initWithFont:(CCFont*)font
{
    return [self initWithFont:font andTextureSize:0];
}

- (CCFontAtlas*) makeFontAtlas
{
    return nil;
}

@end
