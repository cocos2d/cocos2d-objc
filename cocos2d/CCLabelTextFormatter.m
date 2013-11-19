//
//  CCLabelTextFormatter.m
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 17.11.13.
//
//

#import "CCLabelTextFormatter.h"
#import "CCLetterInfo.h"


@implementation CCLabelTextFormatter
+ (BOOL) multilineText:(id<CCLabelTextFormatProtocol>)label
{
    // to do if (m_fWidth > 0)
    if ([label maxLineWidth]) {
        // Step 1: Make multiline
        NSString* strWhole = [label labelString];
        NSUInteger stringLength = [strWhole length];
        
        NSMutableString* multilineString = [NSMutableString stringWithCapacity:stringLength];
        NSMutableString* lastWord = [NSMutableString stringWithCapacity:stringLength];
        
        NSUInteger line = 1;
        NSUInteger i = 0;
        
        BOOL isStartOfLine  = NO;
        BOOL isStartOfWord = NO;
        CGFloat startOfLine = -1;
        CGFloat startOfWord = -1;
        
        NSUInteger skip = 0;
        
        NSUInteger strLen = [label stringLength];
        
        NSArray* letterInfos = [label lettersInfo];
        
        NSUInteger tIndex = 0;
        
        for (int j = 0; j < strLen; j++)
        {
            CCLetterInfo* info = [letterInfos objectAtIndex:j + skip];
            
            NSUInteger justSkipped = 0;
            
            while (!info.definition.validDefinition) {
                justSkipped++;
                info = [letterInfos objectAtIndex:j + skip + justSkipped];
            }
            
            skip += justSkipped;
            tIndex = j + skip;
            
            if (i >= stringLength)
                break;
            
            unichar character = [strWhole characterAtIndex:i];
            
            if (!isStartOfWord) {
                startOfWord = [label letterPosXLeft:tIndex];
                isStartOfWord = YES;
            }
            
            if (!isStartOfLine) {
                startOfLine = startOfWord;
                isStartOfLine  = YES;
            }
            
            // Newline.
            if (character == '\n') {
                lastWord = [[lastWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
                [lastWord appendString:@"\n"];
                
                
                [multilineString appendString:lastWord];
                
                [lastWord setString:@""];
                
                isStartOfWord = NO;
                isStartOfLine = NO;
                startOfWord = -1;
                startOfLine = -1;
                i += justSkipped;
                ++line;
                
                if (i >= stringLength)
                    break;
                
                character = [strWhole characterAtIndex:i];
                
                if (!startOfWord) {
                    startOfWord = [label letterPosXLeft:tIndex];
                    isStartOfWord = YES;
                }
                if (!startOfLine) {
                    startOfLine  = startOfWord;
                    isStartOfLine = YES;
                }
            }
            
            // Whitespace.
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:character]) {
                [lastWord appendFormat:@"%C", character];
                [multilineString appendString:lastWord];
                [lastWord setString:@""];
                isStartOfWord = NO;
                startOfWord = -1;
                ++i;
                continue;
            }
            
            // Out of bounds.
            if ([label letterPosXRight:tIndex] - startOfLine > [label maxLineWidth]) {
                if (![label breakLineWithoutSpace]) {
                    [lastWord appendFormat:@"%C", character];
                    
                    NSRange found = [multilineString rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] options:NSBackwardsSearch];
                    if (found.location == NSNotFound)
                        multilineString = [[multilineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
                    else
                        [multilineString setString:@""];
                    
                    if ([multilineString length] > 0)
                        [multilineString appendString:@"\n"];
                    
                    ++line;
                    isStartOfLine = NO;
                    startOfLine = -1;
                    ++i;
                }
                else
                {
                    lastWord = [[lastWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
                    [lastWord appendString:@"\n"];
                    
                    [multilineString appendString:lastWord];
                    
                    [lastWord setString:@""];
                    
                    isStartOfWord = NO;
                    isStartOfLine = NO;
                    startOfWord = -1;
                    startOfLine = -1;
                    ++line;
                    
                    if (i >= stringLength)
                        break;
                    
                    if (!startOfWord) {
                        startOfWord = [label letterPosXLeft:tIndex];
                        isStartOfWord = YES;
                    }
                    if (!startOfLine) {
                        startOfLine  = startOfWord;
                        isStartOfLine = YES;
                    }
                    
                    --j;
                }
                
                continue;
            }
            else
            {
                // Character is normal.
                [lastWord appendFormat:@"%C", character];
                ++i;
                continue;
            }
        }
        
        
        [multilineString appendString:lastWord];
        
        [label setLabelString:multilineString];
    
        
        return YES;
    } else {
        return NO;
    }

}

+ (BOOL) alignText:(id<CCLabelTextFormatProtocol>)label
{
    NSUInteger i = 0;
    
    NSUInteger lineNumber = 0;
    NSUInteger strLen =  [label stringLength];
    
    NSMutableString* lastLine = [NSMutableString string];
    NSArray* lettersInfo = [label lettersInfo];
    for (int ctr = 0; ctr < strLen; ++ctr) {
        unichar currentChar = [label charAtStringPosition:ctr];
        
        if (currentChar == '\n') {
            CGFloat lineWidth = 0.0f;
            NSUInteger lineLength = [lastLine length];
            
            // if last line is empty we must just increase lineNumber and work with next line
            if (lineLength == 0) {
                lineNumber++;
                continue;
            }
            int index = i + lineLength - 1 + lineNumber;
            if (index < 0) continue;
            
            if(currentChar == 0)
                continue;
            
            CCLetterInfo* info = [lettersInfo objectAtIndex:index];
            if (!info.definition.validDefinition)
                continue;
            lineWidth = info.position.x + info.contentSize.width / 2.0f;
            
            CGFloat shift = 0;
            switch ([label textAlignment]) {
                case CCTextAlignmentCenter:
                    shift = [label labelContentSize].width / 2.0f - lineWidth / 2.0f;
                    break;
                case CCTextAlignmentRight:
                    shift = [label labelContentSize].width - lineWidth;
                    break;
                default:
                    break;
            }
            
            if (shift != 0) {
                for (unsigned j = 0; j < lineLength; ++j) {
                    index = i + j + lineNumber;
                    if (index < 0)
                        continue;
                    
                    info = [lettersInfo objectAtIndex:index];
                    if(info) {
                        info.position = ccpAdd(info.position, ccp(shift, 0.0f));
                    }
                }
            }
            
            i += lineLength;
            ++lineNumber;
            
            [lastLine setString:@""];
            continue;
        }
        
        [lastLine appendFormat:@"%C", currentChar];
    }
    
    return YES;
}

+ (BOOL) makeStringSprites:(id<CCLabelTextFormatProtocol>)label
{
    // check for string
    unsigned int stringLen = [label stringLength];
    
    // no string
    if (stringLen == 0)
        return NO;
    
    CGFloat nextFontPositionX       = 0;
    CGFloat nextFontPositionY       = 0;
    
    unichar prev         = -1;
    
    
    CGSize tmpSize              = CGSizeZero;
    
    CGFloat longestLine             = 0;
    unsigned int totalHeight    = 0;
    
    
    int quantityOfLines         = [label stringNumLines];
    CGFloat commonLineHeight        = [label commonLineHeight];
    
    totalHeight                 =     commonLineHeight * quantityOfLines;
    nextFontPositionY           = 0 - (commonLineHeight - totalHeight);

    CGRect charRect;
    CGFloat charXOffset = 0;
    CGFloat charYOffset = 0;
    CGFloat charAdvance = 0;
    
    for (NSUInteger i = 0; i < stringLen; i++) {
        // get the current character
        unichar c    = [label charAtStringPosition:i];
        
        charXOffset         = [label xOffsetForChar:c];
        charYOffset         = [label yOffsetForChar:c];
        charAdvance         = [label advanceForChar:c hintPositionInString:i];
        charRect            = [label rectForChar:c];
        
        CGFloat kerningAmount   = [label kerningForCharsPairWithFirst:prev andSecond:c];
        
        if (c == '\n') {
            nextFontPositionX  = 0;
            nextFontPositionY -= commonLineHeight;
            
            [label recordPlaceholderInfo:i];
            continue;
        }
        
        // See issue 1343. cast( signed short + unsigned integer ) == unsigned integer (sign is lost!)
        CGFloat yOffset = commonLineHeight - charYOffset;
        
        
        CGPoint fontPos = CGPointMake((float)nextFontPositionX + charXOffset +   charRect.size.width  *  0.5f + kerningAmount,
                              (float)nextFontPositionY + yOffset     -   charRect.size.height *  0.5f);
        
        if (![label recordLetterInfo:CC_POINT_PIXELS_TO_POINTS(fontPos) character:c spriteIndex:i]) {
            CCLOGWARN(@"can't find letter definition in font file for letter: %c", c);
            continue;
        }
        
        // update kerning
        nextFontPositionX += charAdvance + kerningAmount;
        prev = c;
        
        if (longestLine < nextFontPositionX) {
            longestLine = nextFontPositionX;
        }
    }
    
    // If the last character processed has an xAdvance which is less that the width of the characters image, then we need
    // to adjust the width of the string to take this into account, or the character will overlap the end of the bounding
    // box
    if (charAdvance < charRect.size.width) {
        tmpSize.width = longestLine + charRect.size.width - charAdvance;
    } else {
        tmpSize.width = longestLine;
    }
    
    tmpSize.height = totalHeight;
    [label setLabelContentSize:CC_SIZE_PIXELS_TO_POINTS(tmpSize)];
    return YES;

}


@end
