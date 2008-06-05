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


@interface Sprite : CocosNode {

	/* OpenGL name for the sprite texture */
	Texture2D *texture;
}

+ (id) spriteFromFile:(NSString *)path;
- (id) initFromFile:(NSString *)path;

- (void) draw;
- (void) initAnchors;


@end