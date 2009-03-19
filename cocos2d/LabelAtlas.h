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

#import "AtlasNode.h"
#import "TextureAtlas.h"

/** LabelAtlas is a subclass of AtlasNode.
 
 It can be as a replacement of Label since it is MUCH faster that it.
 
 LabelAtlas versus Label:
 - LabelAtlas is MUCH faster than Label
 - LabelAtlas can't be created with an NSString
 - LabelAtlas "characters" have a fixed height and width
 - LabelAtlas "characters" can anything you want since they are taken from an image file
 */
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
