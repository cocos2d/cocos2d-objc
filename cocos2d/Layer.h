//
//  Layer.h
//	cocos2d
//

#import <UIKit/UIKit.h>

#import "CocosNode.h"

/** a Layer */
@interface Layer : CocosNode {

}
@end

//! a Layer with color and opacity
@interface ColorLayer : Layer
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

/** changes the color of the layer */
- (void) changeColor: (GLuint) aColor;
- (void) initWidth: (GLint)w height:(GLint)h;

@property (readwrite, assign) GLuint color;

@end
