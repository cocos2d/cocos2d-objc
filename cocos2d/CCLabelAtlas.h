/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCAtlasNode.h"
#import "CCTextureAtlas.h"

/** 

 CCLabelAtlas is the original alternative to CCLabel offering improved performance.  
 
 ### Notes
 
 - CCLabelAtlas is MUCH faster than CCLabel
 - CCLabelAtlas "characters" have a fixed height and width
 - CCLabelAtlas "characters" can be anything you want since they are taken from an image file

 A more flexible class is CCLabelBMFont. It supports variable width characters and it also has a nice editor.
 
 */

@interface CCLabelAtlas : CCAtlasNode  <CCLabelProtocol>
{
	// The text to be rendered.
	NSString		*_string;

	// The first character index in the character map.
	NSUInteger		_mapStartChar;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCLabelAtlas Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a label object using the specified text, character map bitmap file, element width, element height and the starting character index values.
 *
 *  @param string       Label text.
 *  @param charmapfile  Character map bitmap file.
 *  @param w            element width in points.
 *  @param h            element height in points.
 *  @param firstElement Starting character index.
 *
 *  @return The CCLabelAtlas Object.
 */
+(id) labelWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(NSUInteger)firstElement;

/**
 *  Creates and returns a label object using the specified text and font configuration file values.
 *
 *  @param string   Label text.
 *  @param fontFile Label font configuration file.
 *
 *  @return The CCLabelAtlas Object.
 */
+(id) labelWithString:(NSString*) string fntFile:(NSString*)fontFile;


/// -----------------------------------------------------------------------
/// @name Initializing a CCLabelAtlas Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a label object using the specified text, character map bitmap file, element width, element height and the starting character index values.
 *
 *  @param string       Label text.
 *  @param charmapfile  Character map bitmap file (the Atlas).
 *  @param w            element width in points.
 *  @param h            element height in points.
 *  @param firstElement Starting character of the atlas.
 *
 *  @return An initialized CCLabelAtlas Object.
 */
-(id) initWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(NSUInteger)firstElement;

/**
 *  Initializes and returns a label object using the specified text, texure, element width, element height and the starting character index values.
 *
 *  @param theString Label text.
 *  @param texture   The texture to use.
 *  @param w         Element width in points.
 *  @param h         Element height in points.
 *  @param c         Index of character.
 *
 *  @return An initialized CCLabelAtlas Object.
 */
-(id) initWithString:(NSString*) theString texture:(CCTexture*)texture itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(NSUInteger)c;

/**
 *  Initializes and returns a label object using the specified text and font configuration file values.
 *
 *  @param string   Label text.
 *  @param fontFile Label font configuration file.
 *
 *  @return An initialized CCLabelAtlas Object.
 */
-(id) initWithString:(NSString*) string fntFile:(NSString*)fontFile;

@end
