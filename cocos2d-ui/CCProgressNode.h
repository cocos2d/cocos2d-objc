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
#import "CCActionProgressTimer.h"

/** Progress Node type used by CCProgressNode. */
typedef NS_ENUM(NSUInteger, CCProgressNodeType) {
	/** Reveals radial (like radar blip) in counter-clockwise direction. */
	CCProgressNodeTypeRadial,
	/** Reveals in horizontal/vertical direction. */
	CCProgressNodeTypeBar,
};

/**
 CCProgressNode uses a CCSprite whose texture can be revealed progressively.
 
 - Progress type can currently be Radial, Horizontal or vertical.
 - Midpoint is used to modify the start position:
    - Radial type: the mid point changes the center point.
    - Bar type: the midpoint changes the bar growth, it expands from the center but clamps to the sprites edge:
        - Left  -> Right use (0,0)
        - Right -> Left use (1,y)
        - Bottom -> Top use (x,0)
        - Top -> Bottom use (x,1)
 
 - Progress percentage is in the range 0 -> 100.
 - Bar change rate allows the bar type to move the component at a specific rate.
    - Set the rate to zero to make sure it stays at 100%
    - Example: If you want a Left -> Right bar and also have the height grow set the rate to (0, 1) and modpoint to (0, 0.5)
 */

@interface CCProgressNode : CCNode


/// -----------------------------------------------------------------------
/// @name Creating a Progress Node
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a progress node object using the specified sprite value.
 *
 *  @param sprite The CCSprite to use.
 *
 *  @return The CCProgressNode Object.
 *  @see CCSprite
 */
+(instancetype)progressWithSprite:(CCSprite*) sprite;

/**
 *  Initializes and returns a progress node object using the specified sprite value.
 *
 *  @param sprite The CCSprite to use.
 *
 *  @return An initialized CCProgressNode Object.
 *  @see CCSprite
 */
-(id)initWithSprite:(CCSprite*) sprite;

/// -----------------------------------------------------------------------
/// @name Changing Progress Behavior
/// -----------------------------------------------------------------------

/**	
 Determines how the sprite's texture is revealed.
 @see CCProgressNodeType
 */
@property (nonatomic, readwrite) CCProgressNodeType type;

/**	
 Reverse the direction of the progressive reveal.
 */
@property (nonatomic, readwrite) BOOL reverseDirection;

/** Progress start position. */
@property (nonatomic, readwrite) CGPoint midpoint;

/// -----------------------------------------------------------------------
/// @name Animating the Progress Node
/// -----------------------------------------------------------------------

/** Progress percentage. Changing this will effectively animate the progress node. */
@property (nonatomic, readwrite) float percentage;

/** Rate at which the bar changes. */
@property (nonatomic, readwrite) CGPoint barChangeRate;

/// -----------------------------------------------------------------------
/// @name Accessing the Progress Sprite
/// -----------------------------------------------------------------------

/** The CCSprite used by the progress node.
 @see CCSprite */
@property (nonatomic, readwrite, strong) CCSprite *sprite;

@end
