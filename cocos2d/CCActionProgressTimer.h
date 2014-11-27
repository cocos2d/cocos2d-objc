/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Lam Pham
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
#import "CCProgressNode.h"
#import "CCActionInterval.h"

/**
 *  This action is for use with the CCProgressNode to control the progression to animation.
 *  @warning The target node must be a CCProgressNode or subclass of CCProgressNode.
 */
@interface CCActionProgressTo : CCActionInterval <NSCopying> {
	float _to;
	float _from;
}

/** @name Creating a Progress Action */

/**
 *  Creates a progress action.
 *
 *  @param duration Action duration.
 *  @param percent  Percentage.
 *
 *  @return New prgress action.
 */
+ (id)actionWithDuration:(CCTime)duration percent:(float)percent;

/**
 *  Initializes a progress action.
 *
 *  @param duration Action duration.
 *  @param percent  Percentage.
 *
 *  @return New progress action.
 */
- (id)initWithDuration:(CCTime)duration percent:(float)percent;

@end


/**
 *  This action is for use with the CCProgressNode to control the progression from and to animation.
 *  @warning The target node must be a CCProgressNode or subclass of CCProgressNode.
 */
@interface CCActionProgressFromTo : CCActionInterval <NSCopying> {
	float _to;
	float _from;
}

/** @name Creating a Progress Action */

/**
 *  Creates a progress action.
 *
 *  @param duration       Action duration.
 *  @param fromPercentage Percentage to start from.
 *  @param toPercentage   Percentage to end at.
 *
 *  @return New progress action.
 */
+ (id)actionWithDuration:(CCTime)duration from:(float)fromPercentage to:(float)toPercentage;

/**
 *  Initializes a progress action.
 *
 *  @param duration       Action duration.
 *  @param fromPercentage Percentage to start from.
 *  @param toPercentage   Percentage to end at.
 *
 *  @return New progress action.
 */
- (id)initWithDuration:(CCTime)duration from:(float)fromPercentage to:(float)toPercentage;

@end
