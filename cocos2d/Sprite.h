//
//  sprite.h
//  test-opengl
//
//  Created by Ricardo Quesada on 28/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Texture2D.h"

#import "CocosNode.h"

//! a 2D sprite
@interface Sprite : CocosNode {

	/* OpenGL name for the sprite texture */
	Texture2D *texture;
}

//! creates an sprite from a filepath
+ (id) spriteFromFile:(NSString *)path;
//! initializes the sprite from a filepath
- (id) initFromFile:(NSString *)path;

- (void) draw;
- (void) initAnchors;


@end