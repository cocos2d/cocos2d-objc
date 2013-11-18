//
//  CCFontAtlasCache.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Platforms/CCGL.h"
#import "ccTypes.h"

#import "CCGlyphCollection.h"

@class CCFontAtlas;

@interface CCFontAtlasCache : NSObject

+ (instancetype) sharedFontAtlasCache;


- (CCFontAtlas*) fontAtlasTTFWithName:(NSString*)fontPath size:(CGFloat)size glyphs:(CCGlyphCollection)glyphs;
- (CCFontAtlas*) fontAtlasTTFWithName:(NSString*)fontPath size:(CGFloat)size glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs;
- (CCFontAtlas*) fontAtlasFNTWithFilePath:(NSString*)filePath;
- (BOOL) releaseFontAtlas:(CCFontAtlas*)atlas;

@end
