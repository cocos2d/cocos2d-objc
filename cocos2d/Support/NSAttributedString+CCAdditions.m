/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Apportable
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "NSAttributedString+CCAdditions.h"
#import "ccMacros.h"
#import "cocos2d.h"
#import <CoreText/CoreText.h>


BOOL NSAttributedStringHasAttribute(NSAttributedString *attrString, NSString*attr){
    NSRange fullRange = NSMakeRange(0, attrString.length);
    __block BOOL hasAttribute = NO;
    [attrString enumerateAttribute:attr inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            hasAttribute = YES;
            *stop = YES;
        }
    }];
    
    return hasAttribute;
}

NSAttributedString* NSAttributedStringCopyAdjustedForContentScaleFactor(NSAttributedString *attrString){
    NSMutableAttributedString* copy = [attrString mutableCopy];
    
    NSRange fullRange = NSMakeRange(0, copy.length);
    
    CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
	
#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID

    // Update font size
    [copy enumerateAttribute:(id)kCTFontAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            NSCAssert((CFGetTypeID((__bridge CFTypeRef)(value))==CTFontGetTypeID()), @"CFTypeID does not match");
            CTFontRef oldFont = (__bridge CTFontRef)value;
            CTFontRef font = CTFontCreateCopyWithAttributes(oldFont, CTFontGetSize(oldFont) * scale, NULL, NULL);
            [copy removeAttribute:(id)kCTFontAttributeName range:range];
            [copy addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:range];
            CFRelease(font);
        }
    }];
    
    
#elif __CC_PLATFORM_MAC

    [copy enumerateAttribute:NSFontAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {

            NSFont* font = value;
            font = [NSFont fontWithName:font.fontName size:font.pointSize * scale];
            [copy removeAttribute:NSFontAttributeName range:range];
            [copy addAttribute:NSFontAttributeName value:(id)font range:range];
            
            
        }
    }];
#endif
#if 0 /*__CC_PLATFORM_ANDROID_FIXME*/
    // Update shadows
    [copy enumerateAttribute:NSShadowAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            NSShadow* shadow = value;
            [copy removeAttribute:NSShadowAttributeName range:range];
            shadow.shadowBlurRadius = shadow.shadowBlurRadius * scale;
            CGSize offset = shadow.shadowOffset;
            shadow.shadowOffset = CGSizeMake(offset.width * scale, offset.height * scale);
            [copy addAttribute:NSShadowAttributeName value:shadow range:range];
        }
    }];
#endif
    return copy;
}

float NSAttributedStringSingleFontSize(NSAttributedString *attrString){
    NSRange fullRange = NSMakeRange(0, attrString.length);
    __block BOOL foundValue = NO;
    __block BOOL singleValue = YES;
    __block float fontSize = 0;
#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
    [attrString enumerateAttribute:(id)kCTFontAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            NSCAssert((CFGetTypeID((__bridge CFTypeRef)(value))==CTFontGetTypeID()), @"CFTypeID does not match");

            CTFontRef font = (__bridge CTFontRef)(value);
            if (foundValue)
            {
                singleValue = NO;
                *stop = YES;
            }
            foundValue = YES;
            fontSize = CTFontGetSize(font);
            if (!NSEqualRanges(fullRange, range)) singleValue = NO;
        }
    }];
    
    
#elif __CC_PLATFORM_MAC

    
    [attrString enumerateAttribute:(id)kCTFontAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            NSFont* font = value;
            if (foundValue)
            {
                singleValue = NO;
                *stop = YES;
            }
            foundValue = YES;
            fontSize = font.pointSize;
            if (!NSEqualRanges(fullRange, range)) singleValue = NO;
        }
    }];
#endif

    
    
    if (foundValue && singleValue) return fontSize;
    return 0;
}

NSAttributedString *NSAttributedStringCopyWithNewFontSize(NSAttributedString *attrString, float size){
    NSMutableAttributedString* copy = [attrString mutableCopy];

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
    CFTypeRef value = (__bridge CTFontRef)([attrString attribute:(id)kCTFontAttributeName atIndex:0 effectiveRange:NULL]);
    NSCAssert((CFGetTypeID(value)==CTFontGetTypeID()), @"CFTypeID does not match");
    CTFontRef font = (CTFontRef)value;
    CTFontRef newFont = CTFontCreateCopyWithAttributes(font, size, NULL, NULL);
    [copy addAttribute:(id)kCTFontAttributeName value:(__bridge id)(newFont) range:NSMakeRange(0, copy.length)];
    CFRelease(newFont);
#elif __CC_PLATFORM_MAC
    NSFont* font = [attrString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    NSFont* newFont = [NSFont fontWithName:font.fontName size:size];
    [copy addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, copy.length)];

#endif
    return copy;
}

