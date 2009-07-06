/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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


/** TextureNode is a subclass of CocosNode that implements the CocosNodeRGBA
 * and CocosNodeTexture protocol.
 *
 * As the name implies it, it knows how to render a textures.
 *
 * All features from CocosNode are valid, plus the following new features:
 *  - opacity and RGB
 *  - texture (can be Aliased or AntiAliased)
 */
@interface TextureNode : CocosNode <CocosNodeRGBA, CocosNodeTexture> {

	// texture
	Texture2D *texture_;

	// blend func
	ccBlendFunc	blendFunc_;
	
	// texture RGBA
	GLubyte	opacity_;
	ccColor3B color_;
	BOOL opacityModifyRGB_;
	
}

/** conforms to CocosNodeTexture protocol */
@property (readwrite,retain) Texture2D *texture;

/** conforms to CocosNodeTexture protocol */
@property (readwrite) ccBlendFunc blendFunc;

/** conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte opacity;
/** conforms to CocosNodeRGBA protocol */
@property (readwrite) ccColor3B color;
@end
