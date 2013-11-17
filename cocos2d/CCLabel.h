//
//  CCLabel.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCSpriteBatchNode.h"

#import "CCLabelTextFormatProtocol.h"
#import "CCGlyphCollection.h"


@interface CCLabel : CCSpriteBatchNode <CCLabelProtocol, CCRGBAProtocol, CCLabelTextFormatProtocol>
- (instancetype) initWithString:(NSString*)label ttfFontName:(NSString*)fontName fontSize:(CGFloat)fontSize lineSize:(CGFloat)lineSize alignment:(CCTextAlignment)alignment glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs;

- (instancetype) initWithFontAtlas:(CCFontAtlas*)atlas alignment:(CCTextAlignment)alignment;
@end
