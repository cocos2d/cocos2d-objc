/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Lam Pham
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
#import "CCSprite.h"

/** Progress Node Type. */
typedef NS_ENUM(NSUInteger, CCProgressNodeType) {
	/** Radial Counter-Clockwise */
	CCProgressNodeTypeRadial,
	/** Bar */
	CCProgressNodeTypeBar,
};

/**
 CCProgressNode displays a sprite with a progressive reveal.
 
 ### Notes
 
 - Progress type can currently be Radial, Horizontal or vertical.
 - Midpoint is used to modify the start position:
    - Radial type the mid point changes the center point.
    - Bar type the midpoint changes the bar growth, it expands from the center but clamps to the sprites edge:
        - Left  -> Right use (0,0)
        - Right -> Left use (1,y)
        - Bottom -> Top use (x,0)
        - Top -> Bottom use (x,1)
 
 - Progress percentage is 0 -> 100.
 - Bar change rate allows the bar type to move the component at a specific rate.
    - Set the rate to zero to make sure it stays at 100%
    - Example: If you want a Left -> Right bar and also have the height grow set the rate to (0,1) and modpoint to (0,0.5f)
  
 */

@interface CCProgressNode : CCNode {
	CCProgressNodeType	_type;
	float				_percentage;
	CCSprite			*_sprite;

	int					_vertexDataCount;
	ccV2F_C4B_T2F		*_vertexData;
	CGPoint				_midpoint;
	CGPoint				_barChangeRate;
	BOOL				_reverseDirection;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Progress Node Attributes
/// -----------------------------------------------------------------------

/**	Progress type. */
@property (nonatomic, readwrite) CCProgressNodeType type;

/**	Reverse progress direction. */
@property (nonatomic, readwrite) BOOL reverseDirection;

/** Progress start position. */
@property (nonatomic, readwrite) CGPoint midpoint;

/** Bar change rate. */
@property (nonatomic, readwrite) CGPoint barChangeRate;

/** Progress percentage. */
@property (nonatomic, readwrite) float percentage;

/** The Sprite to use. */
@property (nonatomic, readwrite, strong) CCSprite *sprite;


/// -----------------------------------------------------------------------
/// @name Creating a CCProgressNode Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a progress node object using the specified sprite value.
 *
 *  @param sprite The CCSprite to use.
 *
 *  @return The CCProgressNode Object.
 */
+(id)progressWithSprite:(CCSprite*) sprite;


/// -----------------------------------------------------------------------
/// @name Initializing a CCProgressNode Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a progress node object using the specified sprite value.
 *
 *  @param sprite The CCSprite to use.
 *
 *  @return An initialized CCProgressNode Object.
 */
-(id)initWithSprite:(CCSprite*) sprite;

@end
