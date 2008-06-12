//
//  Layer.h
//  cocos2d
//

#import <UIKit/UIKit.h>

#import "CocosNode.h"

//
// Layer
//
/** a Layer */
@interface Layer : CocosNode
{
	//! wheter or not it will receive Touch events
	BOOL isEventHandler;
}
@end

//
// ColorLayer
//
//! a Layer with color and opacity
@interface ColorLayer : Layer <CocosNodeOpacity>
{
	GLuint color;
	GLfloat squareVertices[4 * 2];
	GLubyte squareColors[4 * 4];
}

/** creates the Layer with color, width and height */
+ (id) layerWithColor: (GLuint) aColor width:(GLint)w height:(GLint)h;
/** creates the layer with color. Width and height are the window size. */
+ (id) layerWithColor: (GLuint) aColor;

/** initializes a Layer with color, width and height */
- (id) initWithColor: (GLuint) aColor width:(GLint)w height:(GLint)h;
/** initializes a Layer with color. Width and height are the window size. */
- (id) initWithColor: (GLuint) aColor;

/** initializes the witdh and height of the layer */
- (void) initWidth: (GLint)w height:(GLint)h;

/** changes the color of the layer */
- (void) changeColor: (GLuint) aColor;

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
-(id) initWithLayers: (Layer*) layer, ... NS_REQUIRES_NIL_TERMINATION;
/** switches to a certain layer */
-(void) switchTo: (unsigned int) n;
@end
