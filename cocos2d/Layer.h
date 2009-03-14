/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import <UIKit/UIKit.h>

#import "CocosNode.h"

//
// TouchEventDelegate
//
/**Touch event delegate
 * return YES if the event was handled
 * return NO if the event was not handled
 */
@protocol TouchEventsDelegate <NSObject>
@optional
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end


//
// Layer
//
/** a Layer */
@interface Layer : CocosNode <UIAccelerometerDelegate, TouchEventsDelegate>
{
	//! whether or not it will receive Touch events
	BOOL isTouchEnabled;
	
	//! whether or not it will receive Accelerometer events
	BOOL isAccelerometerEnabled;
}

@property(nonatomic,assign) BOOL isTouchEnabled;
@property(nonatomic,assign) BOOL isAccelerometerEnabled;

@end

//
// ColorLayer
//
/** a Layer with color and opacity */
@interface ColorLayer : Layer <CocosNodeOpacity, CocosNodeRGB>
{
	GLubyte r,g,b,opacity;
	GLfloat squareVertices[4 * 2];
	GLubyte squareColors[4 * 4];
}

/** creates the Layer with color, width and height */
+ (id) layerWithColor: (GLuint) aColor width:(GLfloat)w height:(GLfloat)h;
/** creates the layer with color. Width and height are the window size. */
+ (id) layerWithColor: (GLuint) aColor;

/** initializes a Layer with color, width and height */
- (id) initWithColor: (GLuint) aColor width:(GLint)w height:(GLint)h;
/** initializes a Layer with color. Width and height are the window size. */
- (id) initWithColor: (GLuint) aColor;

/** initializes the witdh and height of the layer */
- (void) initWidth: (GLfloat)w height:(GLfloat)h;

/** changes the color of the layer
 @deprecated Use CocosNodeRGB protocol instead
 */
- (void) changeColor: (GLuint) aColor __attribute__ ((deprecated));

/** change width */
-(void) changeWidth: (GLfloat)w;
/** change height */
-(void) changeHeight: (GLfloat)h;

/* deprecated */
@property (readonly) GLuint color __attribute__ ((deprecated));

/** conforms to CocosNodeRGB and CocosNodeOpacity protocol */
@property (readonly) GLubyte r,g,b,opacity;

@end

//
// MultiplexLayer
//
@interface MultiplexLayer : Layer
{
	unsigned int enabledLayer;
	NSMutableArray *layers;
}

/** creates a MultiplexLayer with one or more layers */
+(id) layerWithLayers: (Layer*) layer, ... NS_REQUIRES_NIL_TERMINATION;
/** initializes a MultiplexLayer with one or more layers */
-(id) initWithLayers: (Layer*) layer vaList:(va_list) params;
/** switches to a certain layer indexed by n*/
-(void) switchTo: (unsigned int) n;
/** release the current layer and switches to another layer indexed by n */
-(void) switchToAndReleaseMe: (unsigned int) n;
@end
