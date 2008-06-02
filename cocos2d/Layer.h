//
//  Layer.h
//  test-opengl2
//
//  Created by Ricardo Quesada on 30/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CocosNode.h"

@interface Layer : CocosNode {

}
@end

@interface ColorLayer : Layer
{
	GLfloat squareVertices[4 * 2];
	GLubyte squareColors[4 * 4];
}

- (id) initWithColor: (GLuint) aColor width:(GLint)w height:(GLint)h;
- (id) initWithColor: (GLuint) aColor;
- (void) changeColor: (GLuint) aColor;
- (void) initWidth: (GLint)w height:(GLint)h;

@end
