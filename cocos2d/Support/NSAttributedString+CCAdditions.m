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
    
    if (hasAttribute) NSLog(@"hasAttribute: %@",attr);
    
    return hasAttribute;
}

- (NSAttributedString*) copyAdjustedForContentScaleFactor
{
    NSMutableAttributedString* copy = [self mutableCopy];
    
#ifdef __CC_PLATFORM_IOS   
    NSRange fullRange = NSMakeRange(0, copy.length);
    
    // Update font size
    [copy enumerateAttribute:NSFontAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            UIFont* font = value;
            [copy removeAttribute:NSFontAttributeName range:range];
            font = [UIFont fontWithName:font.fontName size:font.pointSize * CC_CONTENT_SCALE_FACTOR()];
            [copy addAttribute:NSFontAttributeName value:font range:range];
        }
    }];
    
    // Update shadows
    [copy enumerateAttribute:NSShadowAttributeName inRange:fullRange options:0 usingBlock:^(id value, NSRange range, BOOL* stop){
        if (value)
        {
            NSShadow* shadow = value;
            [copy removeAttribute:NSShadowAttributeName range:range];
            shadow.shadowBlurRadius = shadow.shadowBlurRadius * CC_CONTENT_SCALE_FACTOR();
            CGSize offset = shadow.shadowOffset;
            shadow.shadowOffset = CGSizeMake(offset.width * CC_CONTENT_SCALE_FACTOR(), offset.height * CC_CONTENT_SCALE_FACTOR());
            [copy addAttribute:NSShadowAttributeName value:shadow range:range];
        }
    }];
#endif
    
    return copy;
}

@end
