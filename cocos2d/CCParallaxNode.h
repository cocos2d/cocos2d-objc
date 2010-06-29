/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
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

#import "CCNode.h"
#import "Support/ccCArray.h"

/** CCParallaxNode: A node that simulates a parallax scroller
 
 The children will be moved faster / slower than the parent according the the parallax ratio.
 
 */
@interface CCParallaxNode : CCNode {
	ccArray				*parallaxArray_;
	CGPoint				lastPosition;
}

/** array that holds the offset / ratio of the children */
@property (nonatomic,readwrite) ccArray * parallaxArray;

/** Adds a child to the container with a z-order, a parallax ratio and a position offset
 It returns self, so you can chain several addChilds.
 @since v0.8
 */
-(id) addChild: (CCNode*)node z:(int)z parallaxRatio:(CGPoint)c positionOffset:(CGPoint)positionOffset;

@end
