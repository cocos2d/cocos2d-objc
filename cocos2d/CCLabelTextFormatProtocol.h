//
//  CCLabelTextureFormatProtocol.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCFontAtlas.h"

//
//
//struct LetterInfo
//{
//    FontLetterDefinition def;
//    
//    Point position;
//    Size  contentSize;
//    bool  visible;
//};
//
//
#pragma mark - CCLabelTextFormatProtocol
@class CCSprite;
@protocol CCLabelTextFormatProtocol <NSObject>
- (BOOL) recordLetterInfo:(CGPoint)point character:(unsigned short int)theChar spriteIndex:(NSInteger)spriteIndex;
- (BOOL) recordPlaceholderInfo:(NSInteger)spriteIndex;
- (NSArray*) lettersInfo;
- (CGFloat) letterPosXLeft:(NSInteger)idx;
- (CGFloat) letterPosXRight:(NSInteger)idx;
// sprite related stuff
- (CCSprite*) letter:(NSInteger)ID;

// font related stuff
- (NSInteger) commonLineHeight;
- (NSInteger) kerningForCharsPairWithFirst:(unsigned short)first andSecond:(unsigned short)second;
- (NSInteger) xOffsetForChar:(unsigned short)c;
- (NSInteger) yOffsetForChar:(unsigned short)c;
- (NSInteger) advanceForChar:(unsigned short)c hintPositionInString:(NSInteger)hintPos;
- (CGRect)    rectForChar:(unsigned short)c;

// string related stuff
- (NSInteger) stringNumLines;
- (NSInteger) stringLength;
- (unsigned short) charAtStringPosition:(NSInteger)position;
- (unsigned short*) UTF8String;
- (void) assignNewUTF8String:(unsigned short*)newString;

@property (assign, readonly) CCTextAlignment textAlignment;
- (CCTextAlignment) textAlignment;
// label related stuff
@property (assign, readonly) CGFloat maxLineWidth;
@property (assign, readonly) BOOL breakLineWithoutSpace;

@property (assign, readwrite) CGSize labelContentSize;
@end