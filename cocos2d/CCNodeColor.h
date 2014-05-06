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

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>									// Needed for UIAccelerometerDelegate
#elif defined(__CC_PLATFORM_MAC)

#endif

#import "CCProtocols.h"
#import "CCNode.h"

#pragma mark - CCNodeColor

/**
 * CCNodeColor is a subclass of CCNode that is used to generate solid colors.
 */
@interface CCNodeColor : CCNode <CCShaderProtocol, CCBlendProtocol>

/// -----------------------------------------------------------------------
/// @name Creating a CCNodeColor Object
/// -----------------------------------------------------------------------

/**
 *  Creates a node with color, width and height in Points.
 *
 *  @param color Color of the node.
 *  @param w     Width of the node.
 *  @param h     Height of the node.
 *
 *  @return The CCNodeColor Object.
 */
+(id) nodeWithColor: (CCColor*)color width:(GLfloat)w height:(GLfloat)h;

/**
 *  Creates a node with color. Width and height are the window size.
 *
 *  @param color Color of the node.
 *
 *  @return The CCNodeColor Object.
 */
+(id) nodeWithColor: (CCColor*)color;

/// -----------------------------------------------------------------------
/// @name Initializing a CCNodeColor Object
/// -----------------------------------------------------------------------


/**
 *  Initializes a node with color, width and height in Points.
 *
 *  @param color Color of the node.
 *  @param w     Width of the node.
 *  @param h     Height of the node.
 *
 *  @return An initialized CCNodeColor Object.
 */
-(id) initWithColor:(CCColor*)color width:(GLfloat)w height:(GLfloat)h;

/**
 *  Initializes a node with color. Width and height are the window size.
 *
 *  @param color Color of the node.
 *
 *  @return An initialized CCNodeColor Object.
 */
-(id) initWithColor:(CCColor*)color;

@end

#pragma mark - CCNodeGradient

/** 
 *  CCNodeGradient is a subclass of CCNodeColor that draws gradients across the background.
 *
 *  All features from CCNodeColor are valid, plus the following new features:
 *  - direction
 *  - final color
 *  - interpolation mode
 *
 *  Color is interpolated between the startColor and endColor along the given vector (starting at the origin, ending at the terminus).  
 *
 *  If no vector is supplied, it defaults to (0, -1) -- a fade from top to bottom.
 *
 *  If 'compressedInterpolation' is disabled, you will not see either the start or end color for non-cardinal vectors; a smooth gradient implying both end points will be still be drawn, however.
 *
 *  If ' compressedInterpolation' is enabled (default mode) you will see both the start and end colors of the gradient.
 */
@interface CCNodeGradient : CCNodeColor {
	ccColor4F _endColor;
	CGPoint _vector;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCNodeGradient Object
/// -----------------------------------------------------------------------

/**
 *  Creates a full-screen CCNode with a gradient between start and end color values.
 *
 *  @param start Start color.
 *  @param end   End color.
 *
 *  @return The CCNodeGradient Object.
 */
+(id)nodeWithColor:(CCColor*)start fadingTo:(CCColor*)end;

/**
 *  Creates a full-screen CCNode with a gradient between start and end color values with gradient direction vector.
 *
 *  @param start Start color.
 *  @param end   End color.
 *  @param v Direction vector for gradient.
 *
 *  @return The CCNodeGradient Object.
 */
+(id)nodeWithColor:(CCColor*)start fadingTo:(CCColor*)end alongVector:(CGPoint)v;


/// -----------------------------------------------------------------------
/// @name Initializing a CCNodeGradient Object
/// -----------------------------------------------------------------------

/**
 *  Initializes a full-screen CCNode with a gradient between start and end color values.
 *
 *  @param start Start color.
 *  @param end   End color.
 *
 *  @return An initialized CCNodeGradient Object.
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
 */
- (id)initWithColor:(CCColor*)start fadingTo:(CCColor*)end alongVector:(CGPoint)v;


/// -----------------------------------------------------------------------
/// @name Accessing CCNodeGradient Attributes
/// -----------------------------------------------------------------------

/** The starting color. */
@property (nonatomic, strong) CCColor* startColor;

/** The ending color. */
@property (nonatomic, strong) CCColor* endColor;

/** The starting opacity. */
@property (nonatomic, readwrite) CGFloat startOpacity;

/** The ending color. */
@property (nonatomic, readwrite) CGFloat endOpacity;

/** The vector along which to fade color. */
@property (nonatomic, readwrite) CGPoint vector;

/**
 *	Deprecated in 3.1. All colors are correctly displayed across the node's rectangle.
 *  Default: YES.
 */
@property (nonatomic, readwrite) BOOL compressedInterpolation __attribute__((deprecated));

@end

#pragma mark - CCNodeMultiplexer

/** CCNodeMultiplexer is a CCNode with the ability to multiplex its children.
 *
 *  Features:
 *
 *  - It supports one or more children
 *  - Only one children will be active a time
 */
@interface CCNodeMultiplexer : CCNode {
	unsigned int _enabledNode;
	NSMutableArray *_nodes;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCNodeMultiplexer Object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCNodeMultiplexer with an array of layers.
 *
 *  @param arrayOfNodes Array of nodes.
 *
 *  @return The CCNodeMultiplexer Object.
 */
+(id)nodeWithArray:(NSArray*)arrayOfNodes;

/** Creates a CCMultiplexLayer with one or more layers using a variable argument list.
 *  Example: 
 *  @code mux = [CCNodeMultiplexer nodeWithNodes:nodeA, nodeB, nodeC, nil];
 *  
 *  @param node List of nodes.
 *  @param ... Nil terminator.
 *  @return The CCNodeMultiplexer Object.
 */
+(id)nodeWithNodes:(CCNode*)node, ... NS_REQUIRES_NIL_TERMINATION;


/// -----------------------------------------------------------------------
/// @name Initializing a CCNodeMultiplexer Object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCNodeMultiplexer with an array of layers.
 *
 *  @param arrayOfNodes Array of nodes.
 *
 *  @return An initialized CCNodeMultiplexer Object.
 */

-(id)initWithArray:(NSArray*)arrayOfNodes;


/// -----------------------------------------------------------------------
/// @name CCNodeMultiplexer Management
/// -----------------------------------------------------------------------

/**
 *  Switches to a certain node indexed by n.
 *
 *  The current (old) node will be removed from its parent with 'cleanup:YES'.
 *
 *  @param n Index of node to switch to.
 */
-(void)switchTo:(unsigned int) n;

@end

