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

//! A label
@interface Label : CocosNode {

	/* OpenGL name for the sprite texture */
	Texture2D *texture;
}

// initializes the label with a font name and font size
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
//! initializes the label with font class
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*)font;

- (void) draw;
- (void) initAnchors;


@end