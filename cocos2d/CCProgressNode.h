/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Lam Pham
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
#import "CCSprite.h"

/** Types of progress
 @since v0.99.1
 */
typedef NS_ENUM(NSUInteger, CCProgressNodeType) {
	/// Radial Counter-Clockwise
	CCProgressNodeTypeRadial,
	/// Bar
	CCProgressNodeTypeBar,
};

/**
 CCProgresstimer is a subclass of CCNode.
 It renders the inner sprite according to the percentage.
 The progress can be Radial, Horizontal or vertical.
 @since v0.99.1
 */
@interface CCProgressNode : CCNodeRGBA {
	CCProgressNodeType	_type;
	float				_percentage;
	CCSprite			*_sprite;

	int					_vertexDataCount;
	ccV2F_C4B_T2F		*_vertexData;
	CGPoint				_midpoint;
	CGPoint				_barChangeRate;
	BOOL				_reverseDirection;
}
/**	Change the percentage to change progress. */
@property (nonatomic, readwrite) CCProgressNodeType type;
@property (nonatomic, readwrite) BOOL reverseDirection;

/**
 *	Midpoint is used to modify the progress start position.
 *	If you're using radials type then the midpoint changes the center point
 *	If you're using bar type the the midpoint changes the bar growth
 *		it expands from the center but clamps to the sprites edge so:
 *		you want a left to right then set the midpoint all the way to ccp(0,y)
 *		you want a right to left then set the midpoint all the way to ccp(1,y)
 *		you want a bottom to top then set the midpoint all the way to ccp(x,0)
 *		you want a top to bottom then set the midpoint all the way to ccp(x,1)
 */
@property (nonatomic, readwrite) CGPoint midpoint;

/**
 *	This allows the bar type to move the component at a specific rate
 *	Set the component to 0 to make sure it stays at 100%.
 *	For example you want a left to right bar but not have the height stay 100%
 *	Set the rate to be ccp(0,1); and set the midpoint to = ccp(0,.5f);
 */
@property (nonatomic, readwrite) CGPoint barChangeRate;

/** Percentages are from 0 to 100 */
@property (nonatomic, readwrite) float percentage;

/** The image to show the progress percentage */
@property (nonatomic, readwrite, strong) CCSprite *sprite;

/** Creates a progress timer with the sprite as the shape the timer goes through */
+ (id) progressWithSprite:(CCSprite*) sprite;
/** Initializes a progress timer with the sprite as the shape the timer goes through */
- (id) initWithSprite:(CCSprite*) sprite;
@end
