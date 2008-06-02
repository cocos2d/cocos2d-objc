//
//  sprite.h
//  test-opengl
//
//  Created by Ricardo Quesada on 28/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CocosNode.h"

@interface Sprite : CocosNode {

	/* OpenGL name for the sprite texture */
	GLuint spriteTexture;
	
	/* sprite image size */
	size_t	width, height;

	/* sprite vertices */
	GLfloat spriteVertices[4 * 2];	
}

- (id) initFromFile:(NSString *)path;
- (void) draw;
- (void) initVertices;
- (void) initAnchors;


@end