/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "AtlasNode.h"
#import "TextureAtlas.h"

/** A Label that laods the font from a Texture Atlas */
@interface LabelAtlas : AtlasNode {
		
	/// string to render
	NSString		*string;
	
	/// the first char in the charmap
	char			mapStartChar;
}

/** creates the LabelAtlas with a string, a char map file(the atlas), the width and height of each element and the starting char of the atlas */
+(id) labelAtlasWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c;

/** initializes the LabelAtlas with a string, a char map file(the atlas), the width and height of each element and the starting char of the atlas */
-(id) initWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c;

/** changes the string to render. */
- (void) setString:(NSString*)string;

@end
