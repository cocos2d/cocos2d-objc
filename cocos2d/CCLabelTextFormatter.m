//
//  CCLabelTextFormatter.m
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 17.11.13.
//
//

#import "CCLabelTextFormatter.h"

@implementation CCLabelTextFormatter
+ (BOOL) multilineText:(id<CCLabelTextFormatProtocol>)label
{
    return NO;
    // to do if (m_fWidth > 0)
//    if ([label maxLineWidth])
//    {
//        // Step 1: Make multiline
//        vector<unsigned short> strWhole = cc_utf16_vec_from_utf16_str(theLabel->getUTF8String());
//        unsigned int stringLength        = strWhole.size();
//        
//        vector<unsigned short> multiline_string;
//        multiline_string.reserve( stringLength );
//        
//        vector<unsigned short> last_word;
//        last_word.reserve( stringLength );
//        
//        unsigned int line = 1, i = 0;
//        
//        bool   isStartOfLine  = false, isStartOfWord = false;
//        float  startOfLine = -1, startOfWord   = -1;
//        
//        int skip = 0;
//        
//        int strLen = theLabel->getStringLenght();
//        std::vector<LetterInfo>  *leterInfo = theLabel->getLettersInfo();
//        int tIndex = 0;
//        
//        for (int j = 0; j < strLen; j++)
//        {
//            LetterInfo* info = &leterInfo->at(j+skip);
//            
//            unsigned int justSkipped = 0;
//            
//            while (info->def.validDefinition == false)
//            {
//                justSkipped++;
//                info = &leterInfo->at( j+skip+justSkipped );
//            }
//            skip += justSkipped;
//            tIndex = j + skip;
//            
//            if (i >= stringLength)
//                break;
//            
//            unsigned short character = strWhole[i];
//            
//            if (!isStartOfWord)
//            {
//                startOfWord = theLabel->getLetterPosXLeft( tIndex );
//                isStartOfWord = true;
//            }
//            
//            if (!isStartOfLine)
//            {
//                startOfLine = startOfWord;
//                isStartOfLine  = true;
//            }
//            
//            // Newline.
//            if (character == '\n')
//            {
//                cc_utf8_trim_ws(&last_word);
//                
//                last_word.push_back('\n');
//                multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
//                last_word.clear();
//                isStartOfWord = false;
//                isStartOfLine = false;
//                startOfWord = -1;
//                startOfLine = -1;
//                i += justSkipped;
//                ++line;
//                
//                if (i >= stringLength)
//                    break;
//                
//                character = strWhole[i];
//                
//                if (!startOfWord)
//                {
//                    startOfWord = theLabel->getLetterPosXLeft( tIndex );
//                    isStartOfWord = true;
//                }
//                if (!startOfLine)
//                {
//                    startOfLine  = startOfWord;
//                    isStartOfLine = true;
//                }
//            }
//            
//            // Whitespace.
//            if (isspace_unicode(character))
//            {
//                last_word.push_back(character);
//                multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
//                last_word.clear();
//                isStartOfWord = false;
//                startOfWord = -1;
//                ++i;
//                continue;
//            }
//            
//            // Out of bounds.
//            if (theLabel->getLetterPosXRight( tIndex ) - startOfLine > theLabel->getMaxLineWidth())
//            {
//                if (!theLabel->breakLineWithoutSpace())
//                {
//                    last_word.push_back(character);
//                    
//                    int found = cc_utf8_find_last_not_char(multiline_string, ' ');
//                    if (found != -1)
//                        cc_utf8_trim_ws(&multiline_string);
//                    else
//                        multiline_string.clear();
//                    
//                    if (multiline_string.size() > 0)
//                        multiline_string.push_back('\n');
//                    
//                    ++line;
//                    isStartOfLine = false;
//                    startOfLine = -1;
//                    ++i;
//                }
//                else
//                {
//                    cc_utf8_trim_ws(&last_word);
//                    
//                    last_word.push_back('\n');
//                    multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
//                    last_word.clear();
//                    isStartOfWord = false;
//                    isStartOfLine = false;
//                    startOfWord = -1;
//                    startOfLine = -1;
//                    ++line;
//                    
//                    if (i >= stringLength)
//                        break;
//                    
//                    if (!startOfWord)
//                    {
//                        startOfWord = theLabel->getLetterPosXLeft( tIndex );
//                        isStartOfWord = true;
//                    }
//                    if (!startOfLine)
//                    {
//                        startOfLine  = startOfWord;
//                        isStartOfLine = true;
//                    }
//                    
//                    --j;
//                }
//                
//                continue;
//            }
//            else
//            {
//                // Character is normal.
//                last_word.push_back(character);
//                ++i;
//                continue;
//            }
//        }
//        
//        multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
//        
//        int size = multiline_string.size();
//        unsigned short* strNew = new unsigned short[size + 1];
//        
//        for (int j = 0; j < size; ++j)
//        {
//            strNew[j] = multiline_string[j];
//        }
//        
//        strNew[size] = 0;
//        theLabel->assignNewUTF8String(strNew);
//        
//        return true;
//    }
//    else
//    {
//        return false;
//    }

}

+ (BOOL) alignText:(id<CCLabelTextFormatProtocol>)label
{
    return NO;
}

+ (BOOL) makeStringSprites:(id<CCLabelTextFormatProtocol>)label
{
    // check for string
    unsigned int stringLen = [label stringLength];
    
    // no string
    if (stringLen == 0)
        return NO;
    
    int nextFontPositionX       = 0;
    int nextFontPositionY       = 0;
    
    unsigned short prev         = -1;
    
    
    CGSize tmpSize              = CGSizeZero;
    
    int longestLine             = 0;
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
        
        int kerningAmount   = [label kerningForCharsPairWithFirst:prev andSecond:c];
        
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
