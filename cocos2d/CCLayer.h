/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

#import "CCProtocols.h"
#import "CCNode.h"
#import "CCTouchDelegateProtocol.h"

//
// CCLayer
//
/** CCLayer is a subclass of CCNode that implements the TouchEventsDelegate protocol.
 
 All features from CCNode are valid, plus the following new features:
 - It can receive iPhone Touches
 - It can receive Accelerometer input
*/
@interface CCLayer : CCNode <UIAccelerometerDelegate, CCStandardTouchDelegate, CCTargetedTouchDelegate>
{
	BOOL isTouchEnabled;
	BOOL isAccelerometerEnabled;
}

/** If isTouchEnabled, this method is called onEnter. Override it to change the
 way CCLayer receives touch events.
 ( Default: [[TouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0] )
 Example:
     -(void) registerWithTouchDispatcher
     {
        [[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
     }
 @since v0.8.0
 */
-(void) registerWithTouchDispatcher;

/** whether or not it will receive Touch events.
 You can enable / disable touch events with this property.
 Only the touches of this node will be affected. This "method" is not propagated to it's children.
 @since v0.8.1
 */
@property(nonatomic,assign) BOOL isTouchEnabled;
/** whether or not it will receive Accelerometer events
 You can enable / disable accelerometer events with this property.
 @since v0.8.1
 */
@property(nonatomic,assign) BOOL isAccelerometerEnabled;

@end

//
// CCColorLayer
//
/** CCColorLayer is a subclass of CCLayer that implements the CCRGBAProtocol protocol.
 
 All features from CCLayer are valid, plus the following new features:
 - opacity
 - RGB colors
 */
@interface CCColorLayer : CCLayer <CCRGBAProtocol, CCBlendProtocol>
{
	GLubyte		opacity_;
	ccColor3B	color_;	
	GLfloat squareVertices[4 * 2];
	GLubyte squareColors[4 * 4];
	
	ccBlendFunc	blendFunc_;
}

/** creates a CCLayer with color, width and height */
+ (id) layerWithColor: (ccColor4B)color width:(GLfloat)w height:(GLfloat)h;
/** creates a CCLayer with color. Width and height are the window size. */
+ (id) layerWithColor: (ccColor4B)color;

/** initializes a CCLayer with color, width and height */
- (id) initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h;
/** initializes a CCLayer with color. Width and height are the window size. */
- (id) initWithColor:(ccColor4B)color;

/** change width */
-(void) changeWidth: (GLfloat)w;
/** change height */
-(void) changeHeight: (GLfloat)h;
/** change width and height
 @since v0.8
 */
-(void) changeWidth:(GLfloat)w height:(GLfloat)h;

/** Opacity: conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** Opacity: conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) ccColor3B color;
/** BlendFunction. Conforms to CCBlendProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;
@end

/** CCMultipleLayer is a CCLayer with the ability to multiplex it's children.
 Features:
   - It supports one or more children
   - Only one children will be active a time
 */
@interface CCMultiplexLayer : CCLayer
{
	unsigned int enabledLayer;
	NSMutableArray *layers;
}

/** creates a CCMultiplexLayer with one or more layers using a variable argument list. */
+(id) layerWithLayers: (CCLayer*) layer, ... NS_REQUIRES_NIL_TERMINATION;
/** initializes a MultiplexLayer with one or more layers using a variable argument list. */
-(id) initWithLayers: (CCLayer*) layer vaList:(va_list) params;
/** switches to a certain layer indexed by n. 
 The current (old) layer will be removed from it's parent with 'cleanup:YES'.
 */
-(void) switchTo: (unsigned int) n;
/** release the current layer and switches to another layer indexed by n.
 The current (old) layer will be removed from it's parent with 'cleanup:YES'.
 */
-(void) switchToAndReleaseMe: (unsigned int) n;
@end
