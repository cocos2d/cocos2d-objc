/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
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

#import "ccMacros.h"

#import "CCRenderableNode.h"

#pragma mark - CCNodeColor

/**
 Draws a rectangle filled with a solid color.
 */
@interface CCNodeColor : CCRenderableNode <CCShaderProtocol, CCBlendProtocol>

/// -----------------------------------------------------------------------
/// @name Creating a Color Node
/// -----------------------------------------------------------------------

/**
 *  Creates a node with color, width and height in Points.
 *
 *  @param color Color of the node.
 *  @param w     Width of the node.
 *  @param h     Height of the node.
 *
 *  @return The CCNodeColor Object.
 *  @see CCColor
 */
+(instancetype) nodeWithColor: (CCColor*)color width:(float)w height:(float)h;

/**
 *  Creates a node with color. Width and height are the window size.
 *
 *  @param color Color of the node.
 *
 *  @return The CCNodeColor Object.
 *  @see CCColor
 */
+(instancetype) nodeWithColor: (CCColor*)color;

/**
 *  Creates a node with color, width and height in Points.
 *
 *  @param color Color of the node.
 *  @param w     Width of the node.
 *  @param h     Height of the node.
 *
 *  @return An initialized CCNodeColor Object.
 *  @see CCColor
 */
-(id) initWithColor:(CCColor*)color width:(float)w height:(float)h;

/**
 *  Creates a node with color. Width and height are the window size.
 *
 *  @param color Color of the node.
 *
 *  @return An initialized CCNodeColor Object.
 *  @see CCColor
 */
-(id) initWithColor:(CCColor*)color;

@end

#pragma mark - CCNodeGradient

/** 
 Draws a rectangle filled with a gradient.
 
 The gradient node adds the following properties to the ones already provided by CCNodeColor:
 
 - vector (direction)
 - startColor and endColor (gradient colors)
 
 If no vector is supplied, it defaults to (0, -1) - fading from top to bottom. 
 Color is interpolated between the startColor and endColor along the given vector (starting at the origin, ending at the terminus).
 */
@interface CCNodeGradient : CCNodeColor {
	GLKVector4 _endColor;
	CGPoint _vector;
}


/// -----------------------------------------------------------------------
/// @name Creating a Gradient Node
/// -----------------------------------------------------------------------

/**
 *  Creates a full-screen CCNode with a gradient between start and end color values.
 *
 *  @param start Start color.
 *  @param end   End color.
 *
 *  @return The CCNodeGradient Object.
 *  @see CCColor
 */
+(instancetype)nodeWithColor:(CCColor*)start fadingTo:(CCColor*)end;

/**
 *  Creates a full-screen CCNode with a gradient between start and end color values with gradient direction vector.
 *
 *  @param start Start color.
 *  @param end   End color.
 *  @param v Direction vector for gradient.
 *
 *  @return The CCNodeGradient Object.
 *  @see CCColor
 */
+(instancetype)nodeWithColor:(CCColor*)start fadingTo:(CCColor*)end alongVector:(CGPoint)v;

/**
 *  Creates a full-screen CCNode with a gradient between start and end color values.
 *
 *  @param start Start color.
 *  @param end   End color.
 *
 *  @return An initialized CCNodeGradient Object.
 *  @see CCColor
 */
- (id)initWithColor:(CCColor*)start fadingTo:(CCColor*)end;

/**
 *  Creates a full-screen CCNode with a gradient between start and end color values with gradient direction vector.
 *
 *  @param start Start color.
 *  @param end   End color.
 *  @param v Direction vector for gradient.
 *
 *  @return An initialized CCNodeGradient Object.
 *  @see CCColor
 */
- (id)initWithColor:(CCColor*)start fadingTo:(CCColor*)end alongVector:(CGPoint)v;


/// -----------------------------------------------------------------------
/// @name Gradient Color and Opacity
/// -----------------------------------------------------------------------

/** The starting color.
 @see CCColor
*/
@property (nonatomic, strong) CCColor* startColor;

/** The ending color. 
 @see CCColor
*/
@property (nonatomic, strong) CCColor* endColor;

/** The start color's opacity. */
@property (nonatomic, readwrite) CGFloat startOpacity;

/** The end color's opacity. */
@property (nonatomic, readwrite) CGFloat endOpacity;

/// -----------------------------------------------------------------------
/// @name Gradient Direction
/// -----------------------------------------------------------------------

/** The vector that determines the gradient's direction. Defaults to {0, -1}. */
@property (nonatomic, readwrite) CGPoint vector;

@end
