/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
 *
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/**
 CCSprite9Slice will render an image in nine quads, keeping the margins fixed and stretching the center quad to fit the content size.
 The effect is that the image's borders will remain unstretched while the center stretches.
 */
@interface CCSprite9Slice : CCSprite {
}

/// -----------------------------------------------------------------------
/// @name Setting the Margin
/// -----------------------------------------------------------------------

/**
 Sets the margin as a normalized percentage of the total image size.
 If set to 0.25, 25% of the left, right, top and bottom borders of the image will remain unstretched.
 
 @note Margin must be in the range 0.0 to below 0.5.
 */
@property (nonatomic, assign) float margin;

/// -----------------------------------------------------------------------
/// @name Individual Margins
/// -----------------------------------------------------------------------

/** Adjusts the margin only for this border.
 @note The sum of the this border's margin plus its opposing border's margin must not be equal to or greater than 1.0! */
@property (nonatomic, assign) float marginLeft;

/** Adjusts the margin only for this border.
 @note The sum of the this border's margin plus its opposing border's margin must not be equal to or greater than 1.0! */
@property (nonatomic, assign) float marginRight;

/** Adjusts the margin only for this border.
 @note The sum of the this border's margin plus its opposing border's margin must not be equal to or greater than 1.0! */
@property (nonatomic, assign) float marginTop;

/** Adjusts the margin only for this border.
 @note The sum of the this border's margin plus its opposing border's margin must not be equal to or greater than 1.0! */
@property (nonatomic, assign) float marginBottom;

@end









































