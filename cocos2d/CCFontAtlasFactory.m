//
//  CCFontAtlasFactory.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFontAtlasFactory.h"

#import "CCFont.h"

@implementation CCFontAtlasFactory

+ (instancetype) sharedFontAtlasFactory
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (CCFontAtlas*) atlasFromTTF:(NSString*)fontFilePath size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs
{
    return [self atlasFromTTF:fontFilePath size:fontSize glyphs:glyphs customGlyphs:nil];
}


- (CCFontAtlas*) atlasFromTTF:(NSString*)fontFilePath size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    CCFont* font = [CCFontCoreGraphics fontWithFontName:fontFilePath size:fontSize glyphs:glyphs customGlyphs:customGlyphs];
    if (!font) {
        NSAssert1(NO, @"Cannot load font `%@`", fontFilePath);
        return nil;
    }
    return [font makeFontAtlas];
}

@end
