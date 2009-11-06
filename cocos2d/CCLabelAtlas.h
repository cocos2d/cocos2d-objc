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

#import "CCAtlasNode.h"
#import "CCTextureAtlas.h"

/** CCLabelAtlas is a subclass of CCAtlasNode.
 
 It can be as a replacement of CCLabel since it is MUCH faster.
 
 CCLabelAtlas versus CCLabel:
 - CCLabelAtlas is MUCH faster than CCLabel
 - CCLabelAtlas "characters" have a fixed height and width
 - CCLabelAtlas "characters" can be anything you want since they are taken from an image file
 
 A more flexible class is CCBitmapFontAtlas. It supports variable width characters and it also has a nice editor.
 */
@interface CCLabelAtlas : CCAtlasNode  <CCLabelProtocol> {
		
	// string to render
	NSString		*string_;
	
	// the first char in the charmap
	char			mapStartChar;
}

/** creates the CCLabelAtlas with a string, a char map file(the atlas), the width and height of each element and the starting char of the atlas */
+(id) labelAtlasWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c;

/** initializes the CCLabelAtlas with a string, a char map file(the atlas), the width and height of each element and the starting char of the atlas */
-(id) initWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c;
@end
