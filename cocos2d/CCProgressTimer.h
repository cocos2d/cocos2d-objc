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
typedef enum {
	/// Radial Counter-Clockwise
	kCCProgressTimerTypeRadialCCW,
	/// Radial ClockWise
	kCCProgressTimerTypeRadialCW,
	/// Horizontal Left-Right
	kCCProgressTimerTypeHorizontalBarLR,
	/// Horizontal Right-Left
	kCCProgressTimerTypeHorizontalBarRL,
	/// Vertical Bottom-top
	kCCProgressTimerTypeVerticalBarBT,
	/// Vertical Top-Bottom
	kCCProgressTimerTypeVerticalBarTB,
} CCProgressTimerType;

/**
 CCProgresstimer is a subclass of CCNode.
 It renders the inner sprite according to the percentage.
 The progress can be Radial, Horizontal or vertical.
 @since v0.99.1

 Conforms to CCRGBAProtocol since 1.1RC0
 */
@interface CCProgressTimer : CCNode<CCRGBAProtocol>
{
	CCProgressTimerType	type_;
	float				percentage_;
	CCSprite			*sprite_;

	int					vertexDataCount_;
	ccV2F_C4B_T2F		*vertexData_;
}

/**	Change the percentage to change progress. */
@property (nonatomic, readwrite) CCProgressTimerType type;

/** Percentages are from 0 to 100 */
@property (nonatomic, readwrite) float percentage;

/** The image to show the progress percentage */
@property (nonatomic, readwrite, retain) CCSprite *sprite;


/** Creates a progress timer with an image filename as the shape the timer goes through */
+ (id) progressWithFile:(NSString*) filename;
/** Initializes  a progress timer with an image filename as the shape the timer goes through */
- (id) initWithFile:(NSString*) filename;

/** Creates a progress timer with the texture as the shape the timer goes through */
+ (id) progressWithTexture:(CCTexture2D*) texture;
/** Creates a progress timer with the texture as the shape the timer goes through */
- (id) initWithTexture:(CCTexture2D*) texture;

@end
