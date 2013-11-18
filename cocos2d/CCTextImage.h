//
//  CCTextImage.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 14.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@class CCFont;

/** @brief CCGlyphDef defines one single glyph (character) in a text image
 *
 * it defines the bounding box for the glyph in the texture page, the character the padding (spacing) between characters
 *
 */

@interface CCGlyphDef : NSObject
- (instancetype) init;
- (instancetype) initWithLetter:(unichar)letter andRect:(CGRect)rect;

@property (assign) unichar letter;
@property (assign) CGRect rect;
@property (assign) CGFloat padding;
@property (assign) CGFloat commonHeight;
@property (assign, getter = isValid) BOOL valid;
@end

/** @brief CCTextLineDef define a line of text in a text image texture page
 *
 * conllects all the CCGlyphDef for a text line plus line size and line position in text image space
 *
 */
@interface CCTextLineDef : NSObject
- (instancetype) initWithRect:(CGRect)rect;

- (void) addGlyph:(CCGlyphDef*)glyph;
- (CCGlyphDef*) glyphAtIndex:(NSUInteger)idx;

@property (assign, readonly) NSUInteger glyphCount;
@property (assign, readonly) CGRect rect;

@end

/** @brief CCTextPageDef defines one text image page (a CCTextImage can have/use more than one page)
 *
 * collects all the TextLineDef for one page, the witdh and height of the page and the  graphics (texture) for the page
 *
 */
@interface CCTextPageDef : NSObject
- (instancetype) initWithPageNumber:(NSUInteger)pageNumber andSize:(CGSize)size;

- (void) addLine:(CCTextLineDef*)line;
- (CCTextLineDef*) lineAtIndex:(NSUInteger)idx;


@property (assign, readonly) CGSize size;
@property (assign, readonly) NSUInteger pageNumber;
@property (assign, readonly) NSUInteger lineCount;

@property (assign) unsigned char* pageData;

@property (retain, readonly) CCTexture* pageTexture;

- (void) preparePageTextureWithReleaseData:(BOOL)releaseData;
- (void) preparePageTexture;

@end

/** @brief CCTextFontPages collection of pages (CCTextPageDef)
 *
 *  A CCTextImage is composed by one or more text pages. This calss collects all of those pages
 */
@interface CCTextFontPages : NSObject

- (void) addPage:(CCTextPageDef*)page;
- (CCTextPageDef*) pageAtIndex:(NSUInteger)idx;
@property (assign, readonly) NSUInteger pageCount;

@end

/** @brief TextImage
 *
 */
@interface CCTextImage : NSObject
- (instancetype) initWithString:(NSString*)text size:(CGSize)size font:(CCFont*)font;
- (instancetype) initWithString:(NSString*)text size:(CGSize)size font:(CCFont*)font releaseData:(BOOL)releaseData;

@property (retain, readonly) CCTextFontPages* pages;
@property (retain, readonly) CCFont* font;
@end
