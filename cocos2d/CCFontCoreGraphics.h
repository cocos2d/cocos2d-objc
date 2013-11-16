//
//  CCFontCoreGraphics.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFont.h"

@interface CCFontCoreGraphics : CCFont
+ (instancetype) fontWithFontName:(NSString*)fontName size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs;
- (instancetype) initWithFontName:(NSString*)fontName size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs;

- (BOOL) getBBOXForCharacter:(unichar)theChar rect:(CGRect*)outRect;

@property (assign, readonly) BOOL isDynamicGlyphCollection;
@end
