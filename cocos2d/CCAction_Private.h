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

#import "CCAction.h"

enum {
	//! Default tag
	kCCActionTagInvalid = -1,
};


@interface CCAction() {
    @protected
    __unsafe_unretained id _target;
}

@end


@interface CCActionFiniteTime() {
    @protected
    CCTime _duration;
}

@end


// TODO what to do with CCAction follow?
@interface CCActionFollow() {
    
	// Node to follow.
	CCNode *_followedNode;

	// Whether camera should be limited to certain area.
	BOOL _boundarySet;

	// If screen-size is bigger than the boundary - update not needed.
	BOOL _boundaryFullyCovered;

	// Fast access to the screen dimensions.
	CGPoint _halfScreenSize;
	CGPoint _fullScreenSize;

	// World boundaries.
	float _leftBoundary;
	float _rightBoundary;
	float _topBoundary;
	float _bottomBoundary;
}

@end

