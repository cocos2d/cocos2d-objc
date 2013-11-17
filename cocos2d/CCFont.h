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
- (CCFontAtlas*) makeFontAtlas;
- (CGSize*) getAdvancesForText:(NSString*)text;

@property (nonatomic, copy, readonly) NSString* currentGlyphCollection;
@property (nonatomic, assign, readonly) CGFloat letterPadding;

- (unsigned char*) glyphBitmapWithCharacter:(unichar)theChar outWidth:(NSUInteger*)width outHeight:(NSUInteger*)height;
- (NSArray*) glyphDefintionsForText:(NSString*)text;

@property (nonatomic, assign, readonly) CGFloat fontMaxHeight;

- (CGRect) rectForCharacter:(unichar)theChar;

@end
