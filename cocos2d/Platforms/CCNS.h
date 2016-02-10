/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 */

//
// Common layer for NS (Next-Step) stuff
//

#import "../ccMacros.h"

#import <Foundation/Foundation.h> //	for NSObject

//#if __CC_PLATFORM_IOS 
//
//#define CCRectFromString(__r__)		CGRectFromString(__r__)
//#define CCPointFromString(__p__)	CGPointFromString(__p__)
//#define CCSizeFromString(__s__)		CGSizeFromString(__s__)
//#define CCNSSizeToCGSize
//#define CCNSRectToCGRect
//#define CCNSPointToCGPoint


#if __CC_PLATFORM_IOS

#if 1
//#ifndef __CC_CG_STRING_UTILS
#define __CC_CG_STRING_UTILS

static inline NSString *CCNSStringFromCGPoint(CGPoint point);
static inline NSString *CCNSStringFromCGSize(CGSize size);
static inline NSString *CCNSStringFromCGRect(CGRect rect);
static inline NSString *CCNSStringFromCGAffineTransform(CGAffineTransform transform);
static inline CGPoint CCCGPointFromString(NSString *string);
static inline CGSize CCCGSizeFromString(NSString *string);
static inline CGRect CCCGRectFromString(NSString *string);
static inline CGAffineTransform CCCGAffineTransformFromString(NSString *string);

static inline NSArray *CGFloatArrayFromString(NSString *string) {
    static NSCharacterSet *ignoredCharacters = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        ignoredCharacters = [NSCharacterSet characterSetWithCharactersInString:@"{} ,"];
    });
    NSArray *components = [string componentsSeparatedByCharactersInSet:ignoredCharacters];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < [components count]; i++) {
        NSString *component = [components objectAtIndex:i];
        if ([component length] > 0)
            [result addObject:[components objectAtIndex:i]];
    }
    return result;
}

static inline CGSize CCCGSizeFromString(NSString *string) {
    NSArray *components = CGFloatArrayFromString(string);
    if ([components count] == 2) {
        return CGSizeMake([[components objectAtIndex:0] floatValue],
                          [[components objectAtIndex:1] floatValue]);
    } else {
        return CGSizeZero;
    }
}

static inline CGPoint CCCGPointFromString(NSString *string) {
    NSArray *components = CGFloatArrayFromString(string);
    if ([components count] == 2) {
        return CGPointMake([[components objectAtIndex:0] floatValue],
                           [[components objectAtIndex:1] floatValue]);
    } else {
        return CGPointZero;
    }
}

static inline CGRect CCCGRectFromString(NSString *string) {
    NSArray *components = CGFloatArrayFromString(string);
    if ([components count] == 4) {
        return CGRectMake([[components objectAtIndex:0] floatValue],
                          [[components objectAtIndex:1] floatValue],
                          [[components objectAtIndex:2] floatValue],
                          [[components objectAtIndex:3] floatValue]);
    } else {
        return CGRectZero;
    }
}

static inline CGAffineTransform CCCGAffineTransformFromString(NSString *string) {
    NSArray *components = CGFloatArrayFromString(string);
    if ([components count] == 6) {
        return CGAffineTransformMake([[components objectAtIndex:0] floatValue],
                                     [[components objectAtIndex:1] floatValue],
                                     [[components objectAtIndex:2] floatValue],
                                     [[components objectAtIndex:3] floatValue],
                                     [[components objectAtIndex:4] floatValue],
                                     [[components objectAtIndex:5] floatValue]);
    } else {
        return CGAffineTransformIdentity;
    }
}

static inline NSString *CCNSStringFromCGRect(CGRect r)
{
    return [NSString stringWithFormat:@"{{%g, %g}, {%g, %g}}", r.origin.x, r.origin.y, r.size.width, r.size.height];
}

static inline NSString *CCNSStringFromCGPoint(CGPoint point)
{
    return [NSString stringWithFormat:@"{%g, %g}", point.x, point.y];
}

static inline NSString *CCNSStringFromCGSize(CGSize size)
{
    return [NSString stringWithFormat:@"{%g, %g}", size.width, size.height];
}

static inline NSString *CCNSStringFromCGAffineTransform(CGAffineTransform m)
{
    return [NSString stringWithFormat:@"[%g, %g, %g, %g, %g, %g]", m.a, m.b, m.c, m.d, m.tx, m.ty];
}


#define CCRectFromString(__r__)		CCCGRectFromString(__r__)
#define CCPointFromString(__p__)	CCCGPointFromString(__p__)
#define CCSizeFromString(__s__)		CCCGSizeFromString(__s__)
#define CCNSSizeToCGSize
#define CCNSRectToCGRect
#define CCNSPointToCGPoint

#endif

#elif __CC_PLATFORM_MAC

#define CCRectFromString(__r__)		NSRectToCGRect( NSRectFromString(__r__) )
#define CCPointFromString(__p__)	NSPointToCGPoint( NSPointFromString(__p__) )
#define CCSizeFromString(__s__)		NSSizeToCGSize( NSSizeFromString(__s__) )
#define CCNSSizeToCGSize			NSSizeToCGSize
#define CCNSRectToCGRect			NSRectToCGRect
#define CCNSPointToCGPoint			NSPointToCGPoint
#endif


