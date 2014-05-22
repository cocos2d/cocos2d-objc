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
@interface CCNodeColor : CCNode <CCBlendProtocol> {
	ccVertex2F	_squareVertices[4];
	ccColor4F	_squareColors[4];
	ccBlendFunc	_blendFunc;
}


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

/** Blend method to use. */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

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
	BOOL	_compressedInterpolation;
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

/** Whether or not the interpolation will be compressed in order to display all the colors of the gradient both in canonical and non canonical vectors.
 *
 *  Default: YES.
 */
@property (nonatomic, readwrite) BOOL compressedInterpolation;

@end

#pragma mark - CCNodeGradientRadial

/** CCNodeGradientRadial is a CCNode that can be used to display radial gradient
 *
 * It isn't a subclass of CCNodeColor because 
 *
 * 1. CCNodeColor only has 4 vertex available whereas for a gradient effect we 
 *    need more vertices.
 * 2. CCNodeColor uses GL_TRIANGLE_STRIP for rendering but for gradient we use 
 *    GL_TRIANGLE_FAN
 *
 * Still the CCNodeGradientRadial's interface is kept as close to CCNodeGradient
 * so that the gradient effect could be switched with minimum efforts.
 *
 */

/** kCCNodeGradientRadialResolution tells the how detailed the mesh is.
 *
 * Total vertices for a circular fan are calculated as:
 *
 *  int vertexCount = 2 + resolution * 4;
 *
 * where:
 * - resolution > 0
 * - vertex[0] is the center vertex
 * - vertex[1] == vertex[vertexCount-1]; to close the loop
 *
 * In my test cases for resolution > 3 didn't improve much quality
 * so we shall use resolution = 3
 * Remember these are just the number of vertices, for improving the gradient
 * we always have the gradientFactor property.
 */
#define kCCNodeGradientRadialResolution 3
#define kCCNodeGradientRadialVertexCount(r) (2 + r * 4)

@interface CCNodeGradientRadial : CCNode<CCBlendProtocol> {
	ccVertex2F	_fanVertices[kCCNodeGradientRadialVertexCount(kCCNodeGradientRadialResolution)];
	ccColor4F	_fanColors[kCCNodeGradientRadialVertexCount(kCCNodeGradientRadialResolution)];
	ccBlendFunc	_blendFunc;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCNodeGradientRadial Object
/// -----------------------------------------------------------------------

/**
 *  Creates a node with color, width and height in Points.
 *
 *  @param color Color of the node.
 *  @param w     Width of the node.
 *  @param h     Height of the node.
 *
 *  @return The CCNodeGradientRadial Object.
 */
+(id) nodeWithColor: (CCColor*)color width:(GLfloat)w height:(GLfloat)h;

/**
 *  Creates a node with color. Width and height are the window size.
 *
 *  @param color Color of the node.
 *
 *  @return The CCNodeGradientRadial Object.
 */
+(id) nodeWithColor: (CCColor*)color;

/**
 *  Creates a full-screen CCNode with a gradient between start and end color values.
 *
 *  @param start Start color.
 *  @param end   End color.
 *
 *  @return The CCNodeGradientRadial Object.
 */
+(id)nodeWithColor:(CCColor*)start fadingTo:(CCColor*)end;

/// -----------------------------------------------------------------------
/// @name Initializing a CCNodeGradientRadial Object
/// -----------------------------------------------------------------------


/**
 *  Initializes a node with color, width and height in Points.
 *
 *  @param color Color of the node.
 *  @param w     Width of the node.
 *  @param h     Height of the node.
 *
 *  @return An initialized CCNodeGradientRadial Object.
 */
-(id) initWithColor:(CCColor*)color width:(GLfloat)w height:(GLfloat)h;

/**
 *  Initializes a node with color. Width and height are the window size.
 *
 *  @param color Color of the node.
 *
 *  @return An initialized CCNodeGradientRadial Object.
 */
-(id) initWithColor:(CCColor*)color;

/**
 *  Initializes a full-screen CCNode with a gradient between start and end color values.
 *
 *  @param start Start color.
 *  @param end   End color.
 *
 *  @return An initialized CCNodeGradientRadial Object.
 */
- (id)initWithColor:(CCColor*)start fadingTo:(CCColor*)end;


/// -----------------------------------------------------------------------
/// @name Accessing CCNodeGradientRadial Attributes
/// -----------------------------------------------------------------------

/** The starting color. */
@property (nonatomic, strong) CCColor* startColor;

/** The ending color. */
@property (nonatomic, strong) CCColor* endColor;

/** The starting opacity. */
@property (nonatomic, readwrite) CGFloat startOpacity;

/** The ending color. */
@property (nonatomic, readwrite) CGFloat endOpacity;

/** The gradientFactor controls the interpolation from startColor to endColor. 
 * If resolution = 6 (or vertexCount = 26) then along each edge we get 6 vertices
 * For gradientFactor = 1 the color fades along each edge as
 * [0.00, 0.33, 0.67, 1.00, 0.67, 0.33]
 *
 * for gradientFactor = 2; the color fade along each edge as:
 * [0.00, 0.17, 0.33, 0.50, 0.33, 0.17]
 *
 * The default value is 3.0
 *
 * @warning gradientFactor should be > 0
 */
@property (nonatomic, readwrite) CGFloat gradientFactor;

/** Blend method to use. */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

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

