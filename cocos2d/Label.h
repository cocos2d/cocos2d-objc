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

#import "TextureNode.h"

/** Label is a subclass of TextureNode that knows how to render text labels
 *
 * All features from TextureNode are valid in Label
 *
 * Label are slow. Consider using LabelAtlas or BitmapFontAtlas instead.
 */
@interface Label : TextureNode <CocosNodeLabel>
{
	CGSize _dimensions;
	UITextAlignment _alignment;
	NSString * _fontName;
	CGFloat _fontSize;
}

/** creates a label from a fontname, alignment, dimension and font size */
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** creates a label from a fontname and font size */
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the label with a font name, alignment, dimension and font size */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the label with a font name and font size */
- (id) initWithString:(NSString*)string  fontName:(NSString*)name fontSize:(CGFloat)size;

/** changes the string to render
 * @warning Changing the string is as expensive as creating a new Label. To obtain better performance use LabelAtlas
 */
- (void) setString:(NSString*)string;

@end
