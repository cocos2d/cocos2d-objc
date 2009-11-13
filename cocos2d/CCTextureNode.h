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


#import "CCProtocols.h"
#import "CCTexture2D.h"

#import "CCNode.h"


/** TextureNode is a subclass of CCNode that implements the CCRGBAProtocol
 * and CCTextureProtocol protocol.
 *
 * As the name implies it, it knows how to render a textures.
 *
 * All features from CCNode are valid, plus the following new features:
 *  - opacity and RGB
 *  - texture (can be Aliased or AntiAliased)
 */
@interface CCTextureNode : CCNode <CCRGBAProtocol, CCTextureProtocol> {

	// texture
	CCTexture2D *texture_;

	// blend func
	ccBlendFunc	blendFunc_;
	
	// texture RGBA
	GLubyte	opacity_;
	ccColor3B color_;
	BOOL opacityModifyRGB_;
	
}

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite,retain) CCTexture2D *texture;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readwrite) ccColor3B color;
@end
