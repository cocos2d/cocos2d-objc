/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

#pragma mark -
#pragma mark CCLayerColor

/** CCLayerColor is a subclass of CCLayer that implements the CCRGBAProtocol protocol.

 All features from CCLayer are valid, plus the following new features:
 - opacity
 - RGB colors
 */
@interface CCLayerColor : CCNodeRGBA <CCBlendProtocol>
{
	ccVertex2F	_squareVertices[4];
	ccColor4F	_squareColors[4];

	ccBlendFunc	_blendFunc;
}

/** creates a CCLayer with color, width and height in Points*/
+ (id) layerWithColor: (ccColor4B)color width:(GLfloat)w height:(GLfloat)h;
/** creates a CCLayer with color. Width and height are the window size. */
+ (id) layerWithColor: (ccColor4B)color;

/** initializes a CCLayer with color, width and height in Points.
 This is the designated initializer.
 */
- (id) initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h;
/** initializes a CCLayer with color. Width and height are the window size. */
- (id) initWithColor:(ccColor4B)color;

/** BlendFunction. Conforms to CCBlendProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;
@end

#pragma mark -
#pragma mark CCLayerGradient

/** CCLayerGradient is a subclass of CCLayerColor that draws gradients across
the background.

 All features from CCLayerColor are valid, plus the following new features:
 - direction
 - final color
 - interpolation mode

 Color is interpolated between the startColor and endColor along the given
 vector (starting at the origin, ending at the terminus).  If no vector is
 supplied, it defaults to (0, -1) -- a fade from top to bottom.

 If 'compressedInterpolation' is disabled, you will not see either the start or end color for
 non-cardinal vectors; a smooth gradient implying both end points will be still
 be drawn, however.

 If ' compressedInterpolation' is enabled (default mode) you will see both the start and end colors of the gradient.

 @since v0.99.5
 */
@interface CCLayerGradient : CCLayerColor
{
	ccColor3B _endColor;
	GLubyte _startOpacity;
	GLubyte _endOpacity;
	CGPoint _vector;
	BOOL	_compressedInterpolation;
}

/** Creates a full-screen CCLayer with a gradient between start and end. */
+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end;
/** Creates a full-screen CCLayer with a gradient between start and end in the direction of v. */
+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v;

/** Initializes the CCLayer with a gradient between start and end. */
- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end;
/** Initializes the CCLayer with a gradient between start and end in the direction of v. */
- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v;

/** The starting color. */
@property (nonatomic, readwrite) ccColor3B startColor;
/** The ending color. */
@property (nonatomic, readwrite) ccColor3B endColor;
/** The starting opacity. */
@property (nonatomic, readwrite) GLubyte startOpacity;
/** The ending color. */
@property (nonatomic, readwrite) GLubyte endOpacity;
/** The vector along which to fade color. */
@property (nonatomic, readwrite) CGPoint vector;
/** Whether or not the interpolation will be compressed in order to display all the colors of the gradient both in canonical and non canonical vectors
 Default: YES
 */
@property (nonatomic, readwrite) BOOL compressedInterpolation;

@end

#pragma mark -
#pragma mark CCLayerMultiplex

/** CCLayerMultiplex is a CCLayer with the ability to multiplex its children.
 Features:
   - It supports one or more children
   - Only one children will be active a time
 */
@interface CCNodeMultiplex : CCNode
{
	unsigned int _enabledLayer;
	NSMutableArray *_layers;
}

/** creates a CCMultiplexLayer with an array of layers.
 @since v2.1
 */
+(id) nodeWithArray:(NSArray*)arrayOfLayers;
/** creates a CCMultiplexLayer with one or more layers using a variable argument list. */
+(id) nodeWithNodes: (CCNode*) layer, ... NS_REQUIRES_NIL_TERMINATION;
/** initializes a CCMultiplexLayer with an array of layers
 @since v2.1
 */
-(id) initWithArray:(NSArray*)arrayOfLayers;
/** switches to a certain layer indexed by n.
 The current (old) layer will be removed from its parent with 'cleanup:YES'.
 */
-(void) switchTo: (unsigned int) n;

@end

