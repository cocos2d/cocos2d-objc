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
#import "Platforms/iOS/CCTouchDelegateProtocol.h"		// Touches only supported on iOS
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCEventDispatcher.h"
#endif

#import "CCProtocols.h"
#import "CCNode.h"

#pragma mark - CCLayer

typedef enum {
	kCCTouchesAllAtOnce,
	kCCTouchesOneByOne,
} ccTouchesMode;

/** CCLayer is a subclass of CCNode that implements the CCTouchEventsDelegate protocol.

 All features from CCNode are valid, plus the following new features:
 - It can receive Touches both on iOS and Mac
 - It can receive Accelerometer input on iOS
 - It can receive Keyboard events on Mac
 - It can receive Mouse events on Mac
*/
#ifdef __CC_PLATFORM_IOS
@interface CCLayer : CCNode <CCAccelerometerDelegate, CCTouchAllAtOnceDelegate, CCTouchOneByOneDelegate>
{
	BOOL _touchEnabled;
	NSInteger _touchPriority;
	BOOL _touchMode;
	
	BOOL _accelerometerEnabled;
}

/** whether or not it will receive Accelerometer events
 You can enable / disable accelerometer events with this property.

 Valid only on iOS. Not valid on Mac.

 @since v0.8.1
 */
@property(nonatomic, assign, getter = isAccelerometerEnabled) BOOL accelerometerEnabled;

/** whether or not it will receive Touch events
 @since v0.8.1
 */
@property(nonatomic, assign, getter = isTouchEnabled) BOOL touchEnabled;
/** priority of the touch events. Default is 0 */
@property(nonatomic, assign) NSInteger touchPriority;
/** Touch modes.
	- kCCTouchesAllAtOnce: Receives all the available touches at once.
	- kCCTouchesOneByOne: Receives one touch at the time.
 */
@property(nonatomic, assign) ccTouchesMode touchMode;

/** sets the accelerometer's update frequency. A value of 1/2 means that the callback is going to be called twice per second.
 @since v2.1
 */
-(void) setAccelerometerInterval:(float)interval;


#elif defined(__CC_PLATFORM_MAC)


@interface CCLayer : CCNode <CCKeyboardEventDelegate, CCMouseEventDelegate, CCTouchEventDelegate, CCGestureEventDelegate>
{
	BOOL		_mouseEnabled;
	NSInteger	_mousePriority;

	BOOL		_keyboardEnabled;
	NSInteger	_keyboardPriority;

	BOOL		_touchEnabled;
	NSInteger	_touchPriority;
	NSInteger	_touchMode;
    
	BOOL		_gestureEnabled;
	NSInteger	_gesturePriority;
}

/** whether or not it will receive touche events. */
@property (nonatomic, readwrite, getter=isTouchEnabled) BOOL touchEnabled;
/** priority of the touch events. Default is 0 */
@property(nonatomic, assign) NSInteger touchPriority;

/** whether or not it will receive gesture events. */
@property (nonatomic, readwrite, getter=isGestureEnabled) BOOL gestureEnabled;
/** priority of the gesture events. Default is 0 */
@property(nonatomic, assign) NSInteger gesturePriority;


/** whether or not it will receive mouse events.

 Valid only on OS X. Not valid on iOS
 */
@property (nonatomic, readwrite, getter=isMouseEnabled) BOOL mouseEnabled;
/** priority of the mouse events. Default is 0 */
@property (nonatomic, assign) NSInteger mousePriority;

/** whether or not it will receive keyboard events.

 Valid only on OS X. Not valid on iOS
 */
@property (nonatomic, readwrite, getter = isKeyboardEnabled) BOOL keyboardEnabled;
/** Priority of keyboard events. Default is 0 */
@property (nonatomic, assign) NSInteger keyboardPriority;

#endif // mac

@end


#pragma mark -
#pragma mark CCLayerRGBA

/** CCLayerRGBA is a subclass of CCLayer that implements the CCRGBAProtocol protocol using a solid color as the background.

 All features from CCLayer are valid, plus the following new features that propagate into children that conform to the CCRGBAProtocol:
 - opacity
 - RGB colors
 @since 2.1
 */
@interface CCLayerRGBA : CCLayer <CCRGBAProtocol>
{
	GLubyte		_displayedOpacity, _realOpacity;
	ccColor3B	_displayedColor, _realColor;
	BOOL		_cascadeOpacityEnabled, _cascadeColorEnabled;
}

// XXX: To make BridgeSupport happy
-(GLubyte) opacity;
@end



#pragma mark -
#pragma mark CCLayerColor

/** CCLayerColor is a subclass of CCLayer that implements the CCRGBAProtocol protocol.

 All features from CCLayer are valid, plus the following new features:
 - opacity
 - RGB colors
 */
@interface CCLayerColor : CCLayerRGBA <CCBlendProtocol>
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

/** change width in Points */
-(void) changeWidth: (GLfloat)w;
/** change height in Points */
-(void) changeHeight: (GLfloat)h;
/** change width and height in Points
 @since v0.8
 */
-(void) changeWidth:(GLfloat)w height:(GLfloat)h;

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
@interface CCLayerMultiplex : CCLayer
{
	unsigned int _enabledLayer;
	NSMutableArray *_layers;
}

/** creates a CCMultiplexLayer with an array of layers.
 @since v2.1
 */
+(id) layerWithArray:(NSArray*)arrayOfLayers;
/** creates a CCMultiplexLayer with one or more layers using a variable argument list. */
+(id) layerWithLayers: (CCLayer*) layer, ... NS_REQUIRES_NIL_TERMINATION;
/** initializes a CCMultiplexLayer with an array of layers
 @since v2.1
 */
-(id) initWithArray:(NSArray*)arrayOfLayers;
/** initializes a MultiplexLayer with one or more layers using a variable argument list. */
-(id) initWithLayers: (CCLayer*) layer vaList:(va_list) params;
/** switches to a certain layer indexed by n.
 The current (old) layer will be removed from its parent with 'cleanup:YES'.
 */
-(void) switchTo: (unsigned int) n;
/** release the current layer and switches to another layer indexed by n.
 The current (old) layer will be removed from its parent with 'cleanup:YES'.
 */
-(void) switchToAndReleaseMe: (unsigned int) n;
@end

