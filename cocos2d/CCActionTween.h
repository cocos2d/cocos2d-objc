/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright 2009 lhunath (Maarten Billemont)
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
 *
 */

#import <Foundation/Foundation.h>
#import "CCActionInterval.h"

/**
 *  CCActionTween is an action that lets you modify over time any property of a node.
 *
 *  Examples: 
 *
 *  1) Modify the width property of a target from 200 to 300 in 2 seconds:
 *  - [target runAction:[CCActionTween actionWithDuration:2 key:@"width" from:200 to:300]]
 *
 *  2) Modify the scale property from 1 to 3 in 5 seconds
 *  - [target runAction:[CCActionTween actionWithDuration:5 key:@"scale" from:1 to:3]]
 */
@interface CCActionTween : CCActionInterval {
	NSString		*_key;
	float			_from, _to;
	float			_delta;
}

/**
 *  Creates an initializes a tween action.
 *
 *  @param aDuration Action duration.
 *  @param key       Property key to modify.
 *  @param from      Value to tween from.
 *  @param to        Value to tween to.
 *
 *  @return New tween action.
 */
+ (id)actionWithDuration:(CCTime)aDuration key:(NSString *)key from:(float)from to:(float)to;

/**
 *  Initializes an initializes a tween action.
 *
 *  @param aDuration Action duration.
 *  @param key       Property key to modify.
 *  @param from      Value to tween from.
 *  @param to        Value to tween to.
 *
 *  @return New tween action.
 */
- (id)initWithDuration:(CCTime)aDuration key:(NSString *)key from:(float)from to:(float)to;

@end
