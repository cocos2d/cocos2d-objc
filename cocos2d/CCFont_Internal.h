//
//  CCFont_Internal.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCFont(Internal)
- (void) setCurrentGlyphCollection:(CCGlyphCollection)glyphs;
- (void) setCurrentGlyphCollection:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs;

- (NSString*) glyphCollection:(CCGlyphCollection)glyphs;
@end