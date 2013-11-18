//
//  CCFontAtlasFactory.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCFontAtlas.h"

#import "CCGlyphCollection.h"

@interface CCFontAtlasFactory : NSObject
+ (instancetype) sharedFontAtlasFactory;

- (CCFontAtlas*) atlasFromTTF:(NSString*)fontFilePath size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs;
- (CCFontAtlas*) atlasFromTTF:(NSString*)fontFilePath size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs;
- (CCFontAtlas*) atlasFromFNT:(NSString*)fntFilePath;
@end
