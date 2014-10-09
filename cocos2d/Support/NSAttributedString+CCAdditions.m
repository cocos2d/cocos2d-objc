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

BOOL NSMutableAttributedStringSetDefaultAttribute(NSMutableAttributedString *attrString, NSString*attr, id defaultValue);
CGColorRef CGColorCreateWithPlatformSpecificColor(id platformColor);
CTFontRef CTFontCreateWithPlatformSpecificFont(id font);

BOOL NSMutableAttributedStringSetDefaultAttribute(NSMutableAttributedString *attrString, NSString*attr, id defaultValue){
    NSRange fullRange = NSMakeRange(0, attrString.length);
    __block BOOL result = YES;
    NSMutableArray *rangesAndValues = [[NSMutableArray alloc] init];
    [attrString enumerateAttribute:attr inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            //only special case
            if (fullRange.location==range.location && fullRange.length == range.length){
                result = NO;
            }
            NSArray *rangeAndValue = @[value, [NSValue valueWithRange:range]];
            [rangesAndValues addObject:rangeAndValue];
        };
    }];
    [attrString addAttribute:attr value:defaultValue range:fullRange];
    [rangesAndValues enumerateObjectsUsingBlock:^(NSArray *rangeAndValue, NSUInteger idx, BOOL *stop) {
        NSRange range = [(NSValue *)[rangeAndValue objectAtIndex:1] rangeValue];
        [attrString addAttribute:attr value:[rangeAndValue objectAtIndex:0] range:range];
    }];
    return result;
}

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

CGColorRef CGColorCreateWithPlatformSpecificColor(id platformColor) {
#if __CC_PLATFORM_IOS
    return CGColorRetain(((UIColor *)platformColor).CGColor);
#elif __CC_PLATFORM_MAC
    return CGColorRetain(((NSColor *)platformColor).CGColor);
#elif __CC_PLATFORM_ANDROID_ANDROID_COLOR
    int32_t androidColor = (int32_t)[(NSNumber *)platformColor intValue];
    return CGColorCreateGenericRGB([AndroidColor redWithColor:androidColor]/255.0,
                                   [AndroidColor greenWithColor:androidColor]/255.0,
                                   [AndroidColor blueWithColor:androidColor]/255.0,
                                   [AndroidColor alphaWithColor:androidColor]/255.0);
#else
    return NULL;
#endif
}

CTFontRef CTFontCreateWithPlatformSpecificFont(id font) {
#if __CC_PLATFORM_IOS
    return CTFontCreateWithName((__bridge CFStringRef)((UIFont *)font).fontName, ((UIFont *)font).pointSize, NULL);
#elif __CC_PLATFORM_MAC
    return CTFontCreateWithName((__bridge CFStringRef)((NSFont *)font).fontName, ((NSFont *)font).pointSize, NULL);
#else
    return NULL;
#endif
}

#if !__CC_PLATFORM_ANDROID
static NSTextAlignment NSTextAlignmentFromCCTextAlignment(CCTextAlignment ccAligment) {
#if __CC_PLATFORM_IOS
    switch (ccAligment) {
        case CCTextAlignmentLeft:
            return NSTextAlignmentLeft;
        case CCTextAlignmentRight:
            return NSTextAlignmentRight;
        case CCTextAlignmentCenter:
            return NSTextAlignmentCenter;
        default:
            return 0;
    }
#elif __CC_PLATFORM_MAC
    switch (ccAligment) {
        case CCTextAlignmentLeft:
            return NSLeftTextAlignment;
        case CCTextAlignmentRight:
            return NSRightTextAlignment;
        case CCTextAlignmentCenter:
            return NSCenterTextAlignment;
        default:
            return 0;
    }
#else
    return 0;
#endif
    
    
}
#endif


BOOL NSMutableAttributedStringFixPlatformSpecificAttributes(NSMutableAttributedString* string, CCColor* defaultColor, NSString* defaultFontName, CGFloat defaultFontSize, CCTextAlignment defaultHorizontalAlignment){
    NSRange fullRange = NSMakeRange(0, string.length);
    BOOL useFullColor = NO;
#if !__CC_PLATFORM_ANDROID
    if (NSAttributedStringHasAttribute(string, NSForegroundColorAttributeName)) {
        CGColorRef color = CGColorCreateWithPlatformSpecificColor([string attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL]);
        [string addAttribute:(id)kCTForegroundColorFromContextAttributeName value:(__bridge id)color range:fullRange];
        CGColorRelease(color);
    }
    if (NSAttributedStringHasAttribute(string, NSFontAttributeName)) {
        id font = [string attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
        CTFontRef ctFont = CTFontCreateWithPlatformSpecificFont(font);
        [string addAttribute:(id)kCTFontAttributeName value:(__bridge id)ctFont range:fullRange];
        CFRelease(ctFont);
    }
    
    // Shadow
    if (NSAttributedStringHasAttribute(string, NSShadowAttributeName))
    {
        useFullColor = YES;
    }
    
    // Text alignment
    
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentFromCCTextAlignment(defaultHorizontalAlignment);
    NSMutableAttributedStringSetDefaultAttribute(string, NSParagraphStyleAttributeName, style);
    
    
    
#else
    // You betcha not to have those attributes on Android, they are not supported
    assert(!NSAttributedStringHasAttribute(string, @"NSParagraphStyle"));
    assert(!NSAttributedStringHasAttribute(string, @"NSFont"));
    assert(!NSAttributedStringHasAttribute(string, @"NSForegroundColor"));
    
    // Shadow (No CT alternative)
    if (NSAttributedStringHasAttribute(string, @"NSShadow"))
    {
        useFullColor = YES;
    }
    
    
    CTTextAlignment alignment;
    if (defaultHorizontalAlignment == CCTextAlignmentLeft) alignment = kCTTextAlignmentLeft;
    else if (defaultHorizontalAlignment == CCTextAlignmentCenter) alignment = kCTTextAlignmentCenter;
    else if (defaultHorizontalAlignment == CCTextAlignmentRight) alignment = kCTTextAlignmentRight;
    
    
    CTParagraphStyleSetting paragraphStyleSettings[] = {
        {
            .spec = kCTParagraphStyleSpecifierAlignment,
            .valueSize = sizeof(typeof(alignment)),
            .value = &alignment
        },
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(paragraphStyleSettings, sizeof(paragraphStyleSettings) / sizeof(CTParagraphStyleSetting));
    NSMutableAttributedStringSetDefaultAttribute(string, (NSString *)kCTParagraphStyleAttributeName, (__bridge id)style);
    
    CFRelease(style);
    
    
#endif
    
    
    
#if !__CC_PLATFORM_ANDROID
    NSString *foregroundColorAttributeName = NSForegroundColorAttributeName;
#else
    NSString *foregroundColorAttributeName = (__bridge id)kCTForegroundColorAttributeName;
#endif
    BOOL colorChanged = NSMutableAttributedStringSetDefaultAttribute(string, foregroundColorAttributeName, (__bridge id)defaultColor.CGColor);
    useFullColor |= (![defaultColor isEqualToColor:[CCColor whiteColor]]) && colorChanged;
    
    // Font
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)defaultFontName, defaultFontSize, NULL);
    if (font == NULL) font = CTFontCreateWithName(CFSTR("Helvetica"), defaultFontSize, NULL);
    [string addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:fullRange];
    NSMutableAttributedStringSetDefaultAttribute(string, (NSString *)kCTFontAttributeName, (__bridge id)font);
    CFRelease(font);
    return useFullColor;
}

