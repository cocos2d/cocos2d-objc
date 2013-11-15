//
//  CCFont.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "Platforms/CCGL.h"
#import "ccTypes.h"

#import "CCGlyphCollection.h"

@class CCFontAtlas;
@class CCGlyphDef;

@interface CCFont : NSObject
+ (instancetype) fontWithTTFFilePath:(NSString*)fontPath size:(CGFloat)fontSize glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs;

- (CCFontAtlas*) makeFontAtlas;
- (CGSize*) getAdvancesForText:(NSString*)text outLength:(int*)length;

@property (copy, readonly) NSString* currentGlyphCollection;
@property (assign, readonly) CGFloat letterPadding;

- (unsigned char*) glyphBitmapWithCharacter:(unichar)theChar outWidth:(NSUInteger*)width outHeight:(NSUInteger*)height;
- (NSArray*) glyphDefintionsForText:(NSString*)text;

@property (assign, readonly) CGFloat fontMaxHeight;

- (CGRect) rectForCharacter:(unichar)theChar;

@end
