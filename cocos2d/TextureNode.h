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

#import "Support/Texture2D.h"

#import "CocosNode.h"


/** A CocosNode that knows how to render a texture
 * Features:
 *  - opacity
 *  - contentSize
 *  - RGB (setRGB:::)
 */
@interface TextureNode : CocosNode <CocosNodeOpacity, CocosNodeRGB, CocosNodeSize> {

	/// texture
	Texture2D *texture;
	
	/// texture opacity
	GLubyte opacity;
	
	/// texture color
	GLubyte	r,g,b;
}

@property (readwrite,assign) Texture2D *texture;
@property (readwrite,assign) GLubyte r, g, b, opacity;


/** returns the size in pixels of the texture without transformations.
 * Conforms to the CocosNodeSize protocol
 */
-(CGSize) contentSize;
@end
