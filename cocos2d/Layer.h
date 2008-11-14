/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import <UIKit/UIKit.h>

#import "CocosNode.h"

//
// Layer
//
/** a Layer */
@interface Layer : CocosNode <UIAccelerometerDelegate>
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
@interface ColorLayer : Layer <CocosNodeOpacity>
{
	GLuint color;
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

/** changes the color of the layer */
- (void) changeColor: (GLuint) aColor;

/** change width */
-(void) changeWidth: (GLfloat)w;
/** change height */
-(void) changeHeight: (GLfloat)h;

// CocosNodeOpacity protocol
/** returns the opacity */
-(GLubyte) opacity;
/** sets the opacity of the layer */
-(void) setOpacity: (GLubyte) opacity;

@property (readwrite, assign) GLuint color;

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
/** switches to a certain layer */
-(void) switchTo: (unsigned int) n;
@end
