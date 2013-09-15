/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright 2009 lhunath (Maarten Billemont)
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

/** CCActionTween

 CCActionTween is an action that lets you update any property of an object.
 For example, if you want to modify the "width" property of a target from 200 to 300 in 2 seconds, then:

	id modifyWidth = [CCActionTween actionWithDuration:2 key:@"width" from:200 to:300];
	[target runAction:modifyWidth];


 Another example: CCScaleTo action could be rewriten using CCPropertyAction:

	// scaleA and scaleB are equivalents
	id scaleA = [CCScaleTo actionWithDuration:2 scale:3];
	id scaleB = [CCActionTween actionWithDuration:2 key:@"scale" from:1 to:3];


 @since v0.99.2
 */
@interface CCActionTween : CCActionInterval
{
	NSString		*_key;

	float			_from, _to;
	float			_delta;
}

/** creates an initializes the action with the property name (key), and the from and to parameters. */
+ (id)actionWithDuration:(ccTime)aDuration key:(NSString *)key from:(float)from to:(float)to;

/** initializes the action with the property name (key), and the from and to parameters. */
- (id)initWithDuration:(ccTime)aDuration key:(NSString *)key from:(float)from to:(float)to;

@end
