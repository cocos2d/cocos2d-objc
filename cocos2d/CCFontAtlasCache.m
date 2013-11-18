//
//  CCFontAtlasCache.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFontAtlasCache.h"

#import "CCGlyphCollection.h"

#import "CCFontAtlasFactory.h"

@interface CCFontAtlasCache()

@end

@implementation CCFontAtlasCache
{
    NSMutableDictionary* _atlasMap;
}

+ (instancetype) sharedFontAtlasCache
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
        _atlasMap = [[NSMutableDictionary alloc] initWithCapacity:8];
    }
    return self;
}

- (CCFontAtlas*) fontAtlasTTFWithName:(NSString*)fontName size:(CGFloat)size glyphs:(CCGlyphCollection)glyphs
{
    return [self fontAtlasTTFWithName:fontName size:size glyphs:glyphs customGlyphs:nil];
}

- (CCFontAtlas*) fontAtlasTTFWithName:(NSString*)fontName size:(CGFloat)size glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    NSString* atlasName = [self generateFontNameWithName:fontName size:size andGlypsCollection:glyphs];
    
    CCFontAtlas* atlas = [_atlasMap objectForKey:atlasName];
    
    if (atlas == nil) {
        atlas = [[CCFontAtlasFactory sharedFontAtlasFactory] atlasFromTTF:fontName size:size glyphs:glyphs customGlyphs:customGlyphs];
        if (atlas != nil)
            [_atlasMap setObject:atlas forKey:atlasName];
    }
    
    return atlas;
}


- (CCFontAtlas*) fontAtlasFNTWithFilePath:(NSString*)filePath
{
    NSString* atlasName = [self generateFontNameWithName:filePath size:0.0f andGlypsCollection:CCGlyphCollectionCustom];
    
    CCFontAtlas* atlas = [_atlasMap objectForKey:atlasName];
    if (!atlas) {
        atlas = [[CCFontAtlasFactory sharedFontAtlasFactory] atlasFromFNT:filePath];
        if (atlas != nil)
            [_atlasMap setObject:atlas forKey:atlasName];
    }
    
    return atlas;
}

- (BOOL) releaseFontAtlas:(CCFontAtlas*)atlasToRelease
{
    if (atlasToRelease) {
        for (id key in [_atlasMap keyEnumerator]) {
            CCFontAtlas* currentAtlas = [_atlasMap objectForKey:key];
            if ([currentAtlas isEqual:atlasToRelease]) {
                NSUInteger retainCount = CFGetRetainCount((CFTypeRef)currentAtlas);
                if (retainCount == 1) {
                    [_atlasMap removeObjectForKey:key];
                    return YES;
                }
            }
        }
    }
    
    return NO;;
}

#pragma mark - Helpers

- (NSString*) generateFontNameWithName:(NSString*)fontPath size:(CGFloat)size andGlypsCollection:(CCGlyphCollection)theGlyphs
{
    return [NSString stringWithFormat:@"%@%5.1f%u", fontPath, size, theGlyphs];
}


@end
