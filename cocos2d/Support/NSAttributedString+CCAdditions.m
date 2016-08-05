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

@implementation NSAttributedString (CCAdditions)

- (BOOL) hasAttribute:(NSString*)attr
{
    NSRange fullRange = NSMakeRange(0, self.length);
    __block BOOL hasAttribute = NO;
    [self enumerateAttribute:attr inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            hasAttribute = YES;
            *stop = YES;
        }
    }];
    
    return hasAttribute;
}

- (NSAttributedString*) copyAdjustedForContentScaleFactor
{
    NSMutableAttributedString* copy = [self mutableCopy];
    
    NSRange fullRange = NSMakeRange(0, copy.length);
    
		CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
		
    // Update font size
    [copy enumerateAttribute:NSFontAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
#ifdef __CC_PLATFORM_IOS
            UIFont* font = value;
            font = [UIFont fontWithName:font.fontName size:font.pointSize * scale];
#elif defined(__CC_PLATFORM_MAC)
            NSFont* font = value;
            font = [NSFont fontWithName:font.fontName size:font.pointSize * scale];
#elif defined(__CC_PLATFORM_ANDROID)
            CTFontRef font = CTFontCreateCopyWithAttributes(value, font.pointSize * scale, NULL, NULL);
#endif
            [copy removeAttribute:NSFontAttributeName range:range];
            [copy addAttribute:NSFontAttributeName value:(id)font range:range];
#if defined(__CC_PLATFORM_ANDROID)
            CFRelease(font);
#endif
        }
    }];
    
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
    
    return copy;
}

- (float) singleFontSize
{
    NSRange fullRange = NSMakeRange(0, self.length);
    __block BOOL foundValue = NO;
    __block BOOL singleValue = YES;
    __block float fontSize = 0;
    [self enumerateAttribute:NSFontAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
#ifdef __CC_PLATFORM_IOS
            UIFont* font = value;
#elif defined(__CC_PLATFORM_MAC)
            NSFont* font = value;
#elif defined(__CC_PLATFORM_ANDROID)
            CTFontRef font = value;
#endif
            
            if (foundValue)
            {
                singleValue = NO;
                *stop = YES;
            }
            foundValue = YES;
#if defined(__CC_PLATFORM_ANDROID)
            fontSize = CTFontGetSize(font);
#else
            fontSize = font.pointSize;
#endif
            if (!NSEqualRanges(fullRange, range)) singleValue = NO;
        }
    }];
    
    if (foundValue && singleValue) return fontSize;
    return 0;
}

- (NSAttributedString*) copyWithNewFontSize:(float) size
{
#ifdef __CC_PLATFORM_IOS
    UIFont* font = [self attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
#elif defined(__CC_PLATFORM_MAC)
    NSFont* font = [self attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
#elif defined(__CC_PLATFORM_ANDROID)
    CTFontRef font = [self attribute:(__bridge NSString*)kCTFontAttributeName atIndex:0 effectiveRange:NULL];
#endif
    if (!font) return NULL;

#ifdef __CC_PLATFORM_IOS
    UIFont* newFont = [UIFont fontWithName:font.fontName size:size];
#elif defined(__CC_PLATFORM_MAC)
    NSFont* newFont = [NSFont fontWithName:font.fontName size:size];
#elif defined(__CC_PLATFORM_ANDROID)
    CTFontRef newFont = CTFontCreateCopyWithAttributes(font, size, NULL, NULL);
#endif
    NSMutableAttributedString* copy = [self mutableCopy];
    [copy addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, copy.length)];
#if defined(__CC_PLATFORM_ANDROID)
    CFRelease(newFont);
#endif
    return copy;
}

@end
