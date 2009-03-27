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


/** TextureNode is a subclass of CocosNode that implements the CocosNodeOpacity,
 * CocosNodeRGB and CocosNodeSize protocol.
 *
 * As the name implies it, it knows how to render a textures.
 *
 * All features from CocosNode are valid, plus the following new features:
 *  - opacity
 *  - contentSize
 *  - RGB (setRGB:::)
 *  - texture (can be Aliased or AntiAliased)
 */
@interface TextureNode : CocosNode <CocosNodeOpacity, CocosNodeRGB, CocosNodeSize> {

	/// texture
	Texture2D *texture;
	
	/// texture opacity
	GLubyte opacity;
	
	/// texture color
	GLubyte	r,g,b;
}

/** The texture that is rendered */
@property (readwrite,retain) Texture2D *texture;

/** conforms to CocosNodeOpacity and CocosNodeRGB protocol */
@property (readwrite,assign) GLubyte r, g, b, opacity;
@end
