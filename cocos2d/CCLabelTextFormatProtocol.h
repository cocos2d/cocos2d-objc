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
- (BOOL) recordLetterInfo:(CGPoint)point character:(unichar)theChar spriteIndex:(NSInteger)spriteIndex;
- (BOOL) recordPlaceholderInfo:(NSInteger)spriteIndex;
- (NSArray*) lettersInfo;
- (CGFloat) letterPosXLeft:(NSInteger)idx;
- (CGFloat) letterPosXRight:(NSInteger)idx;
// sprite related stuff
- (CCSprite*) letter:(NSInteger)ID;

// font related stuff
- (CGFloat) commonLineHeight;
- (CGFloat) kerningForCharsPairWithFirst:(unichar)first andSecond:(unichar)second;
- (CGFloat) xOffsetForChar:(unichar)c;
- (CGFloat) yOffsetForChar:(unichar)c;
- (CGFloat) advanceForChar:(unichar)c hintPositionInString:(NSInteger)hintPos;
- (CGRect)    rectForChar:(unichar)c;

// string related stuff
- (NSInteger) stringNumLines;
- (NSInteger) stringLength;
- (unichar) charAtStringPosition:(NSInteger)position;
- (const char*) UTF8String;
- (void) assignNewUTF8String:(NSString*)newString;

@property (nonatomic, assign, readonly) CCTextAlignment textAlignment;
- (CCTextAlignment) textAlignment;
// label related stuff
@property (nonatomic, assign, readonly) CGFloat maxLineWidth;
@property (nonatomic, assign, readonly) BOOL breakLineWithoutSpace;

@property (nonatomic, assign, readwrite) CGSize labelContentSize;
@end